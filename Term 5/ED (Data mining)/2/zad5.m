sum_not_change = 0;
sum_change = 0;
N = 10000;
for i = 1:N
  sum_not_change = sum_not_change + game2(randi(3),0);
  sum_change = sum_change + game2(randi(3),1);
endfor
sum_not_change/N
sum_change/N