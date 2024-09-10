CREATE DATABASE APP_MOVIE_TICKET;
go

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
    Role BIT NOT NULL,
	CreateDate Datetime not null,
	UpdateDate Datetime not null,
	UpdateBy VARCHAR(50)not null,
	Status VARCHAR(20) not null, 
);
go
-- BẢNG Users CHUẨN
-- + 1 bảng lịch sử hoạt động của users
-- + 1 bảng lịch sử hoạt động của admin



CREATE TABLE Cinemas(
    CinemaID INT PRIMARY KEY IDENTITY(1,1),  -- Mã rạp, tự động tăng
    CinemaName NVARCHAR(100) NOT NULL,       -- Tên rạp
    Address NVARCHAR(255) NOT NULL           -- Địa chỉ của rạp
);
go
CREATE TABLE CinemaRoom (
	CinemaRoomID INT PRIMARY KEY,
    CinemaID INT,  -- Mã rạp
	FOREIGN KEY (CinemaID) REFERENCES Cinemas(CinemaID)

);
go
-- BẢNG Cinemas CHUẨN

CREATE TABLE Genre (
    IdGenre INT PRIMARY KEY IDENTITY(1,1),
    GenreName NVARCHAR(100) NOT NULL
);
go
CREATE TABLE Age (
    AgeID INT PRIMARY KEY IDENTITY(1,1),
    Value NVARCHAR(10),
);
go
CREATE TABLE Movies (
    MovieID INT PRIMARY KEY IDENTITY(1,1),
	CinemaID INT,
    Title NVARCHAR(255) NOT NULL,
    IdGenre INT NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,
    Duration INT NOT NULL,
    ReleaseDate DATE NOT NULL,
    PosterUrl VARCHAR(255),
    TrailerUrl VARCHAR(255),
    AgeID Int  NOT NULL,
	SubTitle BIT,
	Voiceover BIT,
	CONSTRAINT FK_CinemaID FOREIGN KEY (CinemaID) REFERENCES Cinemas (CinemaID),
	CONSTRAINT FK_IdGenre FOREIGN KEY (IdGenre) REFERENCES Genre(IdGenre),
	CONSTRAINT FK_AgeID FOREIGN KEY (AgeID) REFERENCES Age(AgeID)
);
go

CREATE TABLE MovieGenre (
    MovieID INT NOT NULL,
    IdGenre INT NOT NULL,
    PRIMARY KEY (MovieID, IdGenre),
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID),
    FOREIGN KEY (IdGenre) REFERENCES Genre(IdGenre)
);
go


CREATE TABLE Rate (
    IdRate INT PRIMARY KEY IDENTITY(1,1),
    MovieID INT NOT NULL,
    UserId INT NOT NULL,
    Content NVARCHAR(MAX) NOT NULL,
    Rating FLOAT NOT NULL,
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID),
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);
go



CREATE TABLE Favourite (
    IdFavourite INT PRIMARY KEY IDENTITY(1,1),
    MovieID INT NOT NULL,
    UserId INT NOT NULL,
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID),
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);
go

CREATE TABLE BuyTicket (
    BuyTicketId INT PRIMARY KEY IDENTITY(1,1),
	UserId INT NOT NULL,
    MovieID INT NOT NULL,
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID),
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);
go
CREATE TABLE BuyTicketInfo (
    BuyTicketInfoId INT PRIMARY KEY IDENTITY(1,1),
	BuyTicketId INT NOT NULL,
	Quantity int NOT NULL,
	CreateDate Datetime NOT NULL,
	TotalPrice float NOT NULL,
	ComboID int,
    FOREIGN KEY (BuyTicketId) REFERENCES BuyTicket(BuyTicketId),
);

go
CREATE TABLE ComBo (
    ComboID INT PRIMARY KEY IDENTITY(1,1),
	BuyTicketInfoId INT NOT NULL,
	Quantity int NOT NULL,
	Price float NOT NULL,
    FOREIGN KEY (BuyTicketInfoId) REFERENCES BuyTicketInfo(BuyTicketInfoId),
);

go
CREATE TABLE Ticket(
	BuyTicketId INT NOT NULL,
	Price float NOT NULL,
	ChairCode Nvarchar(10),
	CinemaRoomID INT PRIMARY KEY,
	FOREIGN KEY (CinemaRoomID) REFERENCES CinemaRoom(CinemaRoomID),
    FOREIGN KEY (BuyTicketId) REFERENCES BuyTicket(BuyTicketId),
);
go


---- INSERT DATA
-- Insert dữ liệu cho bảng Users
INSERT INTO Users (UserName, Password, Email, FullName, PhoneNumber, Photo, Role, CreateDate, UpdateDate, UpdateBy, Status)
VALUES 
('user1', 'password1', 'user1@example.com', N'Nguyễn Văn A', 123456789, 'photo1.jpg', 1, GETDATE(), GETDATE(), 'admin', 'Active'),
('user2', 'password2', 'user2@example.com', N'Nguyễn Văn B', 987654321, 'photo2.jpg', 0, GETDATE(), GETDATE(), 'admin', 'Active'),
('user3', 'password3', 'user3@example.com', N'Nguyễn Văn C', 456789123, 'photo3.jpg', 1, GETDATE(), GETDATE(), 'admin', 'Inactive'),
('user4', 'password4', 'user4@example.com', N'Nguyễn Văn D', 789123456, 'photo4.jpg', 0, GETDATE(), GETDATE(), 'admin', 'Active'),
('user5', 'password5', 'user5@example.com', N'Nguyễn Văn E', 321654987, 'photo5.jpg', 1, GETDATE(), GETDATE(), 'admin', 'Inactive');

