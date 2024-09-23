CREATE DATABASE APP_MOVIE_TICKET;
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

CREATE TABLE Showtime (
    ShowtimeID INT PRIMARY KEY IDENTITY(1,1),    -- Mã lịch chiếu, tự động tăng
    MovieID INT NOT NULL,                        -- Mã phim
    CinemaRoomID INT NOT NULL,                   -- Mã phòng chiếu
    ShowtimeDate DATE NOT NULL,                  -- Ngày chiếu
    StartTime TIME NOT NULL,                     -- Giờ bắt đầu
    CONSTRAINT FK_MovieID FOREIGN KEY (MovieID) REFERENCES Movies(MovieID),
    CONSTRAINT FK_CinemaRoomID FOREIGN KEY (CinemaRoomID) REFERENCES CinemaRoom(CinemaRoomID)
);
GO

-- tạo bảng chứa ghế
CREATE TABLE Seats (
    SeatID INT PRIMARY KEY IDENTITY(1,1),      -- Mã ghế tự động tăng
    CinemaRoomID INT NOT NULL,                 -- Mã phòng chiếu
    ChairCode NVARCHAR(10) NOT NULL,           -- Mã ghế (Ví dụ: A1, A2, ...)
    Status BIT NOT NULL DEFAULT 0,             -- Trạng thái ghế (0: chưa đặt, 1: đã đặt)
    FOREIGN KEY (CinemaRoomID) REFERENCES CinemaRoom(CinemaRoomID)
);
GO


DECLARE @RoomID INT = 1;  -- RoomID của phòng chiếu bắt đầu
DECLARE @Row CHAR(1);  -- Hàng ghế (A, B, C,...)
DECLARE @SeatNumber INT;  -- Số ghế (1, 2, 3,...)

WHILE @RoomID <= 6  -- Giả sử có 6 phòng chiếu
BEGIN
    SET @Row = 'A';  -- Bắt đầu từ hàng 'A'
    
    -- Duyệt qua từng hàng từ 'A' đến 'M'
    WHILE ASCII(@Row) <= ASCII('M')  
    BEGIN
        SET @SeatNumber = 1;  -- Đặt lại số ghế bắt đầu từ 1
        
        -- Duyệt qua từng ghế từ 1 đến 16 trong mỗi hàng
        WHILE @SeatNumber <= 16  
        BEGIN
            -- Xác định mã ghế theo hàng và số ghế (ví dụ A1, A2,... M16,...)
            INSERT INTO Seats (CinemaRoomID, ChairCode, Status)
            VALUES (@RoomID, @Row + CAST(@SeatNumber AS NVARCHAR(10)), 0);
            
            -- Tăng số ghế lên
            SET @SeatNumber = @SeatNumber + 1;
        END
        
        -- Chuyển sang hàng tiếp theo (A -> B -> C, v.v.)
        SET @Row = CHAR(ASCII(@Row) + 1);  
    END
    
    -- Chuyển sang phòng chiếu tiếp theo
    SET @RoomID = @RoomID + 1;
END;
GO


-- insert:
-- BẢNG Users 
INSERT INTO Users (UserName, Password, Email, FullName, PhoneNumber, Photo, Role, CreateDate, UpdateDate, UpdateBy, Status,IsDelete)
VALUES 
('minhduc1122003', '123123', 'user1@example.com', N'Lê Minh Đức KH', 123456789, null, 0, GETDATE(), GETDATE(), 0, N'Đang hoạt động',0),
('minhduc11220031', '123123', 'user1@example.com', N'Lê Minh Đức NV', 123456789, null, 1, GETDATE(), GETDATE(), 1, N'Đang hoạt động',0),
('minhduc11220032', '123123', 'user1@example.com', N'Lê Minh Đức AD', 123456789, null, 2, GETDATE(), GETDATE(), 2, N'Đang hoạt động',0)
go

-- BẢNG rạp phim
INSERT INTO Cinemas (CinemaName, Address)
VALUES 
(N'Panthers Cinemar', N'Nguyễn Văn Quá, Quận 12, TP.HCM')
go

-- Insert dữ liệu cho bảng CinemaRoom ( phòng chiếu )
INSERT INTO CinemaRoom (CinemaID,CinemaRoomID)
VALUES 
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(1,6);
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
go

-- Insert dữ liệu cho bảng Tuổi(Age)
INSERT INTO Age (Value)
VALUES 
(N'K'),
(N'P'),
(N'13+'),
(N'16+'),
(N'18+');
go

-- Insert dữ liệu cho bảng Movies(danh sách phim)

