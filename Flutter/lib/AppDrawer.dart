import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usinsaapp/ItemInsertPage.dart';
import 'package:usinsaapp/LoginPage.dart';
import 'package:usinsaapp/MemberInfoPage.dart';
import 'package:usinsaapp/MemberOrderListPage.dart';
import 'package:usinsaapp/MemberUpdate.dart';
import 'package:usinsaapp/MyHomePage.dart';
import 'package:usinsaapp/SignupPage.dart';
import 'package:usinsaapp/Member.dart';
import 'package:usinsaapp/my_favoritelist.dart';
import 'package:http_parser/http_parser.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late Member members;
  Uint8List? _image;
  String username = "";
  String token = "";
  int role = 0;
  bool isLoading = false;
  bool _isDeleting = false;
  String formattedCreateDate = '';
  String formattedUpdateDate = '';
  final Future<SharedPreferences> future_prefs = SharedPreferences.getInstance();

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

      bool isDeleted = await deleteImage(username);
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


  Future<void> fetchUserInfo() async {
    setState(() {
      isLoading = true;
    });
    String url = "http://10.0.2.2:8000/member-service/members/username/${username}";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
    );

    try {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          members = Member(
            username: data["username"],
            name: data["name"],
            role: data["role"],
            createDate: DateTime.parse(data["createDate"]),
            updateDate: DateTime.parse(data["updateDate"]),
            phoneNumber: data["phoneNumber"] ?? "",
            address: data["address"] ?? "",
            height: data["height"] ?? "",
            weight: data["weight"] ?? "",
          );
        });
      } else {
        throw Exception("Failed to fetch user info");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void loadingPrefs() async {
    SharedPreferences prefs = await future_prefs;
    token = prefs.getString("token") ?? "";
    role = prefs.getInt("role") ?? 0;
    username = prefs.getString("username") ?? "";

    if (username.isNotEmpty) {
      fetchUserInfo();
    }
    setState(() {});
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

  @override
  void initState() {
    super.initState();
    members = Member(id: '', username: '', name: '', createDate: DateTime.now(), updateDate: DateTime.now(), password: '', token: '', role: 0);
    loadingPrefs();
    formattedCreateDate = DateFormat('yyyy년 MM월 dd일').format(members.createDate);
    formattedUpdateDate = DateFormat('yyyy년 MM월 dd일').format(members.updateDate);
    _loadImageFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          if (token.isNotEmpty) ...[
            UserAccountsDrawerHeader(
              currentAccountPicture: Container(
                width: 150, // 아바타 영역의 가로 크기
                height: 150, // 아바타 영역의 세로 크기
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: _image != null
                          ? MemoryImage(_image! as Uint8List)
                          : AssetImage('asset/profil.png') as ImageProvider,
                      backgroundColor: Colors.white,
                      radius: 33,
                      // Other properties for the CircleAvatar
                    ),
                    Positioned(
                      right: -18,
                      bottom: -15,
                      child: IconButton(
                        icon: Icon(Icons.upload, color: Colors.white),
                        onPressed: () {
                          // 업로드 버튼 눌렀을 때 동작할 코드 작성
                          _uploadImage();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              accountName: Text("아이디: ${members.username}", style: TextStyle(fontSize: 16),),
              accountEmail: Text("이름: ${members.name}", style: TextStyle(fontSize: 16),),
              decoration: BoxDecoration(color: Colors.black),
            ),
            if (token.isNotEmpty) ...[
              ElevatedButton(
                onPressed: () {
                  Logout();
                },
                child: Text("로그아웃", style: TextStyle(fontSize: 20,fontFamily: 'Jalnan'),),
                style: ElevatedButton.styleFrom(primary: Colors.black),
              ), //로그아웃
            ],
            ListTile(
              leading: Icon(
                Icons.account_box,
                color: Colors.black,
              ),
              title: Text(
                "내 정보",
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemberInfoPage(members),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(
                Icons.shopping_bag_sharp,
                color: Colors.black,
              ),
              title: Text("장바구니", style: TextStyle(fontSize: 20),),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MemberOrderListPage()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              title: Text("좋아요", style: TextStyle(fontSize: 20),),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context)=>MyFavoriteList())
                );
              },
            ),
          ],
          Row(
            children: [
              if (token.isEmpty) ...[
                SizedBox(
                  width: 35,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text("로그인", style: TextStyle(fontSize: 20),),
                  style: ElevatedButton.styleFrom(primary: Colors.black),
                ), //로그인
                SizedBox(
                  width: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignupPage()));
                  },
                  child: Text("회원가입", style: TextStyle(fontSize: 20),),
                  style: ElevatedButton.styleFrom(primary: Colors.black),
                ),
              ],
            ],
          ),
          if (role == 1 || role == 2) ...[
            ListTile(
              leading: Icon(
                Icons.add_circle,
                color: Colors.black,
              ),
              title: Text("아이템 등록", style: TextStyle(fontSize: 20),),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ItemInsertPage()),
                );
              },
            ), //아이템등록
          ],
        ],
      ),
    );
  }

  // 회원 삭제 함수
  Future<void> deleteMember(String username) async {
    setState(() {
      _isDeleting = true;
    });

    String url = "http://10.0.2.2:8000/member-service/members/delete";

    Map<String, String> body = {"username": username};

    try {
      final response = await http.delete(Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body));

      if (response.statusCode != 200) {
        print(response.statusCode);
        throw Exception();
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", "");

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyHomePage()));
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
      _isDeleting = false;
    }
  }

  // 로그아웃
  Future<void> Logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", "");
    prefs.setString("username", "");
    prefs.setInt("role", 0);

    setState(() {
      token = ""; // token 값을 비워줍니다.
      username = "";
      role = 0;
    });
  }

}

