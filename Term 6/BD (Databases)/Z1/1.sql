-- DROP TABLE IF EXISTS temperatures;
-- CREATE TABLE temperatures(id SERIAL PRIMARY KEY, temp INT, timestamprange TSRANGE);
-- INSERT INTO temperatures(temp,timestamprange) 
--     SELECT round(random()*100 - 50)::int,tsrange(ts,ts + '1 second'::INTERVAL) 
--     -- FROM generate_series('2019-01-01'::timestamp,'2019-01-16'::timestamp,'1 second') as ts;
--     FROM generate_series('2019-01-01'::timestamp,'2019-12-31'::timestamp,'1 second') as ts;

DROP INDEX brin_range;

VACUUM ANALYZE temperatures;

explain analyze 
    SELECT * 
    FROM temperatures 
    WHERE timestamprange -|- '["2019-01-10 10:00:00","2019-01-10 10:00:01")';

explain analyze 
    SELECT avg(temp) 
    FROM temperatures 
    WHERE '["2019-11-29 20:00:00","2019-11-29 20:00:01")' -|- timestamprange;    

CREATE INDEX brin_range ON temperatures USING BRIN(timestamprange range_inclusion_ops) WITH (pages_per_range = 64);

VACUUM ANALYZE temperatures;

explain analyze 
    SELECT * 
    FROM temperatures 
    WHERE timestamprange -|- '["2019-01-10 10:00:00","2019-01-10 10:00:01")';

explain analyze 
    SELECT avg(temp) 
    FROM temperatures 
    WHERE '["2019-11-29 20:00:00","2019-11-29 20:00:01")' -|- timestamprange;

-- DROP TABLE IF EXISTS temperatures;
-- CREATE TABLE temperatures(id SERIAL PRIMARY KEY, temp int, timestamprange int8range);
-- INSERT INTO temperatures(temp,timestamprange) SELECT round(random()*100)::int,int8range(ts,ts+1) FROM generate_series(1,1000000) as ts;

-- vacuum analyze temperatures;
-- explain analyze select * from temperatures where timestamprange -|- int8range(543667,543668);
-- create index on temperatures using BRIN(timestamprange range_inclusion_ops) WITH (pages_per_range = 128);
-- vacuum analyze temperatures;
-- explain analyze select * from temperatures where timestamprange -|- int8range(543667,543668);

