
# Tools, A3

## 1

### 1

```
g.V().has('airport','code','WRO').repeat(out().simplePath()).emit().times(2).has('country','UK').dedup().values('city').order().count()
```

### 2

```
g.V().has('airport','code','WRO').repeat(out().simplePath()).emit().times(2).has('country','UK').values('city').dedup().order().count()
```

City in the UK with airports that we can reach from Wrocław in at most 2 steps. Results are ordered (alphabetically) and counted.
In the first example, results are deduplicated by the path. In the second one, results are deduplicated by name of the city.

## 2

### 1

Find all direct connections between any airport in Poland and any airport in Germany. For each connection show the airports and the distance between them. (hint: use `path()`)

    g.V().has('airport', 'country', 'PL').outE().inV().has('airport', 'country', 'DE').path().by('code').by('dist').dedup()
    
### 2

Find all direct connections between any airport in Poland and any airport in Germany such that the distance between the airports is greater than 400 miles. For each connection show the airports and the distance between them. (hint: use `where()`)

    g.V().has('airport', 'country', 'PL').outE().where(values('dist').is(gt(400))).inV().has('airport', 'country', 'DE').path().by('code').by('dist').dedup()
    
### 3

Find all direct connections between any airport in Poland that has a connection to Munich and any airport in Germany. For each connection show the airports and the distance between them. (hint: use where() twice)

    g.V().has('airport', 'country', 'PL').where(out().has('city', 'Munich')).outE().inV().has('airport', 'country', 'DE').path().by('code').by('dist').dedup()
    
### 4

What are the airports in UK (United Kingdom) you can reach from Wrocław with at most three stops? For each connection show all the airports including the intermediate ones.

    g.V().has('airport', 'code', 'WRO').repeat(out().simplePath()).emit().times(4).has('airport', 'country', 'UK').dedup().path().by('code')
    
### 5

What are the airports in UK you can reach from Wrocław with at most three stops within UK? For each connection show all the airports including the intermediate ones.

    g.V().has('airport', 'code', 'WRO').repeat(out().where(values('country').is('UK')).simplePath()).emit().times(4).path().by('code').dedup()
    
### 6

What are the codes of the airports in UK you cannot reach from Wrocław with at most three stops. (hint: e.g., you can use - (minus) operator on lists)

    g.V().has('airport', 'country', 'UK').values('code').next() - g.V().has('airport', 'code', 'WRO').repeat(out().simplePath()).emit().times(4).has('airport', 'country', 'UK').values('code').next()

### 7

For each polish airport return its code, city and the numbers of incoming and outgoing direct connections. Sort the result in descending order by the first number.

    g.V().has('airport', 'country', 'PL').order().by(inE('route').count(), desc).project('code', 'city', '#in', '#out').by('code').by('city').by(inE('route').count()).by(outE('route').count())
    
### 8

For each polish airport return the list of directly connected countries.

    g.V().has('airport', 'country', 'PL').group().by('code').by(out().values('country').dedup().order().fold())

### 9

Find ten European airports that have the biggest number of outgoing direct connections. For each of them return the airport code, city and the number of connections. (hint: start at the EU continent node and then find all EU airports)

    g.V().has('continent', 'code', 'EU').out().hasLabel('airport').order().by(outE('route').count(), desc).limit(10).project('code', 'city', '#out').by('code').by('city').by(outE('route').count())
