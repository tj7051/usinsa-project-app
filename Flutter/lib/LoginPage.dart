import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:usinsaapp/Member.dart';
import 'dart:convert';
import 'package:usinsaapp/MyHomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  String _id = "";
  String _password = "";
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("로그인"),
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('asset/image2.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.2),
                      BlendMode.dstATop,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _idController,
                        decoration: InputDecoration(
                          labelText: "아이디",
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "비밀번호",
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        style: TextStyle(fontSize: 20),
                        obscureText: true,
                        autocorrect: false,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.black),
                        onPressed: _isLoading ? null : login,
                        child: _isLoading
                            ? CircularProgressIndicator()
                            : Text("로그인"),
                      ),
                    ],
                  ),
                ),
              ),
          ),
        ],
      ),
    );
  }

  Future<void> login() async {
    setState(() {
      _isLoading = true;
    });

    _id = _idController.text;
    _password = _passwordController.text;

    String url = "http://10.0.2.2:8000/member-service/login";

    Map<String, String> body = {"username": _id, "password": _password};

    final response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(body));

    try {
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception();
      }

      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      // 로그인 정보 저장
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["token"]);
      await prefs.setInt("role", data["role"]);
      await prefs.setString("username", data["username"]);
      print("로그인 성공");

      // Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyHomePage()));

      // Snackbar를 통한 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "로그인 성공",
            style: TextStyle(fontSize: 20),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print("로그인 실패");
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
