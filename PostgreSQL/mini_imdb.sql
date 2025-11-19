-- mini_imdb.sql - generated dataset (small, realistic, balanced genres)
BEGIN;

CREATE SCHEMA imdb;

SET search_path = imdb, pg_catalog;

SET default_tablespace = '';

CREATE TABLE IF NOT EXISTS movies (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  release_year INT,
  genres JSONB,
  rating NUMERIC(3,1),
  description TEXT
);
CREATE TABLE IF NOT EXISTS actors (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  birth_date DATE
);
CREATE TABLE IF NOT EXISTS movie_cast (
  movie_id INT REFERENCES movies(id),
  actor_id INT REFERENCES actors(id),
  role VARCHAR(255),
  PRIMARY KEY (movie_id, actor_id)
);
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100),
  joined_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS reviews (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id),
  movie_id INT REFERENCES movies(id),
  review_text TEXT,
  rating NUMERIC(2,1),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Insert movies
INSERT INTO movies VALUES (1, 'The Shawshank Redemption', 1994, '["Drama"]'::jsonb, NULL, 'The Shawshank Redemption (1994) is a Drama film.');
INSERT INTO movies VALUES (2, 'The Godfather', 1972, '["Crime", "Drama"]'::jsonb, NULL, 'The Godfather (1972) is a Crime, Drama film.');
INSERT INTO movies VALUES (3, 'The Dark Knight', 2008, '["Action", "Crime", "Drama"]'::jsonb, NULL, 'The Dark Knight (2008) is a Action, Crime, Drama film.');
INSERT INTO movies VALUES (4, 'Pulp Fiction', 1994, '["Crime", "Drama"]'::jsonb, NULL, 'Pulp Fiction (1994) is a Crime, Drama film.');
INSERT INTO movies VALUES (5, 'Inception', 2010, '["Action", "Sci-Fi"]'::jsonb, NULL, 'Inception (2010) is a Action, Sci-Fi film.');
INSERT INTO movies VALUES (6, 'Forrest Gump', 1994, '["Drama", "Romance"]'::jsonb, NULL, 'Forrest Gump (1994) is a Drama, Romance film.');
INSERT INTO movies VALUES (7, 'The Matrix', 1999, '["Action", "Sci-Fi"]'::jsonb, NULL, 'The Matrix (1999) is a Action, Sci-Fi film.');
INSERT INTO movies VALUES (8, 'Interstellar', 2014, '["Adventure", "Drama", "Sci-Fi"]'::jsonb, NULL, 'Interstellar (2014) is a Adventure, Drama, Sci-Fi film.');
INSERT INTO movies VALUES (9, 'Fight Club', 1999, '["Drama"]'::jsonb, NULL, 'Fight Club (1999) is a Drama film.');
INSERT INTO movies VALUES (10, 'Titanic', 1997, '["Drama", "Romance"]'::jsonb, NULL, 'Titanic (1997) is a Drama, Romance film.');
INSERT INTO movies VALUES (11, 'The Lord of the Rings: The Fellowship of the Ring', 2001, '["Adventure", "Fantasy"]'::jsonb, NULL, 'The Lord of the Rings: The Fellowship of the Ring (2001) is a Adventure, Fantasy film.');
INSERT INTO movies VALUES (12, 'The Lord of the Rings: The Return of the King', 2003, '["Adventure", "Fantasy"]'::jsonb, NULL, 'The Lord of the Rings: The Return of the King (2003) is a Adventure, Fantasy film.');
INSERT INTO movies VALUES (13, 'Gladiator', 2000, '["Action", "Drama"]'::jsonb, NULL, 'Gladiator (2000) is a Action, Drama film.');
INSERT INTO movies VALUES (14, 'The Social Network', 2010, '["Biography", "Drama"]'::jsonb, NULL, 'The Social Network (2010) is a Biography, Drama film.');
INSERT INTO movies VALUES (15, 'Whiplash', 2014, '["Drama", "Music"]'::jsonb, NULL, 'Whiplash (2014) is a Drama, Music film.');
INSERT INTO movies VALUES (16, 'La La Land', 2016, '["Comedy", "Drama", "Music", "Romance"]'::jsonb, NULL, 'La La Land (2016) is a Comedy, Drama, Music, Romance film.');
INSERT INTO movies VALUES (17, 'The Silence of the Lambs', 1991, '["Crime", "Drama", "Thriller"]'::jsonb, NULL, 'The Silence of the Lambs (1991) is a Crime, Drama, Thriller film.');
INSERT INTO movies VALUES (18, 'Se7en', 1995, '["Crime", "Drama", "Mystery"]'::jsonb, NULL, 'Se7en (1995) is a Crime, Drama, Mystery film.');
INSERT INTO movies VALUES (19, 'The Departed', 2006, '["Crime", "Drama", "Thriller"]'::jsonb, NULL, 'The Departed (2006) is a Crime, Drama, Thriller film.');
INSERT INTO movies VALUES (20, 'The Prestige', 2006, '["Drama", "Mystery", "Sci-Fi"]'::jsonb, NULL, 'The Prestige (2006) is a Drama, Mystery, Sci-Fi film.');
INSERT INTO movies VALUES (21, 'Mad Max: Fury Road', 2015, '["Action", "Adventure", "Sci-Fi"]'::jsonb, NULL, 'Mad Max: Fury Road (2015) is a Action, Adventure, Sci-Fi film.');
INSERT INTO movies VALUES (22, 'Django Unchained', 2012, '["Drama", "Western"]'::jsonb, NULL, 'Django Unchained (2012) is a Drama, Western film.');
INSERT INTO movies VALUES (23, 'The Grand Budapest Hotel', 2014, '["Adventure", "Comedy", "Drama"]'::jsonb, NULL, 'The Grand Budapest Hotel (2014) is a Adventure, Comedy, Drama film.');
INSERT INTO movies VALUES (24, 'Her', 2013, '["Drama", "Romance", "Sci-Fi"]'::jsonb, NULL, 'Her (2013) is a Drama, Romance, Sci-Fi film.');
INSERT INTO movies VALUES (25, 'The Pianist', 2002, '["Biography", "Drama", "Music"]'::jsonb, NULL, 'The Pianist (2002) is a Biography, Drama, Music film.');
INSERT INTO movies VALUES (26, 'Blade Runner 2049', 2017, '["Action", "Drama", "Sci-Fi"]'::jsonb, NULL, 'Blade Runner 2049 (2017) is a Action, Drama, Sci-Fi film.');
INSERT INTO movies VALUES (27, 'No Country for Old Men', 2007, '["Crime", "Drama", "Thriller"]'::jsonb, NULL, 'No Country for Old Men (2007) is a Crime, Drama, Thriller film.');
INSERT INTO movies VALUES (28, 'Moonlight', 2016, '["Drama"]'::jsonb, NULL, 'Moonlight (2016) is a Drama film.');
INSERT INTO movies VALUES (29, 'Arrival', 2016, '["Drama", "Sci-Fi"]'::jsonb, NULL, 'Arrival (2016) is a Drama, Sci-Fi film.');
INSERT INTO movies VALUES (30, 'Parasite', 2019, '["Comedy", "Drama", "Thriller"]'::jsonb, NULL, 'Parasite (2019) is a Comedy, Drama, Thriller film.');

