cd("lesson-modules")

using Pkg
Pkg.add("SpecialFunctions")
#%%
using SpecialFunctions

gamma(3)

sinint(5)

#%% restart the REPL befor running this piece of code
using SpecialFunctions: gamma, sinint

gamma(3)

sinint(5)

cosint(5)

#%%
function gamma(x)
    println("I am another 'gamma' function")
    return x^2
end

using SpecialFunctions

gamma(3)

SpecialFunctions.gamma(3)

#%% a better solution
import SpecialFunctions

gamma(3)

SpecialFunctions.gamma(3)

function gamma(x)
    println("I am another 'gamma' function")
    return x^2
end

gamma(3)

#%%

module MyModule
export func2

a = 42
function func1(x)
    return x^2
end

function func2(x)
    return func1(x) + a
end

end #end of module

#%%

using Main.MyModule

func2(3)
func1(3)
MyModule.func1(3)

#%% using MyBigModule
include("big-module.jl")

using .MyBigModule

func2big(3)

#%%
