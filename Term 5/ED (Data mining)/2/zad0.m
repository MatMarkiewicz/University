a = [1:1:100]
b = [1:2:99]
c = [pi*-1:pi*0.01:pi*1];
c = round(c .* 10 ^ 6) / 10^6
d = [pi*-1:pi*0.01:pi*-0.01,pi*0.01:pi*0.01:pi*1]
e = [sin(1:1:100) .* (sin(1:1:100) > 0)]
A = reshape(1:1:100,[10,10])
B = diag(1:1:100) + diag(99:-1:1,-1) + diag(99:-1:1,1)
C = triu(ones(10,10))
D = [cumsum(1:1:100);factorial(1:1:100)]
E = ones(100,100)
for i = 1:100
  for j = 1:100
    E(i,j) = mod(j,i) == 0;
  endfor
endfor

