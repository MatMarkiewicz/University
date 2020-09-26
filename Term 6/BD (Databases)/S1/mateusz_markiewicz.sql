-- Mateusz Markiewicz, grupa PWI
-- Zadanie 1
SELECT CreationDate
FROM posts
  WHERE body LIKE '%Turing%'
ORDER BY CreationDate DESC;

-- Zadanie 2
SELECT id, title
FROM posts
WHERE CreationDate > '2018-10-10'
  AND EXTRACT (month FROM CreationDate) BETWEEN 9 AND 12
  AND title IS NOT NULL
  AND score >= 9
ORDER BY title ASC;

-- Zadanie 3
SELECT DISTINCT displayname, reputation
FROM users 
  JOIN posts ON (posts.owneruserid = users.id) 
  JOIN comments ON (comments.postid = posts.id)
WHERE posts.body LIKE '%deterministic%'
  AND comments.text LIKE '%deterministic%'
ORDER BY reputation DESC;

-- Zadanie 4
SELECT DISTINCT displayname 
FROM(
(SELECT displayname, users.id
FROM users JOIN posts ON (posts.owneruserid = users.id))
EXCEPT
(SELECT displayname, users.id
FROM users JOIN posts ON (posts.owneruserid = users.id)
  JOIN comments ON (comments.userid = users.id))
ORDER BY displayname) 
AS result
LIMIT 10;