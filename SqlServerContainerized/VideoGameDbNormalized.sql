-- Create VideoGameDbNormalized Database
-- CREATE DATABASE VideoGameDbNormalized;
USE VideoGameDbNormalized;

-- Create Publishers Table
CREATE TABLE Publishers (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL
);

-- Insert Data into Publishers Table
INSERT INTO Publishers (Name)
VALUES ('Nintendo'),
       ('Rockstar Games'),
       ('CD Projekt'),
       ('Sony Interactive Entertainment'),
       ('Mojang Studios'),
       ('Epic Games'),
       ('Supergiant Games'),
       ('InnerSloth');

-- Create Developers Table
CREATE TABLE Developers (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL
);

-- Insert Data into Developers Table
INSERT INTO Developers (Name)
VALUES ('Nintendo EPD'),
       ('Rockstar Studios'),
       ('CD Projekt Red'),
       ('Santa Monica Studio'),
       ('Mojang Studios'),
       ('Epic Games'),
       ('Supergiant Games'),
       ('InnerSloth');

-- Create Platforms Table
CREATE TABLE Platforms (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL
);

-- Insert Data into Platforms Table
INSERT INTO Platforms (Name)
VALUES ('Nintendo Switch'),
       ('PlayStation 4'),
       ('Xbox One'),
       ('PC'),
       ('PlayStation 5'),
       ('Xbox Series X'),
       ('Mobile');

-- Create VideoGames Table
CREATE TABLE VideoGames (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(100) NOT NULL,
    PublisherId INT,
    DeveloperId INT,
    ReleaseDate DATE NOT NULL,
    FOREIGN KEY (PublisherId) REFERENCES Publishers(Id),
    FOREIGN KEY (DeveloperId) REFERENCES Developers(Id)
);

-- Insert Data into VideoGames Table
INSERT INTO VideoGames (Title, PublisherId, DeveloperId, ReleaseDate)
VALUES ('The Legend of Zelda: Breath of the Wild', 1, 1, '2017-03-03'),
       ('Red Dead Redemption 2', 2, 2, '2018-10-26'),
       ('The Witcher 3: Wild Hunt', 3, 3, '2015-05-19'),
       ('God of War', 4, 4, '2018-04-20'),
       ('Cyberpunk 2077', 3, 3, '2020-12-10'),
       ('Minecraft', 5, 5, '2011-11-18'),
       ('Fortnite', 6, 6, '2017-07-21'),
       ('Animal Crossing: New Horizons', 1, 1, '2020-03-20'),
       ('Hades', 7, 7, '2020-09-17'),
       ('Among Us', 8, 8, '2018-11-16');

-- Create GameDetails Table (One-to-One Relationship)
CREATE TABLE GameDetails (
    VideoGameId INT PRIMARY KEY,
    Description NVARCHAR(MAX),
    Rating NVARCHAR(10),
    FOREIGN KEY (VideoGameId) REFERENCES VideoGames(Id)
);

-- Insert Data into GameDetails Table
INSERT INTO GameDetails (VideoGameId, Description, Rating)
VALUES (1, 'An open-world action-adventure game set in a fantasy world.', 'E10+'),
       (2, 'An action-adventure game set in the American frontier.', 'M'),
       (3, 'An open-world RPG set in a dark fantasy universe.', 'M'),
       (4, 'An action-adventure game following the story of Kratos.', 'M'),
       (5, 'An open-world RPG set in a dystopian future.', 'M'),
       (6, 'A sandbox game that allows players to build and explore.', 'E10+'),
       (7, 'A battle royale game featuring 100-player matches.', 'T'),
       (8, 'A life simulation game where players develop a village.', 'E'),
       (9, 'A rogue-like dungeon crawler with Greek mythology.', 'T'),
       (10, 'A multiplayer game where players work to find imposters.', 'E10+');

-- Create Reviews Table (One-to-Many Relationship)
CREATE TABLE Reviews (
    Id INT PRIMARY KEY IDENTITY(1,1),
    VideoGameId INT,
    ReviewerName NVARCHAR(100),
    Content NVARCHAR(MAX),
    Rating INT,
    FOREIGN KEY (VideoGameId) REFERENCES VideoGames(Id)
);

-- Insert Data into Reviews Table
INSERT INTO Reviews (VideoGameId, ReviewerName, Content, Rating)
VALUES (1, 'Link', 'Amazing gameplay and open world!', 10),
       (2, 'Arthur Morgan', 'A masterpiece of storytelling and graphics.', 9),
       (3, 'Geralt of Rivia', 'The best RPG experience I have ever had.', 10),
       (4, 'Kratos', 'Fantastic story and combat mechanics.', 9),
       (5, 'V', 'A bit buggy, but the story and world are amazing.', 7),
       (6, 'Steve', 'Endless creativity and fun in this sandbox world.', 10),
       (7, 'Jonesy', 'Highly addictive and fun battle royale.', 8),
       (8, 'Isabelle', 'A charming and relaxing life simulation.', 9),
       (9, 'Zagreus', 'Exciting gameplay and great story.', 9),
       (10, 'Cyan', 'Simple but extremely fun and engaging.', 8);

-- Create VideoGamesPlatforms Table (Many-to-Many Relationship)
CREATE TABLE VideoGamesPlatforms (
    VideoGameId INT,
    PlatformId INT,
    FOREIGN KEY (VideoGameId) REFERENCES VideoGames(Id),
    FOREIGN KEY (PlatformId) REFERENCES Platforms(Id),
    PRIMARY KEY (VideoGameId, PlatformId)
);

-- Insert Data into VideoGamesPlatforms Table
INSERT INTO VideoGamesPlatforms (VideoGameId, PlatformId)
VALUES (1, 1),    -- The Legend of Zelda: Breath of the Wild on Nintendo Switch
       (2, 2),    -- Red Dead Redemption 2 on PlayStation 4
       (2, 3),    -- Red Dead Redemption 2 on Xbox One
       (2, 4),    -- Red Dead Redemption 2 on PC
       (3, 2),    -- The Witcher 3: Wild Hunt on PlayStation 4
       (3, 3),    -- The Witcher 3: Wild Hunt on Xbox One
       (3, 1),    -- The Witcher 3: Wild Hunt on Nintendo Switch
       (3, 4),    -- The Witcher 3: Wild Hunt on PC
       (4, 2),    -- God of War on PlayStation 4
       (4, 5),    -- God of War on PlayStation 5
       (5, 4),    -- Cyberpunk 2077 on PC
       (5, 2),    -- Cyberpunk 2077 on PlayStation 4
       (5, 3),    -- Cyberpunk 2077 on Xbox One
       (5, 5),    -- Cyberpunk 2077 on PlayStation 5
       (5, 6),    -- Cyberpunk 2077 on Xbox Series X
       (6, 4),    -- Minecraft on PC
       (6, 7),    -- Minecraft on Mobile
       (6, 3),    -- Minecraft on Xbox One
       (7, 4),    -- Fortnite on PC
       (7, 3),    -- Fortnite on Xbox One
       (7, 2),    -- Fortnite on PlayStation 4
       (7, 7),    -- Fortnite on Mobile
       (8, 1),    -- Animal Crossing: New Horizons on Nintendo Switch
       (9, 4),    -- Hades on PC
       (9, 1),    -- Hades on Nintendo Switch
       (10, 4),   -- Among Us on PC
       (10, 7);   -- Among Us on Mobile
