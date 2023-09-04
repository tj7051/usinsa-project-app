import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usinsaapp/ItemDetailPage.dart';
import 'package:usinsaapp/Reply.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReplyInsertPage extends StatefulWidget {
  const ReplyInsertPage(this.id, this.itemName, {Key? key}) : super(key: key);
  final String id;
  final String itemName;

  @override
  State<ReplyInsertPage> createState() => _ReplyInsertPageState();
}

class _ReplyInsertPageState extends State<ReplyInsertPage> {
  final Future<SharedPreferences> future_prefs =  SharedPreferences.getInstance();

  late Reply _reply;
  bool _isLoading = false;
  String token = "";
  String username = "";

  late TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    loadingPrefs();
  }

  void loadingPrefs() async{
    SharedPreferences prefs = await future_prefs;
    // token = prefs.getString("token") ?? "";
    // username = prefs.getString("username") ?? "";
    setState(() {
      token = prefs.getString("token") ?? "";
      username = prefs.getString("username") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text("댓글 작성"),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('asset/image2.jpg'),
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.2), BlendMode.dstATop))
        ),
        child: Column(
          children: [
            SizedBox(height: 20,),
            Text(
              "작성자: ${username}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '내용',
                labelStyle: TextStyle(fontSize: 30)
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
                onPressed: (){
                  insertReply();
                },
                child: Text("댓글 작성 완료",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                style: ElevatedButton.styleFrom(primary: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> insertReply() async {

    String content = _contentController.text;

    setState(() {
      _isLoading = true;
    });

    String url = "http://10.0.2.2:8000/reply-service/user/replys";

    try{

      Map<String, dynamic> body = {
        "username":username,
        "content":content,
        "bid":widget.id,
        "productName":widget.itemName
      };
      final response = await http.post(Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        },
        body: jsonEncode(body)
      );


      if(response.statusCode == 200 || response.statusCode == 201){
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        print("::::::::::::::::::::::");
        print(data);
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetail(widget.id),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("댓글 작성 성공", style: TextStyle(fontSize: 20),),
            duration: Duration(seconds: 3),
          ),
        );
      }else{
        print("댓글 작성 실패");
        print(response.statusCode);
      }


    }catch(e){
      print(e.toString());
    }finally{
      setState(() {
        _isLoading = false;
      });
    }

  }

}
