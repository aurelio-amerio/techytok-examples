
module Mandelbrot

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
        scale_function::Function = x -> x,
    ) where {T<:Real}
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
            scale_function,
        )
    end
end

function get_coords(fractal::FractalData)
    return fractal.xmin, fractal.xmax, fractal.ymin, fractal.ymax
end

function set_coords(fractal::FractalData, xmin, xmax, ymin, ymax)
    fractal.xmin, fractal.xmax, fractal.ymin, fractal.ymax = xmin, xmax, ymin, ymax
    return
end

# functions to move on the fractal
function move_center!(fractal::FractalData, nStepsX::Int, nStepsY::Int)

    if nStepsX != 0
        xc = (fractal.xmax + fractal.xmin) / 2
        width = fractal.xmax - fractal.xmin
        dx = width / 100

        xc += nStepsX * dx
        fractal.xmin = xc - width / 2
        fractal.xmax = xc + width / 2
    end
    if nStepsY != 0
        yc = (fractal.ymax + fractal.ymin) / 2
        height = fractal.ymax - fractal.ymin
        dy = height / 100

        yc += nStepsY * dy
        fractal.ymin = yc - height / 2
        fractal.ymax = yc + height / 2
    end
    return preview_fractal(fractal) #preview changes
end

function move_up!(fractal::FractalData, nSteps::Int = 1)
    move_center!(fractal::FractalData, 0, nSteps)
end

function move_down!(fractal::FractalData, nSteps::Int = 1)
    move_center!(fractal::FractalData, 0, -nSteps)
end

function move_left!(fractal::FractalData, nSteps::Int = 1)
    move_center!(fractal::FractalData, -nSteps, 0)
end

function move_right!(fractal::FractalData, nSteps::Int = 1)
    move_center!(fractal::FractalData, nSteps, 0)
end

function zoom!(fractal::FractalData, zoom_factor::Real)
    xc = (fractal.xmax + fractal.xmin) / 2
    width = fractal.xmax - fractal.xmin
    width /= zoom_factor

    fractal.xmin = xc - width / 2
    fractal.xmax = xc + width / 2

    yc = (fractal.ymax + fractal.ymin) / 2
    height = fractal.ymax - fractal.ymin
    height /= zoom_factor

    fractal.ymin = yc - height / 2
    fractal.ymax = yc + height / 2

    return preview_fractal(fractal) #preview changes
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
        nRepeat,
    ))
end

function cycle_cmap(cmap::Symbol, nRepeat::Int = 1)
    return ColorGradient(repeat(cgrad(cmap).colors, nRepeat))
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

    x_arr = range(xmin, stop = xmax, length = width)
    y_arr = range(ymin, stop = ymax, length = height)

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

function computeMandelbrot!(fractal_data::FractalData; verbose = true)
    pixels = computeMandelbrot(
        fractal_data.xmin,
        fractal_data.xmax,
        fractal_data.ymin,
        fractal_data.ymax,
        fractal_data.width,
        fractal_data.height,
        fractal_data.maxIter,
        verbose,
    )
    fractal_data.fractal = pixels
    return pixels
end

function display_fractal(
    fractal::Matrix;
    colormap = :magma,
    scale = :linear,
    filename = :none,
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
function display_fractal(fractal::FractalData; scale = :none, filename = :none)
    if scale == :none
        display_fractal(
            fractal.fractal,
            colormap = fractal.colormap,
            scale = fractal.scale_function,
            filename = filename,
        )
    else
        display_fractal(
            fractal.fractal,
            colormap = fractal.colormap,
            scale = scale,
            filename = filename,
        )
    end
end

function preview_fractal(fractal_data::FractalData; scale = :linear)
    pixels = computeMandelbrot(
        fractal_data.xmin,
        fractal_data.xmax,
        fractal_data.ymin,
        fractal_data.ymax,
        w_pw,
        h_pw,
        fractal_data.maxIter,
        true,
    )
    return display_fractal(
        pixels,
        colormap = fractal_data.colormap,
        scale = scale,
        filename = :none,
    )
end

end # end module