INSERT INTO Movies (CinemaID, Title, IdGenre, Description, Duration, ReleaseDate, PosterUrl, TrailerUrl, AgeID, SubTitle, Voiceover,StatusMovie,IsDelete)
VALUES 
(1, N'Làm Giàu Với Ma', 1, N'Kể về Lanh (Tuấn Trần) - con trai của ông Đạo làm nghề mai táng (Hoài Linh), lâm vào đường cùng vì cờ bạc. Trong cơn túng quẫn, “duyên tình” đẩy đưa anh gặp một ma nữ (Diệp Bảo Ngọc) và cùng nhau thực hiện những “kèo thơm" để phục vụ mục đích của cả hai.', 120, '2024-08-30', 'lamgiauvoima.jpg', 'https://youtu.be/2DmOv-pM1bM', 4, 1, 0,N'Đang chiếu',0),
(1, N'Tìm Kiếm Tài Năng Âm Phủ', 2, N'Newbie - một hồn ma mới, kinh hoàng nhận ra rằng cô chỉ còn 28 ngày nữa cho đến khi linh hồn của cô biến mất khỏi thế giới. Makoto, một đặc vụ quỷ tiếp cận Newbie với lời đề nghị cô kết hợp cùng ngôi sao quỷ Catherine để dựng lại câu chuyện kinh dị huyền thoại về khách sạn Wang Lai. Nếu câu chuyện đủ sức hù dọa người sống thì cái tên của cô sẽ trở thành huyền thoại và linh hồn của Newbie sẽ tiếp tục được sống dưới địa ngục.', 112, '2024-09-13', 'timkiemtainangamphu.jpg', 'https://youtu.be/KsnXHxMkf70', 4, 1, 0,N'Đang chiếu',0),
(1, N'Không Nói Điều Dữ', 3, N'Chuyển thể từ tựa phim kinh dị nổi tiếng của Đan Mạch Gæsterne (Speak No Evil), được phát hành vào năm 2022 và đã nhận được 11 đề cử Giải thưởng Điện ảnh Đan Mạch, tương đương với giải Oscar của Đan Mạch. Bộ phim đánh dấu sự quay lại của hai tên tuổi trong làng kinh dị là Blumhouse cùng phù thủy của những nỗi sợ - James Wan. Kì nghỉ tuyệt vời của gia đình Ben bỗng trở thành cơn ác mộng khi họ làm quen với ông bà Paddy. Nhận lời mời đến nhà, Ben và Louise dần phát hiện ra những bí mật đen tối. Gã bạn mới hiện nguyên hình là một tên khát máu, hắn bắt người ăn chay trường như Louise phải ăn thịt, đánh đập đứa con và làm ra những hành động điên rồ. Ant - cậu con trai không nói được của Paddy và Ciara, liên tục thể hiện hành động kỳ lạ, cố gắng giao tiếp bằng ngôn ngữ hình thể với Agnes, con gái Ben và Louise. Cậu bé đưa Agnes đến căn hầm bí mật, nơi ẩn chứa bí mật đáng sợ trong chính ngôi nhà, một phần bóng tối dần được phơi bày. Gia đình Ben phải lao vào cuộc chiến sinh tử để thoát khỏi gã Paddy điên loạn, nhưng họ có thực sự thoát được gia đình đáng sợ kia?', 110, '2024-09-13', 'khongnoidieudu.jpg', 'https://youtu.be/T-TQAfES10g', 5, 1, 0,N'Đang chiếu',0),
(1, N'Joker', 4, N'Lấy bối cảnh thành phố Gotham những năm 80, Arthur Fleck lớn lên trong sự cô đơn, luôn phải cười vì lời dạy thuở nhỏ của mẹ. Nghèo khó cơ cực nên anh ta phải làm chú hề mua vui trên phố. Thế nhưng, dù khuôn mặt chú hề luôn cười nhưng nội tâm Arthur lại có vô vàn nỗi đau khi thương xuyên bị chà đạp, khinh khi. Cuối cùng, hắn trở nên điên loạn và trở thành "Hoàng tử tội phạm" Joker. Dù không liên quan đến vũ trụ điện ảnh DC mở rộng, Joker vẫn được các fan hâm mộ hết sức quan tâm.', 110, '2024-10-04', 'joker.jpg', 'https://youtu.be/Wh28HYiM80Y', 5, 1, 0,N'Đang chiếu',0),

(1, N'Quỷ Án', 5, N'Kể về vụ án người phụ nữ Dani bị sát hại dã man tại ngôi nhà mà vợ chồng cô đang sửa sang ở vùng nông thôn hẻo lánh. Chồng cô - Ted đang làm bác sĩ tại bệnh viện tâm thần. Mọi nghi ngờ đổ dồn vào một bệnh nhân tại đây. Không may, nghi phạm đã chết. Một năm sau, em gái mù của Dani ghé tới. Darcy là nhà ngoại cảm tự xưng, mang theo nhiều món đồ kì quái. Cô đến nhà Ted để tìm chân tướng về cái chết của chị gái.', 110, '2024-09-13', 'quyan.jpg', 'https://youtu.be/RA5qp5btmT8', 4, 1, 0,N'Đang chiếu',0),

