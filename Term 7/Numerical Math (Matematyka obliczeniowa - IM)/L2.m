A = [1 1 2; 2 1 3; 1 4 6];
det(A)
b = [9; 13; 27];
x = inv(A)*b

x = 6;
k = 0;
while x+2.^(-k-1)!=x
    k+=1;
end
k