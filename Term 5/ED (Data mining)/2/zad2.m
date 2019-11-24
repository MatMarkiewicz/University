X = rand(100,1000);
Y = rand(100,1000);
tic;
dists = matrix_of_dists(X,Y);
toc
X2 = rand(100,10000);
Y2 = rand(100,1000);
tic;
dists = matrix_of_dists(X2,Y2);
toc
