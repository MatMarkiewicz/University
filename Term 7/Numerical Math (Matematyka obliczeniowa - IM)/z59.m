function res = z59 (x, y, z)
  n = length(y);
  M = zeros(2*n);
  M(1:2:2*n,1) = y;
  M(2:2:2*n,1) = y;
  M(2:2:2*n,2) = z;
  for i=3:2:2*n
    M(i,2) = (M(i,1)-M(i-1,1))/(x(ceil(i/2))-x(ceil(i/2)-1));
  endfor
  for j = 3:2*n
    for i = j:2*n
      M(i,j) = (M(i,j-1)-M(i-1,j-1))/(x(ceil(i/2))-x(ceil((i-j+1)/2)));
    endfor
  endfor
  M
  res = diag(M);
endfunction
