
function f(x)
    (x-3)^3
end

function f2(x)
    3*(x^2) - 18*x + 27
end

function iter(n,x0,f1,f2)
    x = x0
    for i = 1:n
        x = x - (f1(x))/(f2(x))
        print(x)
        println("")
    end
    return x
end

println("")
print(iter(10,2,f,f2))
