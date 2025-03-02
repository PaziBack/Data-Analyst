Create DATABASE Records_pro
use records_pro

GO

CREATE TABLE Genres (
    GenreID INT IDENTITY(1,1) PRIMARY KEY, -- מזהה ייחודי לז'אנר
    GenreName NVARCHAR(100) NOT NULL UNIQUE, -- שם הז'אנר
    Description NVARCHAR(255), -- תיאור הז'אנר
    Popularity INT CHECK (Popularity >= 0 AND Popularity <= 100)) -- פופולריות בין 0 ל-10
ALTER TABLE Genres
ADD CONSTRAINT CK_Popularity CHECK (Popularity >= 1 AND Popularity <= 10)


CREATE TABLE Artists (
    ArtistID INT IDENTITY(1,1) PRIMARY KEY, -- מזהה ייחודי לאמן
    Name NVARCHAR(100) NOT NULL UNIQUE, -- שם האמן
    DebutYear INT CHECK (DebutYear > 1900 AND DebutYear <= YEAR(GETDATE()))) -- שנת הבכורה
ALTER TABLE Artists
ADD GenreID INT NOT NULL
ALTER TABLE Artists
ADD CONSTRAINT FK_Artists_Genres FOREIGN KEY (GenreID) REFERENCES Genres(GenreID)

CREATE TABLE Songs (
    SongID INT IDENTITY(1,1) PRIMARY KEY, -- מזהה ייחודי לשיר
    TrackName NVARCHAR(100) NOT NULL, -- שם השיר
    ArtistID INT NOT NULL, -- מזהה האמן (FK ל-Artists)
    GenreID INT NOT NULL, -- מזהה הז'אנר (FK ל-Genres)
    ReleaseYear INT CHECK (ReleaseYear > 1900 AND ReleaseYear <= YEAR(GETDATE())), -- שנת יציאה
    FOREIGN KEY (ArtistID) REFERENCES Artists(ArtistID),
    FOREIGN KEY (GenreID) REFERENCES Genres(GenreID))

CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY, -- מזהה ייחודי למשתמש
    UserName NVARCHAR(100) NOT NULL UNIQUE, -- שם המשתמש
    Age INT NOT NULL CHECK (Age > 0), -- גיל (חובה, מעל 0)
    WhileWorking NVARCHAR(10), -- האם מאזינים בזמן עבודה
    HrsPerDay FLOAT CHECK (HrsPerDay >= 0), -- שעות האזנה יומיות
    FavGenre INT NOT NULL, -- מזהה הז'אנר המועדף (FK ל-Genres)
    FOREIGN KEY (FavGenre) REFERENCES Genres(GenreID)
)

CREATE TABLE MusicEffect (
    EffectID INT IDENTITY(1,1) PRIMARY KEY, -- מזהה ייחודי להשפעה
    UserID INT NOT NULL, -- מזהה המשתמש (FK ל-Users)
    GenreID INT NOT NULL, -- מזהה הז'אנר (FK ל-Genres)
    MoodEffect NVARCHAR(255), -- תיאור השפעה על מצב הרוח
    FrequencyClassical FLOAT CHECK (FrequencyClassical >= 0), -- תדירות האזנה לקלאסית
    Anxiety NVARCHAR(10), -- חרדה (כן/לא)
    Depression NVARCHAR(10), -- דיכאון (כן/לא)
    Insomnia NVARCHAR(10), -- נדודי שינה (כן/לא)
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (GenreID) REFERENCES Genres(GenreID))


