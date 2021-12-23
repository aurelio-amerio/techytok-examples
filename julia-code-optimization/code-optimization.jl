using BenchmarkTools
using Profile
#%%

function test1(x::Int)
    println("$x is an Int")
end

function test1(x::Float64)
    println("$x is a Float64")
end

function test1(x)
    println("$x is neither an Int nor a Float64")
end
#%%
test1(1)

test1(1.0)

test1("techytok")

#%%
"""
Returns x if x>0 else returns 0
"""
function test3(x)
    if x > 0
        return x
    else
        return 0
    end
end
#%%
test3(2)
test3(-1)

test3(2.0)
test3(-1.0)
#%%
"""
Returns x if x>0 else returns 0
"""
function test4(x)
    if x > 0
        return x
    else
        return zero(x)
    end
end
#%%
test4(-1.0)

#%%
@code_warntype test4(1.0)

#%%
function test5()
    r = 0
    for i in 1:10
        r += sin(i)
    end
    return r
end

function test6()
    r = 0.0
    for i in 1:10
        r += sin(i)
    end
    return r
end
#%%
@code_warntype test5()
@code_warntype test6()

@btime test5()
@btime test6()

#%%
function test7(x)
    result = 0
    if x > 0
        result = x
    else
        result = 0
    end
    return result::typeof(x)
end
#%%
test7(-2.0)

#%%
function take_a_breath()
    sleep(0.2)
    return
end

function test8()
    r = zeros(100, 100)
    take_a_breath()
    for i in 1:100
        A = rand(100, 100)
        r += A
    end
    return r
end

#%%
test8()
Profile.clear()
@profile test8()
Profile.print()


@profview test8()
#%%
function profile_test(n)
    for i = 1:n
        A = randn(100, 100, 20)
        m = maximum(A)
        Am = mapslices(sum, A; dims = 2)
        B = A[:, :, 5]
        Bsort = mapslices(sort, B; dims = 1)
        b = rand(100)
        C = B .* b
    end
end

@profview profile_test(1)  # run once to trigger compilation (ignore this one)
@profview profile_test(10)
#%%
using BenchmarkTools

arr1 = zeros(10000)

function put1!(arr)
    for i in 1:length(arr)
        arr[i] = 1.0
    end
end

function put1_inbounds!(arr)
    @inbounds for i in 1:length(arr)
        arr[i] = 1.0
    end
end

@btime put1!($arr1)

@btime put1_inbounds!($arr1)

#%%

#%%
using BenchmarkTools
using LinearAlgebra
using StaticArrays

add!(C, A, B) = (C .= A .+ B)

function simple_bench(N, T = Float64)
    A = rand(T, N, N)
    A = A' * A
    B = copy(A)
    SA = SMatrix{N,N}(A)
    MA = MMatrix{N,N}(A)
    MB = copy(MA)

    print("""
============================================
    Benchmarks for $N×$N $T matrices
============================================
""")
    ops = [
        ("Matrix multiplication              ", *, (A, A), (SA, SA)),
        ("Matrix multiplication (mutating)   ", mul!, (B, A, A), (MB, MA, MA)),
        ("Matrix addition                    ", +, (A, A), (SA, SA)),
        ("Matrix addition (mutating)         ", add!, (B, A, A), (MB, MA, MA)),
        ("Matrix determinant                 ", det, (A,), (SA,)),
        ("Matrix inverse                     ", inv, (A,), (SA,)),
        ("Matrix symmetric eigendecomposition", eigen, (A,), (SA,)),
        ("Matrix Cholesky decomposition      ", cholesky, (A,), (SA,)),
        ("Matrix LU decomposition            ", lu, (A,), (SA,)),
        ("Matrix QR decomposition            ", qr, (A,), (SA,)),
    ]
    for (name, op, Aargs, SAargs) in ops
        # We load from Ref's here to avoid the compiler completely removing the
        # benchmark in some cases.
        #
        # Like any microbenchmark, the speedups you see here should only be
        # taken as roughly indicative of the speedup you may see in real code.
        if length(Aargs) == 1
            A1 = Ref(Aargs[1])
            SA1 = Ref(SAargs[1])
            speedup = @belapsed($op($A1[])) / @belapsed($op($SA1[]))
        elseif length(Aargs) == 2
            A1 = Ref(Aargs[1])
            A2 = Ref(Aargs[2])
            SA1 = Ref(SAargs[1])
            SA2 = Ref(SAargs[2])
            speedup = @belapsed($op($A1[], $A2[])) / @belapsed($op($SA1[], $SA2[]))
        elseif length(Aargs) == 3
            A1 = Ref(Aargs[1])
            A2 = Ref(Aargs[2])
            A3 = Ref(Aargs[3])
            SA1 = Ref(SAargs[1])
            SA2 = Ref(SAargs[2])
            SA3 = Ref(SAargs[3])
            speedup = @belapsed($op($A1[], $A2[], $A3[])) / @belapsed($op($SA1[], $SA2[], $SA3[]))
        else
        end
        println(name * " -> $(round(speedup, digits=1))x speedup")
    end
end
#%%
simple_bench(3)

#%%
arr1 = zeros(100, 200)

@btime for i in 1:100
    for j in 1:200
        arr1[i, j] = 1
    end
end


@btime for j in 1:200
    for i in 1:100
        arr1[i, j] = 1
    end
end

#%%
function test_positional(a, b, c)
    return a + b + c
end

function test_keyword(; a, b, c)
    return a + b + c
end

@code_llvm test_positional(1, 2, 3)

@code_llvm test_keyword(a = 1, b = 2, c = 3)


@btime test_positional(1, 2, 3)

@btime test_keyword(a = 1, b = 2, c = 3)
