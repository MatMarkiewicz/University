function integral = l6z72MateuszM (f, k)
  T = zeros(1,k+1);
  for i=1:(k+1)
    T(i) = z71(f,2.^(i-1));
  endfor
  for j=1:k
    for i=k:-1:j
      T(i+1) = (4.^j .* T(i+1) .- T(i)) ./ (4.^j - 1);
    endfor
  endfor
  integral = T(k+1);
endfunction
