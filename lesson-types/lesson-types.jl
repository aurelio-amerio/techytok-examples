abstract type Person
end

abstract type Musician <: Person
end

mutable struct Rockstar <: Musician
	name::String
	instrument::String
	bandName::String
	headbandColor::String
end

struct ClassicMusician <: Musician
	name::String
	instrument::String
end

mutable struct Physicist <: Person
	name::String
	sleepHours::Float64
	favouriteLanguage::String
end
#%%
aure = Physicist("Aurelio", 6, "Julia")
aure.sleepHours = 8
aure_musician = ClassicMusician("Aurelio", "Violin")
aure_musician.instrument="Cello"

ricky = Rockstar("Riccardo", "Voice", "Black Lotus", "red", 2)

ricky.headbandColor

#%%
function introduceMe(person::Person)
    println("Hello, my name is $(person.name).")
end

function introduceMe(person::Musician)
    println("Hello, my name is $(person.name) and I play $(person.instrument).")
end

function introduceMe(person::Rockstar)
	if person.instrument == "Voice"
		println("Hello, my name is $(person.name) and I sing.")
	else
		println("Hello, my name is $(person.name) and I play $(person.instrument).")
	end

	println("My band name is $(person.bandName) and my favourite headband colour is $(person.headbandColor)!")
end
#%%
introduceMe(aure)

introduceMe(aure_musician)

introduceMe(ricky)

#%%
mutable struct MyData
	x::Float64
	x2::Float64
	y::Float64
	z::Float64
	function MyData(x::Float64, y::Float64)
		x2=x^2
		z = sin(x2+y)
		new(x, x2, y, z)
	end
end

mutable struct MyData2{T<:Real}
	x::T
	x2::T
	y::T
	z::Float64
	function MyData2{T}(x::T, y::T) where {T<:Real}
		x2=x^2
		z = sin(x2+y)
		new(x, x2, y, z)
	end
end

#%%
MyData2{Float64}(2.0,3.0)
MyData2{Int}(2,3)

#%%
module TestModuleTypes

export Circle, computePerimeter, computeArea, printCircleEquation

mutable struct Circle{T<:Real}
    radius::T
    perimeter::Float64
    area::Float64

    function Circle{T}(radius::T) where {T<:Real}
# we initialize perimeter and area to -1.0, which is not a possible value
        new(radius, -1.0, -1.0)
    end
end

@doc raw"""
	computePerimeter(circle::Circle)

Compute the perimeter of `circle` and store the value.
"""
function computePerimeter(circle::Circle)
    circle.perimeter = 2 * π * circle.radius
    return circle.perimeter
end

@doc raw"""
	computeArea(circle::Circle)

Compute the area of `circle` and store the value.
"""
function computeArea(circle::Circle)
    circle.area = π * circle.radius^2
    return circle.area
end

@doc raw"""
	printCircleEquation(xc::Real, yc::Real, circle::Circle )

Print the equation of a cricle with center at (xc, yc) and radius given by circle.
"""
function printCircleEquation(xc::Real, yc::Real, circle::Circle)
    println("(x - $xc)^2 + (y - $yc)^2 = $(circle.radius^2)")
    return
end
end # end module
#%%
using .TestModuleTypes

circle1 = Circle{Float64}(5.0)

computePerimeter(circle1)
circle1.perimeter

computeArea(circle1)
circle1.area

printCircleEquation(2, 3, circle1)
