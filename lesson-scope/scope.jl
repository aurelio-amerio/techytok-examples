a = let
    i=3
    i+=5
    i # the value returned from the computation
end

a

b = let i=5
    i+=42
    i
end

c = let i=10
    i+=42
    i
end

c

i

d = begin
    i=41
    i+=1
    i
end


i
d

const C = 299792458 # m / s, this is an Int

C = 300000000 # change the value of C

C = 2.998 * 1e8 #change the type of C, not permitted

#%%
module ScopeTestModule
export a1
a1 = 25
b1 = 42
end # end of module
#%%
using .ScopeTestModule

a1
b1

ScopeTestModule.b1=26
