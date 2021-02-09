function M = L3z54MateuszM(n)
  M = zeros(n);
  for i = 1:n
    for j = 1:n
      M(i,j) = round(max(abs(i-(n+1)/2),abs(j-(n+1)/2)))
    endfor
  endfor
endfunction
