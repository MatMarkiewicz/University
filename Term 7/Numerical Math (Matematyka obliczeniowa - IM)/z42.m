function [y]=z42(L,b)
  [n m] = size(L);
  A = [L b];
  for i=1:n
    for j=(i+1):n
      A(j,:) -= A(i,:).*A(j,i);
    endfor
  endfor
  y = A(:,n+1);
endfunction
