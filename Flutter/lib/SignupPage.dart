import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:usinsaapp/MyHomePage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  bool _isLoading = false;

  String id = "";
  String name = "";
  String password = "";
  String password2 = "";

  TextEditingController _idController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _password2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("회원가입"),
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
                    children: [
                      TextField(
                        controller: _idController,
                        decoration: InputDecoration(
                          labelText: "아이디",
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      SizedBox(height: 20,),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "이름",
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      SizedBox(height: 20,),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "비밀번호",
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        obscureText: true,
                        autocorrect: false,
                      ),
                      SizedBox(height: 20,),
                      TextField(
                        controller: _password2Controller,
                        decoration: InputDecoration(
                          labelText: "비밀번호 확인",
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        obscureText: true,
                        autocorrect: false,
                      ),
                      SizedBox(height: 20,),
                      ElevatedButton(
                        onPressed:
                        _isLoading ? null : signup,
                        child: _isLoading ? CircularProgressIndicator() : Text("가입완료"),
                        style: ElevatedButton.styleFrom(primary: Colors.black),
                      )
                    ],
                  ),
                ),
              ),
          ),
        ],
      ),
    );
  }

  Future <void> signup() async {
    id = _idController.text;
    name = _nameController.text;
    password = _passwordController.text;
    password2 = _password2Controller.text;

    String url = "http://10.0.2.2:8000/member-service/members";

    Map<String, String> body = {
      "username" : id,
      "name" : name,
      "password" : password,
      "password2" : password2,
    };

    final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type" : "application/json"
        },
        body: jsonEncode(body)
    );

    try{
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isNotEmpty) {
          Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

          print("::::::::::::::::::::");
          print(data);
          print(data['username']);

          print("회원가입 성공");

          _idController.text = "";
          _nameController.text = "";
          _passwordController.text = "";
          _password2Controller.text = "";

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MyHomePage()));

          // Snackbar를 통한 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("회원가입 성공",style: TextStyle(fontSize: 20),),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          print("회원가입 실패");
          print("응답 본문이 비어 있습니다.");
        }
      } else {
        print("회원가입 실패");
        print("Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch(e){
      print("회원가입 실패");
      print(e.toString());
    } finally{
      setState(() {
        _isLoading = false;
      });
    }

  }

}