-- Insert actors
INSERT INTO actors VALUES (1, 'Morgan Freeman', '1942-11-25');
INSERT INTO actors VALUES (2, 'Tim Robbins', '1976-05-21');
INSERT INTO actors VALUES (3, 'Marlon Brando', '1953-10-14');
INSERT INTO actors VALUES (4, 'Al Pacino', '1979-11-01');
INSERT INTO actors VALUES (5, 'Christian Bale', '1971-11-18');
INSERT INTO actors VALUES (6, 'Heath Ledger', '1958-11-10');
INSERT INTO actors VALUES (7, 'John Travolta', '1970-04-26');
INSERT INTO actors VALUES (8, 'Samuel L. Jackson', '1983-07-10');
INSERT INTO actors VALUES (9, 'Leonardo DiCaprio', '1969-02-23');
INSERT INTO actors VALUES (10, 'Joseph Gordon-Levitt', '1943-03-15');
INSERT INTO actors VALUES (11, 'Tom Hanks', '1966-08-15');
INSERT INTO actors VALUES (12, 'Robin Wright', '1953-06-20');
INSERT INTO actors VALUES (13, 'Keanu Reeves', '1949-06-28');
INSERT INTO actors VALUES (14, 'Laurence Fishburne', '1985-06-24');
INSERT INTO actors VALUES (15, 'Matthew McConaughey', '1962-07-05');
INSERT INTO actors VALUES (16, 'Anne Hathaway', '1988-06-17');
INSERT INTO actors VALUES (17, 'Brad Pitt', '1975-02-11');
INSERT INTO actors VALUES (18, 'Edward Norton', '1955-08-04');
INSERT INTO actors VALUES (19, 'Kate Winslet', '1957-08-08');
INSERT INTO actors VALUES (20, 'Ian McKellen', '1949-02-02');
INSERT INTO actors VALUES (21, 'Viggo Mortensen', '1958-07-28');
INSERT INTO actors VALUES (22, 'Russell Crowe', '1979-07-08');
INSERT INTO actors VALUES (23, 'Jesse Eisenberg', '1950-06-19');
INSERT INTO actors VALUES (24, 'Andrew Garfield', '1986-06-07');
INSERT INTO actors VALUES (25, 'Miles Teller', '1988-03-16');
INSERT INTO actors VALUES (26, 'Emma Stone', '1972-08-16');
INSERT INTO actors VALUES (27, 'Jodie Foster', '1959-08-01');
INSERT INTO actors VALUES (28, 'Anthony Hopkins', '1945-07-17');
INSERT INTO actors VALUES (29, 'Kevin Spacey', '1969-04-07');
INSERT INTO actors VALUES (30, 'Jack Nicholson', '1977-06-02');
INSERT INTO actors VALUES (31, 'Tom Hardy', '1943-05-16');
INSERT INTO actors VALUES (32, 'Charlize Theron', '1978-11-22');
INSERT INTO actors VALUES (33, 'Christoph Waltz', '1970-05-18');
INSERT INTO actors VALUES (34, 'Ralph Fiennes', '1940-02-14');
INSERT INTO actors VALUES (35, 'Saoirse Ronan', '1948-05-24');
INSERT INTO actors VALUES (36, 'Adam Driver', '1963-07-12');
INSERT INTO actors VALUES (37, 'Ryan Gosling', '1942-07-02');
INSERT INTO actors VALUES (38, 'Olivia Colman', '1976-09-07');
INSERT INTO actors VALUES (39, 'Mahershala Ali', '1963-09-10');
INSERT INTO actors VALUES (40, 'Amy Adams', '1944-07-17');
INSERT INTO actors VALUES (41, 'Ellen Burstyn', '1968-09-09');
INSERT INTO actors VALUES (42, 'Oscar Isaac', '1979-11-20');
INSERT INTO actors VALUES (43, 'Harrison Ford', '1947-03-04');
INSERT INTO actors VALUES (44, 'Javier Bardem', '1965-06-26');
INSERT INTO actors VALUES (45, 'Tilda Swinton', '1961-09-12');
INSERT INTO actors VALUES (46, 'Natalie Portman', '1988-03-07');
INSERT INTO actors VALUES (47, 'Daniel Day-Lewis', '1978-09-13');
INSERT INTO actors VALUES (48, 'Philip Seymour Hoffman', '1972-01-02');
INSERT INTO actors VALUES (49, 'Frances McDormand', '1942-03-23');
INSERT INTO actors VALUES (50, 'Benedict Cumberbatch', '1961-08-17');

