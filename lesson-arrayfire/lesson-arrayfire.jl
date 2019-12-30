using ArrayFire
using BenchmarkTools

function pi_gpu(n)
    return 4 *
           sum(rand(AFArray{Float64}, n)^2 .+ rand(AFArray{Float64}, n)^2 .<= 1) ./
           n
end

@btime pi_gpu(10_000_000)

function pi_serial(n)
    inside = 0
    for i = 1:n
        x, y = rand(), rand()
        inside += (x^2 + y^2 <= 1)
    end
    return 4 * inside / n
end

@btime pi_serial(10_000_000)

#%% Mandelbrot fractal
using Plots
gr()

maxIterations = 500
gridSize = 2048
xlim = [-0.748766713922161, -0.748766707771757]
ylim = [0.123640844894862, 0.123640851045266]

x = range(xlim[1], xlim[2], length = gridSize)
y = range(ylim[1], ylim[2], length = gridSize)

xGrid = [i for i in x, j in y]
yGrid = [j for i in x, j in y]

z0 = xGrid + im * yGrid

function mandelbrotGPU(z0, maxIterations)
    z = z0
    count = ones(AFArray{Float32}, size(z))

    for n = 1:maxIterations
        z = z .* z .+ z0
        count = count + (abs(z) <= 2)
    end
    return sync(log(count))
end

count = Array(mandelbrotGPU(AFArray(z0), maxIterations))
heatmap(
    count,
    color = :inferno,
    grid = false,
    colorbar = :none,
    framestyle = :none,
    size = (2048, 2048),
)
savefig("mandelbrot.png")
