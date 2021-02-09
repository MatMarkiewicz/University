function M = z53(n)
  M = zeros(n);
  for i = 1:n
    for j = 1:n
      M(i,j) = abs(n+1-i-j)+1;
    endfor
  endfor
endfunction
