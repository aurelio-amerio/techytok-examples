cd("lesson-packages")
using Pkg
Pkg.activate("TestPackage1")

#%%
using TestPackage1

TestPackage1.greet()
#%%
mySpecialFunction(3)
#%%
using Pkg
Pkg.instantiate()
