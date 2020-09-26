-- Mateusz Markiewicz, pwi
-- Zadanie 1
ALTER TABLE comments ADD COLUMN lasteditdate timestamp NOT NULL DEFAULT now();
UPDATE comments SET lasteditdate = creationdate;

CREATE TABLE commenthistory(id SERIAL PRIMARY KEY, 
                            commentid integer, 
                            creationdate timestamp,
                            text text);

-- Zadanie 2
CREATE OR REPLACE FUNCTION update_validation() RETURNS TRIGGER AS $X$
    DECLARE
        led timestamp := OLD.lasteditdate;
    BEGIN
        IF (OLD.id != NEW.id 
            OR OLD.postid != NEW.postid
            OR OLD.lasteditdate != NEW.lasteditdate)
        THEN 
            RAISE EXCEPTION 'Can`t change id/postid/lasteditdate';
        END IF;
        IF (OLD.text != NEW.text)
            THEN 
                led := now();
                INSERT INTO commenthistory(commentid,creationdate,text) 
                    VALUES (OLD.id, OLD.lasteditdate, OLD.text);
        END IF;
        RETURN (OLD.id, 
                NEW.postid, 
                NEW.score, 
                NEW.text, 
                OLD.creationdate, 
                NEW.userid, 
                NEW.userdisplayname, 
                led);
    END
$X$ LANGUAGE plpgsql;

CREATE TRIGGER on_update_to_comments BEFORE UPDATE ON comments
FOR EACH ROW EXECUTE PROCEDURE update_validation();

-- Zadanie 3
CREATE OR REPLACE FUNCTION insert_validation() RETURNS TRIGGER AS $X$
    BEGIN
        RETURN (NEW.id, 
                NEW.postid, 
                NEW.score, 
                NEW.text, 
                NEW.creationdate, 
                NEW.userid, 
                NEW.userdisplayname, 
                NEW.creationdate);
    END
$X$ LANGUAGE plpgsql;

CREATE TRIGGER on_insert_to_comments BEFORE INSERT ON comments
FOR EACH ROW EXECUTE PROCEDURE insert_validation();