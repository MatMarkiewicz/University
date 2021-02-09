function res = L3z55MateuszM(x,y)
  n = length(y);
  M = zeros(n);
  M(1:n,1) = y;
  for j = 2:n
    for i = j:n
      M(i,j) = (M(i,j-1)-M(i-1,j-1))/(x(i)-x(i-j+1));
    endfor
  endfor
  res = diag(M);
endfunction
