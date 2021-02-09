function MSE = z70 (n)
  x = cos(pi .* (2.*[0:n] .+ 1) ./ (2*n+2));
  y = 1./(1 + 25*x.^2);
  
  for j=2:(n+1)
    for i=(n+1):-1:j
      y(i)=(y(i)-y(i-1))/(x(i)-x(i-j+1));
    endfor
  endfor
  
  h_t = 2/(100*n);
  T = [-1:h_t:1];
  f_t = 1./(1 + 25*T.^2);
  
  w_t = zeros(1,100*n+1);
  for i = n:-1:1;
    w_t = (T - x(i)).*(w_t + y(i+1));
  endfor
  w_t = w_t + y(1);
  
  err = f_t .- w_t;
  MSE = mean(err.^2);
  
  plot(T,f_t);
  hold on;
  plot(T,w_t);
  hold on;
  plot(T,err);
  hold on;
  scatter(x, 1./(1 + 25*x.^2));
  legend('f(x)','w(x)','f(x) - w(x)');
  
endfunction