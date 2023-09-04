import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:usinsaapp/MyHomePage.dart';

class MemberUpdatePassword extends StatefulWidget {
  const MemberUpdatePassword({Key? key, required this.username}) : super(key: key);
  final String username;

  @override
  State<MemberUpdatePassword> createState() => _MemberUpdatePasswordState();
}

class _MemberUpdatePasswordState extends State<MemberUpdatePassword> {
  final Future<SharedPreferences> future_prefs =  SharedPreferences.getInstance();
  String token = "";
  bool _isLoading = false;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _password2Controller = TextEditingController();
  TextEditingController _orgPasswordController = TextEditingController();


  @override
  void initState() {
    loadingPrefs();
    loadData();
  }

  void loadingPrefs() async{

    SharedPreferences prefs = await future_prefs;
    token = prefs.getString("token") ?? "";
    setState(() {});

  }

  Future<void> loadData() async {
    setState(() {
      _isLoading = true;
    });

    try{
      String url =
          "http://10.0.2.2:8000/member-service/members/username/${widget.username}";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode != 200) {
        print(response.statusCode);
        throw Exception();
      }

      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      setState(() {
        _usernameController.text = data['username'];
      });

    }catch(e){
      print(e.toString());
    }finally{
      setState(() {
        _isLoading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? CircularProgressIndicator() : Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text("비밀번호 수정"),
        actions: [
          IconButton(
            onPressed: (){
              updatePassword();
            },
            icon: Icon(Icons.check),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('asset/image2.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.2), BlendMode.dstATop)
            )
        ),
        child: Column(
          children: [
            SizedBox(height: 20,),
            Text(
              "아이디 : ${_usernameController.text}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: _passwordController,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: "새 비밀번호"
              ),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: _password2Controller,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: "비밀번호 확인"
              ),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: _orgPasswordController,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: "기존 비밀번호"
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updatePassword() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String password2 = _password2Controller.text;
    String orgPassword = _orgPasswordController.text;

    setState(() {
      _isLoading = true;
    });

    try{
      String url = "http://10.0.2.2:8000/member-service/members/user/password";
      Map<String, dynamic> body = {
        "username": username,
        "password": password,
        "password2": password2,
        "orgPassword": orgPassword
      };

      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        },
        body: jsonEncode(body)
      );

      if (response.statusCode != 200) {
        print(response.statusCode);
        throw Exception();
      }
      Navigator.push(
          context, 
          MaterialPageRoute(builder: (context)=>MyHomePage())
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("비밀번호 수정 성공", style: TextStyle(fontSize: 20),),
          duration: Duration(seconds: 3),
        ),
      );
    } catch(e) {
      throw e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

  }

}