-- Insert movie_cast
INSERT INTO movie_cast VALUES (1, 8, 'Director');
INSERT INTO movie_cast VALUES (1, 2, 'Director');
INSERT INTO movie_cast VALUES (1, 48, 'Director');
INSERT INTO movie_cast VALUES (1, 18, 'Director');
INSERT INTO movie_cast VALUES (2, 15, 'Director');
INSERT INTO movie_cast VALUES (2, 9, 'Director');
INSERT INTO movie_cast VALUES (3, 7, 'Director');
INSERT INTO movie_cast VALUES (3, 44, 'Writer');
INSERT INTO movie_cast VALUES (3, 48, 'Writer');
INSERT INTO movie_cast VALUES (3, 35, 'Writer');
INSERT INTO movie_cast VALUES (4, 38, 'Writer');
INSERT INTO movie_cast VALUES (4, 28, 'Writer');
INSERT INTO movie_cast VALUES (5, 2, 'Writer');
INSERT INTO movie_cast VALUES (5, 6, 'Writer');
INSERT INTO movie_cast VALUES (6, 15, 'Writer');
INSERT INTO movie_cast VALUES (6, 33, 'Writer');
INSERT INTO movie_cast VALUES (7, 2, 'Producer');
INSERT INTO movie_cast VALUES (7, 36, 'Producer');
INSERT INTO movie_cast VALUES (7, 13, 'Producer');
INSERT INTO movie_cast VALUES (7, 46, 'Producer');
INSERT INTO movie_cast VALUES (8, 45, 'Producer');
INSERT INTO movie_cast VALUES (8, 35, 'Producer');
INSERT INTO movie_cast VALUES (8, 27, 'Producer');
INSERT INTO movie_cast VALUES (8, 15, 'Producer');
INSERT INTO movie_cast VALUES (9, 38, 'Producer');
INSERT INTO movie_cast VALUES (9, 18, 'Producer');
INSERT INTO movie_cast VALUES (9, 1, 'Co-star');
INSERT INTO movie_cast VALUES (10, 45, 'Co-star');
INSERT INTO movie_cast VALUES (10, 28, 'Co-star');
INSERT INTO movie_cast VALUES (11, 18, 'Co-star');
INSERT INTO movie_cast VALUES (11, 10, 'Co-star');
INSERT INTO movie_cast VALUES (11, 14, 'Co-star');
INSERT INTO movie_cast VALUES (12, 7, 'Co-star');
INSERT INTO movie_cast VALUES (12, 6, 'Co-star');
INSERT INTO movie_cast VALUES (12, 25, 'Co-star');
INSERT INTO movie_cast VALUES (13, 23, 'Co-star');
INSERT INTO movie_cast VALUES (13, 39, 'Co-star');
INSERT INTO movie_cast VALUES (14, 3, 'Co-star');
INSERT INTO movie_cast VALUES (14, 47, 'Co-star');
INSERT INTO movie_cast VALUES (14, 30, 'Start');
INSERT INTO movie_cast VALUES (15, 8, 'Start');
INSERT INTO movie_cast VALUES (15, 25, 'Start');
INSERT INTO movie_cast VALUES (15, 6, 'Start');
INSERT INTO movie_cast VALUES (15, 36, 'Start');
INSERT INTO movie_cast VALUES (16, 41, 'Start');
INSERT INTO movie_cast VALUES (16, 40, 'Start');
INSERT INTO movie_cast VALUES (16, 24, 'Start');
INSERT INTO movie_cast VALUES (17, 13, 'Start');
INSERT INTO movie_cast VALUES (17, 46, 'Start');
INSERT INTO movie_cast VALUES (17, 5, 'Start');
INSERT INTO movie_cast VALUES (17, 3, 'Start');
INSERT INTO movie_cast VALUES (18, 15, 'Start');
INSERT INTO movie_cast VALUES (18, 50, 'Start');
INSERT INTO movie_cast VALUES (18, 19, 'Supporting');
INSERT INTO movie_cast VALUES (18, 6, 'Supporting');
INSERT INTO movie_cast VALUES (19, 7, 'Supporting');
INSERT INTO movie_cast VALUES (19, 25, 'Supporting');
INSERT INTO movie_cast VALUES (20, 30, 'Supporting');
INSERT INTO movie_cast VALUES (20, 41, 'Supporting');
INSERT INTO movie_cast VALUES (20, 24, 'Supporting');
INSERT INTO movie_cast VALUES (21, 24, 'Supporting');
INSERT INTO movie_cast VALUES (21, 23, 'Supporting');
INSERT INTO movie_cast VALUES (22, 43, 'Supporting');
INSERT INTO movie_cast VALUES (22, 18, 'Supporting');
INSERT INTO movie_cast VALUES (23, 44, 'Supporting');
INSERT INTO movie_cast VALUES (23, 42, 'Supporting');
INSERT INTO movie_cast VALUES (23, 5, 'Supporting');
INSERT INTO movie_cast VALUES (23, 39, 'Supporting');
INSERT INTO movie_cast VALUES (24, 11, 'Supporting');
INSERT INTO movie_cast VALUES (24, 35, 'Supporting');
INSERT INTO movie_cast VALUES (24, 47, 'Supporting');
INSERT INTO movie_cast VALUES (24, 16, 'Protagonist');
INSERT INTO movie_cast VALUES (25, 30, 'Protagonist');
INSERT INTO movie_cast VALUES (25, 25, 'Protagonist');
INSERT INTO movie_cast VALUES (26, 41, 'Protagonist');
INSERT INTO movie_cast VALUES (26, 45, 'Protagonist');
INSERT INTO movie_cast VALUES (26, 36, 'Protagonist');
INSERT INTO movie_cast VALUES (27, 44, 'Protagonist');
INSERT INTO movie_cast VALUES (27, 21, 'Protagonist');
INSERT INTO movie_cast VALUES (28, 15, 'Protagonist');
INSERT INTO movie_cast VALUES (28, 3, 'Protagonist');
INSERT INTO movie_cast VALUES (29, 26, 'Protagonist');
INSERT INTO movie_cast VALUES (29, 18, 'Protagonist');
INSERT INTO movie_cast VALUES (29, 5, 'Protagonist');
INSERT INTO movie_cast VALUES (30, 37, 'Protagonist');
INSERT INTO movie_cast VALUES (30, 46, 'Protagonist');

-- Insert users
INSERT INTO users VALUES (1, 'user01', '2022-08-05 12:00:00');
INSERT INTO users VALUES (2, 'user02', '2022-10-17 12:00:00');
INSERT INTO users VALUES (3, 'user03', '2022-03-11 12:00:00');
INSERT INTO users VALUES (4, 'user04', '2022-10-11 12:00:00');
INSERT INTO users VALUES (5, 'user05', '2022-03-13 12:00:00');
INSERT INTO users VALUES (6, 'user06', '2022-10-24 12:00:00');
INSERT INTO users VALUES (7, 'user07', '2022-05-19 12:00:00');
INSERT INTO users VALUES (8, 'user08', '2022-06-17 12:00:00');
INSERT INTO users VALUES (9, 'user09', '2022-09-18 12:00:00');
INSERT INTO users VALUES (10, 'user10', '2022-08-23 12:00:00');
INSERT INTO users VALUES (11, 'user11', '2022-10-10 12:00:00');
INSERT INTO users VALUES (12, 'user12', '2022-08-27 12:00:00');
INSERT INTO users VALUES (13, 'user13', '2022-01-12 12:00:00');
INSERT INTO users VALUES (14, 'user14', '2022-06-22 12:00:00');
INSERT INTO users VALUES (15, 'user15', '2022-02-14 12:00:00');
INSERT INTO users VALUES (16, 'user16', '2022-10-10 12:00:00');
INSERT INTO users VALUES (17, 'user17', '2022-12-28 12:00:00');
INSERT INTO users VALUES (18, 'user18', '2022-12-21 12:00:00');
INSERT INTO users VALUES (19, 'user19', '2022-01-20 12:00:00');
INSERT INTO users VALUES (20, 'user20', '2022-08-09 12:00:00');

