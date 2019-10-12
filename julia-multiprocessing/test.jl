using Distributed
addprocs(2)

@everywhere using Pkg
@everywhere Pkg.activate("./julia-multiprocessing/TestModule1")

@everywhere using TestModule1

#%%
print_nprocs()

func1()

func2()

test_interp(3.1415)
sin(3.1415)

TestModule1.create_interp()
