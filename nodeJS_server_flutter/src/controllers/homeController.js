const connection = require("../config/database");
const sql = require("mssql");
const nodemailer = require("nodemailer");
require("dotenv").config();
const crypto = require('crypto');


// Hàm xử lý cho route GET /
const getHomepage = async (req, res) => {
  let pool;
  try {
    // Kết nối đến SQL Server
    pool = await sql.connect(connection);
    console.log("Connecting to SQL Server");

    // Thực hiện một truy vấn đơn giản
    let result = await pool.request().query("SELECT * FROM accounts");

    // Gửi dữ liệu theo định dạng JSON tự động với format dễ đọc
    res.setHeader('Content-Type', 'application/json');
    res.send(JSON.stringify(result.recordset, null, 2)); // Indent with 2 spaces for readability

    console.log("Clients have connected");
  } catch (error) {
    console.error("Error fetching accounts:", error);
    res.status(500).json({ message: "Internal Server Error", error: error.message });
  } finally {
    // Đóng kết nối nếu pool đã được khởi tạo
    if (pool) {
      await pool.close(); // Đóng pool
    }
  }
};

// Hàm xử lý cho route POST /findByViewID
const findByViewID = async (req, res) => {
  console.log("Flutter has connected!");

  // Kiểm tra xem req.body có định nghĩa không
  if (!req.body) {
    return res.status(400).json({ message: "Request body is missing" });
  }

  const { username, password } = req.body || {};
  console.log("Đã nhận dữ liệu từ Flutter!");
  console.log(`Username: ${username}, Password: ${password}`);

  let pool;
  try {
    // Kết nối đến SQL Server
    pool = await sql.connect(connection);
    console.log("Đã kết nối database");

    // Thực hiện truy vấn để tìm tài khoản
    let result = await pool.request()
      .input('username', sql.VarChar, username)
      .input('password', sql.VarChar, password)
      .query("SELECT * FROM Users WHERE username = @username AND password = @password");

    // Kiểm tra xem có tài khoản nào không
    if (result.recordset.length > 0) {
      res.status(200).json({ message: "Login successful", user: result.recordset[0] });
      console.log("data:", result.recordset[0]);
    } else {
      res.status(401).json({ message: "Invalid username or password" });
      console.log("khong tim thay du lieu");

    }
  } catch (error) {
    console.error("Error fetching accounts:", error);
    res.status(500).json({ message: "Internal Server Error", error: error.message });
  } finally {
    // Đóng kết nối
    if (pool) {
      await pool.close(); // Đóng pool
    }
  }
};

// Hàm gửi email
const sendEmail = async (req, res) => {
  console.log("Sending email!");

  if (!req.body) {
    return res.status(400).json({ message: "Request body is missing" });
  }

  const { title, content, recipient } = req.body || {};
  console.log(`Title: ${title}, Content: ${content}, Recipient: ${recipient}`);
  console.log(`0===D==================>`);

  console.log(`Data from flutter:`);

  console.log(`Title:${title}`);
  console.log(`Content:${content}`);
  console.log(`Recipient:${recipient}`);

  // Cấu hình transporter
  let transporter = nodemailer.createTransport({
    service: 'gmail', // Thay đổi theo nhà cung cấp email bạn sử dụng
    auth: {
      user: process.env.MY_EMAIL, // Thay đổi thành email của bạn
      pass: process.env.MY_PASSEMAIL, // Thay đổi thành mật khẩu email của bạn
    },
  });
  const code = generateCode();
  // Cấu hình email
  let mailOptions = {
    from: process.env.MY_EMAIL, // Địa chỉ email của bạn
    to: recipient, // Địa chỉ email người nhận
    subject: 'Đăng ký tài khoản PANTHERs CINEMA', // Tiêu đề email
    html: `
      <html>
      <head>
        <style>
          body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
          }
          .container {
            width: 90%;
            max-width: 600px;
            margin: auto;
            background: #ffffff;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
          }
          .header {
            background: #6F3CD7;
            color: #ffffff;
            padding: 20px;
            text-align: center;
          }
          .header h1 {
            margin: 0;
          }
          .content {
            padding: 20px;
          }
          .footer {
            background: #f4f4f4;
            padding: 10px;
            text-align: center;
            font-size: 12px;
            color: #666;
          }
          .button {
            display: inline-block;
            background: #6F3CD7;
            color: #ffffff;
            padding: 10px 20px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: bold;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>PANTHERs CINEMA</h1>
          </div>
          <div class="content">
            <p>Chào mừng bạn đến với PANTHERs CINEMA!</p>
            <p>Để tiếp tục quá trình đăng ký tài khoản, mã code của bạn là:</p>
            <h2 style="text-align: center; color: #6F3CD7;">${code}</h2>
            <p>Vui lòng sử dụng mã này để hoàn tất quá trình đăng ký.</p>
            <p>Nếu bạn gặp bất kỳ vấn đề nào, hãy liên hệ với chúng tôi.</p>
            <p>Chân thành cảm ơn,</p>
            <p>Đội ngũ PANTHERs CINEMA</p>
          </div>
          <div class="footer">
            <p>Bạn nhận được email này vì bạn đã đăng ký trên PANTHERs CINEMA.</p>
            <p>Bạn không cần trả lời email này. Nếu bạn cần trợ giúp, vui lòng liên hệ với chúng tôi qua email hỗ trợ.</p>
          </div>
        </div>
      </body>
      </html>
    `, // Nội dung email với định dạng HTML
  };


  try {
    await transporter.sendMail(mailOptions);
    res.status(200).json({ message: "Email sent successfully", code: code });
    console.log("Email sent successfully");
  } catch (error) {
    console.error("Error sending email:", error);
    res.status(500).json({ message: "Internal Server Error", error: error.message });
  }
};