(1, N'The Crow: Báo Thù', 6, N'Câu chuyện phim là dị bản kinh dị đẫm máu lấy cảm hứng từ truyện cổ tích nổi tiếng Tấm Cám, nội dung chính của phim xoay quanh Cám - em gái cùng cha khác mẹ của Tấm đồng thời sẽ có nhiều nhân vật và chi tiết sáng tạo, gợi cảm giác vừa lạ vừa quen cho khán giả. Sau loạt tác phẩm kinh dị ăn khách như Tết Ở Làng Địa Ngục, Kẻ Ăn Hồn... bộ đôi nhà sản xuất Hoàng Quân - đạo diễn Trần Hữu Tấn đã tiếp tục với một dị bản của cổ tích Việt Nam mang tên Cám. Cùng dàn diễn viên tiềm năng, vai Tấm do diễn viên Rima Thanh Vy thủ vai, trong khi vai Cám được trao cho gương mặt rất quen thuộc - Lâm Thanh Mỹ. Ngoài ra vai mẹ kế của diễn viên Thúy Diễm và vai Hoàng tử do Hải Nam đảm nhận. Dị bản sẽ cho một góc nhìn hoàn toàn khác về Tấm Cám khi sự thay đổi đến từ người nuôi cá bống lại là Cám. Cô bé có ngoại hình dị dạng, khiến cả gia đình bị dân làng cho là phù thủy. Cũng vì thế mà Cám mới là đứa con bị đối xử tệ bạc, bắt phải lựa gạo chứ không phải Tấm. Cùng với bài đồng dao về cá bống, giọng nói của Bụt trong phim mới cũng vang lên khi hỏi: “Vì sao con khóc?”. Thế nhưng, nó không mang màu sắc dịu hiền, thân thương của một vì thần tiên trong văn hóa Việt Nam mà đậm chất ma mị, kinh dị. Liệu đây có đúng là Bụt hay chính là ác quỷ đội lốt đã lừa dối Tấm và Cám từ lâu để đưa họ vào cái bẫy chết chóc?', 122, '2024-09-20', 'cam.jpg', 'https://youtu.be/RA5qp5btmT8', 5, 1, 1,N'Sắp chiếu',0),
(1, N'Anh Trai Vượt Mọi Tam Tai', 7, N'Kể về Cho Su-gwang là một thanh tra cực kỳ nóng tính, dù có tỷ lệ bắt giữ tội phạm ấn tượng nhưng anh luôn gặp khó khăn trong việc kiểm soát cơn giận của mình. Vì liên tục tấn công các nghi phạm, Cho Su-gwang bị chuyển đến đảo Jeju. Tại đây, vị thanh tra nhận nhiệm vụ truy bắt kẻ lừa đảo giỏi nhất Hàn Quốc - Kim In-hae với 7 tiền án, nổi tiếng thông minh và có khả năng “thiên biến vạn hoá” để ngụy trang hoàn hảo mọi nhân dạng. Cùng lúc đó, Kim In-hae bất ngờ dính vào vụ án mạng nghiêm trọng có liên quan đến tên trùm xã hội đen đang nhăm nhe “thôn tính” đảo Jeju. Trước tình hình nguy cấp phải “giải cứu” hòn đảo Jeju và triệt phá đường dây nguy hiểm của tên trùm xã hội đen, thanh tra Cho Su-gwang bất đắc dĩ phải hợp tác cùng nghi phạm Kim In-hae, tận dụng triệt để các kỹ năng từ phá án đến lừa đảo trên hành trình rượt đuổi vừa gay cấn vừa hài hước để có thể hoàn thành nhiệm vụ cam go.', 96, '2024-09-13', 'anhtraivuotmoitamtai.jpg', 'https://youtu.be/OmmAlqNgkNI', 4, 1, 0, N'Đang chiếu', 0),
(1, N'Báo Thủ Đi Tìm Chủ', 8, N'Kể về cún cưng Gracie và mèo Pedro tinh nghịch bị lạc khỏi chủ trong một lần chuyển nhà. Các “báo thủ” bắt đầu cuộc hành trình vượt ngàn chông gai, được cứu nguy bởi bài hát viral của chủ nhân, đối đầu với các nhân vật có tiếng trong giới mộ điệu cho đến khi đoàn tụ với Sophie và Gavin để tìm đường về nhà.', 96, '2024-09-13', 'baothuditimchu.jpg', 'https://youtu.be/OmmAlqNgkNI', 3, 1, 1, N'Đang chiếu', 0),

(1, N'Longlegs: Thảm Kịch Dị Giáo', 9, N'Theo chân một đặc vụ FBI do Maika Monroe thủ vai. Cô được giao điều tra một vụ án liên quan đến kẻ giết người hàng loạt, nổi tiếng với việc để lại các dòng chữ mã hóa ở hiện trường vụ án.', 101, '2024-09-06', 'longlegs_thamkichdigiao.jpg', 'https://youtu.be/pvPRijZ8dWI', 5, 1, 0, N'Đang chiếu', 0),


-- insert sắp chiếu

