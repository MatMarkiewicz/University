
#=
Pracownia z anlizy numerycznej
Zadanie 3.20
Autorzy:
Artur Derechowski
Mateusz Markiewicz
=#

function LU_decomposition(A)
    n = size(A)[1]
    L = zeros(Float64,n,n)
    U = zeros(Float64,n,n)
    function sum_of_mults(A,B,i,j)
        s = Float64(0)
        for k = 1:i-1
            s += A[i,k] * B[k,j]
        end
        return s
    end
    function sum_of_mults2(A,B,i,j)
        s = Float64(0)
        for k = 1:i-1
            s += A[j,k] * B[k,i]
        end
        return s
    end
    for i = 1:n
        U[i,i] = A[i,i] - sum_of_mults(L,U,i,i)
        L[i,i] = 1
        for j = (i+1):n
            U[i,j] = A[i,j] - sum_of_mults(L,U,i,j)
            L[j,i] = 1/U[i,i] * (A[j,i] - sum_of_mults2(L,U,i,j))
        end
    end
    return L,U
end
    
function solve(L,U,B)
    n = size(L)[1]
    Y = zeros(Float64,n,1)
    X = zeros(Float64,n,1)
    Y[1] = B[1]
    function sum(L,Y,i)
        s = Float64(0)
        for j = 1:i-1
            s += L[i,j] * Y[j]
        end
        return s
    end
    for i = 2:n
        Y[i] = B[i] - sum(L,Y,i)
    end
    function sum2(U,X,i,n)
        s = Float64(0)
        for j = (i+1):n
            s += U[i,j] * X[j]
        end
        return s
    end
    X[n] = Y[n] / U[n,n]
    for i = (n-1):-1:1
        X[i] = 1/U[i,i] * (Y[i] - sum2(U,X,i,n))
    end
    return X
end 

function invertible(A)
    n = size(A)[1]
    L,U = LU_decomposition(A)
    B = zeros(Float64,1,n)
    B[1] = 1
    X = solve(L,U,B)
    for i = 2:n
        B = zeros(Float64,n)
        B[i] = 1
        X = [X (solve(L,U,B))]
    end
    return X
end
    
using LinearAlgebra

function _norm(v)
    n = 0.0
    for i = 1:length(v)
        n += v[i]*v[i]
    end
    return sqrt(n)
end

function householder(A, k)
    n = size(A)[1]
    v = zeros(Float64,(n-k) +1)
    for i = k:n
        v[i-k+1] = A[i,k]
    end
    v[1] = (Float64(sign(A[k,k]))*norm(v)) + v[1]
    vt = transpose(v)
    H = -2 * v*vt / (vt*v) + I
    ret = zeros(n,n)
    for i = 1:k-1
        ret[i,i] = 1
    end
    for i = k:n
        for j = k:n
            ret[i,j] = H[i-k+1,j-k+1]
        end
    end
    return ret
end

function QRfactorize(A) 
    n = size(A)[1]
    Q = I
    H = A
    for i = 1:n
        H = householder(A, i)
        A = H * A
        Q = Q*H
    end
    return Q,A
end   

function inv_tri(B) 
    n = size(B)[1]
    A = deepcopy(B)
    for i = 1:n
        A[i,i] = 1.0/A[i,i]
    end
    for i = n-1:-1:1
        for j = n:-1:i+1
            s = 0.0
            for k = i+1:j
                s += A[i,k]*A[k,j]
            end
            A[i,j] = - A[i,i]*s
        end
    end
    return A
end

function QRinv(A)
    Q,R = QRfactorize(A)
    R_i = inv(UpperTriangular(R))
    Q_t = transpose(Q)
    return R_i*Q_t
end


function first_norm(A)
    n = size(A)[1]
    m = 0
    for i = 1:n
        m = max(m, sum(map(abs,A[:,i])))
    end
    return m
end

function test_LU(A)
    return abs(1 - first_norm(A * invertible(A)))
end

function test_QR(A)
    return abs(1 - first_norm(A*QRinv(A)))
end

