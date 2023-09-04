import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usinsaapp/ItemDetailPage.dart';
import 'package:usinsaapp/bookmark.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyFavoriteList extends StatefulWidget {
  const MyFavoriteList({Key? key}) : super(key: key);

  @override
  State<MyFavoriteList> createState() => _MyFavoriteListState();
}

class _MyFavoriteListState extends State<MyFavoriteList> {
  int totalPage = 1;
  int currentPage = 0;
  List<Bookmark> bookmarks = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  String username = "";
  final Future<SharedPreferences> future_prefs =
      SharedPreferences.getInstance();

  void loadingPrefs() async {
    SharedPreferences prefs = await future_prefs;
    username = prefs.getString("username") ?? "";
    loadData(currentPage);
  }

  Future<void> loadData(int page) async {
    if (!_isLoading && page <= totalPage) {
      setState(() {
        _isLoading = true;
      });

      try {
        String url =
            'http://10.0.2.2:8000/bookmark-service/username?username=$username&pageNum=$page';
        print(username);
        final response = await http.get(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept-Charset": "utf-8",
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> bookmarkList =
              jsonDecode(utf8.decode(response.bodyBytes));

          setState(() {
            bookmarkList.forEach((bookmarkJson) {
              Bookmark bookmark = Bookmark.fromJson(bookmarkJson);
              bookmarks.add(bookmark);
            });
          });
        } else {
          print(response.statusCode);
          throw Exception();
        }
      } catch (e) {
        print(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void changePage(int page) {
    if (page <= totalPage) {
      setState(() {
        currentPage = page;
      });
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      loadData(page);
    }
  }

  @override
  void initState() {
    super.initState();
    loadingPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text("좋아요", style: TextStyle(fontFamily: 'Jalnan')),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: bookmarks.length,
                itemBuilder: (context, index) {
                  Bookmark bookmark = bookmarks[index];
                  return Padding(
                    padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
                    child: Card(
                      color: Colors.white30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                "상품 이름: ${bookmark.itemName}",
                                style: TextStyle(fontSize: 20,fontFamily: 'Jalnan'),
                              ),
                              SizedBox(height: 16,),
                              Text(
                                "판매자: ${bookmark.sellerName}",
                                style: TextStyle(fontSize: 16,fontFamily: 'Jalnan'),
                              ),
                              SizedBox(height: 16,),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.black),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ItemDetail(
                                                bookmark.bid.toString()))).then(
                                        (value) => Navigator.pop(context));
                                  },
                                  child: Text(
                                    "상품 자세히 보기",
                                    style: TextStyle(fontSize: 16,fontFamily: 'Jalnan'),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: currentPage > 0
                      ? () => changePage(currentPage - 1)
                      : null,
                ),
                Text("페이지 ${currentPage + 1}", style: TextStyle(fontFamily: 'Jalnan')),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: currentPage < totalPage - 1
                      ? () => changePage(currentPage + 1)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
