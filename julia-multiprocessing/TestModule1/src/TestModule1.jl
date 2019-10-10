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
        arr[i] = rand()
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

function create_interp()
    @info "create_interp"
    x = range(0, stop = 10, length = 1000)

    y = SharedArray{Float64}(length(x))
    @info "Computing Interpolation..."
    p = Progress(length(x), "Progress: ")
    update!(p, 0)
    pr = SharedArray{Int}(1)
    @sync @distributed for i = 1:length(x)
        #some really hard computations
        sleep(0.01)
        y[i] = sin(x[i])
        pr[1] += 1
        update!(p, pr[1])
    end


    knots = (x,)
    itp = interpolate(knots, y, Gridded(Linear()))

    return itp
end

const test_interp = create_interp()

function print_nprocs()
    return nworkers()
end

end # module
