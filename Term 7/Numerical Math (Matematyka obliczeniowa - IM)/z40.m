function [p]=z40(a,b)
  A = reshape(a,[4,1])*b;
  p1 = A(1,1)-A(2,2)-A(3,3)-A(4,4);
  p2 = A(2,1)+A(1,2)+A(3,4)-A(4,3);
  p3 = A(1,3)-A(2,4)+A(3,1)+A(4,2);
  p4 = A(1,4)+A(2,3)-A(3,2)+A(4,1);
  p=[p1 p2 p3 p4];
endfunction