// hàm tạo tài khoản
const createAccount = async (req, res) => {
  console.log("Flutter has requested to create an account!");

  // Kiểm tra xem req.body có tồn tại không
  if (!req.body) {
    return res.status(400).json({ message: "Request body is missing" });
  }

  const { email, password, username, fullname, phoneNumber, photo } = req.body;
  console.log("Đã nhận dữ liệu tạo tài khoản từ Flutter!");
  console.log(`email: ${email}`);
  console.log(`password: ${password}`);
  console.log(`username: ${username}`);
  console.log(`fullname: ${fullname}`);
  console.log(`phoneNumber: ${phoneNumber}`);
  console.log(`photo: ${photo}`);

  let pool;
  try {
    // Kết nối đến SQL Server
    pool = await sql.connect(connection);
    console.log("Đã kết nối database");

    // Thực hiện truy vấn để tạo tài khoản
    let result = await pool.request()
      .input('username', sql.VarChar, username)
      .input('password', sql.VarChar, password)
      .input('email', sql.VarChar, email)
      .input('fullname', sql.NVarChar, fullname)
      .input('phoneNumber', sql.Int, phoneNumber)
      .input('photo', sql.VarChar, photo)
      .query(`
        INSERT INTO Users (UserName, Password, Email, FullName, PhoneNumber, Photo, Role)
        VALUES (@username, @password, @email, @fullname, @phoneNumber, @photo, 0)
      `);

    console.log('User created successfully:', result);

    // Kiểm tra kết quả của truy vấn INSERT
    if (result.rowsAffected[0] > 0) {
      res.status(200).json({ message: "Account created successfully" });
      console.log("Account created:", { username, email });
    } else {
      res.status(400).json({ message: "Account creation failed" });
      console.log("Account creation failed");
    }
  } catch (error) {
    console.error("Error creating account:", error);
    res.status(500).json({ message: "Internal Server Error", error: error.message });
  } finally {
    // Đóng kết nối
    if (pool) {
      await pool.close(); // Đóng pool
    }
  }
};

// hàm sinh code random
function generateCode(length = 8) {
  return crypto.randomBytes(length)
    .toString('hex')
    .slice(0, length)
    .toUpperCase(); // Đổi thành chữ hoa nếu cần
}


// Hàm xử lý cho route GET /movies
const getAllMovies = async (req, res) => {
  let pool;
  try {
    // Kết nối đến SQL Server
    pool = await sql.connect(connection);
    console.log("Connecting to SQL Server");

    // Thực hiện truy vấn để lấy thông tin phim, đánh giá, thể loại, rạp chiếu, thời lượng và ngày khởi chiếu
    let result = await pool.request().query(`
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

    `);

    // Gửi dữ liệu theo định dạng JSON tự động với format dễ đọc
    res.setHeader('Content-Type', 'application/json');
    res.send(JSON.stringify(result.recordset, null, 2)); // Indent with 2 spaces for readability

    console.log("Clients have connected");
  } catch (error) {
    console.error("Error fetching movies:", error);
    res.status(500).json({ message: "Internal Server Error", error: error.message });
  } finally {
    // Đóng kết nối nếu pool đã được khởi tạo
    if (pool) {
      await pool.close(); // Đóng pool
    }
  }
};