(1, N'Cám', 10, N'Câu chuyện phim là dị bản kinh dị đẫm máu lấy cảm hứng từ truyện cổ tích nổi tiếng Tấm Cám, nội dung chính của phim xoay quanh Cám - em gái cùng cha khác mẹ của Tấm đồng thời sẽ có nhiều nhân vật và chi tiết sáng tạo, gợi cảm giác vừa lạ vừa quen cho khán giả. Sau loạt tác phẩm kinh dị ăn khách như Tết Ở Làng Địa Ngục, Kẻ Ăn Hồn... bộ đôi nhà sản xuất Hoàng Quân - đạo diễn Trần Hữu Tấn đã tiếp tục với một dị bản của cổ tích Việt Nam mang tên Cám. Cùng dàn diễn viên tiềm năng, vai Tấm do diễn viên Rima Thanh Vy thủ vai, trong khi vai Cám được trao cho gương mặt rất quen thuộc - Lâm Thanh Mỹ. Ngoài ra vai mẹ kế của diễn viên Thúy Diễm và vai Hoàng tử do Hải Nam đảm nhận. Dị bản sẽ cho một góc nhìn hoàn toàn khác về Tấm Cám khi sự thay đổi đến từ người nuôi cá bống lại là Cám. Cô bé có ngoại hình dị dạng, khiến cả gia đình bị dân làng cho là phù thủy. Cũng vì thế mà Cám mới là đứa con bị đối xử tệ bạc, bắt phải lựa gạo chứ không phải Tấm. Cùng với bài đồng dao về cá bống, giọng nói của Bụt trong phim mới cũng vang lên khi hỏi: “Vì sao con khóc?”. Thế nhưng, nó không mang màu sắc dịu hiền, thân thương của một vì thần tiên trong văn hóa Việt Nam mà đậm chất ma mị, kinh dị. Liệu đây có đúng là Bụt hay chính là ác quỷ đội lốt đã lừa dối Tấm và Cám từ lâu để đưa họ vào cái bẫy chết chóc?', 122, '2024-09-20', 'cam.jpg', 'https://youtu.be/RA5qp5btmT8', 5, 1, 1,N'Sắp chiếu',0),
(1, N'Cô Dâu Hào Môn', 11, N'Uyển Ân chính thức lên xe hoa trong thế giới thượng lưu của đạo diễn Vũ Ngọc Đãng qua bộ phim Cô Dâu Hào Môn. Thừa thắng xông lên sau doanh thu trăm tỷ từ Chị Chị Em Em 2, nhà sản xuất Will Vũ và đạo diễn Vũ Ngọc Đãng bắt tay thực hiện dự án Cô Dâu Hào Môn. Bộ phim xoay quanh câu chuyện làm dâu nhà hào môn dưới góc nhìn hài hước và châm biếm, hé lộ những câu chuyện kén dâu chọn rể trong giới thượng lưu. Phối hợp cùng Uyển Ân ở các phân đoạn tình cảm trong bộ phim lần này là diễn viên Samuel An. Anh được đạo diễn Vũ Ngọc Đãng “đo ni đóng giày” cho vai cậu thiếu gia Bảo Hoàng với ngoại hình điển trai, phong cách lịch lãm và gia thế khủng. Cùng góp mặt với Uyển Ân trong bộ phim đình đám lần này là sự xuất hiện của những cái tên bảo chứng phòng vé như: Thu Trang, Kiều Minh Tuấn, Samuel An, Lê Giang, NSND Hồng Vân,...', 122, '2024-10-18', 'codauhaomon.jpg', 'https://youtu.be/e9nGWTxlLDo', 5, 1, 1,N'Sắp chiếu',0),
(1, N'Hắn', 12, N'Lấy bối cảnh vùng nông thôn Nhật Bản, khi hàng loạt cái chết kì lạ xảy ra. Tất cả các nạn nhân đều có điểm chung: Trước khi chết họ gặp một người đàn ông lạ mặt trong mơ. Nữ chính Yasaka cũng không ngoại lệ. Trước khi bi kịch xảy ra, cô đang sống hạnh phúc bên chồng con. Khi ngày càng nhiều người thân qua đời, cô bắt đầu sợ ngủ. Cuối cùng, cô nhìn thấy “người đàn ông” trong giấc mơ của mình. Cái kết tồi tệ nhất sắp xảy ra…?', 122, '2024-09-20', 'han.jpg', 'https://youtu.be/dTp7pUlNUMg', 5, 1, 1,N'Sắp chiếu',0),
(1, N'Transformer Một', 13, N'Là bộ phim hoạt hình Transformers đầu tiên sau 40 năm, và để kỷ niệm 40 năm thương hiệu Transformers, bộ phim là câu chuyện gốc về quá trình Optimus Prime và Megatron từ bạn thành thù. Lấy chủ đề câu chuyện phiêu lưu hài hước tràn ngập tình đồng đội cùng những pha hành động và biến hình cực đã mắt, Transformer One hé lộ câu chuyện gốc được chờ đợi bấy lâu về cách các nhân vật mang tính biểu tượng nhất trong vũ trụ Transformers - Orion Pax và D-16 từ anh em chiến đấu trở thành Optimus Prime và Megatron - kẻ thù không đội trời chung. Với sự tham gia lồng tiếng của Chris Hemsworth và Scarlett Johansson, Transformers One hứa hẹn đưa thương hiệu Transformers lên “tầm cao mới”. Orion Pax và D-16 từng là robot công nhân “quèn” tại Cybertron. Hai robot “trẻ trâu” thường xuyên dính vào rắc rối. Những người máy thường bị cấm và chỉ được hoạt động dưới lòng đất vì bề mặt của hành tinh quê nhà là nơi cực kì nguy hiểm. Tuy nhiên, càng cấm thì càng tò mò! Orion, D-16 và các Cybertronians khác như Elita-1 và B-127 / Bumblebee quyết định thực hiện một chuyến phiêu lưu. Tại đây, họ đã chạm trán với nhiều dạng động thực vật cơ giới hóa xưa nay chưa từng thấy. Cuộc chạm trán với Alpha Trion giúp cho robot công nhân cấp thấp trở thành người máy biến hình cấu hình “xịn đét”. Ngoài ra, dường như, cũng thay đổi cả cách họ nhìn nhận thế giới, trở thành tiền đề sự chia rẽ về sau... Thời kì đầu về Optimus Prime và Megatron đã được khám phá trong loạt phim hoạt hình và truyện tranh nhưng Transformers One là tác phẩm chiếu rạp đầu tiên lấy chủ đề này. Theo nhà sản xuất loạt phim Transformers lâu năm Lorenzo di Bonaventura, Transformers One hứa hẹn quy mô khủng cỡ Unicron. Transformers One có sự tham gia của dàn diễn viên lồng tiếng cực chất bao gồm Chris Hemsworth, Brian Tyree Henry, Scarlett Johansson, Keegan-Michael Key, Jon Hamm, Laurence Fishburne và Steve Buscemi. Josh Cooley, cựu họa sĩ và nhà biên kịch Pixar, đạo diễn Toy Story 4, sẽ chỉ đạo bộ phim. Phim có Andrew Barrer và Gabriel Ferrari (Ant-Man and the Wasp) chịu trách nhiệm kịch bản. Michael Bay - đạo diễn nhiều phần phim Transformers ăn khách trước đây - là nhà sản xuất bộ phim bên cạnh Lorenzo di Bonaventura, Tom DeSanto, Don Murphy, Mark Vahradian và Aaron Dem.', 122, '2024-09-27', 'transformermot.jpg', 'https://youtu.be/YTP6joQcCho', 4, 1, 0,N'Sắp chiếu',0),
(1, N'Đố Anh Còng Được Tôi', 14, N'Các thanh tra kỳ cựu nổi tiếng đã hoạt động trở lại! Thám tử Seo Do-cheol (HWANG Jung-min) và đội điều tra tội phạm nguy hiểm của anh không ngừng truy lùng tội phạm cả ngày lẫn đêm, đặt cược cả cuộc sống cá nhân của họ. Nhận một vụ án sát hại một giáo sư, đội thanh tra nhận ra những mối liên hệ với các vụ án trong quá khứ và nảy sinh những nghi ngờ về một kẻ giết người hàng loạt. Điều này đã khiến cả nước rơi vào tình trạng hỗn loạn. Khi đội thanh tra đi sâu vào cuộc điều tra, kẻ sát nhân đã chế nhạo họ bằng cách công khai tung ra một đoạn giới thiệu trực tuyến, chỉ ra nạn nhân tiếp theo và làm gia tăng sự hỗn loạn. Để giải quyết mối đe dọa ngày càng leo thang, nhóm đã kết nạp một sĩ quan tân binh trẻ Park Sun-woo (JUNG Hae-in), dẫn đến những khúc mắc và đầy rẫy bất ngờ trong vụ án.', 122, '2024-09-27', 'doanhcongduoctoi.jpg', 'https://youtu.be/Mb3f6ZDSty0', 5, 1, 0,N'Sắp chiếu',0),
(1, N'Minh Hôn', 15, N'Diễn ra sau khi mất vợ và con gái, Won Go Myeong – một pháp sư đầy hận thù, đãphát hiện ra gã tài phiệt đứng sau cái chết gia đình ông. Với ma thuật đen, Go Myeong đã gọi hồn, triệu vong vạch trần sự thật và khiến gã tài phiệt đền mạng. Thế nhưng, mọi chuyện chỉ là khởi đầu….', 122, '2024-09-27', 'minhhon.jpg', 'https://youtu.be/x7hgcR3u5xM', 5, 1, 0,N'Sắp chiếu',0),
(1, N'Hẹn Hò Với Sát Nhân', 16, N'Cheryl Bradshaw (Anna Kendrick thủ vai) tham gia chương trình truyền hình về hẹn hò - The Dating Game với khát khao được nổi tiếng. Tại đây, cô nàng đã gặp gỡ Rodney Alcala - tên sát nhân đội lốt một nhiếp ảnh gia lãng tử và đối đáp cực kỳ hài hước, thông minh trong chương trình hẹn hò. Quyết định kết đôi cùng Rodney Alcala, trong quá trình hẹn hò, Cheryl Bradshaw dần khám phá ra hàng loạt bí mật gây sốc được che giấu khéo léo bởi cái lốt người đàn ông hoàn hảo: đội lốt một gã sát nhân, kẻ biến thái đã chủ mưu rất nhiều vụ hiếp dâm và giết người man rợ.', 122, '2024-09-27', 'henhovoisatnhan.jpg', 'https://youtu.be/64ePhFIKUA4', 5, 1, 0,N'Sắp chiếu',0),
(1, N'Joker: Folie À Deux Điên Có Đôi', 17, N'Không ngoa khi nói rằng, Joker là nhân vật phản diện nổi tiếng hàng đầu thế giới. Kẻ thù của Batman là cái tên mang tính biểu tượng từ truyện tranh đến màn ảnh rộng. Năm 2019, Todd Phillips và Joaquin Phoenix mang đến cho khán giả một Joker cực kì khác biệt, chưa từng có trong lịch sử. Phim thành công nhận 11 đề cử Oscar và thắng 2 giải, trong đó có Nam chính xuất sắc nhất cho Joaquin Phoenix. Lần này, Joker 2 trở lại, mang đến cho khán giả bộ đôi diễn viên trong mơ – Joaquin Phoenix tiếp tục trở thành Arthur Fleck còn vai diễn Harley Quinn thuộc về Lady Gaga. Chưa tham gia nhiều phim, nữ ca sĩ huyền thoại vẫn nhận được sự tin tưởng từ công chúng bởi diễn xuất chất lượng trong A Star Is Born (2018), House Of Gucci (2021). Folie À Deux là căn bệnh rối loạn tâm thần chia sẻ. Chứng bệnh khiến cả hai người cùng tiếp xúc với nguồn năng lực tiêu cực trong tâm trí. Dường như, ở Joker 2, gã hề đã “lây lan” căn bệnh đến Harley Quinn, khiến cả hai người họ “điên có đôi”. Tên phim đã khắc họa được một phần nội dung, xoáy sâu vào mối quan hệ độc hại giữa Joker và Harley Quinn. Ít nhất 15 bài hát nổi tiếng sẽ tái hiện lại trong Joker: Folie À Deux. Joker và Harley Quinn luôn đi kèm âm thanh từ bản nhạc bất hủ Close To You, What The World Needs Now,… Có lẽ, chỉ có âm nhạc mới thể hiện nổi sự điên loạn và chứng rối loạn ảo tưởng. Ngoài ra, âm nhạc còn giúp Joker: Folie À Deux khác biệt với tác phẩm thuộc DC Comic từ trước tới nay cũng như phát huy sở trường của Lady Gaga. Tất nhiên, dù hát ca nhiều bao nhiêu, phim vẫn dán nhãn R, tràn ngập bạo lực.', 122, '2024-10-04', 'joker_folieadeuxdiencodoi.jpg', 'https://youtu.be/n2k54qx9YkE', 5, 1, 0,N'Sắp chiếu',0);

