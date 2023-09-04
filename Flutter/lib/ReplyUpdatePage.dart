import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:usinsaapp/ItemDetailPage.dart';
import 'dart:convert';

import 'package:usinsaapp/Reply.dart';

class ReplyUpdatePage extends StatefulWidget {
  const ReplyUpdatePage(this.id, this.bid, {Key? key}) : super(key: key);
  final int id;
  final int bid;

  @override
  State<ReplyUpdatePage> createState() => _ReplyUpdatePageState();
}

class _ReplyUpdatePageState extends State<ReplyUpdatePage> {

  final Future<SharedPreferences> future_prefs = SharedPreferences.getInstance();
  late Reply _reply;
  bool _isLoading = false;
  bool _isDeleting = false;
  String token = "";
  String username = "";

  TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    loadingPrefs();
    loadData();
    super.initState();
  }

  void loadingPrefs() async {
    SharedPreferences prefs = await future_prefs;
    token = prefs.getString("token") ?? "";
    username = prefs.getString("username") ?? "";

    setState(() {});
  }

  Future<void> loadData() async{
    setState(() {
      _isLoading = true;
    });

    try{
      String url = "http://10.0.2.2:8000/reply-service/id/${widget.id}";
      final response = await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
      });

      if (response.statusCode != 200) {
        throw Exception();
      }
      setState(() {
        _reply = Reply.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        _contentController.text = _reply.content;
      });

    } catch(e){
      print(e.toString());
    } finally{
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text("댓글 수정"),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: '댓글 내용',
                  labelStyle: TextStyle(fontSize: 30),
                ),
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: (){
                updateReply();
              },
              child: Text(
                "댓글 수정 완료",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(primary: Colors.black),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: (){
                _showDeleteConfirmationDialog(widget.id.toString());
              },
              child: Text(
                "댓글 삭제",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(primary: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateReply() async {
    String content = _contentController.text;

    setState(() {
      _isLoading = true;
    });

    try{
      String url = "http://10.0.2.2:8000/reply-service/user";
      Map<String, dynamic> body = {
        "id": widget.id,
        "content": content,
        "username": username
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

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ItemDetail(widget.bid.toString()),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "댓글 수정 성공",
            style: TextStyle(fontSize: 20),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }catch(e){
      print(e.toString());
    }finally{
      setState(() {
        _isLoading = false;
      });
    }
  }

  void deleteReply(String id) async {
    setState(() {
      _isDeleting = true;
    });
    
    try{
      String url = "http://10.0.2.2:8000/reply-service/user";
      Map<String, String> body = {"id": id};
      
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        },
        body: jsonEncode(body),
      );
      
      if (response.statusCode != 200) {
        print(response.statusCode);
        throw Exception();
      }

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ItemDetail(widget.bid.toString()),
        ),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "댓글 삭제 성공",
            style: TextStyle(fontSize: 20),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      
    }catch(e){
      print(e.toString());
    }finally{
      setState(() {
        _isDeleting = false;
      });
    }
    
  }

  Future<void> _showDeleteConfirmationDialog(String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 창 외부를 터치해도 닫히지 않도록 설정합니다.
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('댓글 삭제'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '정말로 상품을 삭제하시겠습니까?',
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
                deleteReply(widget.id.toString()); // 회원 삭제 메서드 호출
                Navigator.of(context).pop(); // 창을 닫습니다.
              },
            ),
          ],
        );
      },
    );
  }

}