INSERT INTO Genres (GenreName,Description, Popularity)
VALUES ('Pop', 'Contemporary popular music', 10),
		('Rock', 'Guitar-based music', 9),
		('Jazz', 'Improvisational music', 7),
		('Classical', 'Orchestral compositions', 6),
		('Hip-Hop', 'Beat-driven vocal style', 10),
		('Electronic', 'Synthesizer-based music', 6),
		('R&B', 'Soulful-rhythmic and smooth melodies', 8),
		('Reggae', 'Jamaican, offbeat rhythms, soulful', 7),
		('Country', 'Storytelling, southern, acoustic-based', 8),
		('Blues', 'Melancholic, expressive, guitar-driven', 7),
		('Metal', 'Distorted guitars, aggressive vocals', 8),
		('Punk Rock', 'Fast-paced, rebellious, raw', 7),
		('Folk', 'Acoustic, traditional, narrative-driven', 6),
		('Soul', 'Emotional, heartfelt vocal delivery', 7),
		('House', 'Repetitive beats, dancefloor-oriented', 7),
		('Techno', 'Electronic, repetitive, futuristic', 7),
		('Latin', 'Latin American, rhythmic, danceable', 8),
		('Alternative Rock', 'Experimental, diverse, non-mainstream', 8),
		('Indie Rock', 'Independent, unique, alternative rock', 7),
		('K-Pop', 'Pop, Korean, visually captivating', 9)


INSERT INTO Artists (Name, DebutYear, GenreID)
VALUES
	--('Queen', 1970),
	--('Ludwig van Beethoven', 1800)
    ('Jack Jackson', 2010, 3),  -- Pop
    ('The Weeknd', 2010, 3),    -- Pop
    ('Dua Lipa', 2015, 3),      -- Pop
    ('The Kid LAROI & Justin Bieber', 2020, 3), -- Pop
    ('Ed Sheeran', 2011, 3),    -- Pop
    ('Lewis Capaldi', 2018, 3), -- Pop
    ('Lil Nas X', 2019, 7),     -- Country
    ('Billie Eilish', 2015, 3), -- Pop
    ('Olivia Rodrigo', 2020, 3), -- Pop
    ('Bob Dylan', 1961, 4),     -- Folk
    ('Uncle Tupelo', 1987, 7),  -- Country
    ('Kendrick Lamar', 2011, 5), -- Hip-Hop
    ('Taylor Swift', 2006, 3),  -- Pop
    ('Mark Ronson ft. Bruno Mars', 2014, 3), -- Pop
    ('Queen', 1970, 6),         -- Rock
    ('Eagles', 1971, 6),        -- Rock
    ('Nirvana', 1987, 6),       -- Rock
    ('Dave Brubeck', 1940, 8),  -- Jazz
    ('Miles Davis', 1944, 8),   -- Jazz
    ('John Coltrane', 1955, 8), -- Jazz
    ('Travis Scott', 2012, 5),  -- Hip-Hop
    ('Deadmau5', 2005, 9),      -- Electronic
    ('David Guetta ft. Sia', 2002, 9), -- Electronic
    ('Martin Garrix', 2013, 9), -- Electronic
    ('Harry Styles', 2010, 2),  -- R&B
    ('Blackstreet', 1991, 2),   -- R&B
    ('SZA', 2013, 2),           -- R&B
    ('Bob Marley & The Wailers', 1962, 10), -- Reggae
    ('Bob Marley', 1962, 10),   -- Reggae
    ('Inner Circle', 1968, 10), -- Reggae
    ('John Denver', 1964, 7),   -- Country
    ('Dolly Parton', 1967, 7),  -- Country
    ('Carrie Underwood', 2005, 7), -- Country
    ('BTS', 2013, 11),          -- K-Pop
    ('PSY', 2000, 11),          -- K-Pop
    ('BLACKPINK', 2016, 11),    -- K-Pop
    ('Rick James', 1978, 12),   -- Funk
    ('Luis Fonsi ft. Daddy Yankee', 2000, 13), -- Latin
    ('Ritchie Valens', 1958, 13), -- Latin
    ('Ricky Martin', 1991, 13); -- Latin


INSERT INTO Songs (TrackName, ArtistID, GenreID, ReleaseYear)
VALUES
 ('Anti-Hero', 13, 1, 2022), -- Taylor Swift, Pop
    ('As It Was', 16, 1, 2022), -- Harry Styles, Pop
    ('Unholy', 17, 1, 2022), -- Sam Smith ft. Kim Petras, Pop
    ('Flowers', 18, 1, 2023), -- Miley Cyrus, Pop
    ('Creepin', 2, 2, 2022), -- The Weeknd ft. Metro Boomin, Hip-Hop
    ('Calm Down', 19, 1, 2023), -- Rema ft. Selena Gomez, Pop
    ('Kill Bill', 20, 10, 2023), -- SZA, R&B
    ('Golden Hour', 21, 1, 2023), -- JVKE, Pop
    ('Escapism.', 22, 10, 2022), -- RAYE ft. 070 Shake, R&B
    ('I’m Good (Blue)', 23, 8, 2022); -- David Guetta ft. Bebe Rexha, Electronic
