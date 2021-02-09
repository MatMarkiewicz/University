function A = z61v2 (x, y, m)
  n = length(x);
  A = zeros(4,n-1);
  h = x(2:end) - x(1:end-1);
  A(1,1:end) = y(1:end-1);
  A(2,1:end) = m(1:end-1);
  A(3,1:end) = (-3.*y(1:end-1) + 3.*y(2:end) - 3.*m(1:end-1).*h - m(2:end).*h)./(h.^4);
  A(4,1:end) = (2.*y(1:end-1) - 2.*y(2:end) + 2.*m(1:end-1).*h + m(2:end).*h)./(h.^3);
endfunction
