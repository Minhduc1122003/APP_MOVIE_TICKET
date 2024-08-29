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

CREATE TABLE Cinemas (
    CinemaID INT PRIMARY KEY IDENTITY(1,1),  -- Mã rạp, tự động tăng
    CinemaName NVARCHAR(100) NOT NULL,       -- Tên rạp
    Address NVARCHAR(255) NOT NULL           -- Địa chỉ của rạp
);
ALTER TABLE Movies
ADD CinemaID INT;

ALTER TABLE Movies
ADD CONSTRAINT FK_CinemaID FOREIGN KEY (CinemaID)
REFERENCES Cinemas (CinemaID);


INSERT INTO Cinemas (CinemaName, Address) VALUES
('Cinema A', '123 Main St, City A'),
('Cinema B', '456 Elm St, City B'),
('Cinema C', '789 Oak St, City C'),
('Cinema D', '101 Maple Ave, City D'),
('Cinema E', '202 Pine Rd, City E');



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

UPDATE Movies SET CinemaID = 1 WHERE MovieID = 1;  -- Ví dụ: "Avengers: Endgame" chiếu tại "Cinema A"
UPDATE Movies SET CinemaID = 2 WHERE MovieID = 2;  -- "The Hangover" chiếu tại "Cinema B"
UPDATE Movies SET CinemaID = 3 WHERE MovieID = 3;  -- "The Godfather" chiếu tại "Cinema C"
UPDATE Movies SET CinemaID = 4 WHERE MovieID = 4;  -- "It" chiếu tại "Cinema D"
UPDATE Movies SET CinemaID = 5 WHERE MovieID = 5;  -- "Inception" chiếu tại "Cinema E"

INSERT INTO MovieGenre (MovieID, IdGenre) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

INSERT INTO MovieGenre (MovieID, IdGenre) VALUES
(1, 2),  -- Avengers: Endgame có thể loại Comedy
(2, 3),  -- The Hangover có thể loại Drama
(3, 4),  -- The Godfather có thể loại Horror
(4, 5),  -- It có thể loại Sci-Fi
(5, 1);  -- Inception có thể loại Action
INSERT INTO Users (UserName, Password, Email, FullName, PhoneNumber, Photo, Role)
VALUES 
('tuananh', '123', 'john.doe@example.com', 'John Doe', '1234567890', 'john_photo.jpg', 1),
('jane_smith', 'securePass!', 'jane.smith@example.com', 'Jane Smith', '1234567890', 'jane_photo.jpg', 0),
('mike_jones', 'mike123!', 'mike.jones@example.com', 'Mike Jones', '1234567890', 'mike_photo.jpg', 1),
('lisa_brown', 'lisaSecure', 'lisa.brown@example.com', 'Lisa Brown', '1234567890', 'lisa_photo.jpg', 0),
('tom_clark', 'tomPassword!', 'tom.clark@example.com', 'Tom Clark', '1234567890', 'tom_photo.jpg', 1);


INSERT INTO Rate (MovieID, UserId, Content, Rating) VALUES
(3, 3, 'A masterpiece of storytelling.', 10.0),
(4, 4, 'Scary and well-made.', 7.5),
(5, 4, 'Mind-bending and thought-provoking.', 9.0);


-- Cập nhật thêm người đánh giá
INSERT INTO Rate (MovieID, UserId, Content, Rating) VALUES
(2, 3, 'A fun comedy with great moments.', 8.5),
(3, 4, 'An unforgettable classic, highly recommend.', 9.7),
(4, 5, 'Not as scary as expected, but still good.', 7.8),
(5, 6, 'A mind-bending experience, worth watching.', 9.2);

INSERT INTO Language (LanguageName, Subtitle) VALUES
('English', 1),
('French', 1),
('Spanish', 0),
('German', 1),
('Japanese', 1);


INSERT INTO MovieLanguage (MovieID, IdLanguage) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 3),
(5, 4);


INSERT INTO Favourite (MovieID, UserId) VALUES

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

SELECT 
    m.MovieID,
    m.Title,
    m.Description,
    m.Duration,
    m.ReleaseDate,
    m.PosterUrl,
    m.TrailerUrl,
    l.LanguageName,
    STRING_AGG(g.GenreName, ', ') AS Genres, -- Kết hợp các thể loại thành một chuỗi
    c.CinemaName,
    c.Address AS CinemaAddress,
    STRING_AGG(r.Content, ' | ') AS ReviewContents, -- Kết hợp các đánh giá thành một chuỗi
    AVG(r.Rating) AS AverageRating, -- Tính điểm đánh giá trung bình
    COUNT(r.IdRate) AS ReviewCount -- Đếm số lượng đánh giá
FROM 
    Movies m
LEFT JOIN 
    Language l ON m.IdLanguage = l.IdLanguage
LEFT JOIN 
    MovieGenre mg ON m.MovieID = mg.MovieID
LEFT JOIN 
    Genre g ON mg.IdGenre = g.IdGenre
LEFT JOIN 
    Cinemas c ON m.CinemaID = c.CinemaID
LEFT JOIN 
    Rate r ON m.MovieID = r.MovieID
LEFT JOIN 
    Users u ON r.UserId = u.UserId
GROUP BY 
    m.MovieID, m.Title, m.Description, m.Duration, m.ReleaseDate, 
    m.PosterUrl, m.TrailerUrl, l.LanguageName, c.CinemaName, 
    c.Address;
