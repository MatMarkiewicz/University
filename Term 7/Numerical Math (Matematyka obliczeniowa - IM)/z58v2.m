function c = z58v2 (t, d)
  factorial = 0;
  c = d;
  factorial = 1;
  for i=1:length(d)
    c(i) = d(i)/factorial;
    factorial = factorial*i;
  endfor
endfunction
