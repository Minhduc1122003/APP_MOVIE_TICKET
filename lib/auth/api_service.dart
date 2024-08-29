import 'dart:convert';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/chat_item_model.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';

class ApiService {
  late String baseUrl;

  ApiService() {
    // Khởi tạo baseUrl trong constructor async
    _initBaseUrl();
  }

  Future<void> _initBaseUrl() async {
    final info = NetworkInfo();
    // String? ip = await info.getWifiIP(); // 192.168.1.43
    // wifi trọ tuan anh:
    // baseUrl = 'http://192.168.1.12:8081';

    // wifi trọ của đức:
    baseUrl = 'http://192.168.100.24:8081';

    // wifi cty
    // baseUrl = 'http://192.168.1.27:8081';

    print(baseUrl);
  }

  Future<List<User>> fetchData() async {
    await _initBaseUrl(); // Đảm bảo rằng baseUrl đã được khởi tạo

    print('Connecting to API...');

    final response = await http.get(Uri.parse(baseUrl));
    print('API response received');

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<User> users = jsonData.map((data) => User.fromJson(data)).toList();
      return users;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    await _initBaseUrl(); // Đảm bảo rằng baseUrl đã được khởi tạo

    final response = await http.post(
      Uri.parse('$baseUrl/findByViewID'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Nếu server trả về một response thành công
      return jsonDecode(response.body);
    } else {
      // Nếu server trả về một lỗi
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> createAccount(String email, String password,
      String username, String fullname, int phoneNumber, String photo) async {
    await _initBaseUrl(); // Đảm bảo rằng baseUrl đã được khởi tạo
    print('Đã vào API_Service: $phoneNumber');

    final response = await http.post(
      Uri.parse('$baseUrl/createAccount'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'username': username,
        'fullname': fullname,
        'phoneNumber': phoneNumber.toString(),
        'photo': photo,
      }),
    );

    if (response.statusCode == 200) {
      // Nếu server trả về một response thành công
      return jsonDecode(response.body);
    } else {
      // Nếu server trả về một lỗi
      throw Exception('Failed to createAccount');
    }
  }

  Future<Map<String, dynamic>> sendCodeToEmail(
      String title, String content, String recipient) async {
    await _initBaseUrl(); // Đảm bảo rằng baseUrl đã được khởi tạo

    final response = await http.post(
      Uri.parse('$baseUrl/sendEmail'), // Đổi URL thành endpoint của bạn
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'content': content,
        'recipient': recipient,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send data');
    }
  }

  // Giả sử bạn đã có sẵn model MovieDetails
  Future<List<MovieDetails>> getAllMovies() async {
    await _initBaseUrl(); // Đảm bảo rằng baseUrl đã được khởi tạo

    try {
      // Gửi yêu cầu GET đến API
      final response = await http.get(
        Uri.parse('$baseUrl/getAllMovies'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Parsed Data: $data');

        // Chuyển đổi dữ liệu từ JSON sang danh sách các đối tượng MovieDetails
        return data.map((item) => MovieDetails.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get movies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to get movies');
    }
  }

  // --------------------------------- SOCKET IO --------------------------
  Future<List<ChatItem>> getConversations(int userId) async {
    await _initBaseUrl(); // Đảm bảo rằng baseUrl đã được khởi tạo
    print('Base URL: $baseUrl');
    print('Đã vào getConversations gửi data với userId: $userId');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/getConversations'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int>{
          'userId': userId,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Parsed Data: $data');
        return data.map((item) => ChatItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get conversations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to get conversations');
    }
  }

  Future<MovieDetails> findByViewMovieID(int movieId) async {
    await _initBaseUrl(); // Đảm bảo rằng baseUrl đã được khởi tạo
    //final String movieIdString = movieId.toString();

    final response = await http.post(
      Uri.parse('$baseUrl/findByViewMovieID'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'movieId': "1", // hoặc giá trị động tùy theo ngữ cảnh
      }),
    );

    if (response.statusCode == 200) {
      // Nếu server trả về một response thành công
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      // Trích xuất phần movie
      final Map<String, dynamic> movieData = jsonData['movie'];
      final MovieDetails movieDetails = MovieDetails.fromJson(movieData);

      print('Thông tin phim: $movieData');
      print('đã nhận data : ${response.body}');
      return movieDetails;
    } else {
      // Nếu server trả về một lỗi
      throw Exception('Failed to findByViewMovieID');
    }
  }
}
