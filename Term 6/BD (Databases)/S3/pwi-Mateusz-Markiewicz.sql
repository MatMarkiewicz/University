-- Mateusz Markiewicz, pwi
-- Zadanie 1
CREATE VIEW public.ranking(displayname, liczba_odpowiedzi)
AS SELECT displayname, COUNT(a.id)
FROM users 
    JOIN posts a ON (users.id = a.owneruserid)
    JOIN posts b ON (b.acceptedanswerid = a.id)
GROUP BY displayname, users.id
ORDER BY 2 DESC, displayname ASC;

-- Zadanie 2
CREATE TEMP TABLE enlightened_users(userid int, upvotes int); 
INSERT INTO enlightened_users
SELECT DISTINCT users.id, upvotes
FROM users
JOIN badges ON (users.id = badges.userid)
WHERE badges.name = 'Enlightened';

CREATE TEMP TABLE number_of_comments(userid int, num int); 
INSERT INTO number_of_comments
SELECT users.id, COUNT(DISTINCT comments.id)
FROM users
    JOIN comments ON (users.id = comments.userid) 
    JOIN posts ON (posts.id = comments.postid)
WHERE EXTRACT (year FROM posts.creationdate) = 2020
GROUP BY users.id;

SELECT users.id, displayname, reputation
FROM users 
    JOIN number_of_comments ON (users.id = number_of_comments.userid)
WHERE users.id NOT IN (SELECT userid FROM enlightened_users)
    AND users.upvotes > (SELECT AVG(upvotes) FROM enlightened_users)
    AND number_of_comments.num > 1
ORDER BY users.creationdate;

-- Zadanie 3
WITH RECURSIVE rec_users(id, displayname) AS (
SELECT u.id, u.displayname 
FROM users u
    JOIN posts ON (u.id = posts.owneruserid)
WHERE posts.body LIKE '%recurrence%'
UNION
SELECT u2.id, u2.displayname
FROM users u2
    JOIN comments c ON (u2.id = c.userid)
    JOIN posts p ON (p.id = c.postid)
    JOIN rec_users ON (p.owneruserid = rec_users.id)
)
SELECT * FROM rec_users;

