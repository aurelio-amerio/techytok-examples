using Pkg
Pkg.add("Unitful")
using Unitful

one_meter = 1u"m"

b = uconvert(u"km", one_meter)
b
one_meter

c = ustrip(u"m", one_meter)
c
typeof(c)
one_meter

ustrip(u"km", one_meter)
ustrip(one_meter)
#%%
function compute_speed(Δx, Δt)
    return Δx/Δt
end

compute_speed(1u"km", 2u"s")

function compute_speed(Δx::Unitful.Length, Δt::Unitful.Time)
    return uconvert(u"m/s", Δx/Δt)
end

compute_speed(1u"km", 2u"s")
#%%
struct Person
    height::typeof(1.0u"m")
    mass::typeof(1.0u"kg")
end
#%%
using QuadGK
velocity(t::Unitful.Time) = 2u"m/s^2"*t + 1u"m/s"

quadgk(velocity, 0u"s", 3u"s")[1]
