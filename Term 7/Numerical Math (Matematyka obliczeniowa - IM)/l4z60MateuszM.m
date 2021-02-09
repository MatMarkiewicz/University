function a = l4z60MateuszM (x, y, m)
  a = zeros(4,1);
  a(1) = y(1);
  a(2) = m(1);
  h = x(2)-x(1);
  a(3) = (-6*y(1)+6*y(2)-5*m(1)*h-m(2)*h)/(4*h^2);
  a(4) = (2*y(1)-2*y(2)+m(1)*h+m(2)*h)/(4*h^3);
endfunction
