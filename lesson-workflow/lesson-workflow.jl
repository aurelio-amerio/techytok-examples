cd("lesson-workflow")
using Pkg
Pkg.activate("TestPackage1")
# Pkg.add("Revise") # it is necessary to install Revise only once
#%%
using Revise
using TestPackage1
using BenchmarkTools
TestPackage1.greet()
#%%
mySpecialFunction(3)
#%%
function test_me(x)
    return x
end

a = test_me(1)

b = [1,2,3]
c = rand(2,3)
#%%
# debugging tests

function helper_function(x)
    return log10(x) +3
end

function debug_me(x)
    a = zeros(10)
    for i in 1:length(a)
        a[i] = helper_function(x*i)
    end
    b = a ./ 3
    return sum(b)
end

debug_me(3)

@run debug_me(3)

#%% a function with a Domain Error
function debug_me2()
    x = -1
    res = sqrt(x)
    return res
end

debug_me2()
@run debug_me2()

# Problems tab
debug_me2(3) # FIXME: function called with the wrong argument
# TODO: add a TODO 
