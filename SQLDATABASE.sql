CREATE DATABASE APP_MOVIE_TICKET2;
go

USE APP_MOVIE_TICKET2;
GO

CREATE TABLE Users (
    UserId INT PRIMARY KEY IDENTITY(1,1), -- Thiết lập UserId tự động tăng
    UserName VARCHAR(50) NOT NULL,
    Password VARCHAR(55) NOT NULL,
    Email VARCHAR(155) NOT NULL,
    FullName NVARCHAR(155) NOT NULL,
    PhoneNumber INT NOT NULL,
    Photo VARCHAR(50),
    Role INT NOT NULL, -- Sử dụng TINYINT để lưu trữ nhiều giá trị, 0: khach hàng, 1: nhân viên, 2 quản lý, 3: admin
	CreateDate Datetime not null,
	UpdateDate Datetime not null,
	UpdateBy VARCHAR(50)not null,
	Status NVARCHAR(20) not null, 
	IsDelete BIT not null, -- 0: false, 1: true;
);
go
INSERT INTO Users (UserName, Password, Email, FullName, PhoneNumber, Photo, Role, CreateDate, UpdateDate, UpdateBy, Status,IsDelete)
VALUES 
('minhduc1122003', '123123', 'user1@example.com', N'Lê Minh Đức KH', 123456789, null, 0, GETDATE(), GETDATE(), 0, N'Đang hoạt động',0),
('minhduc11220031', '123123', 'user1@example.com', N'Lê Minh Đức NV', 123456789, null, 1, GETDATE(), GETDATE(), 1, N'Đang hoạt động',0),
('minhduc11220032', '123123', 'user1@example.com', N'Lê Minh Đức AD', 123456789, null, 2, GETDATE(), GETDATE(), 2, N'Đang hoạt động',0)

-- BẢNG Users CHUẨN

-- + 1 bảng lịch sử hoạt động của users
-- + 1 bảng lịch sử hoạt động của admin

CREATE TABLE Cinemas(
    CinemaID INT PRIMARY KEY IDENTITY(1,1),  -- Mã rạp, tự động tăng
    CinemaName NVARCHAR(100) NOT NULL,       -- Tên rạp
    Address NVARCHAR(255) NOT NULL           -- Địa chỉ của rạp
);
go

INSERT INTO Cinemas (CinemaName, Address)
VALUES 
(N'Panthers Cinemar', N'Nguyễn Văn Quá, Quận 12, TP.HCM')

CREATE TABLE CinemaRoom (
	CinemaRoomID INT PRIMARY KEY,
    CinemaID INT,  -- Mã rạp
	FOREIGN KEY (CinemaID) REFERENCES Cinemas(CinemaID)

);
go
-- Insert dữ liệu cho bảng CinemaRoom
INSERT INTO CinemaRoom (CinemaID,CinemaRoomID)
VALUES 
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(1,6);

-- BẢNG Cinemas CHUẨN

CREATE TABLE Genre (
    IdGenre INT PRIMARY KEY IDENTITY(1,1),
    GenreName NVARCHAR(100) NOT NULL
);
go

-- Insert dữ liệu cho bảng Thể loại (Genre)
INSERT INTO Genre (GenreName)
VALUES 
(N'Hành động'),
(N'Phiêu lưu'),
(N'Hài'),
(N'Chính kịch'),
(N'Tâm lý'),
(N'Kinh dị'),
(N'Tội phạm'),
(N'Tình cảm'),
(N'Khoa học viễn tưởng'),
(N'Giả tưởng'),
(N'Hoạt hình'),
(N'Chiến tranh'),
(N'Âm nhạc'),
(N'Tài liệu'),
(N'Gia đình'),
(N'Thần thoại'),
(N'Lịch sử'),
(N'Hình sự'),
(N'Bí ẩn'),
(N'Võ thuật'),
(N'Siêu anh hùng'),
(N'Viễn Tây');


