function [x]=z45(A,b)
  [n,m] = size(A);
  x = zeros(n,1);
  d = det(A);
  for i=1:n
    B = A;
    B(:,i) = b;
    x(i) = det(B)/d;
  endfor
endfunction
