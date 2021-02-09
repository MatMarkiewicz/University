% Zad 5
A = (ones(5,5) .* [1:1:5]') .^ [0:1:4];
A_inv = inv(A);
b = [0; 7; 26; 63; 124];
alphas = A_inv * b
A* alphas

% Zad 11
a = [1 2 3];
b = [4 5 6];
c = [7 8 9];
B = [c' a' b']

% Zad 14
e = [2:1:7]./[5:2:15]

% Zad 17
C = fix(rand(3,3)*2)