function A = z61 (x, y, m)
  n = length(x);
  A = zeros(4,n-1);
  for i=1:n-1
    A(1:4,i) = l4z60MateuszM(x(i:i+1), y(i:i+1), m(i:i+1));
  endfor  
endfunction
