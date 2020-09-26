CREATE TABLE nodes(id integer PRIMARY KEY, geo geography, description text);
CREATE TABLE catalog(id integer PRIMARY KEY, routeLength integer);
CREATE TABLE route(version integer references catalog(id) on delete set null,
    node integer references nodes(id) on delete set null,routeOrder integer);
CREATE TABLE trip(cyclist text,date date,version integer references catalog(id) on delete set null);
CREATE VIEW accomodation(cyclist,node,date,geo) AS 
    SELECT cyclist,node,date + (routeOrder-1),geo
    FROM trip
    JOIN route USING(version)
    JOIN catalog ON(trip.version = catalog.id)
    JOIN nodes ON(route.node = nodes.id)
    WHERE routeOrder != 0 
    AND routeOrder != (routeLength-1);
CREATE VIEW routeDists(version,totalDistance) AS 
    SELECT r1.version,SUM(ST_Distance(n1.geo,n2.geo)) FROM route as r1
    JOIN route as r2 ON(r1.version = r2.version and r1.routeOrder = r2.routeOrder-1)
    JOIN nodes as n1 ON(r1.node = n1.id)
    JOIN nodes as n2 ON(r2.node = n2.id)
    GROUP BY r1.version;