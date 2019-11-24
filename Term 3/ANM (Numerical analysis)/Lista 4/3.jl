
function secant(x0,x1,i,f)
    xn = Float64(x1)
    xn_1 = Float64(x0)
    for j = 0:i
        p = xn
        w1 = xn - xn_1
        w2 = f(xn) - f(xn_1)
        w3 = w1/w2
        w4 = w3*f(xn)
        xn = xn - w4
        xn_1 = p
    end
    return xn
end

function secant2(x0,x1,i,f)
    xn = Float64(x1)
    xn_1 = Float64(x0)
    for j = 0:i
        p = xn
        w1 = f(xn)*xn_1
        w2 = f(xn_1)*xn
        w3 = w1-w2
        w4 = f(xn) - f(xn_1)
        w5 = w3/w4
        xn = w5
        xn_1 = p
    end
    return xn
end

function test(x)
    return x^2
end

print(secant(-10,9,500,test))
print("\n")
print(secant2(-10,9,500,test))