-- Insert reviews
INSERT INTO reviews VALUES (1, 11, 7, 'Predictable plot but well executed.', 7.9, '2023-07-21 14:09:16');
INSERT INTO reviews VALUES (2, 18, 18, 'A powerful story with emotional depth.', 6.2, '2023-10-14 18:25:23');
INSERT INTO reviews VALUES (3, 17, 16, 'Complex, thought-provoking, and rewarding.', 5.4, '2023-01-28 03:09:40');
INSERT INTO reviews VALUES (4, 20, 3, 'The pacing felt off but the acting saved it.', 6.7, '2023-10-15 16:16:35');
INSERT INTO reviews VALUES (5, 18, 25, 'Great chemistry between leads.', 6.2, '2023-11-11 03:18:27');
INSERT INTO reviews VALUES (6, 1, 24, 'Terrific soundtrack and memorable scenes.', 8.9, '2023-05-17 05:32:58');
INSERT INTO reviews VALUES (7, 17, 20, 'A masterpiece that stands the test of time. A little overrated in my opinion. The ending was surprising and well done.', 5.9, '2023-06-25 05:34:49');
INSERT INTO reviews VALUES (8, 1, 4, 'Stunning visuals and incredible performances. One of the best in its genre. The ending was surprising and well done.', 9.2, '2023-05-08 01:15:56');
INSERT INTO reviews VALUES (9, 3, 25, 'A cinematic triumph \u2014 every frame matters.', 7.4, '2023-03-05 21:30:35');
INSERT INTO reviews VALUES (10, 17, 28, 'Terrific soundtrack and memorable scenes. Heartfelt and genuinely moving. Brilliant direction and superb performances.', 7.7, '2023-04-18 23:44:12');
INSERT INTO reviews VALUES (11, 15, 29, 'A flawed gem; worth the watch.', 7.3, '2023-02-08 07:04:21');
INSERT INTO reviews VALUES (12, 18, 8, 'Stunning visuals and incredible performances.', 7.6, '2023-01-03 22:40:03');
INSERT INTO reviews VALUES (13, 2, 28, 'Excellent world-building and atmosphere.', 6.5, '2023-09-08 08:42:31');
INSERT INTO reviews VALUES (14, 5, 24, 'Complex, thought-provoking, and rewarding. An innovative film with daring choices.', 9.2, '2023-10-19 15:15:50');
INSERT INTO reviews VALUES (15, 4, 4, 'Enjoyable but a bit slow in the middle. The pacing felt off but the acting saved it. One of the best in its genre.', 8.0, '2023-06-14 13:29:55');
INSERT INTO reviews VALUES (16, 13, 24, 'A powerful story with emotional depth. Complex, thought-provoking, and rewarding.', 6.5, '2023-02-08 06:12:34');
INSERT INTO reviews VALUES (17, 6, 9, 'Excellent world-building and atmosphere. A masterpiece that stands the test of time. Stunning visuals and incredible performances.', 7.1, '2023-02-15 17:06:03');
INSERT INTO reviews VALUES (18, 8, 6, 'Heartfelt and genuinely moving.', 6.8, '2023-08-07 12:57:03');
INSERT INTO reviews VALUES (19, 1, 13, 'The ending was surprising and well done. A powerful story with emotional depth. An innovative film with daring choices.', 6.2, '2023-08-10 13:44:46');
INSERT INTO reviews VALUES (20, 10, 7, 'Enjoyable but a bit slow in the middle. One of the best in its genre.', 9.4, '2023-10-24 17:03:47');
INSERT INTO reviews VALUES (21, 19, 16, 'Stunning visuals and incredible performances.', 7.3, '2023-09-06 01:32:05');
INSERT INTO reviews VALUES (22, 20, 3, 'A flawed gem; worth the watch.', 8.0, '2023-04-13 03:56:36');
INSERT INTO reviews VALUES (23, 20, 2, 'A cinematic triumph \u2014 every frame matters. An innovative film with daring choices.', 7.8, '2023-07-22 18:36:33');
INSERT INTO reviews VALUES (24, 11, 8, 'Stunning visuals and incredible performances. A masterpiece that stands the test of time.', 6.2, '2023-03-22 20:19:29');
INSERT INTO reviews VALUES (25, 15, 20, 'A powerful story with emotional depth. Brilliant direction and superb performances.', 9.5, '2023-02-03 17:13:32');
INSERT INTO reviews VALUES (26, 3, 29, 'Terrific soundtrack and memorable scenes. A visual feast with a strong story. A masterpiece that stands the test of time.', 6.1, '2023-05-06 14:53:34');
INSERT INTO reviews VALUES (27, 18, 10, 'Excellent world-building and atmosphere.', 9.2, '2023-02-05 08:07:56');
INSERT INTO reviews VALUES (28, 5, 9, 'A cinematic triumph \u2014 every frame matters. A visual feast with a strong story. The ending was surprising and well done.', 6.3, '2023-04-23 10:13:43');
INSERT INTO reviews VALUES (29, 9, 29, 'Enjoyable but a bit slow in the middle. A masterpiece that stands the test of time.', 9.1, '2023-01-03 20:27:53');
INSERT INTO reviews VALUES (30, 11, 25, 'Complex, thought-provoking, and rewarding. Excellent world-building and atmosphere. A masterpiece that stands the test of time.', 5.6, '2023-05-06 23:28:35');
INSERT INTO reviews VALUES (31, 4, 3, 'A flawed gem; worth the watch. Excellent world-building and atmosphere.', 9.3, '2023-12-05 17:02:53');
INSERT INTO reviews VALUES (32, 5, 14, 'Predictable plot but well executed.', 5.6, '2023-05-12 01:57:22');
INSERT INTO reviews VALUES (33, 4, 12, 'Not my cup of tea, but I see why others love it.', 8.5, '2023-07-20 23:09:59');
INSERT INTO reviews VALUES (34, 6, 29, 'Predictable plot but well executed. A cinematic triumph \u2014 every frame matters.', 6.9, '2023-03-24 10:50:59');
INSERT INTO reviews VALUES (35, 6, 26, 'An innovative film with daring choices.', 8.2, '2023-07-28 01:54:30');
INSERT INTO reviews VALUES (36, 15, 12, 'A little overrated in my opinion. A cinematic triumph \u2014 every frame matters.', 6.4, '2023-04-08 00:42:12');
INSERT INTO reviews VALUES (37, 3, 25, 'A little overrated in my opinion. A masterpiece that stands the test of time. The pacing felt off but the acting saved it.', 6.3, '2023-11-17 12:43:53');
INSERT INTO reviews VALUES (38, 9, 6, 'A little overrated in my opinion. Complex, thought-provoking, and rewarding.', 7.6, '2023-05-02 03:38:27');
INSERT INTO reviews VALUES (39, 20, 17, 'A masterpiece that stands the test of time. A visual feast with a strong story.', 5.5, '2023-10-07 08:02:45');
INSERT INTO reviews VALUES (40, 18, 22, 'Stunning visuals and incredible performances. A little overrated in my opinion.', 8.2, '2023-12-24 21:12:23');
INSERT INTO reviews VALUES (41, 20, 11, 'Complex, thought-provoking, and rewarding. A little overrated in my opinion. Heartfelt and genuinely moving.', 8.0, '2023-02-24 09:32:19');
INSERT INTO reviews VALUES (42, 10, 18, 'One of the best in its genre.', 5.6, '2023-07-22 12:43:47');
INSERT INTO reviews VALUES (43, 19, 10, 'One of the best in its genre. A little overrated in my opinion. Great chemistry between leads.', 6.8, '2023-01-10 09:13:27');
INSERT INTO reviews VALUES (44, 15, 15, 'Terrific soundtrack and memorable scenes.', 8.0, '2023-09-16 23:10:42');
INSERT INTO reviews VALUES (45, 17, 22, 'An innovative film with daring choices.', 7.8, '2023-06-03 07:43:19');
INSERT INTO reviews VALUES (46, 5, 1, 'A flawed gem; worth the watch. An innovative film with daring choices. Heartfelt and genuinely moving.', 5.2, '2023-08-20 02:29:26');
INSERT INTO reviews VALUES (47, 16, 13, 'Complex, thought-provoking, and rewarding.', 6.1, '2023-11-23 00:57:48');
INSERT INTO reviews VALUES (48, 8, 6, 'The pacing felt off but the acting saved it.', 8.6, '2023-12-17 14:03:35');
INSERT INTO reviews VALUES (49, 15, 5, 'One of the best in its genre. A visual feast with a strong story.', 8.6, '2023-11-17 17:38:20');
INSERT INTO reviews VALUES (50, 14, 27, 'A cinematic triumph \u2014 every frame matters. Predictable plot but well executed.', 9.1, '2023-08-06 23:55:30');
INSERT INTO reviews VALUES (51, 9, 25, 'Terrific soundtrack and memorable scenes.', 8.5, '2023-08-21 07:17:28');
INSERT INTO reviews VALUES (52, 8, 9, 'A powerful story with emotional depth. An innovative film with daring choices.', 6.5, '2023-09-03 04:09:14');
INSERT INTO reviews VALUES (53, 3, 14, 'Heartfelt and genuinely moving. A flawed gem; worth the watch.', 6.8, '2023-09-15 13:03:13');
INSERT INTO reviews VALUES (54, 1, 28, 'Heartfelt and genuinely moving. Complex, thought-provoking, and rewarding.', 9.0, '2023-10-13 15:00:22');
INSERT INTO reviews VALUES (55, 18, 24, 'The ending was surprising and well done. A masterpiece that stands the test of time.', 8.3, '2023-10-08 15:14:17');
INSERT INTO reviews VALUES (56, 13, 11, 'One of the best in its genre.', 8.0, '2023-07-24 05:53:29');
INSERT INTO reviews VALUES (57, 18, 1, 'Complex, thought-provoking, and rewarding. A powerful story with emotional depth. Great chemistry between leads.', 9.1, '2023-10-19 21:01:05');
INSERT INTO reviews VALUES (58, 6, 2, 'A cinematic triumph \u2014 every frame matters. Complex, thought-provoking, and rewarding.', 6.2, '2023-06-07 14:20:21');
INSERT INTO reviews VALUES (59, 9, 27, 'Stunning visuals and incredible performances.', 5.4, '2023-01-24 17:03:22');
INSERT INTO reviews VALUES (60, 2, 25, 'A powerful story with emotional depth.', 5.1, '2023-04-07 00:39:09');
INSERT INTO reviews VALUES (61, 16, 22, 'Not my cup of tea, but I see why others love it. The pacing felt off but the acting saved it.', 5.5, '2023-04-15 22:16:49');
INSERT INTO reviews VALUES (62, 6, 10, 'Heartfelt and genuinely moving. An innovative film with daring choices.', 5.5, '2023-01-10 18:43:58');
INSERT INTO reviews VALUES (63, 3, 19, 'One of the best in its genre. The pacing felt off but the acting saved it.', 8.1, '2023-11-08 03:44:49');
INSERT INTO reviews VALUES (64, 19, 26, 'A little overrated in my opinion. A masterpiece that stands the test of time. Complex, thought-provoking, and rewarding.', 5.2, '2023-09-14 21:23:04');
INSERT INTO reviews VALUES (65, 16, 4, 'Not my cup of tea, but I see why others love it. A visual feast with a strong story.', 7.0, '2023-06-21 14:45:09');
INSERT INTO reviews VALUES (66, 9, 20, 'A flawed gem; worth the watch. A cinematic triumph \u2014 every frame matters. A little overrated in my opinion.', 8.6, '2023-09-25 15:29:27');
INSERT INTO reviews VALUES (67, 8, 27, 'One of the best in its genre. Heartfelt and genuinely moving. A little overrated in my opinion.', 9.2, '2023-05-15 07:48:29');
INSERT INTO reviews VALUES (68, 1, 16, 'A little overrated in my opinion. A cinematic triumph \u2014 every frame matters.', 8.8, '2023-03-16 06:22:51');
INSERT INTO reviews VALUES (69, 20, 23, 'Complex, thought-provoking, and rewarding.', 9.0, '2023-09-01 16:12:05');
INSERT INTO reviews VALUES (70, 16, 18, 'A masterpiece that stands the test of time. Stunning visuals and incredible performances.', 8.4, '2023-12-16 20:45:31');
INSERT INTO reviews VALUES (71, 10, 8, 'Excellent world-building and atmosphere. A visual feast with a strong story.', 6.8, '2023-04-10 21:37:23');
INSERT INTO reviews VALUES (72, 12, 14, 'Terrific soundtrack and memorable scenes. A cinematic triumph \u2014 every frame matters.', 9.5, '2023-09-11 11:44:29');
INSERT INTO reviews VALUES (73, 8, 4, 'Not my cup of tea, but I see why others love it. An innovative film with daring choices. A flawed gem; worth the watch.', 8.2, '2023-06-04 23:34:48');
INSERT INTO reviews VALUES (74, 16, 9, 'Terrific soundtrack and memorable scenes.', 8.3, '2023-09-20 09:06:53');
INSERT INTO reviews VALUES (75, 8, 12, 'Enjoyable but a bit slow in the middle.', 5.8, '2023-01-23 17:08:17');
INSERT INTO reviews VALUES (76, 18, 10, 'A flawed gem; worth the watch.', 8.1, '2023-03-21 15:06:55');
INSERT INTO reviews VALUES (77, 10, 16, 'The pacing felt off but the acting saved it. Stunning visuals and incredible performances.', 7.2, '2023-06-06 01:16:55');
INSERT INTO reviews VALUES (78, 13, 16, 'Terrific soundtrack and memorable scenes. Stunning visuals and incredible performances. Predictable plot but well executed.', 5.3, '2023-11-22 01:09:09');
INSERT INTO reviews VALUES (79, 4, 18, 'Heartfelt and genuinely moving. Great chemistry between leads. A flawed gem; worth the watch.', 8.4, '2023-10-20 19:14:49');
INSERT INTO reviews VALUES (80, 10, 28, 'The pacing felt off but the acting saved it. An innovative film with daring choices. A flawed gem; worth the watch.', 7.6, '2023-07-10 18:39:03');
INSERT INTO reviews VALUES (81, 9, 22, 'Complex, thought-provoking, and rewarding.', 5.4, '2023-04-06 17:04:10');
INSERT INTO reviews VALUES (82, 15, 23, 'Great chemistry between leads. Stunning visuals and incredible performances.', 7.7, '2023-05-02 07:18:45');
INSERT INTO reviews VALUES (83, 8, 30, 'Complex, thought-provoking, and rewarding.', 6.2, '2023-11-19 21:51:59');
INSERT INTO reviews VALUES (84, 4, 18, 'Terrific soundtrack and memorable scenes.', 6.0, '2023-03-09 04:04:03');
INSERT INTO reviews VALUES (85, 20, 24, 'Heartfelt and genuinely moving. A cinematic triumph \u2014 every frame matters.', 8.7, '2023-05-15 03:29:44');
INSERT INTO reviews VALUES (86, 17, 18, 'A little overrated in my opinion. A cinematic triumph \u2014 every frame matters. A masterpiece that stands the test of time.', 7.2, '2023-02-20 01:56:27');
INSERT INTO reviews VALUES (87, 3, 8, 'A flawed gem; worth the watch. Enjoyable but a bit slow in the middle.', 9.3, '2023-10-19 00:48:43');
INSERT INTO reviews VALUES (88, 6, 16, 'The ending was surprising and well done. Stunning visuals and incredible performances. One of the best in its genre.', 7.3, '2023-08-09 05:37:27');
INSERT INTO reviews VALUES (89, 12, 14, 'The ending was surprising and well done. Terrific soundtrack and memorable scenes. Heartfelt and genuinely moving.', 6.5, '2023-11-04 05:21:26');
INSERT INTO reviews VALUES (90, 18, 2, 'A visual feast with a strong story. A masterpiece that stands the test of time.', 7.0, '2023-06-09 10:07:49');
INSERT INTO reviews VALUES (91, 18, 15, 'Great chemistry between leads. Enjoyable but a bit slow in the middle.', 6.9, '2023-04-17 11:39:48');
INSERT INTO reviews VALUES (92, 7, 9, 'One of the best in its genre.', 7.5, '2023-05-15 22:31:07');
INSERT INTO reviews VALUES (93, 8, 23, 'The pacing felt off but the acting saved it.', 5.7, '2023-09-01 17:26:05');
INSERT INTO reviews VALUES (94, 15, 4, 'A cinematic triumph \u2014 every frame matters. Complex, thought-provoking, and rewarding. The ending was surprising and well done.', 7.9, '2023-03-16 22:18:32');
INSERT INTO reviews VALUES (95, 16, 8, 'A powerful story with emotional depth. Stunning visuals and incredible performances. A cinematic triumph \u2014 every frame matters.', 7.1, '2023-03-13 06:58:38');
INSERT INTO reviews VALUES (96, 14, 11, 'A flawed gem; worth the watch. One of the best in its genre.', 9.2, '2023-09-09 00:18:46');
INSERT INTO reviews VALUES (97, 16, 28, 'Heartfelt and genuinely moving. Great chemistry between leads. A little overrated in my opinion.', 5.7, '2023-09-16 11:21:35');
INSERT INTO reviews VALUES (98, 7, 23, 'The ending was surprising and well done. Heartfelt and genuinely moving. A flawed gem; worth the watch.', 6.1, '2023-07-08 13:02:20');
INSERT INTO reviews VALUES (99, 5, 16, 'Great chemistry between leads.', 9.3, '2023-03-17 18:21:55');
INSERT INTO reviews VALUES (100, 4, 17, 'A powerful story with emotional depth. Stunning visuals and incredible performances. The ending was surprising and well done.', 9.1, '2023-01-24 04:26:55');
INSERT INTO reviews VALUES (101, 9, 11, 'Excellent world-building and atmosphere. Heartfelt and genuinely moving. A little overrated in my opinion.', 7.8, '2023-07-21 02:54:21');
INSERT INTO reviews VALUES (102, 16, 28, 'Predictable plot but well executed. Stunning visuals and incredible performances.', 7.4, '2023-10-03 07:40:43');
INSERT INTO reviews VALUES (103, 14, 4, 'Terrific soundtrack and memorable scenes. A masterpiece that stands the test of time. Enjoyable but a bit slow in the middle.', 8.4, '2023-12-28 03:28:10');
INSERT INTO reviews VALUES (104, 11, 26, 'Complex, thought-provoking, and rewarding. A flawed gem; worth the watch. Not my cup of tea, but I see why others love it.', 5.3, '2023-06-12 13:09:15');
INSERT INTO reviews VALUES (105, 6, 6, 'A powerful story with emotional depth. Predictable plot but well executed. Great chemistry between leads.', 5.4, '2023-07-20 21:15:31');
INSERT INTO reviews VALUES (106, 9, 15, 'Excellent world-building and atmosphere. Not my cup of tea, but I see why others love it. Stunning visuals and incredible performances.', 6.1, '2023-01-26 14:57:18');
INSERT INTO reviews VALUES (107, 15, 12, 'Terrific soundtrack and memorable scenes. An innovative film with daring choices.', 9.4, '2023-05-21 13:44:16');
INSERT INTO reviews VALUES (108, 13, 28, 'Terrific soundtrack and memorable scenes. A masterpiece that stands the test of time.', 7.2, '2023-04-13 18:22:36');
INSERT INTO reviews VALUES (109, 13, 9, 'The ending was surprising and well done. Terrific soundtrack and memorable scenes. Predictable plot but well executed.', 5.0, '2023-11-25 23:03:58');
INSERT INTO reviews VALUES (110, 20, 26, 'A powerful story with emotional depth. The pacing felt off but the acting saved it. Enjoyable but a bit slow in the middle.', 6.6, '2023-11-07 19:16:43');
INSERT INTO reviews VALUES (111, 10, 26, 'A little overrated in my opinion. Complex, thought-provoking, and rewarding.', 7.0, '2023-10-12 23:08:05');
INSERT INTO reviews VALUES (112, 6, 7, 'Not my cup of tea, but I see why others love it. A cinematic triumph \u2014 every frame matters.', 5.6, '2023-09-12 16:32:58');
INSERT INTO reviews VALUES (113, 16, 26, 'Predictable plot but well executed.', 6.3, '2023-06-26 03:29:04');
INSERT INTO reviews VALUES (114, 13, 28, 'The pacing felt off but the acting saved it. Great chemistry between leads. Brilliant direction and superb performances.', 8.6, '2023-06-03 12:00:16');
INSERT INTO reviews VALUES (115, 9, 19, 'A masterpiece that stands the test of time. Excellent world-building and atmosphere.', 6.7, '2023-11-12 03:43:14');
INSERT INTO reviews VALUES (116, 11, 30, 'Terrific soundtrack and memorable scenes. Complex, thought-provoking, and rewarding. The pacing felt off but the acting saved it.', 7.7, '2023-11-03 20:52:29');
INSERT INTO reviews VALUES (117, 5, 2, 'A powerful story with emotional depth. Heartfelt and genuinely moving. Great chemistry between leads.', 9.3, '2023-05-16 03:06:15');
INSERT INTO reviews VALUES (118, 12, 22, 'A powerful story with emotional depth. Complex, thought-provoking, and rewarding. The pacing felt off but the acting saved it.', 9.3, '2023-12-18 13:37:47');
INSERT INTO reviews VALUES (119, 16, 20, 'Great chemistry between leads. Predictable plot but well executed.', 6.8, '2023-05-02 22:23:13');
INSERT INTO reviews VALUES (120, 12, 4, 'A cinematic triumph \u2014 every frame matters. An innovative film with daring choices.', 9.4, '2023-06-18 20:22:03');
INSERT INTO reviews VALUES (121, 4, 28, 'A masterpiece that stands the test of time. Enjoyable but a bit slow in the middle. A little overrated in my opinion.', 8.7, '2023-02-22 06:41:40');
INSERT INTO reviews VALUES (122, 8, 5, 'Predictable plot but well executed.', 8.5, '2023-04-03 17:13:37');
INSERT INTO reviews VALUES (123, 11, 25, 'Excellent world-building and atmosphere.', 5.7, '2023-10-01 08:54:09');
INSERT INTO reviews VALUES (124, 9, 26, 'Predictable plot but well executed. A flawed gem; worth the watch.', 5.8, '2023-11-28 00:08:00');
INSERT INTO reviews VALUES (125, 11, 1, 'Stunning visuals and incredible performances.', 5.8, '2023-01-05 23:26:33');
INSERT INTO reviews VALUES (126, 16, 15, 'One of the best in its genre.', 8.5, '2023-09-19 03:28:32');
INSERT INTO reviews VALUES (127, 2, 24, 'Enjoyable but a bit slow in the middle.', 8.5, '2023-11-17 09:29:41');
INSERT INTO reviews VALUES (128, 16, 28, 'Stunning visuals and incredible performances. One of the best in its genre.', 6.8, '2023-11-04 15:45:58');
INSERT INTO reviews VALUES (129, 11, 20, 'A little overrated in my opinion. Heartfelt and genuinely moving. A visual feast with a strong story.', 5.7, '2023-03-09 19:40:37');
INSERT INTO reviews VALUES (130, 10, 15, 'Excellent world-building and atmosphere. An innovative film with daring choices. Complex, thought-provoking, and rewarding.', 7.3, '2023-07-04 22:07:54');
INSERT INTO reviews VALUES (131, 15, 29, 'The pacing felt off but the acting saved it. A little overrated in my opinion. Complex, thought-provoking, and rewarding.', 6.0, '2023-06-27 14:25:26');
INSERT INTO reviews VALUES (132, 11, 22, 'Stunning visuals and incredible performances.', 6.1, '2023-03-22 15:04:05');
INSERT INTO reviews VALUES (133, 14, 4, 'Excellent world-building and atmosphere. One of the best in its genre. A little overrated in my opinion.', 8.4, '2023-06-26 04:35:03');
INSERT INTO reviews VALUES (134, 4, 14, 'Enjoyable but a bit slow in the middle. Terrific soundtrack and memorable scenes. A flawed gem; worth the watch.', 6.6, '2023-11-25 13:55:58');
INSERT INTO reviews VALUES (135, 12, 4, 'Brilliant direction and superb performances.', 7.6, '2023-04-05 21:30:14');
INSERT INTO reviews VALUES (136, 18, 12, 'One of the best in its genre. Excellent world-building and atmosphere. A masterpiece that stands the test of time.', 5.5, '2023-05-19 07:51:27');
INSERT INTO reviews VALUES (137, 20, 30, 'Terrific soundtrack and memorable scenes. A little overrated in my opinion. Brilliant direction and superb performances.', 8.0, '2023-12-09 00:11:17');
INSERT INTO reviews VALUES (138, 1, 6, 'A masterpiece that stands the test of time. Stunning visuals and incredible performances. A visual feast with a strong story.', 8.9, '2023-10-22 12:04:09');
INSERT INTO reviews VALUES (139, 7, 13, 'A flawed gem; worth the watch. Stunning visuals and incredible performances.', 6.9, '2023-06-06 11:19:46');
INSERT INTO reviews VALUES (140, 2, 5, 'Complex, thought-provoking, and rewarding. The ending was surprising and well done.', 5.7, '2023-10-02 21:05:17');
INSERT INTO reviews VALUES (141, 20, 15, 'The pacing felt off but the acting saved it. Terrific soundtrack and memorable scenes.', 6.9, '2023-04-25 16:07:22');
INSERT INTO reviews VALUES (142, 19, 16, 'A masterpiece that stands the test of time.', 7.4, '2023-05-02 07:25:38');
INSERT INTO reviews VALUES (143, 7, 10, 'A masterpiece that stands the test of time.', 9.3, '2023-03-25 08:18:20');
INSERT INTO reviews VALUES (144, 16, 24, 'Excellent world-building and atmosphere. Brilliant direction and superb performances. Stunning visuals and incredible performances.', 6.9, '2023-03-13 17:45:14');
INSERT INTO reviews VALUES (145, 13, 28, 'A flawed gem; worth the watch. Complex, thought-provoking, and rewarding.', 8.3, '2023-07-01 14:58:04');
INSERT INTO reviews VALUES (146, 19, 13, 'Not my cup of tea, but I see why others love it. Great chemistry between leads.', 8.2, '2023-07-10 03:25:01');
INSERT INTO reviews VALUES (147, 12, 3, 'Stunning visuals and incredible performances. Heartfelt and genuinely moving. Terrific soundtrack and memorable scenes.', 7.0, '2023-02-08 13:37:25');
INSERT INTO reviews VALUES (148, 11, 8, 'A visual feast with a strong story. An innovative film with daring choices. Brilliant direction and superb performances.', 6.5, '2023-03-03 16:40:07');
INSERT INTO reviews VALUES (149, 12, 24, 'A cinematic triumph \u2014 every frame matters.', 9.3, '2023-11-27 04:15:06');
INSERT INTO reviews VALUES (150, 7, 6, 'Great chemistry between leads. A flawed gem; worth the watch.', 7.7, '2023-11-03 05:49:40');
INSERT INTO reviews VALUES (151, 19, 15, 'A little overrated in my opinion. A powerful story with emotional depth. Great chemistry between leads.', 8.1, '2023-10-21 20:39:20');
INSERT INTO reviews VALUES (152, 3, 16, 'A visual feast with a strong story. Stunning visuals and incredible performances.', 7.0, '2023-05-26 08:37:03');
INSERT INTO reviews VALUES (153, 10, 15, 'One of the best in its genre.', 7.0, '2023-01-12 09:04:41');
INSERT INTO reviews VALUES (154, 20, 17, 'A flawed gem; worth the watch. An innovative film with daring choices.', 6.7, '2023-10-18 23:57:02');
INSERT INTO reviews VALUES (155, 11, 20, 'Stunning visuals and incredible performances. A visual feast with a strong story.', 7.1, '2023-03-02 14:06:51');
INSERT INTO reviews VALUES (156, 6, 2, 'Brilliant direction and superb performances.', 6.1, '2023-08-15 16:33:39');
INSERT INTO reviews VALUES (157, 12, 30, 'A little overrated in my opinion.', 6.3, '2023-07-25 10:43:38');
INSERT INTO reviews VALUES (158, 3, 11, 'One of the best in its genre. A powerful story with emotional depth. A little overrated in my opinion.', 5.4, '2023-11-13 09:16:46');
INSERT INTO reviews VALUES (159, 3, 19, 'A powerful story with emotional depth. Stunning visuals and incredible performances.', 8.0, '2023-06-10 20:44:42');
INSERT INTO reviews VALUES (160, 10, 18, 'A visual feast with a strong story. Stunning visuals and incredible performances. Complex, thought-provoking, and rewarding.', 6.7, '2023-06-27 04:42:44');
INSERT INTO reviews VALUES (161, 17, 12, 'An innovative film with daring choices. Predictable plot but well executed.', 5.1, '2023-05-06 06:21:49');
INSERT INTO reviews VALUES (162, 5, 5, 'Enjoyable but a bit slow in the middle. A little overrated in my opinion. A powerful story with emotional depth.', 5.3, '2023-02-17 17:53:47');
INSERT INTO reviews VALUES (163, 20, 13, 'Great chemistry between leads.', 5.7, '2023-03-27 22:49:39');
INSERT INTO reviews VALUES (164, 2, 14, 'Great chemistry between leads. Predictable plot but well executed. Excellent world-building and atmosphere.', 6.6, '2023-12-08 14:39:18');
INSERT INTO reviews VALUES (165, 8, 10, 'Great chemistry between leads. One of the best in its genre. Terrific soundtrack and memorable scenes.', 9.3, '2023-08-27 06:23:43');
INSERT INTO reviews VALUES (166, 13, 17, 'A cinematic triumph \u2014 every frame matters.', 7.4, '2023-03-27 06:51:38');
INSERT INTO reviews VALUES (167, 2, 21, 'The pacing felt off but the acting saved it. Terrific soundtrack and memorable scenes. Stunning visuals and incredible performances.', 7.2, '2023-06-18 03:45:54');
INSERT INTO reviews VALUES (168, 6, 9, 'Great chemistry between leads.', 7.0, '2023-09-05 13:05:58');
INSERT INTO reviews VALUES (169, 12, 30, 'Stunning visuals and incredible performances. Brilliant direction and superb performances.', 5.1, '2023-01-13 16:23:15');
INSERT INTO reviews VALUES (170, 8, 1, 'A powerful story with emotional depth.', 6.4, '2023-02-27 22:41:21');
INSERT INTO reviews VALUES (171, 2, 10, 'Great chemistry between leads. A masterpiece that stands the test of time.', 9.1, '2023-08-23 04:48:45');
INSERT INTO reviews VALUES (172, 3, 1, 'The pacing felt off but the acting saved it. Terrific soundtrack and memorable scenes.', 6.2, '2023-03-18 23:38:33');
INSERT INTO reviews VALUES (173, 8, 10, 'Stunning visuals and incredible performances. The pacing felt off but the acting saved it.', 5.5, '2023-04-14 20:50:39');
INSERT INTO reviews VALUES (174, 16, 20, 'Terrific soundtrack and memorable scenes.', 7.4, '2023-11-17 18:15:45');
INSERT INTO reviews VALUES (175, 14, 1, 'Stunning visuals and incredible performances. A visual feast with a strong story. Brilliant direction and superb performances.', 7.8, '2023-04-19 13:11:42');
INSERT INTO reviews VALUES (176, 3, 17, 'Enjoyable but a bit slow in the middle. Heartfelt and genuinely moving.', 7.4, '2023-09-18 00:24:55');
INSERT INTO reviews VALUES (177, 12, 9, 'The pacing felt off but the acting saved it. A flawed gem; worth the watch. A little overrated in my opinion.', 8.4, '2023-06-26 02:22:15');
INSERT INTO reviews VALUES (178, 5, 2, 'Great chemistry between leads. The ending was surprising and well done. Not my cup of tea, but I see why others love it.', 6.6, '2023-06-27 20:11:53');
INSERT INTO reviews VALUES (179, 5, 3, 'Enjoyable but a bit slow in the middle.', 8.2, '2023-08-02 09:12:02');
INSERT INTO reviews VALUES (180, 11, 30, 'An innovative film with daring choices.', 6.4, '2023-07-27 17:30:16');
INSERT INTO reviews VALUES (181, 10, 12, 'Brilliant direction and superb performances.', 8.9, '2023-01-28 20:21:17');
INSERT INTO reviews VALUES (182, 14, 29, 'The ending was surprising and well done. Brilliant direction and superb performances. A visual feast with a strong story.', 6.8, '2023-08-13 10:11:31');
INSERT INTO reviews VALUES (183, 9, 26, 'Excellent world-building and atmosphere.', 5.4, '2023-07-03 13:38:52');
INSERT INTO reviews VALUES (184, 10, 11, 'Complex, thought-provoking, and rewarding. Not my cup of tea, but I see why others love it. Great chemistry between leads.', 5.5, '2023-06-22 09:19:28');
INSERT INTO reviews VALUES (185, 12, 15, 'Stunning visuals and incredible performances.', 5.2, '2023-06-20 13:17:40');
INSERT INTO reviews VALUES (186, 13, 12, 'Great chemistry between leads. Enjoyable but a bit slow in the middle. A powerful story with emotional depth.', 7.3, '2023-12-22 05:01:09');
INSERT INTO reviews VALUES (187, 3, 8, 'A powerful story with emotional depth. Great chemistry between leads. Brilliant direction and superb performances.', 8.5, '2023-06-12 12:36:02');
INSERT INTO reviews VALUES (188, 12, 15, 'A cinematic triumph \u2014 every frame matters. Predictable plot but well executed.', 8.4, '2023-10-05 16:23:25');
INSERT INTO reviews VALUES (189, 4, 1, 'A cinematic triumph \u2014 every frame matters.', 8.3, '2023-08-17 12:58:35');
INSERT INTO reviews VALUES (190, 9, 23, 'The pacing felt off but the acting saved it.', 7.0, '2023-10-10 22:58:31');
INSERT INTO reviews VALUES (191, 5, 28, 'A little overrated in my opinion. Brilliant direction and superb performances. Stunning visuals and incredible performances.', 5.3, '2023-03-23 14:05:51');
INSERT INTO reviews VALUES (192, 18, 18, 'Not my cup of tea, but I see why others love it. Brilliant direction and superb performances. A visual feast with a strong story.', 6.3, '2023-05-28 05:45:45');
INSERT INTO reviews VALUES (193, 8, 4, 'A flawed gem; worth the watch. Brilliant direction and superb performances. Great chemistry between leads.', 9.4, '2023-03-08 15:01:23');
INSERT INTO reviews VALUES (194, 18, 5, 'The ending was surprising and well done. A visual feast with a strong story. Complex, thought-provoking, and rewarding.', 7.8, '2023-02-03 09:25:45');
INSERT INTO reviews VALUES (195, 14, 27, 'A visual feast with a strong story. Brilliant direction and superb performances.', 7.6, '2023-03-11 20:04:28');
INSERT INTO reviews VALUES (196, 5, 29, 'Complex, thought-provoking, and rewarding.', 8.7, '2023-09-21 18:11:49');
INSERT INTO reviews VALUES (197, 17, 30, 'A little overrated in my opinion.', 8.9, '2023-02-17 04:19:10');
INSERT INTO reviews VALUES (198, 8, 12, 'Excellent world-building and atmosphere. A cinematic triumph \u2014 every frame matters. A powerful story with emotional depth.', 9.3, '2023-09-10 02:16:12');
INSERT INTO reviews VALUES (199, 10, 20, 'Not my cup of tea, but I see why others love it.', 7.4, '2023-09-21 05:37:37');
INSERT INTO reviews VALUES (200, 20, 24, 'Stunning visuals and incredible performances.', 9.1, '2023-06-27 18:02:52');

