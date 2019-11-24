
setprecision(128)

function Bairstow(a::Vector{Float64}; maxiter=10)    
    # maxiter = maksymalna liczba iteracji w metodzie Newtona
    function solve_quadratic_equation(a::Float64,b::Float64,c::Float64)
        Δ=b*b-4.0*a*c;
        x1,x2 = 0.0, 0.0;   
        if (Δ>0.0)
            sΔ = sqrt(Δ)
            if (b>0.0)
                x1 = (-b-sΔ)/(2.0*a)
                x2 = c/x1
            else
                x2 = (-b+sΔ)/(2.0*a)
                x1 = c/x2
            end
        elseif (Δ<0.0)
            sΔ = sqrt(-Δ)
            if (b>0.0)
                x1 = (-b-sΔ*im)/(2.0*a)
                x2 = c/x1
            else
                x2 = (-b+sΔ*im)/(2.0*a)
                x1 = c/x2
            end
        else
            x1 = -b/(2.0*a);
            x2 = -b/(2.0*a);
        end
        return x1,x2;
    end      
    
    n = length(a)-1;
    α = zeros( Complex{Float64}, n ); _i = 1;
    while (n>1)
        b = zeros(Float64, size(a))
        b[n+1] = a[n+1]     # b_n     = a_n
        c = zeros(Float64, size(a))
        c[n+1] = 0.0        # c_n     = 0
        c[n]   = a[n+1]     # c_{n-1} = a_n

        u,v = 0.0, 0.0
        for j = 1:maxiter
            b[n] = a[n] + u*b[n+1]
            for k=n-2:-1:0
                b[k+1] = a[k+1] + u*b[k+2] + v*b[k+3]
                c[k+1] = b[k+2] + u*c[k+2] + v*c[k+3]
            end
            J = c[1]*c[3] - c[2]*c[2]
            u = u + (c[2]*b[2] - c[3]*b[1])/J
            v = v + (c[2]*b[1] - c[1]*b[2])/J
            j,u,v,b[1],b[2]
        end
        x1,x2 = solve_quadratic_equation(1.0,-u,-v)
        α[_i] = x1; α[_i+1] = x2; _i = _i+2;
        a = b[3:end]
        n = n-2;
    end
    if (n==1)
        α[_i] = -a[1]/a[2]
    end
    return α
end

a = [1, 2, 3, 4, 5]
print(Bairstow(a))