go

-- insert bảng phim - thể loại
INSERT INTO MovieGenre(MovieID, IdGenre)
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
(6, 5),
(7, 2),
(7, 1),
(7, 6),
(8, 2),
(8, 8),
(9, 1),
(9, 2),
(10, 2),
(10, 1),
(10, 6),
(11, 2),
(11, 8),
(12, 1),
(12, 2),
(13, 2),
(13, 8),
(13, 1),
(13, 5),
(14, 2),
(14, 1),
(15, 2),
(15, 3),
(16, 1),
(16, 4),
(17, 2),
(17, 1),
(17, 6);
go





-- Lịch chiếu từ Rạp 1

INSERT INTO Showtime (MovieID, CinemaRoomID, ShowtimeDate, StartTime) 
VALUES 
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 1, '2024-09-30', '09:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 1, '2024-09-30', '11:15'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 1, '2024-09-30', '13:30'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 1, '2024-09-30', '15:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 1, '2024-09-30', '18:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 1, '2024-09-30', '20:15'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 1, '2024-09-30', '22:30');
go
INSERT INTO Showtime (MovieID, CinemaRoomID, ShowtimeDate, StartTime) 
VALUES 
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 2, '2024-09-30', '09:30'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 2, '2024-09-30', '11:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 2, '2024-09-30', '14:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 2, '2024-09-30', '16:15'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 2, '2024-09-30', '18:30'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 2, '2024-09-30', '20:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 2, '2024-09-30', '23:00');
go