-- Indexes and full-text search
CREATE INDEX IF NOT EXISTS idx_movies_description_tsv ON movies USING gin(to_tsvector('english', coalesce(description,'')));
CREATE INDEX IF NOT EXISTS idx_reviews_text_tsv ON reviews USING gin(to_tsvector('english', coalesce(review_text,'')));
CREATE INDEX IF NOT EXISTS idx_movies_genres_gin ON movies USING gin(genres);

-- Materialized view for cached average ratings
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_movie_avg_ratings AS
SELECT m.id AS movie_id, m.title, ROUND(AVG(r.rating), 2) AS avg_rating, COUNT(r.id) AS total_reviews
FROM movies m
LEFT JOIN reviews r ON r.movie_id = m.id
GROUP BY m.id, m.title;

-- Useful queries examples
-- 1) Top 5 movies by average user rating (using materialized view)
-- SELECT title, avg_rating, total_reviews FROM mv_movie_avg_ratings ORDER BY avg_rating DESC NULLS LAST LIMIT 5;
-- 2) Full-text search for movies mentioning 'masterpiece' in description or reviews
-- SELECT m.title FROM movies m JOIN reviews r ON r.movie_id = m.id WHERE to_tsvector('english', m.description || ' ' || coalesce(r.review_text,'')) @@ to_tsquery('masterpiece');
-- 3) Query genres using JSONB
-- SELECT jsonb_array_elements_text(genres) AS genre, COUNT(*) FROM movies GROUP BY genre ORDER BY COUNT(*) DESC;
-- 4) Actors who have appeared in more than one movie in this dataset
-- SELECT a.name, COUNT(mc.movie_id) as movies_count FROM actors a JOIN movie_cast mc ON mc.actor_id = a.id GROUP BY a.name HAVING COUNT(mc.movie_id) > 1;
COMMIT;
