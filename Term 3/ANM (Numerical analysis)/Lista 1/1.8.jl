
function isOne(x)
    x1 = 1/x
    x2 = x * x1
    if x2 == 1
        return true
    else
        return false
    end
end


z = 0.0000000000000002
let x = 1.0000000000000002
    while !isOne(x)
         x += z
    end
    print(x)
    println("")
    print(isOne(x))
end

println("")
print(isOne(1.000000057228997))