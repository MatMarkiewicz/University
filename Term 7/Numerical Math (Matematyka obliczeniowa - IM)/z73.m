
function err = z73 ()
  n = 20;
  h = 2/n;
  x = [-1:h:1];
  f = 1./(1.+25.*(x).^2);
  f_ = zeros(n,1);
  f__ = zeros(n-1,1);
  M0 = 2;
  Mn = 2;
  for i=1:n
    f_(i) = (f(i+1)-f(i))/(x(i+1)-x(i));
  endfor
  for i=1:n-1
    f__(i) = (f_(i+1)-f_(i))/(x(i+2)-x(i));
  endfor  
  f__ = 6*f__;
  f__(1) = f__(1) - M0/2;
  f__(n-1) = f__(n-1) - Mn/2;
  
  A = zeros(n-1,n-1);
  A(1,1) = 2;
  A(1,2) = 1/2;
  A(n-1,n-2) = 1/2;
  A(n-1,n-1) = 2;
  for i=2:n-2
    A(i,i-1) = 1/2;
    A(i,i) = 2;
    A(i,i+1) = 1/2;
  endfor  
  
  A_inv = inv(A);
  
  M = A_inv * f__;
  
  u = zeros(n-1,1);
  q = zeros(n-1,1);
  
  p = 2;
  q(1) = -1/4;
  u(1) = f__(1)/2;
  
  for i=2:n-1
    p = 1/2 * q(i-1) + 2;
    q(i) = -(1/2) / p;
    u(i) = (f__(i) - 1/2 * u(i-1))/p;
  endfor
  
  M2 = zeros(n-1,1);
  M2(n-1) = u(n-1);
  for k = n-2:-1:1
    M2(k) = u(k) + q(k)*M(k+1);  
  endfor
  
  M = zeros(n+1,1);
  M(1) = M0;
  M(n+1) = Mn;
  M(2:n) = M2; 
  
  A = zeros(n,1);
  B = zeros(n,1);
  C = zeros(n,1);
  D = zeros(n,1);
  
  for i=1:n
    [a,b,c,d] = z73b(x(i), x(i+1), f(i), f(i+1), M(i), M(i+1));
    A(i)=a;
    B(i)=b;
    C(i)=c;
    D(i)=d;
  endfor  
  
  
  T = [-1:2/(100*n):1];
  
  ft = 1./(1.+25.*(T).^2);
  
  st = zeros(1,100*n+1);
  for i=1:n
    for j=1:100
      st(100*(i-1)+j) = z73c(A(i), B(i), C(i), D(i), x(i), T(100*(i-1)+j));
    endfor  
  endfor  
  st(100*n+1) = ft(100*n+1);
  err = mean((ft - st).^2);
  
  plot(T,ft);
  hold on;
  plot(T,st);
  legend('f','s');
  

endfunction