// Hàm xử lý cho route GET /movies
const findByViewMovieID = async (req, res) => {
  console.log("findByViewMovieID");

 // Kiểm tra xem req.body có định nghĩa không
 if (!req.body) {
  return res.status(400).json({ message: "Request body is missing" });
}

  const movieId = parseInt(req.body.movieId, 10);
  console.log("Đã nhận MovieID từ Flutter!");
  console.log(`MovieID: ${movieId}`);
  
  let pool;
  try {
    // Kết nối đến SQL Server
    pool = await sql.connect(connection);
    console.log("Đã kết nối database");

    // Thực hiện truy vấn để tìm thông tin phim dựa trên MovieID
    let result = await pool.request()
      .input('movieId', sql.Int, movieId)
      .query(`
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
        WHERE 
          m.MovieID = @movieId
        GROUP BY 
          m.MovieID, m.Title, m.Description, m.Duration, m.ReleaseDate, 
          m.PosterUrl, m.TrailerUrl, l.LanguageName, c.CinemaName, 
          c.Address;
      `);

    // Kiểm tra xem có dữ liệu phim nào không
    if (result.recordset.length > 0) {
      res.status(200).json({ message: "Movie found", movie: result.recordset[0] });
      console.log("Movie data:", result.recordset[0]);
    } else {
      res.status(404).json({ message: "Movie not found" });
      console.log("Không tìm thấy phim");
    }
  } catch (error) {
    console.error("Error fetching movie:", error);
    res.status(500).json({ message: "Internal Server Error", error: error.message });
  } finally {
    // Đóng kết nối
    if (pool) {
      await pool.close(); // Đóng pool
    }
  }
};















// ----------------- SOCKET IO -----------------------
const getConversations = async (req, res) => {
  const { userId } = req.body; // Lấy userId từ body của request

  // Kiểm tra giá trị userId
  if (typeof userId !== 'number') {
    return res.status(400).send('Invalid user ID');
  }

  let pool;
  try {
    pool = await sql.connect(connection);

    // Truy vấn dữ liệu từ bảng Conversations và lấy thông tin tin nhắn mới nhất và hình ảnh của người còn lại
    const result = await pool.request()
      .input('UserId', sql.Int, userId)
      .query(`
  SELECT 
    c.Id, 
    c.User1Id, 
    c.User2Id, 
    c.StartedAt, 
    MAX(m.SentAt) AS LastMessageTime,
    (SELECT TOP 1 m.Message
     FROM Messages m
     WHERE (m.SenderId = c.User1Id AND m.ReceiverId = c.User2Id)
        OR (m.SenderId = c.User2Id AND m.ReceiverId = c.User1Id)
     ORDER BY m.SentAt DESC) AS LastMessage,
    CASE 
      WHEN @UserId = c.User1Id THEN c.User2Id
      ELSE c.User1Id
    END AS OtherUserId,
    CASE 
      WHEN @UserId = c.User1Id THEN (SELECT Photo FROM Users WHERE UserId = c.User2Id)
      ELSE (SELECT Photo FROM Users WHERE UserId = c.User1Id)
    END AS OtherUserPhoto,
    CASE 
      WHEN @UserId = c.User1Id THEN (SELECT FullName FROM Users WHERE UserId = c.User2Id)
      ELSE (SELECT FullName FROM Users WHERE UserId = c.User1Id)
    END AS OtherUserName,
    @UserId AS RequesterId  -- Thêm cột RequesterId để chứa ID người gửi yêu cầu
  FROM Conversations c
  LEFT JOIN Messages m 
    ON (m.SenderId = c.User1Id AND m.ReceiverId = c.User2Id)
    OR (m.SenderId = c.User2Id AND m.ReceiverId = c.User1Id)
  WHERE c.User1Id = @UserId OR c.User2Id = @UserId
  GROUP BY c.Id, c.User1Id, c.User2Id, c.StartedAt
  ORDER BY LastMessageTime DESC
`);

    // Trả kết quả cho client
    res.json(result.recordset);
  } catch (err) {
    console.error('Failed to get conversations:', err);
    res.status(500).send('Server Error');
  } finally {
    if (pool) {
      await pool.close(); // Đóng pool
    }
  }
};


module.exports = {
  getHomepage,
  findByViewID,
  sendEmail, // Xuất hàm sendEmail
  createAccount,
  getConversations,
  getAllMovies,
  findByViewMovieID
};