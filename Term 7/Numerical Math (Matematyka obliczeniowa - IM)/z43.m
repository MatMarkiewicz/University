function [x]=z43(U,y)
  [n m] = size(U);
  A = [U y];
  for i=n:-1:1
    A(i,:) /= A(i,i);
    for j=(i-1):-1:1
      A(j,:) -= A(i,:).*A(j,i);
    endfor
  endfor
  x = A(:,n+1);
endfunction
