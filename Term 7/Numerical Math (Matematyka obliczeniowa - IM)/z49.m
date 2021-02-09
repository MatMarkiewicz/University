function vals = z49(w,t)
   if length(w) == 1
    vals = ones(1,length(t)) .* w(1);
   else
    vals = w(1) .+ t.*(z49(w(2:end),t));
  endif
endfunction
