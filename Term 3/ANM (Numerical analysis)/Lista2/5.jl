
setprecision(128)
s = BigFloat(1)
c = BigFloat(0)
P = BigFloat(2)

function f(s0,c0,P0)
    s = s0
    c = c0
    P = P0
    for i = 3:128
        s = ((1 - c)/2)^(1/2)
        c = ((1 + c)/2)^(1/2)
        P = (BigInt(2)^(i-1))*s
        println("$(i) $(P) $(s) $(c)")
    end
end

f(s,c,P)
