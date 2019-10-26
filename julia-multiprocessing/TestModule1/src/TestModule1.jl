__precompile__()

module TestModule1

export func1, func2, test_interp, print_nprocs

using Distributed
using SharedArrays
using ProgressMeter
using Interpolations

include("SubModule.jl")
using .SubMod1

function func1()
    n = 200000
    arr = SharedArray{Float64}(n)
    @sync @distributed for i = 1:n
        arr[i] = i^2
    end
    res = sum(arr)
    return res
end

function func2()
    n = 100
    arr = SharedArray{Float64}(n)
    @sync @distributed for i = 1:n
        arr[i] = SubMod1.test_me(i)
    end
    res = sum(arr)
    return res
end

function sine_func(x)
    sleep(22*1e-3)
    return sin(x)
end

function create_interp()
    @info "create_interp"
    x = range(0, stop = 10, length = 1000)

    @info "Computing Interpolation..."
    y = @showprogress pmap(sine_func, x, batch_size=10)


    knots = (x,)
    itp = interpolate(knots, y, Gridded(Linear()))

    return itp
end

const test_interp = create_interp()

function print_nprocs()
    return nworkers()
end

end # module
