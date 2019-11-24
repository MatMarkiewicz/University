
function test(x)
    if length(x) != 64
        print("Błędne słowo maszynowe")
        return 0
    else
        s0 = x[1]
        c0 = reverse(x[2:12])
        m0 = x[13:64]
        if s0 == '0'
            s = 1.0
        else
            s = -1.0
        end
        m = 1.0
        for i = 1:52
            if m0[i] == '1'
                m += 2.0 ^ -i
            end
        end
        c = -1023.0
        for i = 1:11
            if c0[i] == '1'
                c += 2.0 ^ (i-1)
            end
        end
    end
    return 2^c * m * s
end

print(test(bitstring(1.523634)))
println("")
print(test(bitstring(-1.523634)))
println("")
print(test(bitstring(100.0)))
println("")
print(test(bitstring(-100.0)))
println("")
print(test(bitstring(4210.565)))
println("")
print(test(bitstring(-4210.565)))
println("")

(print(test("0011111111110000000000000000000000000000000000000000000000000001")))