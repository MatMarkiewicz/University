function M = z47 (x, y, n)
  M = zeros(n,n);
  M(1,n-1) = y;
  M(1,n) = x;
  for  i = 2:n-1
      M(i,n-i) = y;
      M(i,n-i+1) = x;
      M(i,n-i+2) = y;
   endfor
   M(n,1) = x;
   M(n,2) = y;
endfunction
