module TestPackage1
using SpecialFunctions

export mySpecialFunction

greet() = print("Hello World!")
# greet() = print("Hello from TechyTok!")

"""
    mySpecialFunction(x)

A simple function for testing purposes

# Examples
```jldoctest
julia> mySpecialFunction(3)
18.0
```

See also [`gamma`](@ref).
"""
function mySpecialFunction(x)
    return x^2 * gamma(x)
end

function test_a_special_function(x)
    return mySpecialFunction(x)
end
end # module
