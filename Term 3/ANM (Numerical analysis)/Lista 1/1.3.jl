function f1(x)
    return x^3 - 6*x^2 + 3*x - 0.149
end

function f2(x)
    return ((x-6)*x + 3)*x - 0.149
end

function blad(x, y)
    bb = abs(x-y)
    bw = bb / abs(x)
    return bw
end

x0 = 4.71
wx = -14.636489
x16 = Float16(x0)
x32 = Float32(x0)
x64 = Float64(x0)

println("Wartości f1 i f2 dla Fl16, Fl32 i Fl64")
print(f1(x16))
println("")
print(f1(x32))
println("")
print(f1(x64))
println("")
println("")

print(f2(x16))
println("")
print(f2(x32))
println("")
print(f2(x64))
println("")
println("")

println("Bledy f1 i f2 dla Fl16, Fl32 i Fl64")
print(blad(wx, f1(x16)))
println("")
print(blad(wx, f1(x32)))
println("")
print(blad(wx, f1(x64)))
println("")
println("")

print(blad(wx, f2(x16)))
println("")
print(blad(wx, f2(x32)))
println("")
print(blad(wx, f2(x64)))
println("")