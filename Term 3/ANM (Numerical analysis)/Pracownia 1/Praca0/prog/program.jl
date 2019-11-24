using Printf

log2 = log(Float64(2))
sqrt2_2 = sqrt(Float64(2))/2

function logn_1(x)
    a = [Float64(1.999999993788),Float64(0.399659100019),Float64(0.666669470507),Float64(0.300974506336)]
    s = Float64(0)
    for i = 0:3
        s += a[i+1] * ((x - sqrt2_2)/(x + sqrt2_2))^(2*i+1)
    end
    return s - log2/2
end

function sign_figures(a,b)
    return -log(10,abs((a-b)/b))
end

function logn(x)
    x = Float64(x)
    c = bitstring(x)[2:12]
    i = parse(Int,c,base=2) - 1022
    m = x * Float64(2)^(-i)
    a = [Float64(1.999999993788),Float64(0.399659100019),Float64(0.666669470507),Float64(0.300974506336)]
    s = Float64(0)
    for i = 0:3
        s += a[i+1] * ((m - sqrt2_2)/(m + sqrt2_2))^(2*i+1)
    end
    return s + (i-0.5)*log2
end

function test0(a,b,n)
    e = (b-a)/n
    for i = 0:n
        y = logn(a)
        y0 = BigFloat(log(a))
        s = sign_figures(y,y0)
        @printf("Logarytm naturalny %.3f wynosi %.10f obliczona wartość to %.10f, więc ilość cyfr znaczących to %.3f \n",a, y0, y, s)
        a += e
    end
end

function test(a,b,n)
    e = (b-a)/n
    for i = 0:n
        y = logn2(a)
        y0 = BigFloat(log(a))
        s = sign_figures(y,y0)
        @printf("Logarytm naturalny %.3f wynosi %.10f obliczona wartość to %.10f, więc ilość cyfr znaczących to %.3f \n",a, y0, y, s)
        a += e
    end
end

function logn2(x)
    x = Float64(x)
    c = bitstring(x)[2:12]
    i = parse(Int,c,base=2) - 1022
    m = x * Float64(2)^(-i)
    a = [BigFloat(1.999999993788),BigFloat(0.399659100019),BigFloat(0.666669470507),BigFloat(0.300974506336)]
    s = BigFloat(0)
    for i = 0:3
        s += a[i+1] * ((m - sqrt2_2)/(m + sqrt2_2))^(2*i+1)
    end
    return s + Float64(i-0.5)*log2
end

test0(0.5,1,50)
println("")
test(0.00001,1,50)
test(1,50,50)
test(100,100000000,50)
