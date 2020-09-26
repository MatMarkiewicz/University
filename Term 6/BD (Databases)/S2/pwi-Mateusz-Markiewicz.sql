-- Mateusz Markiewicz, pwi
-- Zadanie 1
SELECT users.id, displayname, reputation, COUNT(*)
FROM users JOIN posts ON (users.id = posts.owneruserid)
    JOIN postlinks ON (postlinks.postid = posts.id)
    JOIN posts rel ON (postlinks.relatedpostid = rel.id)
WHERE linktypeid = 3 
GROUP BY users.id, displayname, reputation
ORDER BY 4 DESC, displayname ASC
LIMIT 20;

-- Zadanie 2
SELECT users.id, displayname, reputation, COUNT(comments.id), AVG(comments.score)
FROM users JOIN badges ON (badges.userid = users.id)
    LEFT JOIN posts ON (posts.owneruserid = users.id)
    LEFT JOIN comments ON (comments.postid = posts.id)
WHERE badges.name = 'Fanatic'
GROUP BY users.id, displayname, reputation
HAVING COUNT(comments.id) <= 100
ORDER BY 4 DESC, displayname ASC
LIMIT 20;

-- Zadanie 3
ALTER TABLE users ADD PRIMARY KEY (id);
ALTER TABLE badges ADD CONSTRAINT fk_userid
    FOREIGN KEY (userid) REFERENCES users(id) DEFERRABLE;
ALTER TABLE posts DROP COLUMN viewcount;
DELETE FROM posts WHERE body='' OR body IS NULL;

-- Zadanie 4
CREATE SEQUENCE public.posts_id;
SELECT setval('posts_id',max(id)) FROM posts;
ALTER TABLE posts ALTER COLUMN id
   SET DEFAULT nextval('posts_id');
ALTER SEQUENCE posts_id OWNED BY posts.id;
INSERT INTO posts(posttypeid,parentid,owneruserid,body,score,creationdate)
SELECT 3, postid, userid, text, score, creationdate FROM comments