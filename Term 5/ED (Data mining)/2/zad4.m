S = zeros(9,9);
S(1:3,1:3) = reshape(randperm(9),[3,3]);
S(4:6,4:6) = reshape(randperm(9),[3,3]);
S(7:9,7:9) = reshape(randperm(9),[3,3]);
[done,S] = fill_sudoku(S,1,4);
S