CREATE TABLE Age (
    AgeID INT PRIMARY KEY IDENTITY(1,1),
    Value NVARCHAR(10),
);
go
-- Insert dữ liệu cho bảng Tuổi(Age)
INSERT INTO Age (Value)
VALUES 
(N'K'),
(N'P'),
(N'13+'),
(N'16+'),
(N'18+');

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
	StatusMovie NVARCHAR (20) NOT NULL,
	IsDelete BIT NOT NULL
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
INSERT INTO Movies (CinemaID, Title, IdGenre, Description, Duration, ReleaseDate, PosterUrl, TrailerUrl, AgeID, SubTitle, Voiceover,StatusMovie,IsDelete)
VALUES 
(1, N'Làm Giàu Với Ma', 1, N'Kể về Lanh (Tuấn Trần) - con trai của ông Đạo làm nghề mai táng (Hoài Linh), lâm vào đường cùng vì cờ bạc. Trong cơn túng quẫn, “duyên tình” đẩy đưa anh gặp một ma nữ (Diệp Bảo Ngọc) và cùng nhau thực hiện những “kèo thơm" để phục vụ mục đích của cả hai.', 120, '2024-08-30', 'lamgiauvoima.jpg', 'https://youtu.be/2DmOv-pM1bM', 4, 1, 0,N'Đang chiếu',0),
(1, N'Tìm Kiếm Tài Năng Âm Phủ', 2, N'Newbie - một hồn ma mới, kinh hoàng nhận ra rằng cô chỉ còn 28 ngày nữa cho đến khi linh hồn của cô biến mất khỏi thế giới. Makoto, một đặc vụ quỷ tiếp cận Newbie với lời đề nghị cô kết hợp cùng ngôi sao quỷ Catherine để dựng lại câu chuyện kinh dị huyền thoại về khách sạn Wang Lai. Nếu câu chuyện đủ sức hù dọa người sống thì cái tên của cô sẽ trở thành huyền thoại và linh hồn của Newbie sẽ tiếp tục được sống dưới địa ngục.', 112, '2024-09-13', 'timkiemtainangamphu.jpg', 'https://youtu.be/KsnXHxMkf70', 4, 1, 0,N'Đang chiếu',0),
(1, N'Không Nói Điều Dữ', 3, N'
Chuyển thể từ tựa phim kinh dị nổi tiếng của Đan Mạch Gæsterne (Speak No Evil), được phát hành vào năm 2022 và đã nhận được 11 đề cử Giải thưởng Điện ảnh Đan Mạch, tương đương với giải Oscar của Đan Mạch. Bộ phim đánh dấu sự quay lại của hai tên tuổi trong làng kinh dị là Blumhouse cùng phù thủy của những nỗi sợ - James Wan. Kì nghỉ tuyệt vời của gia đình Ben bỗng trở thành cơn ác mộng khi họ làm quen với ông bà Paddy. Nhận lời mời đến nhà, Ben và Louise dần phát hiện ra những bí mật đen tối. Gã bạn mới hiện nguyên hình là một tên khát máu, hắn bắt người ăn chay trường như Louise phải ăn thịt, đánh đập đứa con và làm ra những hành động điên rồ. Ant - cậu con trai không nói được của Paddy và Ciara, liên tục thể hiện hành động kỳ lạ, cố gắng giao tiếp bằng ngôn ngữ hình thể với Agnes, con gái Ben và Louise. Cậu bé đưa Agnes đến căn hầm bí mật, nơi ẩn chứa bí mật đáng sợ trong chính ngôi nhà, một phần bóng tối dần được phơi bày. Gia đình Ben phải lao vào cuộc chiến sinh tử để thoát khỏi gã Paddy điên loạn, nhưng họ có thực sự thoát được gia đình đáng sợ kia?
', 110, '2024-09-13', 'khongnoidieudu.jpg', 'https://youtu.be/T-TQAfES10g', 5, 1, 0,N'Đang chiếu',0),
(1, N'Joker', 4, N'
Lấy bối cảnh thành phố Gotham những năm 80, Arthur Fleck lớn lên trong sự cô đơn, luôn phải cười vì lời dạy thuở nhỏ của mẹ. Nghèo khó cơ cực nên anh ta phải làm chú hề mua vui trên phố. Thế nhưng, dù khuôn mặt chú hề luôn cười nhưng nội tâm Arthur lại có vô vàn nỗi đau khi thương xuyên bị chà đạp, khinh khi. Cuối cùng, hắn trở nên điên loạn và trở thành "Hoàng tử tội phạm" Joker. Dù không liên quan đến vũ trụ điện ảnh DC mở rộng, Joker vẫn được các fan hâm mộ hết sức quan tâm.
', 110, '2024-10-04', 'joker.jpg', 'https://youtu.be/Wh28HYiM80Y', 5, 1, 0,N'Đang chiếu',0),

(1, N'Quỷ Án', 5, N'
Kể về vụ án người phụ nữ Dani bị sát hại dã man tại ngôi nhà mà vợ chồng cô đang sửa sang ở vùng nông thôn hẻo lánh. Chồng cô - Ted đang làm bác sĩ tại bệnh viện tâm thần. Mọi nghi ngờ đổ dồn vào một bệnh nhân tại đây. Không may, nghi phạm đã chết. Một năm sau, em gái mù của Dani ghé tới. Darcy là nhà ngoại cảm tự xưng, mang theo nhiều món đồ kì quái. Cô đến nhà Ted để tìm chân tướng về cái chết của chị gái.
', 110, '2024-09-13', 'quyan.jpg', 'https://youtu.be/RA5qp5btmT8', 4, 1, 0,N'Đang chiếu',0),

(1, N'Cám', 6, N'
Câu chuyện phim là dị bản kinh dị đẫm máu lấy cảm hứng từ truyện cổ tích nổi tiếng Tấm Cám, nội dung chính của phim xoay quanh Cám - em gái cùng cha khác mẹ của Tấm đồng thời sẽ có nhiều nhân vật và chi tiết sáng tạo, gợi cảm giác vừa lạ vừa quen cho khán giả. Sau loạt tác phẩm kinh dị ăn khách như Tết Ở Làng Địa Ngục, Kẻ Ăn Hồn... bộ đôi nhà sản xuất Hoàng Quân - đạo diễn Trần Hữu Tấn đã tiếp tục với một dị bản của cổ tích Việt Nam mang tên Cám. Cùng dàn diễn viên tiềm năng, vai Tấm do diễn viên Rima Thanh Vy thủ vai, trong khi vai Cám được trao cho gương mặt rất quen thuộc - Lâm Thanh Mỹ. Ngoài ra vai mẹ kế của diễn viên Thúy Diễm và vai Hoàng tử do Hải Nam đảm nhận. Dị bản sẽ cho một góc nhìn hoàn toàn khác về Tấm Cám khi sự thay đổi đến từ người nuôi cá bống lại là Cám. Cô bé có ngoại hình dị dạng, khiến cả gia đình bị dân làng cho là phù thủy. Cũng vì thế mà Cám mới là đứa con bị đối xử tệ bạc, bắt phải lựa gạo chứ không phải Tấm. Cùng với bài đồng dao về cá bống, giọng nói của Bụt trong phim mới cũng vang lên khi hỏi: “Vì sao con khóc?”. Thế nhưng, nó không mang màu sắc dịu hiền, thân thương của một vì thần tiên trong văn hóa Việt Nam mà đậm chất ma mị, kinh dị. Liệu đây có đúng là Bụt hay chính là ác quỷ đội lốt đã lừa dối Tấm và Cám từ lâu để đưa họ vào cái bẫy chết chóc?
', 122, '2024-09-20', 'cam.jpg', 'https://youtu.be/RA5qp5btmT8', 5, 1, 1,N'Sắp chiếu',0)



INSERT INTO MovieGenre (MovieID, IdGenre)
VALUES 
(1, 1),
(1, 2),
(1, 3),
(2, 1),
(2, 4),
(3, 2),
(3, 1),
(3, 6),
(4, 2),
(4, 8),
(5, 1),
(5, 2),
(6, 2),
(6, 8),
(6, 1),
(6, 5)


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




































/*
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
*/
















/*


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
	*/