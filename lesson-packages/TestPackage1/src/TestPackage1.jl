module TestPackage1
using SpecialFunctions

export mySpecialFunction

greet() = print("Hello World!")

function mySpecialFunction(x)
    return x^2 * gamma(x)
end
end # module
