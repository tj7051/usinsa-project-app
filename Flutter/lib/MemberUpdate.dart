import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usinsaapp/Member.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:usinsaapp/MemberUpdatePassword.dart';
import 'package:usinsaapp/MyHomePage.dart';

class MemberUpdate extends StatefulWidget {
  const MemberUpdate(this.username, {Key? key}) : super(key: key);
  final String username;

  @override
  State<MemberUpdate> createState() => _MemberUpdateState();
}

class _MemberUpdateState extends State<MemberUpdate> {
  final Future<SharedPreferences> future_prefs =  SharedPreferences.getInstance();
  String token = "";
  late Member _member;
  bool _isLoading = false;

  late TextEditingController _usernameController;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    loadingPrefs();
    _usernameController = TextEditingController(); // 초기화 추가
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

    try {
      String url =
          "http://10.0.2.2:8000/member-service/members/username/${widget.username}";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode != 200) {
        throw Exception();
      }

      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      setState(() {
        _usernameController.text = data['username'];
        _nameController.text = data['name'];
        _phoneNumberController.text = data['phoneNumber'];
        _addressController.text = data['address'];
        _heightController.text = data['height'];
        _weightController.text = data['weight'];
      });
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              centerTitle: true,
              title: Text("회원 수정"),
              actions: [
                IconButton(
                  onPressed: () {
                    memberUpdate();
                  },
                  icon: Icon(Icons.check),
                ),
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
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "아이디: ${_usernameController.text}",
                        style: TextStyle(fontSize: 16),
                      ),
                      TextField(
                        controller: _nameController,
                        style: TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: "이름"
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _phoneNumberController,
                        style: TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                            labelText: "전화번호"
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _addressController,
                        style: TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                            labelText: "주소"
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _heightController,
                        style: TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                            labelText: "키"
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _weightController,
                        style: TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                            labelText: "체중"
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _passwordController,
                        style: TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                            labelText: "본인 확인 비밀번호"
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context)=>MemberUpdatePassword(username: widget.username))
                            );
                          },
                          child: Text("비밀번호 수정"),
                          style: ElevatedButton.styleFrom(primary: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Future<void> memberUpdate() async {
    // String id = _idController.text;
    String username = _usernameController.text;
    String name = _nameController.text;
    String phoneNumber = _phoneNumberController.text;
    String address = _addressController.text;
    String height = _heightController.text;
    String weight = _weightController.text;
    String password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    String url = "http://10.0.2.2:8000/member-service/members/user/username";

    try {
      Map<String, dynamic> body = {
        // "id": id,
        "name": name,
        "username":username,
        "phoneNumber": phoneNumber,
        "address": address,
        "height": height,
        "weight": weight,
        "password":password
      };

      final response = await http.put(Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Authorization": token,
          },
          body: jsonEncode(body));

      if (response.statusCode != 200) {
        print(response.statusCode);
        throw Exception();
      }

      // Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      Member member = Member.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("회원정보 수정 성공", style: TextStyle(fontSize: 20),),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

}