--('Bohemian Rhapsody', 1, 1, 1975),
--('Symphony No. 5', 2, 2, 1808),
INSERT INTO Songs (TrackName, ArtistID, GenreID, ReleaseYear)
VALUES
       ('Banana Pancakes', 1, 1, 2010), -- Jack Jackson, Pop
       ('Blinding Lights', 2, 1, 2020), -- The Weeknd, Pop
       ('Levitating', 3, 1, 2020), -- Dua Lipa, Pop
       ('Save Your Tears', 2, 1, 2020), -- The Weeknd, Pop
       ('Stay', 4, 1, 2021), -- The Kid LAROI & Justin Bieber, Pop
       ('Shape of You', 5, 1, 2017), -- Ed Sheeran, Pop
       ('Someone You Loved', 6, 1, 2018), -- Lewis Capaldi, Pop
       ('Old Town Road', 7, 3, 2019), -- Lil Nas X, Country
       ('Bad Guy', 8, 1, 2019), -- Billie Eilish, Pop
       ('Drivers License', 9, 1, 2021), -- Olivia Rodrigo, Pop
       ('The Times They Are a Changin', 10, 4, 1964), -- Bob Dylan, Folk
       ('Moonshine', 11, 3, 1993), -- Uncle Tupelo, Country
       ('HUMBLE.', 12, 2, 2017), -- Kendrick Lamar, Hip-Hop
       ('Shake It Off', 13, 1, 2014), -- Taylor Swift, Pop
       ('Bohemian Rhapsody', 14, 6, 1975), -- Queen, Rock
       ('Hotel California', 15, 6, 1976), -- Eagles, Rock
       ('Take Five', 18, 7, 1959), -- Dave Brubeck, Jazz
       ('Titanium', 22, 8, 2011), -- David Guetta ft. Sia, Electronic
       ('Strobe', 21, 8, 2009), -- Deadmau5, Electronic
       ('No Woman, No Cry', 25, 9, 1974); -- Bob Marley & The Wailers, Reggae



INSERT INTO Users (UserName, Age, WhileWorking, HrsPerDay, FavGenre)
VALUES
    ('Alice', 25, 'Yes', 2, 1),   -- כאן 1 מתאר את ה-GenreID של "Pop"
    ('Bob', 34, 'No', 1, 2),   -- 2 מתאר את ה-GenreID של "Rock"
    ('Charlie', 29, 'No', NULL, 3),   -- 3 מתאר את ה-GenreID של "Jazz"
    ('Diana', 42, 'Yes', 2, 4),   -- 4 מתאר את ה-GenreID של "Classical"
    ('Eve', 19, 'No', 1, 5),   -- 5 מתאר את ה-GenreID של "Hip-Hop"
    ('Frank', 31, 'Yes', 3, 6),   -- 6 מתאר את ה-GenreID של "Electronic"
    ('Grace', 28, 'No', 2, 7),   -- 7 מתאר את ה-GenreID של "Reggae"
    ('Hank', 36, 'Yes', 3, 8),   -- 8 מתאר את ה-GenreID של "Blues"
    ('Ivy', 22, 'No', 1, 9),   -- 9 מתאר את ה-GenreID של "Pop"
    ('Jack', 40, 'Yes', 2, 10),   -- 10 מתאר את ה-GenreID של "Jazz"
    ('Zoe Mitchell', 21, 'No', 1, 11),   -- 11 מתאר את ה-GenreID של "Classical"
    ('Ethan Baker', 37, 'Yes', 2, 12),   -- 12 מתאר את ה-GenreID של "Reggae"
    ('Lila Gear', 31, 'Yes', 3, 13),   -- 13 מתאר את ה-GenreID של "Rock"
    ('Oscar Martinez', 28, 'No', 1, 14),   -- 14 מתאר את ה-GenreID של "Hip-Hop"
    ('Sofia Hernandez', 24, 'Yes', 2, 15),   -- 15 מתאר את ה-GenreID של "Pop"
    ('Leo Fisher', 33, 'Yes', 3, 16),   -- 16 מתאר את ה-GenreID של "Classical"
    ('Ava Patel', 26, 'No', 1, 17),   -- 17 מתאר את ה-GenreID של "Jazz"
    ('Mason Nguyen', 40, 'Yes', 3, 18),   -- 18 מתאר את ה-GenreID של "Blues"
    ('Chloe Kim', 30, 'No', 2, 19),   -- 19 מתאר את ה-GenreID של "Pop"
    ('Lucas Wang', 35, 'Yes', 1, 20);   -- 20 מתאר את ה-GenreID של "Electronic"


