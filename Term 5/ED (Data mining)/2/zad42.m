first_row = randperm(9);
#rzêdy s¹ generowane wed³ug wzoru:
#(3 * (r%3) + r//3 + c)%9
S = zeros(9,9);
for row = 0:8
  for col = 0:8
    S(row+1,col+1) = first_row(mod(3*mod(row,3) + fix(row/3) + col,9)+1);
  endfor
endfor

r = randperm(3);
j = 1;
rows = 1:9;
for i = r
rows(j:j+2) = randperm(3) + 3*(i-1);
j = j+3;
endfor

r = randperm(3);
j = 1;
cols = 1:9;
for i = r
cols(j:j+2) = randperm(3) + 3*(i-1);
j = j+3;
endfor

S2 = zeros(9,9);
for i = 1:9
  for j = 1:9
    S2(i,j) = S(rows(i),cols(j));
  endfor
endfor
  
S2
sum(S2,1)
sum(S2,2)
for i = 1:3:9
  for j = 1:3:9
    sum(sum(S2(i:i+2,j:j+2)))
  endfor
endfor
