import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:usinsaapp/Reply.dart';

class ReplyList extends StatefulWidget {
  const ReplyList(this.id, {Key? key}) : super(key: key);
  final String id;

  @override
  State<ReplyList> createState() => _ReplyListState();
}

class _ReplyListState extends State<ReplyList> {

  List<Reply> replies = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  Future<void> loadReplies() async{
    if(!_isLoading){
    _isLoading = true;

    try{
      print(widget.id);
      String url = 'http://10.0.2.2:8000/reply-service/all/${widget.id}';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept-Charset": "utf-8",
        },
      );

      if(response.statusCode == 200){
        final List<dynamic> replyList = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          replyList.forEach((replyJson) {
            Reply reply = Reply.fromJson(replyJson);
            replies.add(reply);
          });
        });

      }else{
        print(response.statusCode);
        throw Exception();
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


  @override
  void initState() {
    super.initState();
    loadReplies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("댓글목록"),
      ),
      body: ListView.builder(
          controller: _scrollController,
          itemCount: replies.length,
          itemBuilder: (context, index){
            Reply reply = replies[index];
            return ListTile(
              key: ValueKey(reply.id),
              title: Text(
                "댓글 내용: " + reply.content,
              ),
              subtitle: Text(
                "댓글 작성자" + reply.username
              ),
            );
          }
      ),
    );
  }
}