INSERT INTO Showtime (MovieID, CinemaRoomID, ShowtimeDate, StartTime) 
VALUES 
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 3, '2024-09-30', '10:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 3, '2024-09-30', '12:15'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 3, '2024-09-30', '14:30'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 3, '2024-09-30', '16:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 3, '2024-09-30', '19:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 3, '2024-09-30', '21:15'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 3, '2024-09-30', '23:30');
go
INSERT INTO Showtime (MovieID, CinemaRoomID, ShowtimeDate, StartTime) 
VALUES 
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 4, '2024-09-30', '10:30'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 4, '2024-09-30', '12:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 4, '2024-09-30', '15:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 4, '2024-09-30', '17:15'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 4, '2024-09-30', '19:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 4, '2024-09-30', '22:00');
go
INSERT INTO Showtime (MovieID, CinemaRoomID, ShowtimeDate, StartTime) 
VALUES 
((SELECT MovieID FROM Movies WHERE Title = N'Tìm Kiếm Tài Năng Âm Phủ'), 5, '2024-09-30', '09:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Joker'), 5, '2024-09-30', '11:15'),
((SELECT MovieID FROM Movies WHERE Title = N'The Crow: Báo Thù'), 5, '2024-09-30', '13:30'),
((SELECT MovieID FROM Movies WHERE Title = N'Báo Thủ Đi Tìm Chủ'), 5, '2024-09-30', '15:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Tìm Kiếm Tài Năng Âm Phủ'), 5, '2024-09-30', '18:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Joker'), 5, '2024-09-30', '20:15'),
((SELECT MovieID FROM Movies WHERE Title = N'The Crow: Báo Thù'), 5, '2024-09-30', '22:30');
go

