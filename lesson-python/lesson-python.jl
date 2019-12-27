using Pkg

ENV["PYTHON"] = ""
ENV["CONDA_JL_HOME"] = "D:/Users/Aure/Anaconda3/envs/julia" # path to miniconda3 directory

Pkg.add("PyCall")
Pkg.build("PyCall")

using PyCall

math = pyimport("math")

math.sin(3)
