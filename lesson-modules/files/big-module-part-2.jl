a = 42

@doc raw"""
    func2big(x)

Computes the square of `x` and add `a` to it.

# Examples
```julia-repl
julia> include("big-module.jl")
julia> using .MyBigModule
julia> func2big(3)
51
```
"""
function func2big(x)
    return func1big(x) + a
end
