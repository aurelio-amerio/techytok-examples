using Mmap
using JLD

#%%
x = rand(100, 100)
data_dict = Dict("x" => x)

save("files/test-file.jld", data_dict)

function split_file(;filePath::String, fileSizeMb::Real, folderPath="default")
    if folderPath=="default"
        folderPath=dirname(filePath)
    end

    fileName=basename(filePath)

    Kbyte = 1024
    Mbyte = 1024 * 1024
    maxFileSize = fileSizeMb * Mbyte
    nfiles = ceil(Int, bytes / maxFileSize)

    splits_indexes = collect(ceil.(Int, range(0, bytes, length = (files + 1))))

    splits = [file[(splits_indexes[i]+1):(splits_indexes[i+1])] for i = 1:(length(splits_indexes)-1)]
    let s = Mmap.open("$folderPath/$fileName.0", "w+")
        write(s, Int(length(splits_indexes)-1))
        close(s)
    end

    for (i, split) in enumerate(splits)
        let s = Mmap.open("$folderPath/$fileName.$i", "w+")
            write(s, split)
            close(s)
        end
    end
    close(s)
end

function recompose_file(;filePath::String, folderPath="default")
    if folderPath=="default"
        folderPath=dirname(filePath)
    end

    fileName=basename(filePath)

    s0 = Mmap.open("$folderPath/$fileName.0", "r")

    nfiles = read(s0, Int)
    close(s0)

    restored = Vector{UInt8}[]

    for i = 1:nfiles
        let s = Mmap.open("$folderPath/$fileName.$i", "r")
            file = read(s)
            push!(restored, file)
            close(s)
        end
    end

    let s = Mmap.open("$folderPath/$fileName", "w+")
        file = vcat(restored...)
        write(s, file)
        close(s)
    end
    @info "$fileName recomposed"
    return
end
# %%
split_file(filePath="files/test-file.jld", folderPath="files2", fileSizeMb=0.01)
recompose_file(filePath="files2/test-file.jld")
# %%

data_dict2 = load("files/test-file_restored.jld")
# data_dict2 = load("test-file.jld")
data_dict2["x"]==x


basename("files/test-file_restored.jld")

#%%
struct Person
    height::Float64
    weight::Float64
    BMI::Float64

    function Person(heightInMeters::Float64, weightInKilos::Float64)
        BMI = weightInKilos / heightInMeters^2
        new(heightInMeters, weightInKilos, BMI)
    end

    function Person(;heightInMeters::Float64, weightInKilos::Float64)
        BMI = weightInKilos / heightInMeters^2
        new(heightInMeters, weightInKilos, BMI)
    end
end

bob = Person(heightInMeters=1.84, weightInKilos=84.0)
carl = Person(1.84, 84.0)
