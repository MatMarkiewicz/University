function c = l4z57MateuszM (w, t)
  n = length(w);
  c = w;
  for i=1:n
    for j=n-1:-1:i
      c(j) = c(j) + t*c(j+1);
     endfor
  endfor
  factorial = 1;
  for i=1:n
    c(j) = c(j)/factorial;
    factorial = factorial * i;
  endfor
endfunction
