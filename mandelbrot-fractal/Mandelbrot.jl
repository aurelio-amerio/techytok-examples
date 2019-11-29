
module Mandelbrot

using BenchmarkTools
using Base.Threads
using Plots
using ProgressMeter
# using ArrayFire

w_pw = 384
h_pw = 216

w_lr = 768
h_lr = 432

w_HD = 1920
h_HD = 1080

w_4k = 3840
h_4k = 2160

# structure to hold fractal data
mutable struct FractalData{T<:Real}
    xmin::T
    xmax::T
    ymin::T
    ymax::T
    width::Int
    height::Int
    fractal::Matrix{T}
    maxIter::Int
    colormap::ColorGradient
    scale_function::Function

    function FractalData{T}(
        xmin::T,
        xmax::T,
        ymin::T,
        ymax::T;
        width::Int = w_lr,
        height::Int = h_lr,
        fractal = :none,
        maxIter = 1500,
        colormap = cgrad(:inferno),
        scale_function::Function = x -> x
    ) where T <: Real
        img = zeros(T, height, width)
        if fractal != :none
            img = fractal
        end
        new(
            xmin,
            xmax,
            ymin,
            ymax,
            width,
            height,
            img,
            maxIter,
            colormap,
            scale_function
        )
    end
end


# custom colorbars, generate them using https://cssgradient.io/

function pumpkin(nRepeat::Int = 1)
    return ColorGradient(repeat([:black, :red, :orange], nRepeat))
end

function ice(nRepeat::Int = 1)
    return ColorGradient(repeat(["#193e7c", "#dde2ff"], nRepeat))
end

function deep_space(nRepeat::Int = 1)
    return ColorGradient(repeat(["#000000", "#193e7c", "#dde2ff"], nRepeat))
end

function alien_space(nRepeat::Int = 1)
    return ColorGradient(repeat(
        ["#1a072a", "#ff3e24", "#ffa805", "#7b00ff"],
        nRepeat
    ))
end

function cycle_cmap(cmap::Symbol, nRepeat::Int = 1)
    return ColorGradient(repeat(cgrad(cmap).colors, 5))
end

# compute mandelbrot

function mandelbrotBoundCheck(
    cr::T,
    ci::T,
    maxIter::Int = 1000,
) where {T<:AbstractFloat}
    zr = zero(T)
    zi = zero(T)
    zrsqr = zr^2
    zisqr = zi^2
    result = 0
    for i = 1:maxIter
        if zrsqr + zisqr > 4.0
            result = i
            break
        end
        zi = (zr + zi)^2 - zrsqr - zisqr
        zi += ci
        zr = zrsqr - zisqr + cr
        zrsqr = zr^2
        zisqr = zi^2
    end
    return result
end

function computeMandelbrot(
    xmin::Real = -2.2,
    xmax::Real = 0.8,
    ymin::Real = -1.2,
    ymax::Real = 1.2,
    width::Int = 800,
    height::Int = 600,
    maxIter::Int = 1000,
    zoom::Real = 1,
    verbose = true,
)
    if verbose
        p = Progress(width)
        update!(p, 0)
        jj = Threads.Atomic{Int}(0)
        l = Threads.SpinLock()
    end

    xc = (xmax + xmin) / 2
    yc = (ymax + ymin) / 2
    dx = (xmax - xmin) / width
    dy = (ymax - ymin) / height

    x_arr = zeros(typeof(xmin), width)
    y_arr = zeros(typeof(ymin), height)

    if zoom != 1 # redefine bounds according to zoom
        dx /= zoom
        dy /= zoom
        xmin = xc - dx * width / 2
        xmax = xc + dx * width / 2
        ymin = yc - dy * height / 2
        ymax = yc + dy * height / 2

        x_arr .= collect(range(xmin, stop = xmax, length = width))
        y_arr .= collect(range(ymin, stop = ymax, length = height))
    else
        x_arr .= collect(range(xmin, stop = xmax, length = width))
        y_arr .= collect(range(ymin, stop = ymax, length = height))
    end

    # x_arr = range(xmin, stop = xmax, length = width)
    # y_arr = range(ymin, stop = ymax, length = height)

    pixels = zeros(typeof(xmin), height, width) #pixels[y,x]

    @threads for x_j = 1:width
        @inbounds for y_i = 1:height
            pixels[y_i, x_j] = mandelbrotBoundCheck(
                x_arr[x_j],
                y_arr[y_i],
                maxIter,
            )
        end
        if verbose
            Threads.atomic_add!(jj, 1)
            Threads.lock(l)
            update!(p, jj[])
            Threads.unlock(l)
        end
    end
    return pixels
end

function computeMandelbrot!(
    fractal_data::FractalData;
    zoom=1,
    verbose = true,
)
    pixels = computeMandelbrot(
        fractal_data.xmin,
        fractal_data.xmax,
        fractal_data.ymin,
        fractal_data.ymax,
        fractal_data.width,
        fractal_data.height,
        fractal_data.maxIter,
        zoom,
        verbose,
    )
    fractal_data.fractal = pixels
    return pixels
end

function display_fractal(
    fractal::Matrix;
    colormap = :magma, scale = :linear, filename = :none
)
    img = deepcopy(fractal)
    if scale == :log
        img = log.(img) # normalize image to have nicer colors
    elseif scale == :exp
        img = exp.(img)
    elseif typeof(scale) <: Function
        img = scale.(img)
    end

    plot = heatmap(
        img,
        colorbar = :none,
        color = colormap,
        axis = false,
        size = (size(img)[2], size(img)[1]),
        grid = false,
        framestyle = :none,
    )

    if filename != :none
        savefig(filename)
    end

    return plot
end

# version using the structure
function display_fractal(fractal::FractalData; scale=:none, filename = :none)
    if scale == :none
        display_fractal(
            fractal.fractal,
            colormap = fractal.colormap,
            scale = fractal.scale_function,
            filename = filename
        )
    else
        display_fractal(
            fractal.fractal,
            colormap = fractal.colormap,
            scale = scale,
            filename = filename
        )
    end
end

end
