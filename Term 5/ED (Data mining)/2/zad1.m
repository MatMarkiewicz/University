x = rand(100,1);
y = rand(100,1);
w = rand(100,1);

len = sqrt(sum(x.**2))
wmean = sum(x.*w)/sum(w)
euclidean_dist = sqrt(sum((x.-y).**2))
dot_prod = sum(x.*y)

X = rand(100,1000);
lens = sqrt(sum(X.**2))
wmeans = sum(X.*w) ./ sum(w)
euclidean_dists = sqrt(sum((X.-y).**2))
dot_prods = sum(X.*y)


