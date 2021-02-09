function integral = z71 (f, n)
  h = 2/n;
  integral = f(-1)/2;
  x = -1 + h;
  for i=1:(n-1)
    integral += f(x);
    x += h;
   endfor
   integral += f(1)/2;
   integral *= h;
endfunction
