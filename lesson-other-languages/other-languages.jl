using Pkg
Pkg.add("Cxx")

using Cxx

cxx""" #include<iostream> """

# Declare the function
cxx"""
   void mycppfunction() {
      int z = 0;
      int y = 5;
      int x = 10;
      z = x*y + 2;
      std::cout << "The number is " << z << std::endl;
   }
"""
# Convert C++ to Julia function
julia_function() = @cxx mycppfunction()


# Run the function
julia_function()

#%% MathLink
using Pkg
Pkg.add("MathLink")
using MathLink

W"Sin"

sin1 = W"Sin"(1.0)

sinx = W"Sin"(W"x")

weval(sin1)
weval(sinx)
weval(W"Integrate"(sinx, (W"x", 0, 1)))
