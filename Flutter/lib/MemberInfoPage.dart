import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usinsaapp/Member.dart';
import 'package:usinsaapp/MemberUpdate.dart';
import 'package:http/http.dart' as http;
import 'package:usinsaapp/MyHomePage.dart';
import 'package:http_parser/http_parser.dart';

class MemberInfoPage extends StatefulWidget  {
  final Member members;

  MemberInfoPage(this.members);

  @override
  _MemberInfoPageState createState() => _MemberInfoPageState();
}

class _MemberInfoPageState extends State<MemberInfoPage> {
  bool _isDeleting = false;
  String formattedCreateDate = '';
  String formattedUpdateDate = '';
  String token = "";
  Uint8List? _image;
  Map<String, Uint8List?> imageBytes = {};
  bool isLoading = false;
  final Future<SharedPreferences> future_prefs = SharedPreferences.getInstance();


  @override
  void initState() {
    super.initState();
    formattedCreateDate =
        DateFormat('yyyy년 MM월 dd일').format(widget.members.createDate);
    formattedUpdateDate =
        DateFormat('yyyy년 MM월 dd일').format(widget.members.updateDate);
    _loadImageFromServer();
  }

  Future<Uint8List?> loadImageFromServer(String username) async {
    try {
      String url = 'http://10.0.2.2:8000/profile-service/image/$username';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image from server');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> _loadImageFromServer() async {
    SharedPreferences prefs = await future_prefs;
    String username = prefs.getString("username") ?? "";
    setState(() {
      isLoading = true;
    });

    try {
      _image = await loadImageFromServer(username);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> deleteImage(String username) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("token") ?? "";
      String url = 'http://10.0.2.2:8000/profile-service/profiledelete';

      Map<String, dynamic> body = {
        'username': username,
      };

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept-Charset": "utf-8",
          "Authorization": token,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('프로필이미지 삭제 성공');
        return true;
      } else {
        print('프로필이미지 삭제 실패');
        return false;
      }
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }


  Future<void> _deleteprofilImage() async {
    try {

      bool isDeleted = await deleteImage(widget.members.username);
      if (isDeleted) {
        // Image deletion successful
      } else {
        // Image deletion failed
      }
    } catch (e) {
      print('Failed to delete image: $e');
    }
  }

  Future<String?> uploadProfileImage(Uint8List imageBytes, String username) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("token") ?? "";
      String url = 'http://10.0.2.2:8000/profile-service/profileupload';

      Dio dio = Dio();
      dio.options.headers['Authorization'] = token;

      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: 'image.jpg',
          contentType: MediaType.parse('image/jpeg'), // Updated code
        ),
        'username': username,
      });

      var response = await dio.post(url, data: formData);
      if (response.statusCode == 200) {
        print("프로필 업로드 성공");
        return "Success";
      } else {
        print('프로필 업로드 실패');
        return null;
      }
    } catch (e) {
      print('프로필 에러: $e');
      return null;
    }
  }

  Future<void> _uploadImage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _image = Uint8List.fromList(bytes);
        });

        // Upload the selected image
        String username = prefs.getString("username") ?? "";
        _deleteprofilImage();
        String? result = await uploadProfileImage(_image!, username);

        if (result != null && result == "Success") {
          // Image upload successful
          // Do something with the response if needed
        } else {
          // Image upload failed
        }
      }
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보', style: TextStyle( fontFamily: 'Jalnan'),),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => MyHomePage()));
          },
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            SizedBox(height: 20,),
            Center(
              child: CircleAvatar(
                radius: 80, // 이미지의 반지름 크기 조정
                backgroundImage: _image != null
                    ? MemoryImage(_image! as Uint8List)
                    : AssetImage('asset/profil.png') as ImageProvider,
                backgroundColor: Colors.black,
              ),
            ),
            Positioned(
              child: IconButton(
                icon: Icon(Icons.upload, color: Colors.black, size: 50,),
                onPressed: () {
                  // 업로드 버튼 눌렀을 때 동작할 코드 작성
                  _uploadImage();
                },
              ),
            ),
            Divider(
              color: Colors.grey,
              height: 40,
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            Text(
              '아이디:       ${widget.members.username}',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'Jalnan'),
            ),
            SizedBox(height: 10),
            Text(
              '이름:          ${widget.members.name}',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'Jalnan'),
            ),
            SizedBox(height: 10),
            Text(
              '전화번호:    ${widget.members.phoneNumber}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Jalnan'),
            ),
            SizedBox(height: 10),
            Text(
              '주소:     ${widget.members.address}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Jalnan'),
            ),
            SizedBox(height: 10),
            Text(
              '키:    ${widget.members.height}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Jalnan',),
            ),
            SizedBox(height: 10),
            Text(
              '체중:    ${widget.members.weight}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Jalnan'),
            ),
            SizedBox(height: 10),
            Text(
              '회원 생성일:    ${formattedCreateDate}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Jalnan'),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemberUpdate(widget.members.username),
                    ),
                  );
                },
                child: Text('회원수정', style: TextStyle(fontSize: 20, fontFamily: 'Jalnan'),),
                style: ElevatedButton.styleFrom(primary: Colors.black, fixedSize: Size(200, 50), ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showDeleteConfirmationDialog(context, widget.members.username);
                },
                child: Text('회원삭제', style: TextStyle(fontSize: 20, fontFamily: 'Jalnan',),),
                style: ElevatedButton.styleFrom(primary: Colors.black, fixedSize: Size(200, 50), ),
              ),
            ),
          ],
        ),
      ),
    );

  }

  // 회원 삭제 함수
  Future<void> deleteMember(BuildContext context, String username) async {
    setState(() {
      _isDeleting = true;
    });

    String url = "http://10.0.2.2:8000/member-service/members/delete";

    Map<String, String> body = {"username": username};

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        print(response.statusCode);
        throw Exception();
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", "");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "회원삭제 성공",
            style: TextStyle(fontSize: 20),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  // 회원삭제 경고창
  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String username) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 창 외부를 터치해도 닫히지 않도록 설정합니다.
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('회원 삭제'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '정말로 회원을 삭제하시겠습니까?',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  '이 작업은 되돌릴 수 없습니다.',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '취소',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 창을 닫습니다.
              },
            ),
            TextButton(
              child: Text(
                '삭제',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                deleteMember(context, username); // 회원 삭제 메서드 호출
                Navigator.of(context).pop(); // 창을 닫습니다.
              },
            ),
          ],
        );
      },
    );
  }

}