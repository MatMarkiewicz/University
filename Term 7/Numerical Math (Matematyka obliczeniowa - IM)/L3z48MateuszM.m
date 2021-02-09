function val = L3z48MateuszM(w,t)
  if length(w) == 1
    val = w(1);
   else
    val = w(1) + t*(L3z48MateuszM(w(2:end),t));
  endif
endfunction
