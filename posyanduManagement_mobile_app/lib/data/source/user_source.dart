import 'dart:convert';

import 'package:posyandumanagement_mobile_app/common/urls.dart';
import 'package:posyandumanagement_mobile_app/data/models/user.dart';
import 'package:d_method/d_method.dart';
import 'package:http/http.dart' as http;

class UserSource {
  /// `'${URLs.host}/users'`
  static const _baseURL = '${URLs.host}/users';

  static Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseURL/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );
      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        Map resBody = jsonDecode(response.body);
        return User.fromJson(Map.from(resBody));
      } else {
        DMethod.log('Login failed with status code: ${response.statusCode}',
            colorCode: 1);
        return null;
      }
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null;
    }
  }

  static Future<(bool, String)> addMember(String name, String email) async {
    try {
      final response = await http.post(
        Uri.parse(_baseURL),
        body: jsonEncode({
          "name": name,
          "email": email,
        }),
      );
      DMethod.logResponse(response);

      if (response.statusCode == 201) {
        return (true, "Berhasil Menambahkan Member");
      }
      if (response.statusCode == 400) {
        return (false, "Email Telah digunakan");
      }

      return (false, "Gagal Menambahkan Member");
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return (false, "Ada Kesalahan");
    }
  }

  static Future<bool> delete(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseURL/$userId'),
      );
      DMethod.logResponse(response);

      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<List<User>?> getEmlpoyee() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseURL/Member'),
      );
      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        List resBody = jsonDecode(response.body);
        return resBody.map((e) => User.fromJson(Map.from(e))).toList();
      }
      return null;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null;
    }
  }
}
