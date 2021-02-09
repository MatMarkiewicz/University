function z50()
  x = [0.01:0.001:0.10];
  y = ((((x.^8).+1).^0.5) .- 1)./(x.^8);
  y(1)
  y2 = 1 ./ ((((x.^8).+1).^0.5) .+ 1);
  y2(1)
  plot(x,y);
  hold on;
  plot(x,y2);
endfunction
