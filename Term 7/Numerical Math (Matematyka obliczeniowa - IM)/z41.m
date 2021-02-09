function [d]=z41(a,b)
  A = reshape(a,[4,1])*b;
  ss = sum(b.^2)
  d1 = A(1,1)+A(2,2)+A(3,3)+A(4,4);
  d2 = -A(1,2)+A(2,1)-A(3,4)+A(4,3);
  d3 = -A(1,3)+A(2,4)+A(3,1)-A(4,2);
  d4 = -A(1,4)-A(2,3)+A(3,2)+A(4,1);
  d = [d1 d2 d3 d4]./ss;
endfunction