SELECT*
FROM Users

-- יוזר מתחיל ב41
INSERT INTO MusicEffect (UserID, GenreID, MoodEffect, FrequencyClassical, Anxiety, Depression, Insomnia)
VALUES
    (41, 1, 'Helps to focus', 3.0, 'No', 'No', 'No'),
    (42, 2, 'Reduces stress', 4.0, 'Yes', 'No', 'No'),
    (43, 3, 'Improves mood', 2.0, 'No', 'Yes', 'Yes');
    -- כל שאר הנתונים של MusicEffect

INSERT INTO MusicEffect (UserID, GenreID, MoodEffect, FrequencyClassical, Anxiety, Depression, Insomnia)
VALUES
    (44, 4, 'Relaxing', 5.0, 'Yes', 'No', 'No'),          -- Diana, Classical
    (45, 5, 'Boosts energy', 3.0, 'No', 'Yes', 'No'),     -- Eve, Hip-Hop
    (46, 6, 'Calms nerves', 4.5, 'Yes', 'No', 'Yes'),     -- Frank, Electronic
    (47, 7, 'Lifts mood', 2.5, 'No', 'Yes', 'No'),        -- Grace, Reggae
    (48, 8, 'Enhances creativity', 3.5, 'Yes', 'No', 'Yes'), -- Hank, Blues
    (49, 9, 'Improves focus', 2.0, 'No', 'No', 'Yes'),    -- Ivy, Pop
    (50, 10, 'Boosts concentration', 4.0, 'Yes', 'No', 'No'), -- Jack, Jazz
    (51, 11, 'Calms nerves', 3.0, 'Yes', 'Yes', 'No'),   -- Zoe Mitchell, Classical
    (52, 12, 'Reduces anxiety', 4.0, 'No', 'No', 'Yes'), -- Ethan Baker, Reggae
    (53, 13, 'Improves mood', 1.5, 'Yes', 'No', 'Yes'),  -- Lila Gear, Rock
    (54, 14, 'Relieves stress', 2.5, 'Yes', 'No', 'No'), -- Oscar Martinez, Hip-Hop
    (55, 15, 'Boosts focus', 3.0, 'No', 'Yes', 'Yes'),   -- Sofia Hernandez, Pop
    (56, 16, 'Soothing', 5.0, 'Yes', 'No', 'No'),        -- Leo Fisher, Classical
    (57, 17, 'Helps to focus', 4.0, 'Yes', 'Yes', 'No'), -- Ava Patel, Jazz
    (58, 18, 'Improves mood', 3.0, 'No', 'No', 'Yes'),   -- Mason Nguyen, Blues
    (59, 19, 'Enhances concentration', 2.0, 'Yes', 'No', 'No'), -- Chloe Kim, Pop
    (60, 20, 'Reduces anxiety', 4.5, 'No', 'Yes', 'No'); -- Lucas Wang, Electronic


	SELECT*
	FROM MusicEffect

	SELECT*
	FROM users
	ORDER BY FavGenre
	SELECT*
	FROM Songs
	SELECT *
	FROM Artists
	SELECT*
	FROM Genres



