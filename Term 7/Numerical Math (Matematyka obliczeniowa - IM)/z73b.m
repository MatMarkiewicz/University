function [a,b,c,d] = z73b (x1, x2, y1, y2, M1, M2)
  h = x2-x1;
  a = y1;
  c = M1/2;
  d = (M2-M1)/(6*h);
  b = (y2-y1-h^2*c-h^3*d)/h;
endfunction
