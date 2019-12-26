using Pkg
Pkg.add("QuadGK")

using QuadGK


func1(x) = exp(-x^2)
res, err = quadgk(func1, -Inf, Inf)

abs(res - sqrt(π)) / sqrt(π)


res, err = quadgk(func1, -Inf, Inf, rtol = 1e-15)

abs(res - sqrt(π)) / sqrt(π)

res, err = quadgk(func1, -Inf, Inf, order = 12)

abs(res - sqrt(π)) / sqrt(π)

sqrt(π)

#%%
func2(x, y, z) = x + y^3 + sin(z)

x = 5
z = 3
arg(y) = func2(x, y, z)

quadgk(arg, 1, 3)

quadgk(y -> func2(x, y, z), 1, 3)

res, err = let x=5; z=3
    arg(y) = func2(x, y, z)

    quadgk(arg, 1, 3)
end

#%%
func3(x, y) = x^2 * exp(y)

function test_int(x, ymin, ymax)
    arg(y) = func3(x, y)
    return quadgk(arg, ymin, ymax)[1]
end

test_int(3, 1, 5)