-- Insert dữ liệu cho bảng Cinemas
INSERT INTO Cinemas (CinemaName, Address)
VALUES 
(N'Rạp Chiếu Phim 1', N'123 Đường A, Thành phố X'),
(N'Rạp Chiếu Phim 2', N'456 Đường B, Thành phố Y'),
(N'Rạp Chiếu Phim 3', N'789 Đường C, Thành phố Z'),
(N'Rạp Chiếu Phim 4', N'111 Đường D, Thành phố M'),
(N'Rạp Chiếu Phim 5', N'222 Đường E, Thành phố N');

-- Insert dữ liệu cho bảng CinemaRoom
INSERT INTO CinemaRoom (CinemaID,CinemaRoomID)
VALUES 
(1,1),
(1,2),
(1,3),
(1,4),
(1,5);

-- Insert dữ liệu cho bảng Genre
INSERT INTO Genre (GenreName)
VALUES 
(N'Action'),
(N'Comedy'),
(N'Drama'),
(N'Horror'),
(N'Sci-Fi');

-- Insert dữ liệu cho bảng Age
INSERT INTO Age (Value)
VALUES 
(N'C13'),
(N'C16'),
(N'C18'),
(N'P'),
(N'C21');

-- Insert dữ liệu cho bảng Movies
INSERT INTO Movies (CinemaID, Title, IdGenre, Description, Duration, ReleaseDate, PosterUrl, TrailerUrl, AgeID, SubTitle, Voiceover)
VALUES 
(1, N'Movie 1', 1, N'This is an action movie.', 120, '2023-01-01', 'poster1.jpg', 'trailer1.mp4', 1, 1, 0),
(2, N'Movie 2', 2, N'This is a comedy movie.', 90, '2023-02-01', 'poster2.jpg', 'trailer2.mp4', 2, 1, 1),
(3, N'Movie 3', 3, N'This is a drama movie.', 150, '2023-03-01', 'poster3.jpg', 'trailer3.mp4', 3, 0, 1),
(4, N'Movie 4', 4, N'This is a horror movie.', 110, '2023-04-01', 'poster4.jpg', 'trailer4.mp4', 4, 1, 0),
(5, N'Movie 5', 5, N'This is a sci-fi movie.', 130, '2023-05-01', 'poster5.jpg', 'trailer5.mp4', 5, 0, 1);
-- Insert dữ liệu cho bảng MovieGenre
INSERT INTO MovieGenre (MovieID, IdGenre)
VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- Insert dữ liệu cho bảng Rate
INSERT INTO Rate (MovieID, UserId, Content, Rating)
VALUES 
(1, 1, N'Great movie!', 4.5),
(2, 2, N'Hilarious!', 4.0),
(3, 3, N'So touching.', 5.0),
(4, 4, N'Too scary!', 3.5),
(5, 5, N'Out of this world!', 4.8);

-- Insert dữ liệu cho bảng Favourite
INSERT INTO Favourite (MovieID, UserId)
VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- Insert dữ liệu cho bảng BuyTicket
INSERT INTO BuyTicket (UserId, MovieID)
VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- Insert dữ liệu cho bảng BuyTicketInfo
INSERT INTO BuyTicketInfo (BuyTicketId, Quantity, CreateDate, TotalPrice, ComboID)
VALUES 
(1, 2, GETDATE(), 200.00, NULL),
(2, 3, GETDATE(), 300.00, NULL),
(3, 1, GETDATE(), 100.00, NULL),
(4, 4, GETDATE(), 400.00, NULL),
(5, 5, GETDATE(), 500.00, NULL);

-- Insert dữ liệu cho bảng ComBo
INSERT INTO ComBo (BuyTicketInfoId, Quantity, Price)
VALUES 
(1, 1, 50.00),
(2, 2, 100.00),
(3, 1, 50.00),
(4, 2, 100.00),
(5, 3, 150.00);

-- Insert dữ liệu cho bảng Ticket
INSERT INTO Ticket (BuyTicketId, Price, ChairCode, CinemaRoomID)
VALUES 
(1, 100.00, N'A1', 1),
(2, 200.00, N'B2', 2),
(3, 150.00, N'C3', 3),
(4, 180.00, N'D4', 4),
(5, 220.00, N'E5', 5);




















-------------- SOCKET IO ---------------------
CREATE TABLE Conversations (
    Id INT PRIMARY KEY IDENTITY(1,1),
    User1Id INT NOT NULL,
    User2Id INT NOT NULL,
    StartedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (User1Id) REFERENCES Users(UserId) ON DELETE NO ACTION,
    FOREIGN KEY (User2Id) REFERENCES Users(UserId) ON DELETE NO ACTION
);
go

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
go

/* SELECT 
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