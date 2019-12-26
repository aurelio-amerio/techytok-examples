cd("lesson-plots")
using Pkg
Pkg.add("Plots")
# gr()
#%%
using Plots

x=1:0.01:10*π
y=sin.(x)

plot(x,y, label="sin(x)")
plot!(xlab="x", ylab="f(x)")

savefig("img1a.png")

y2=sin.(x).^2
plot!(x, y2, label="sin(x)^2", color=:red, line=:dash)

savefig("img1b.png")

xaxis!(:log10)
plot!(legend=:bottomleft)
savefig("img1c.png")

plot!(title="My first plot!")
#%%
plotly()
x=1:0.1:3*π
y=1:0.1:3*π

xx = reshape([xi for xi in x for yj in y],  length(y), length(x))
yy = reshape([yj for xi in x for yj in y],  length(y), length(x))
zz = sin.(xx).*cos.(yy)
plot3d(xx,yy,zz, label=:none, st = :surface)
plot!(xlab="x", ylab="y", zlab="sin(x)*cos(y)")
savefig("img2")

Pkg.add("ORCA")
using ORCA

savefig("img2.png")
#%%
pyplot()
x=0:0.1:2*π
y=sin.(x).^2

plot(x, y, label="sin(x)^2")
savefig("img3.png")
#%%

Pkg.add("LaTeXStrings")
using LaTeXStrings

plot(x, y, label=L"$\sin(x)^2$")
savefig("img3b.png")
#%%


PyPlot.plot(x,y)
PyPlot.xscale("log")

PyPlot.gcf()
