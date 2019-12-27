using Pkg
Pkg.add("JLD")

using JLD

x = collect(-3:0.1:3)
y = collect(-3:0.1:3)

xx = reshape([xi for xi in x for yj in y], length(y), length(x))
yy = reshape([yj for xi in x for yj in y], length(y), length(x))

z = sin.(xx .+ yy .^ 2)

data_dict = Dict("x" => x, "y" => y, "z" => z)

save("data_dict.jld", data_dict)

#%% restart the REPL
using JLD
data_dict2 = load("data_dict.jld")

x2 = data_dict2["x"]
y2 = data_dict2["y"]
z2 = data_dict2["z"]

using Plots
plotly()

plot(x2, y2, z2, st = :surface, color = :ice)
savefig("img1")

#%%
using JLD
struct Person
    height::Float64
    weight::Float64
end

bob = Person(1.84, 74)

dict_new = Dict("bob" => bob)
save("bob.jld", dict_new)

#%% please restart the REPL
using JLD
struct Person
    height::Float64
    weight::Float64
end
bob2 = load("bob.jld")

bob2["bob"]

#%% please restart the REPL
using JLD

bob3 = load("bob.jld")

bob3["bob"]

bob3["bob"].height
