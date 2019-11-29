#%%
using BenchmarkTools
using Base.Threads
using Plots
using ProgressMeter
# using ArrayFire
#%%
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
    colormap::ColorGradient
    scale_function::Function

    function FractalData{T}(
        xmin::T,
        xmax::T,
        ymin::T,
        ymax::T;
        fractal = :none,
        width::Int = w_lr,
        height::Int = h_lr,
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
function displayMandelbrot(
    ;
    ;
    xmin::Real = -2.2,
    xmax::Real = 0.8,
    ymin::Real = -1.2,
    ymax::Real = 1.2,
    width::Int = 800,
    height::Int = 600,
    maxIter::Int = 1000,
    zoom::Real = 1,
    colormap = :magma,
    scale = :linear,
    filename = :none,
    verbose = true,
)
    img = computeMandelbrot(
        xmin,
        xmax,
        ymin,
        ymax,
        width,
        height,
        maxIter,
        zoom,
        verbose,
    )
    mandelbrot_raw = img
    # img .+= 1 # remove zeros
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
        size = (width, height),
        grid = false,
    )

    if filename != :none
        savefig(filename)
    end
    return (plot, mandelbrot_raw)
end

function display_fractal(
    fractal::Matrix,
    colormap = :magma,
    scale = :linear,
    filename = :none
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
    )

    if filename != :none
        savefig(filename)
    end

    return plot
end
#%%
cmap1 = :inferno
xmin1 = -1.744453831814658538530
xmax1 = -1.744449945239591698236
ymin1 = 0.022017835126305555133
ymax1 = 0.022020017997233506531

cmap2 = :ice
scale2 = :log
maxIter2 = 5000
xmin2 = 0.308405876790033128474
xmax2 = 0.308405910247503605302
ymin2 = 0.025554220954294027410
ymax2 = 0.025554245987221578418

# cmap3b = pumpkin(4)
cmap3c = cycle_cmap(:inferno, 50)
scale3 = x -> x^-5
maxIter3 = 5000
xmin3 = 0.307567454839614329536
xmax3 = 0.307567454903142214608
ymin3 = 0.023304267108419154581
ymax3 = 0.023304267156089095573

cmap4 = alien_space(50)
scale4 = x -> x^-5
maxIter4 = 50000
xmin4 = 0.2503006273651145643691
xmax4 = 0.2503006273651201870891
ymin4 = 0.0000077612880963380370
ymax4 = 0.0000077612881005550770

xmin4b = BigFloat("0.2503006273651145643691")
xmax4b = BigFloat("0.2503006273651201870891")
ymin4b = BigFloat("0.0000077612880963380370")
ymax4b = BigFloat("0.0000077612881005550770")



#%% number 4
displayMandelbrot(
    xmin = xmin4b,
    xmax = xmax4b,
    ymin = ymin4b,
    ymax = ymax4b,
    width = w_HD,
    height = h_HD,
    colormap = cmap4,
    maxIter = maxIter4,
    verbose = true,
    scale = scale4,
    filename = "mandelbrot-fractal/images/mandelbrot4.png",
)
