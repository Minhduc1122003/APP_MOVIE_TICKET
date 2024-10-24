import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_network.dart';
import 'package:flutter_app_chat/models/Chair_modal.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/ShowTime_modal.dart';
import 'package:flutter_app_chat/models/chat_item_model.dart';
import 'package:flutter_app_chat/models/showTimeForAdmin_model.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path/path.dart' as path;

class ApiService {
  late String baseUrl;
  ApiService() {
    _initBaseUrl();
  }
  Future<void> _initBaseUrl() async {
    final info = NetworkInfo();
    // String? ip = await info.getWifiIP(); // 192.168.1.43

    // wifi cf24/24

    baseUrl = 'http://192.168.10.20:8081';
  }

  late Response response;
  String connErr = 'Please check your internet connection and try again';
  Future<Response> getConnect(String url, String token) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    try {
      return await get(Uri.parse(url), headers: headers);
    } catch (e) {
      throw e.toString();
    }
  }

  // POST request with error handling
  Future<Response> postConnect(
      String url, Map<String, dynamic> map, String? token) async {
    var headers = {
      'Content-Type': 'application/json',
    };

    // Chỉ thêm Authorization header nếu token không null
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final uri = Uri.parse(url);
    var body = jsonEncode(map);

    try {
      return await post(
        uri,
        headers: headers,
        body: utf8.encode(body), // Sử dụng UTF-8 encoding cho body
      );
    } catch (e) {
      throw e.toString();
    }
  }

  // Future<User?> login(String username, String password, String token) async {
  //   var postData = {'username': username, 'password': password};
  //   response = await postConnect(loginAPI, postData, token);
  //   var decodedBody = utf8.decode(response.bodyBytes);
  //   print(decodedBody);
  //
  //   if (response.statusCode == statusOk) {
  //     var responseData = jsonDecode(decodedBody);
  //     print(responseData);
  //
  //     // Truy cập phần 'user' trong JSON
  //     var userData = responseData['user'];
  //     String token = responseData['token'];
  //     print(userData);
  //
  //     // Map dữ liệu user thành model User
  //     User model = User.fromJson(userData);
  //     UserManager.instance.setUser(model, token);
  //     return model;
  //   } else {
  //     print('Login API failed with status: ${response.statusCode}');
  //     return null;
  //   }
  // }

  Future<User?> login(String username, String password) async {
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
      // Giải mã response body
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Truy cập vào phần 'user' từ dữ liệu response
      final Map<String, dynamic> userData = data['user'];

      // Chuyển đổi dữ liệu user thành đối tượng User
      User model = User.fromJson(userData);

      // Lưu user và token (nếu có trong response)
      // String token = data['token']; // Giả sử token được trả về trong phần body
      UserManager.instance.setUser(model, 'token');

      return model;
    } else {
      // Nếu server trả về lỗi
      throw Exception('Failed to login');
    }
  }

  Future<User?> createAccount(String email, String password, String username,
      String fullname, int phoneNumber, String photo) async {
    var postDataAccount = {
      'email': email,
      'password': password,
      'username': username,
      'fullname': fullname,
      'phoneNumber': phoneNumber,
      'photo': photo
    };
    response = await postConnect(loginAPI, postDataAccount, '');
    print(response.statusCode);
    var decodedBody = utf8.decode(response.bodyBytes);
    print(decodedBody);

    if (response.statusCode == statusOk) {
      var responseData = jsonDecode(decodedBody);
      print(responseData);
      User model = User.fromJson(responseData);

      return model;
    } else {
      print('Login API failed with status: ${response.statusCode}');
      return null;
    }
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

  Future<List<User>?> getAllUserData(String username) async {
    await _initBaseUrl(); // Đảm bảo rằng baseUrl đã được khởi tạo
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/getAllUserData'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username, // Gửi username để server loại trừ user này
        }),
      );

      if (response.statusCode == 200) {
        // Nếu server trả về một response thành công
        final List<dynamic> jsonResponse = jsonDecode(response.body);

        // Chuyển đổi response thành danh sách User objects
        List<User> users =
            jsonResponse.map((data) => User.fromJson(data)).toList();

        return users;
      } else {
        print('Failed to load users. Status code: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error occurred: $error');
      return null;
    }
  }

  Future<List<MovieDetails>> getMoviesDangChieu() async {
    await _initBaseUrl();

    try {
      // Gửi yêu cầu GET đến API
      final response = await http.get(
        Uri.parse('$baseUrl/getMoviesDangChieu'),
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

  Future<List<MovieDetails>> getMoviesSapChieu() async {
    await _initBaseUrl(); // Đảm bảo rằng baseUrl đã được khởi tạo

    try {
      // Gửi yêu cầu GET đến API
      final response = await http.get(
        Uri.parse('$baseUrl/getMoviesSapChieu'),
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

  Future<MovieDetails?> findByViewMovieID(int movieId, int userID) async {
    await _initBaseUrl(); // Đảm bảo rằng baseUrl đã được khởi tạo
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/findByViewMovieID'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int>{
          'movieId': movieId, // Sử dụng giá trị movieId động
          'userId': userID, // Sử dụng giá trị movieId động
        }),
      );

      if (response.statusCode == 200) {
        // Nếu server trả về một response thành công
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('movie')) {
          MovieDetails details = MovieDetails.fromJson(jsonResponse['movie']);

          return MovieDetails.fromJson(jsonResponse['movie']);
        } else {
          print('Movie not found');
          return null;
        }
      } else {
        print('Failed to load movie. Status code: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error occurred: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>> addFavourite(int movieID, int userID) async {
    await _initBaseUrl(); // Đảm bảo rằng baseUrl đã được khởi tạo
    final response = await http.post(
      Uri.parse('$baseUrl/addFavourire'),
      headers: <String, String>{
        'Content-Type': 'application/json; char'
            'set=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'movieId': movieID,
        'userId': userID,
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

  Future<void> uploadImage(File image) async {
    await _initBaseUrl(); // Đảm bảo rằng baseUrl đã được khởi tạo

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/uploadImage'),
    );

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      image.path,
      filename: path.basename(image.path),
    ));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<Map<String, dynamic>> removeFavourite(int movieID, int userID) async {
    await _initBaseUrl(); // Đảm bảo rằng baseUrl đã được khởi tạo
    final response = await http.post(
      Uri.parse('$baseUrl/removeFavourire'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'movieId': movieID,
        'userId': userID,
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

  Future<List<ShowTimeDetails>> getShowtime(
      int movieID, DateTime dateGet, TimeOfDay timeGet) async {
    await _initBaseUrl(); // Đảm bảo rằng baseUrl đã được khởi tạo

    try {
      // Tạo đối tượng JSON để gửi
      final Map<String, dynamic> requestBody = {
        'movieId': movieID,
        'date': dateGet
            .toIso8601String()
            .split('T')[0], // Chuyển đổi DateTime sang định dạng ngày
        'time':
            '${timeGet.hour}:${timeGet.minute}:00' // Chuyển đổi TimeOfDay sang định dạng giờ
      };

      // Gửi yêu cầu POST đến API
      final response = await http.post(
        Uri.parse('$baseUrl/getShowtime'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody), // Gửi dữ liệu trong body
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Parsed Data: $data');

        // Chuyển đổi dữ liệu từ JSON sang danh sách các đối tượng ShowTimeDetails
        return data.map((item) => ShowTimeDetails.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get showtimes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to get showtimes');
    }
  }

  Future<List<ChairModel>> getChairList(
      int cinemaRoomID, int showTimeID) async {
    await _initBaseUrl(); // Đảm bảo rằng baseUrl đã được khởi tạo

    try {
      // Tạo đối tượng JSON để gửi
      final Map<String, dynamic> requestBody = {
        'cinemaRoomID': cinemaRoomID,
        'showTimeID': showTimeID
      };

      // Gửi yêu cầu POST đến API
      final response = await http.post(
        Uri.parse('$baseUrl/getChair'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody), // Gửi dữ liệu trong body
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Parsed Data: $data');

        // Chuyển đổi dữ liệu từ JSON sang danh sách các đối tượng ShowTimeDetails
        return data.map((item) => ChairModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get showtimes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to get showtimes');
    }
  }

  Future<Map<String, dynamic>> insertBuyTicket(
      int buyTicketId,
      String userId,
      int movieId,
      int quantity,
      double totalPrice,
      int showtimeId,
      List<int> seatIDs) async {
    await _initBaseUrl(); // Đảm bảo rằng baseUrl đã được khởi tạo

    final response = await http.post(
      Uri.parse('$baseUrl/insertBuyTicket'), // Đổi URL thành endpoint của bạn
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'buyTicketId': buyTicketId,
        'userId': userId,
        'movieId': movieId,
        'quantity': quantity,
        'totalPrice': totalPrice, // Lỗi trước đây đã được sửa
        'showtimeId': showtimeId,
        'seatIDs': seatIDs
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send data');
    }
  }

  Future<List<ShowtimeforadminModel>> getShowtimeListForAdmin() async {
    await _initBaseUrl();
    print('Connecting to API...');
    final response =
        await http.get(Uri.parse('$baseUrl/getShowtimeListForAdmin'));
    print('API response received');
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      print('jsonData : $jsonData');
      return jsonData
          .map((json) => ShowtimeforadminModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<List<User>> getUserListForAdmin() async {
    await _initBaseUrl();
    try {
      // Gửi yêu cầu GET đến API
      final response = await http.get(
        Uri.parse('$baseUrl/getUserListForAdmin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => User.fromJson(item)).toList();
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
}
