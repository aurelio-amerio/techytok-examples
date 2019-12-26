using Pkg
Pkg.add("Unitful")
using Unitful

one_meter = 1u"m"

b = uconvert(u"km", one_meter)
b
one_meter

c = ustrip(u"m", one_meter)

function compute_speed(Δx::Unitful.Length, Δt::Unitful.Time)
    return uconvert(u"m/s", Δx/Δt)
end

typeof(compute_speed(1u"km", 2u"s"))

velocity(t::Unitful.Time) = 2u"m/s^2"*t

quadgk(velocity, 0u"s", 3u"s")
