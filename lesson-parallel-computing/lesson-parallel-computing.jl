using Pkg
Pkg.add("SpecialFunctions")
Pkg.add("BenchmarkTools")

using SpecialFunctions
using BenchmarkTools
#%%
x = range(0,100, length=10000)

#%%
using Base.Threads
Threads.nthreads()

results = zeros(length(x))


@btime results .= besselj1.(x)

@btime for i in 1:length(x)
    results[i] = besselj1(x[i])
end

@btime @threads for i in 1:length(x)
    results[i] = besselj1(x[i])
end

#%%
function slow_func(x)
    sleep(0.005)
    return x
end

y = 1:0.1:10
res = zeros(length(y))

@btime res .= slow_func.(y)

@btime for i in 1:length(y)
    res[i] = slow_func(y[i])
end

#%%
import Base.Threads.@spawn
using BenchmarkTools

function fib(n::Int)
    if n < 2
        return n
    end
    t = fib(n - 2)
    return fib(n - 1) + t
end

function fib_threads(n::Int)
    if n < 2
        return n
    end
    t = @spawn fib_threads(n - 2)
    return fib_threads(n - 1) + fetch(t)
end

fib(5)
fib_threads(5)
@btime fib(30)
@btime fib_threads(30)

#%%
import Base.Threads.@spawn
using BenchmarkTools

function slow_func(x)
    sleep(0.005)
    return x
end

@btime let
    x = 1:100
    a = @spawn slow_func(2)
    b = @spawn slow_func(4)
    c = @spawn slow_func(42)
    d = @spawn slow_func(12)
    res = fetch(a) .+ fetch(b) .* fetch(c) ./ fetch(d)
end

@btime let
    x = 1:100
    a = slow_func(2)
    b = slow_func(4)
    c = slow_func(42)
    d = slow_func(12)
    res = a .+ b .* c ./ d
end

#%%
@btime let
    x = 1:100
    a = @spawn sin(2)
    b = @spawn sin(4)
    c = @spawn sin(42)
    d = @spawn sin(12)
    res = fetch(a) .+ fetch(b) .* fetch(c) ./ fetch(d)
end

@btime let
    x = 1:100
    a = sin(2)
    b = sin(4)
    c = sin(42)
    d = sin(12)
    res = a .+ b .* c ./ d
end

# %%
using Pkg
Pkg.add("Distributed")

using Distributed
addprocs(4)

nprocs()

fetch(@spawn myid())
fetch(@spawnat 3 myid())

@everywhere using SpecialFunctions

fetch(@spawn gamma(5))

#%%
@everywhere function my_func(x)
    return x^3*cos(x)
end

fetch(@spawnat 2 my_func(0.42))

@everywhere using SharedArrays
res = SharedArray(zeros(10))
@distributed for x in 1:10
    res[x] = my_func(x)
end

res

#%%
using Distributed
using BenchmarkTools
addprocs(4)

@everywhere using SpecialFunctions
@everywhere function my_func(x)
    arg = repeat([x], 1000)
    return besselj1.(arg)
end
# %%
@btime my_func.(1:1000)

@btime my_func.(1:100)

@btime pmap(my_func, 1:1000, batch_size=1)
@btime pmap(my_func, 1:1000, batch_size=100)
