## funkcje wykorzystywane do rozwiązania zadania 2.16 z pracowni ANM ##
## autor: Mateusz Markiewicz ##
function clenshaw(n,c,x)
    Bk_1 = 0
    Bk_2 = 0
    for i = n:(-1):1
        Bk = Float64(2) * x * Bk_1 - Bk_2 + c[i+1]
        Bk_2 = Bk_1
        Bk_1 = Bk
    end
    return x * Bk_1 - Bk_2 + c[1]/Float64(2)
end

using Distributions

function fluct(c)
    return Float64(c) + rand(Uniform(-(2^(-48)),2^(-48)))
end

function czebyszew(k,x)
    return cos(k * acos(x))
end

function czebyszew2(k,x)
    if k == 0
        return 1
    elseif k == 1
        return x
    else
        return 2*x*czebyszew(k-1,x) - czebyszew(k-2,x)
    end
end

function sign_figures(a,b)
    return -log(10,abs((a-b)/b))
end
 
function rel_err(v,av)
    return Float64(abs((v-av)/v))
end

function t(n,k)
    return Float64(cos(((2*k+1)/(2*n))*pi))
end

function u(n,k)
    return Float64(cos(((k)/(n+1))*pi))
end

function tkMatrix(n)
    matrix = ones(Float64,n+1,n+1)
    for i = 1:(n+1)
        matrix[2,i] = t(n+1,i-1)
    end
    for i = 3:(n+1)
        for j = 1:(n+1)
            matrix[i,j] = 2 * matrix[2,j] * matrix[i-1,j] - matrix[i-2,j]
        end
    end
    return matrix
end

function f(x)
    return Float64(x^22 + e^x + x^7)
end

