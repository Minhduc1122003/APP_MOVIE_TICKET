CREATE DATABASE APP_MOVIE_TICKET;
USE APP_MOVIE_TICKET;

GO
CREATE TABLE Users (
    UserId INT PRIMARY KEY IDENTITY(1,1), -- Thiết lập UserId tự động tăng
    UserName VARCHAR(50) NOT NULL,
    Password VARCHAR(55) NOT NULL,
    Email VARCHAR(155) NOT NULL,
    FullName NVARCHAR(155) NOT NULL,
    PhoneNumber INT NOT NULL,
    Photo VARCHAR(50),
    Role BIT NOT NULL
);

CREATE TABLE Movies (
    MovieID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(255) NOT NULL,
    IdGenre INT NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,
    Duration INT NOT NULL,
    ReleaseDate DATE NOT NULL,
    PosterUrl VARCHAR(255),
    TrailerUrl VARCHAR(255),
    IdLanguage INT NOT NULL,
    Age INT NOT NULL
);
CREATE TABLE Genre (
    IdGenre INT PRIMARY KEY IDENTITY(1,1),
    GenreName NVARCHAR(100) NOT NULL
);

CREATE TABLE MovieGenre (
    MovieID INT NOT NULL,
    IdGenre INT NOT NULL,
    PRIMARY KEY (MovieID, IdGenre),
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID),
    FOREIGN KEY (IdGenre) REFERENCES Genre(IdGenre)
);

CREATE TABLE Rate (
    IdRate INT PRIMARY KEY IDENTITY(1,1),
    MovieID INT NOT NULL,
    UserId INT NOT NULL,
    Content NVARCHAR(MAX) NOT NULL,
    Rating FLOAT NOT NULL,
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID),
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

CREATE TABLE Language (
    IdLanguage INT PRIMARY KEY IDENTITY(1,1),
    LanguageName NVARCHAR(100) NOT NULL,
    Subtitle BIT NOT NULL
);

CREATE TABLE MovieLanguage (
    MovieID INT NOT NULL,
    IdLanguage INT NOT NULL,
    PRIMARY KEY (MovieID, IdLanguage),
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID),
    FOREIGN KEY (IdLanguage) REFERENCES Language(IdLanguage)
);

CREATE TABLE Favourite (
    IdFavourite INT PRIMARY KEY IDENTITY(1,1),
    MovieID INT NOT NULL,
    UserId INT NOT NULL,
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID),
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);




INSERT INTO Genre (GenreName) VALUES
('Action'),
('Comedy'),
('Drama'),
('Horror'),
('Sci-Fi');


INSERT INTO Movies (Title, IdGenre, Description, Duration, ReleaseDate, PosterUrl, TrailerUrl, IdLanguage, Age) VALUES
('Avengers: Endgame', 1, 'The Avengers fight their last battle.', 181, '2019-04-26', 'endgame.jpg', 'endgame_trailer.mp4', 1, 13),
('The Hangover', 2, 'Three friends lose their groom.', 100, '2009-06-05', 'hangover.jpg', 'hangover_trailer.mp4', 2, 18),
('The Godfather', 3, 'A story about a crime family.', 175, '1972-03-24', 'godfather.jpg', 'godfather_trailer.mp4', 3, 18),
('It', 4, 'A horror story about a killer clown.', 135, '2017-09-08', 'it.jpg', 'it_trailer.mp4', 4, 16),
('Inception', 5, 'A thief who enters people''s dreams.', 148, '2010-07-16', 'inception.jpg', 'inception_trailer.mp4', 1, 13);


INSERT INTO MovieGenre (MovieID, IdGenre) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

INSERT INTO Rate (MovieID, UserId, Content, Rating) VALUES
(1, 1, 'Amazing movie! Must watch.', 9.5),
(2, 2, 'Hilarious from start to finish.', 8.0),
(3, 3, 'A masterpiece of storytelling.', 10.0),
(4, 4, 'Scary and well-made.', 7.5),
(5, 4, 'Mind-bending and thought-provoking.', 9.0);


INSERT INTO Language (LanguageName, Subtitle) VALUES
('English', 1),
('French', 1),
('Spanish', 0),
('German', 1),
('Japanese', 0);


INSERT INTO MovieLanguage (MovieID, IdLanguage) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 3),
(5, 4);


INSERT INTO Favourite (MovieID, UserId) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);


































CREATE TABLE Conversations (
    Id INT PRIMARY KEY IDENTITY(1,1),
    User1Id INT NOT NULL,
    User2Id INT NOT NULL,
    StartedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (User1Id) REFERENCES Users(UserId) ON DELETE NO ACTION,
    FOREIGN KEY (User2Id) REFERENCES Users(UserId) ON DELETE NO ACTION
);


CREATE TABLE Messages (
    Id INT PRIMARY KEY IDENTITY(1,1),
    SenderId INT NOT NULL,
    ReceiverId INT NOT NULL,
    Message NVARCHAR(255) NOT NULL,
    SentAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    ConversationId INT NOT NULL,
    FOREIGN KEY (SenderId) REFERENCES Users(UserId) ON DELETE NO ACTION,
    FOREIGN KEY (ReceiverId) REFERENCES Users(UserId) ON DELETE NO ACTION,
    FOREIGN KEY (ConversationId) REFERENCES Conversations(Id) ON DELETE CASCADE
);
