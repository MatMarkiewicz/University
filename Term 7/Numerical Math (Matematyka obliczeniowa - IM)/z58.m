function d = z58 (w, t)
  n = length(w);
  C = zeros(n,n);
  fact = factorial(n);
  for i=n:-1:1
    fact = fact/(i);
    C(i,i) = fact*w(i);
    for j=i+1:n
      C(i,j) = C(i+1,j)*t/(j-i);
    endfor
  endfor
  d = sum(C,2);
endfunction
