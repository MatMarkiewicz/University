function c = z57 (w, t)
  n = length(w);
  C = zeros(n,n);
  for i=n:-1:1
    C(i,i) = w(i);
    for j=i+1:n
      C(i,j) = C(i+1,j)*i*t/(j-i);
    endfor
  endfor
  c = sum(C,2);
endfunction