INSERT INTO Showtime (MovieID, CinemaRoomID, ShowtimeDate, StartTime) 
VALUES 
((SELECT MovieID FROM Movies WHERE Title = N'Không Nói Điều Dữ'), 6, '2024-09-30', '09:30'),
((SELECT MovieID FROM Movies WHERE Title = N'Quỷ Án'), 6, '2024-09-30', '11:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Anh Trai Vượt Mọi Tam Tai'), 6, '2024-09-30', '14:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Longlegs: Thảm Kịch Dị Giáo'), 6, '2024-09-30', '16:15'),
((SELECT MovieID FROM Movies WHERE Title = N'Không Nói Điều Dữ'), 6, '2024-09-30', '18:30'),
((SELECT MovieID FROM Movies WHERE Title = N'Quỷ Án'), 6, '2024-09-30', '20:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Anh Trai Vượt Mọi Tam Tai'), 6, '2024-09-30', '23:00');
go
----------------------------- ngày 29/09/2024-------------------------------------------


INSERT INTO Showtime (MovieID, CinemaRoomID, ShowtimeDate, StartTime) 
VALUES 
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 1, '2024-09-29', '09:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 1, '2024-09-29', '11:15'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 1, '2024-09-29', '13:30'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 1, '2024-09-29', '15:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 1, '2024-09-29', '18:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 1, '2024-09-29', '20:15'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 1, '2024-09-29', '22:30');
go
-- Rạp 2
INSERT INTO Showtime (MovieID, CinemaRoomID, ShowtimeDate, StartTime) 
VALUES 
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 2, '2024-09-29', '09:30'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 2, '2024-09-29', '11:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 2, '2024-09-29', '14:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 2, '2024-09-29', '16:15'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 2, '2024-09-29', '18:30'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 2, '2024-09-29', '20:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 2, '2024-09-29', '23:00');
go
-- Rạp 3
INSERT INTO Showtime (MovieID, CinemaRoomID, ShowtimeDate, StartTime) 
VALUES 
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 3, '2024-09-29', '10:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 3, '2024-09-29', '12:15'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 3, '2024-09-29', '14:30'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 3, '2024-09-29', '16:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 3, '2024-09-29', '19:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 3, '2024-09-29', '21:15'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 3, '2024-09-29', '23:30');
go
-- Rạp 4
INSERT INTO Showtime (MovieID, CinemaRoomID, ShowtimeDate, StartTime) 
VALUES 
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 4, '2024-09-29', '10:30'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 4, '2024-09-29', '12:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 4, '2024-09-29', '15:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 4, '2024-09-29', '17:15'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 4, '2024-09-29', '19:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Làm Giàu Với Ma'), 4, '2024-09-29', '22:00');
go
-- Rạp 5
INSERT INTO Showtime (MovieID, CinemaRoomID, ShowtimeDate, StartTime) 
VALUES 
((SELECT MovieID FROM Movies WHERE Title = N'Tìm Kiếm Tài Năng Âm Phủ'), 5, '2024-09-29', '09:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Joker'), 5, '2024-09-29', '11:15'),
((SELECT MovieID FROM Movies WHERE Title = N'The Crow: Báo Thù'), 5, '2024-09-29', '13:30'),
((SELECT MovieID FROM Movies WHERE Title = N'Báo Thủ Đi Tìm Chủ'), 5, '2024-09-29', '15:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Tìm Kiếm Tài Năng Âm Phủ'), 5, '2024-09-29', '18:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Joker'), 5, '2024-09-29', '20:15'),
((SELECT MovieID FROM Movies WHERE Title = N'The Crow: Báo Thù'), 5, '2024-09-29', '22:30');
go
-- Rạp 6
INSERT INTO Showtime (MovieID, CinemaRoomID, ShowtimeDate, StartTime) 
VALUES 
((SELECT MovieID FROM Movies WHERE Title = N'Không Nói Điều Dữ'), 6, '2024-09-29', '09:30'),
((SELECT MovieID FROM Movies WHERE Title = N'Quỷ Án'), 6, '2024-09-29', '11:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Anh Trai Vượt Mọi Tam Tai'), 6, '2024-09-29', '14:00'),
((SELECT MovieID FROM Movies WHERE Title = N'Longlegs: Thảm Kịch Dị Giáo'), 6, '2024-09-29', '16:15'),
((SELECT MovieID FROM Movies WHERE Title = N'Không Nói Điều Dữ'), 6, '2024-09-29', '18:30'),
((SELECT MovieID FROM Movies WHERE Title = N'Quỷ Án'), 6, '2024-09-29', '20:45'),
((SELECT MovieID FROM Movies WHERE Title = N'Anh Trai Vượt Mọi Tam Tai'), 6, '2024-09-29', '23:00');

-- Insert đánh giá cho Movie 1 (Làm Giàu Với Ma)
INSERT INTO Rate (MovieID, UserId, Content, Rating)
VALUES 
(1, 1, N'Phim rất hay và cảm động!', 1),
(1, 2, N'Cốt truyện hấp dẫn, diễn xuất tốt.', 1),
(1, 3, N'Tạm ổn, còn nhiều điểm thiếu sót.', 4),
(2, 1, N'Phim rất hay và cảm động!', 2),
(2, 2, N'Cốt truyện hấp dẫn, diễn xuất tốt.', 9),
(2, 3, N'Tạm ổn, còn nhiều điểm thiếu sót.', 5),
(3, 1, N'Phim rất hay và cảm động!', 9),
(3, 2, N'Cốt truyện hấp dẫn, diễn xuất tốt.', 7),
(3, 3, N'Tạm ổn, còn nhiều điểm thiếu sót.', 3),
(4, 1, N'Phim rất hay và cảm động!', 7),
(4, 2, N'Cốt truyện hấp dẫn, diễn xuất tốt.', 9),
(5, 3, N'Tạm ổn, còn nhiều điểm thiếu sót.', 6),
(5, 1, N'Phim rất hay và cảm động!', 2),
(5, 2, N'Cốt truyện hấp dẫn, diễn xuất tốt.', 7),
(6, 3, N'Tạm ổn, còn nhiều điểm thiếu sót.', 5),
(7, 1, N'Phim rất hay và cảm động!', 9),
(7, 2, N'Cốt truyện hấp dẫn, diễn xuất tốt.', 7),
(7, 3, N'Tạm ổn, còn nhiều điểm thiếu sót.', 9),
(7, 1, N'Phim rất hay và cảm động!', 8),
(8, 2, N'Cốt truyện hấp dẫn, diễn xuất tốt.', 6),
(8, 3, N'Tạm ổn, còn nhiều điểm thiếu sót.', 2);
go







/*
SELECT * FROM Showtime WHERE MovieID =2


DECLARE @InputDate DATE = '2024-09-30';
DECLARE @InputTime TIME = '21:00';
DECLARE @movieID INT = 1;

SELECT 
    M.Title AS MovieTitle,
    M.Duration AS MovieDuration,  -- Lấy thêm thời lượng phim
    S.CinemaRoomID,
    S.ShowtimeDate,
    S.StartTime,
    DATEADD(MINUTE, M.Duration, CAST(S.StartTime AS DATETIME)) AS EndTime  -- Tính thời gian kết thúc
FROM 
    Showtime S
JOIN 
    Movies M ON S.MovieID = M.MovieID
WHERE 
    S.ShowtimeDate = @InputDate
    AND S.StartTime > @InputTime
    AND M.MovieID = @movieID
ORDER BY 
    S.StartTime;


	*/











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
CREATE TABLE Classes (
    ClassId INT PRIMARY KEY IDENTITY(1,1), -- Thiết lập ClassId tự động tăng
    ClassName NVARCHAR(100) NOT NULL, -- Tên lớp học
    Description NVARCHAR(255), -- Mô tả lớp học
    Status NVARCHAR(20) NOT NULL -- Trạng thái lớp học
);
GO
INSERT INTO Classes (ClassName, Description, Status)
VALUES 
('Toán 10', 'Lớp học môn Toán lớp 10', N'Đang hoạt động'),
('Văn 10', 'Lớp học môn Văn lớp 10', N'Đang hoạt động'),
('Hóa 11', 'Lớp học môn Hóa lớp 11', N'Đang hoạt động'),
('Sinh 12', 'Lớp học môn Sinh lớp 12', N'Đang hoạt động'),
('Anh Văn 11', 'Lớp học môn Anh Văn lớp 11', N'Đang hoạt động');
GO

CREATE TABLE Grades (
    GradeId INT PRIMARY KEY IDENTITY(1,1), -- Thiết lập GradeId tự động tăng
    UserId INT NOT NULL, 
    ClassId INT NOT NULL, 
    Score FLOAT NOT NULL, -- Điểm số
    Status NVARCHAR(20) NOT NULL, -- Trạng thái điểm
    FOREIGN KEY (UserId) REFERENCES Users(UserId), -- Liên kết với bảng Users
    FOREIGN KEY (ClassId) REFERENCES Classes(ClassId) -- Liên kết với bảng Classes
);
GO
INSERT INTO Grades (UserId, ClassId, Score, Status)
VALUES 
(1, 1, 8.5, N'Đạt'),  -- Minh Đức KH trong lớp Toán 10
(2, 1, 9.0, N'Đạt'),  -- Minh Đức NV trong lớp Toán 10
(3, 2, 7.5, N'Đạt'),  -- Minh Đức AD trong lớp Văn 10
(1, 3, 6.0, N'Đạt'),  -- Minh Đức KH trong lớp Hóa 11
(2, 4, 9.2, N'Đạt');  -- Minh Đức NV trong lớp Sinh 12
GO
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