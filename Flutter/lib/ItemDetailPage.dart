// import 'dart:ffi';
// import 'dart:io';
import 'dart:typed_data';

// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usinsaapp/ImageBuilder.dart';
import 'package:usinsaapp/Image_Uploader.dart';
import 'package:usinsaapp/ItemUpdatePage.dart';
import 'package:usinsaapp/ItemView.dart';
import 'package:intl/intl.dart';
import 'package:usinsaapp/LoginPage.dart';
import 'package:usinsaapp/MyHomePage.dart';
import 'package:usinsaapp/OrderItem.dart';
import 'package:usinsaapp/Reply.dart';
import 'package:usinsaapp/ReplyInsertPage.dart';
import 'package:usinsaapp/ReplyUpdatePage.dart';
import 'package:usinsaapp/changenotifier.dart';

class ItemDetail extends StatefulWidget {
  const ItemDetail(this.id, {Key? key}) : super(key: key);
  final String id;

  @override
  State<ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  late TextEditingController _contentController = TextEditingController();
  late TextEditingController _qtyController = TextEditingController();
  Uint8List? _image;
  late Item item;
  bool _isLoading = false;
  String formattedCreateDate = '';
  List<Reply> replies = [];
  final ScrollController _scrollController = ScrollController();
  final Future<SharedPreferences> future_prefs =
      SharedPreferences.getInstance();
  String username = "";
  int role = 0;
  String token = "";
  bool? isFavorite;
  int viewCount = 0;

  Future<void> loadData(String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String url = 'http://10.0.2.2:8000/item-service/item/id/${widget.id}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept-Charset": "utf-8",
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          item = Item(
            id: data["id"],
            username: data["username"],
            itemName: data["itemName"],
            price: data["price"],
            discount: data["discount"],
            ea: data["ea"],
            itemDescribe: data["itemDescribe"],
            itemType: data["itemType"],
            createDate: DateTime.parse(data["createDate"]),
            updateDate: DateTime.parse(data["updateDate"]),
          );
        });
      } else {
        throw Exception();
      }
    } catch (e) {
      e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadReplies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String url = 'http://10.0.2.2:8000/reply-service/all/${widget.id}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept-Charset": "utf-8",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> replyList =
            jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          replyList.forEach((replyJson) {
            Reply reply = Reply.fromJson(replyJson);
            replies.add(reply);
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

  void loadingPrefs() async {
    SharedPreferences prefs = await future_prefs;
    role = prefs.getInt("role") ?? 0;
    username = prefs.getString("username") ?? "";
    token = prefs.getString("token") ?? "";
    loadBookmarkData();
    // setState(() {});
  }

  Future<void> _uploadImage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _image = Uint8List.fromList(bytes);
        });

        // Upload the selected image
        String bid = item.id.toString();
        String uploaderId = prefs.getString("username") ?? "";
        _deleteImage();
        String? imageUrl =
            await ImageUploader.uploadImage(_image!, bid, uploaderId);
        if (imageUrl != null) {
          // Image upload successful, do something with the image URL
        } else {
          // Image upload failed
        }
      }
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<void> _deleteImage() async {
    try {
      String bid = item.id.toString();
      bool isDeleted = await ImageUploader.deleteImage(bid);
      if (isDeleted) {
        // Image deletion successful
      } else {
        // Image deletion failed
      }
    } catch (e) {
      print('Failed to delete image: $e');
    }
  }

  Future<void> _loadImageFromServer() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _image = await ImageBuilder.loadImageFromServer(widget.id);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadBookmarkData() async {
    try {
      String url =
          'http://10.0.2.2:8000/bookmark-service/bid/${widget.id}/username/${username}';
      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          final responseData = jsonDecode(response.body);
          if (responseData.containsKey('result')) {
            Provider.of<FavoriteModel>(context, listen: false)
                .changedBookmark(true);
            isFavorite =
                Provider.of<FavoriteModel>(context, listen: false).bookmark;
          } else {
            Provider.of<FavoriteModel>(context, listen: false)
                .changedBookmark(false);
            isFavorite =
                Provider.of<FavoriteModel>(context, listen: false).bookmark;
          }
        });
      } else {
        Provider.of<FavoriteModel>(context, listen: false)
            .changedBookmark(false);
        isFavorite =
            Provider.of<FavoriteModel>(context, listen: false).bookmark;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> processCreateBookmark() async {
    Map<String, dynamic> body = {
      "bid": item.id,
      "itemName": item.itemName,
      "sellerName": item.username,
      "username": username
    };

    try {
      String url = 'http://10.0.2.2:8000/bookmark-service/createBookmark';
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        setState(() {
          isFavorite = true;
          print("즐겨찾기에 추가했습니다.");
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> processDeleteBookmark() async {
    try {
      String url = 'http://10.0.2.2:8000/bookmark-service/deleteBookmark';
      final response = await http.delete(Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"bid": item.id}));

      if (response.statusCode == 200) {
        setState(() {
          isFavorite = false;
          print("즐겨찾기가 취소되었습니다.");
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !(isFavorite ?? false);

      if (isFavorite ?? false) {
        processCreateBookmark();
      } else {
        processDeleteBookmark();
      }
    });
  }

  Future<void> loadViewCount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String url = 'http://10.0.2.2:8000/item-service/viewcount/${widget.id}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept-Charset": "utf-8",
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data != null && data['viewCount'] != null) {
          setState(() {
            viewCount = data['viewCount']; // 응답에서 조회수 가져와서 저장
          });
        } else {
          setState(() {
            viewCount = -1; // 잘못된 응답 형식이거나 데이터가 없는 경우 에러 상태로 표시
          });
        }
      } else {
        // print(response.statusCode);
        // throw Exception();
        setState(() {
          viewCount = -1; // 에러 상태로 표시
        });
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    item = Item(
      id: 0,
      username: '',
      itemName: '',
      price: 0,
      discount: 0,
      ea: 0,
      itemDescribe: '',
      itemType: '',
      createDate: DateTime.now(),
      updateDate: DateTime.now(),
    );
    loadData(widget.id);
    formattedCreateDate = DateFormat('yyyy년 MM월 dd일').format(item.createDate);
    loadReplies();
    loadingPrefs();
    _loadImageFromServer();
    loadViewCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text("상품 정보", style: TextStyle( fontFamily: 'Jalnan'),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => ItemView()));
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => MyHomePage()));
              },
              icon: Icon(Icons.home)),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                Container(
                  // height: MediaQuery.of(context).size.height - kBottomNavigationBarHeight, // 화면 아래 부분을 제외한 높이로 설정
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('asset/image2.jpg'),
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                              Colors.white.withOpacity(0.2),
                              BlendMode.dstATop))),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(
                          child: Stack(
                            children: [
                              ImageBuilder.buildItemImage(_image),
                              if (username == item.username) ...[
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: FloatingActionButton(
                                    onPressed: _uploadImage,
                                    tooltip: 'Upload Image',
                                    child: Icon(Icons.photo_library),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(width: 10,),
                                Text(
                                  "상품종류 > ${item.itemType}",
                                  style: TextStyle(fontSize: 20, color: Colors.black.withOpacity(0.6), fontFamily: 'Jalnan',),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${item.itemName}",
                                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontFamily: 'Jalnan', letterSpacing: 2),
                                ),
                              ],
                            ),
                            Divider(
                              color: Colors.grey,
                              height: 40,
                              thickness: 1,
                              indent: 20,
                              endIndent: 20,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 20,),
                                Text(
                                  "소비자가",
                                  style: TextStyle(fontSize: 20, fontFamily: 'Jalnan'),
                                ),
                                SizedBox(width: 40,),
                                Text(
                                  "${item.price}원",
                                  style: TextStyle(fontSize: 25, color: Colors.black.withOpacity(0.5), decoration: TextDecoration.lineThrough, fontFamily: 'Jalnan'),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 20,),
                                Text(
                                  "판매가",
                                  style: TextStyle(fontSize: 20, fontFamily: 'Jalnan'),
                                ),
                                SizedBox(width: 60,),
                                Text(
                                  "${(item.price * (100 - item.discount) / 100).toStringAsFixed(0)}원",
                                  style: TextStyle(fontSize: 30, fontFamily: 'Jalnan'),
                                ),
                                Text(
                                  "  ${item.discount}%",
                                  style: TextStyle(fontSize: 20, color: Colors.red, fontFamily: 'Jalnan'),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 20,),
                                Text(
                                  "재고",
                                  style: TextStyle(fontSize: 20, fontFamily: 'Jalnan'),
                                ),
                                SizedBox(width: 80,),
                                Text(
                                  "${item.ea}",
                                  style: TextStyle(fontSize: 20, fontFamily: 'Jalnan'),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 20,),
                                Text(
                                  "상품설명",
                                  style: TextStyle(fontSize: 20, fontFamily: 'Jalnan'),
                                ),
                                SizedBox(width: 42,),
                                Text(
                                  "${item.itemDescribe}",
                                  style: TextStyle(fontSize: 20, fontFamily: 'Jalnan'),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            viewCount == 0
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 20,),
                                    Text("조회수", style: TextStyle(fontSize: 20, fontFamily: 'Jalnan'),),
                                    SizedBox(width: 60,),
                                    Text("${viewCount + 1}", style: TextStyle(fontSize: 20, fontFamily: 'Jalnan'),),
                                  ],
                                )
                            // ? CircularProgressIndicator()
                                : viewCount == -1
                                ? Text("error", style: TextStyle(fontSize: 20, fontFamily: 'Jalnan'),)
                                : Row(
                                  children: [
                                    SizedBox(width: 20,),
                                    Text("조회수", style: TextStyle(fontSize: 20, fontFamily: 'Jalnan'),),
                                    SizedBox(width: 60,),
                                    Text("${viewCount + 1}", style: TextStyle(fontSize: 20, fontFamily: 'Jalnan'),),
                                  ],
                                ),
                            if (username == item.username) ...[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.black),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ItemUpdatePage("${item.id}"),
                                    ),
                                  );
                                },
                                child: Text(
                                  "아이템 수정",
                                  style: TextStyle(fontSize: 20, fontFamily: 'Jalnan'),
                                ),
                              ),
                            ],
                            SizedBox(
                              height: 30,
                            ),
                            Divider(
                              color: Colors.grey,
                              height: 40,
                              thickness: 2,
                              indent: 20,
                              endIndent: 20,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 135,
                                ),
                                Text(
                                  "댓글 목록",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30, fontFamily: 'Jalnan'),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 300,
                                  child: TextField(
                                    controller: _contentController,
                                    decoration: InputDecoration(
                                      labelText: '댓글 내용',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 12.0, horizontal: 16.0),
                                      hintText: '댓글을 입력하세요',
                                      hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Jalnan'),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide:
                                            BorderSide(color: Colors.blue),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                            color: Colors.grey[400]!),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    insertReply();
                                  },
                                  child: Text("입력", style: TextStyle( fontFamily: 'Jalnan'),),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          child: ListView.builder(
                              shrinkWrap: true,
                              controller: _scrollController,
                              itemCount: replies.length,
                              itemBuilder: (context, index) {
                                Reply reply = replies[index];
                                return ReplyTile(
                                    reply: reply,
                                    isCurrentUser: username.isNotEmpty,
                                    same: username == reply.username);
                              }),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 50, // 화면 아래 부분을 제외한 높이로 설정
                        ),
                      )
                    ],
                  ),
                ),
                if ((username != "") && (username != item.username)) ...[
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: toggleFavorite,
                            icon: Icon(
                              isFavorite ?? false
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ?? false
                                  ? Colors.red
                                  : Colors.black,
                              size: 30,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent[700],
                              fixedSize: Size(300, 50),
                            ),
                            child: Text(
                              '구매하기',
                              style: TextStyle(fontSize: 20, fontFamily: 'Jalnan'),
                            ),
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  int quantity = 0; // 수량 변수 초기값 설정
                                  return StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      return Container(
                                        height: 200,
                                        color: Colors.white,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  IconButton(
                                                    icon: Icon(Icons.remove),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (quantity > 0) {
                                                          quantity--;
                                                          _qtyController.text =
                                                              quantity
                                                                  .toString();
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  SizedBox(width: 16),
                                                  Text(
                                                    '수량: $quantity',
                                                    style:
                                                        TextStyle(fontSize: 25,fontFamily: 'Jalnan'),
                                                  ),
                                                  SizedBox(width: 16),
                                                  IconButton(
                                                    icon: Icon(Icons.add),
                                                    onPressed: () {
                                                      setState(() {
                                                        quantity++;
                                                        _qtyController.text =
                                                            quantity.toString();
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 16),
                                              Text(
                                                "총 가격은 ${item.price * quantity}원 입니다.",
                                                style: TextStyle(fontSize: 25,fontFamily: 'Jalnan'),
                                              ),
                                              SizedBox(height: 16),
                                              ElevatedButton(
                                                child: Text(
                                                  "주문 완료",
                                                  style:
                                                      TextStyle(fontSize: 30,fontFamily: 'Jalnan'),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                    primary: Colors.black),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Dialog(
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.2,
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                "총 가격은 ${item.price * quantity}원 입니다.",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,fontFamily: 'Jalnan'),
                                                              ),
                                                              Text(
                                                                "구매 하시겠습니까?",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        25,fontFamily: 'Jalnan'),
                                                              ),
                                                              SizedBox(
                                                                  height: 16),
                                                              Row(
                                                                children: [
                                                                  SizedBox(
                                                                      width:
                                                                          52),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      orderItem();
                                                                    },
                                                                    child: Text(
                                                                      "예",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              25,fontFamily: 'Jalnan'),
                                                                    ),
                                                                    style: ElevatedButton.styleFrom(
                                                                        primary:
                                                                            Colors.black),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          25),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: Text(
                                                                      "아니요",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              30,fontFamily: 'Jalnan'),
                                                                    ),
                                                                    style: ElevatedButton.styleFrom(
                                                                        primary:
                                                                            Colors.black),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Future<void> orderItem() async {
    int qty = int.tryParse(_qtyController.text) ?? 0;

    setState(() {
      _isLoading = true;
    });

    String url = "http://10.0.2.2:8000/order-service/orders";

    try {
      Map<String, dynamic> body = {
        "username": username,
        "productId": item.id,
        "productName": item.itemName,
        "unitPrice": item.price - (item.price * (item.discount / 100)),
        "qty": qty,
        "totalPrice": (item.price - (item.price * (item.discount / 100))) * qty
      };
      final response = await http.post(Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Authorization": token,
          },
          body: jsonEncode(body));

      if (response.statusCode != 201) {
        print(response.statusCode);
        throw Exception();
      }

      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ItemView()));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "상품 주문 성공",
            style: TextStyle(fontSize: 20, fontFamily: 'Jalnan'),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> insertReply() async {
    if (username.isEmpty) {
      print("로그인 후 이용가능");
      showLoginConfirmationDialog();
    }

    String content = _contentController.text;

    setState(() {
      _isLoading = true;
    });

    String url = "http://10.0.2.2:8000/reply-service/user/replys";

    try {
      Map<String, dynamic> body = {
        "username": username,
        "content": content,
        "bid": item.id,
        "productName": item.itemName
      };
      final response = await http.post(Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Authorization": token,
          },
          body: jsonEncode(body));

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetail(widget.id),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "댓글 작성 성공",
              style: TextStyle(fontSize: 20, fontFamily: 'Jalnan'),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print("댓글 작성 실패");
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool?> showLoginConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("로그인 후 이용가능", style: TextStyle(fontFamily: 'Jalnan')),
          actions: [
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.of(context).pop(true); // 확인을 선택했을 때 true 반환
              },
            ),
            TextButton(
              child: Text("로그인 하러가기", style: TextStyle(fontFamily: 'Jalnan')),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            LoginPage())); // 확인을 선택했을 때 true 반환
              },
            ),
          ],
        );
      },
    );
  }
}

class ReplyTile extends StatelessWidget {
  final Reply reply;
  final bool isCurrentUser;
  final bool same;

  const ReplyTile({required this.reply, required this.isCurrentUser, required this.same});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(reply.id),
      title: Text("${reply.content}", style: TextStyle(fontFamily: 'Jalnan')),
      subtitle: Text("댓글 작성자: ${reply.username}", style: TextStyle(fontFamily: 'Jalnan')),
      trailing: isCurrentUser && same
          ? IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ReplyUpdatePage(reply.id, reply.bid)));
              },
              icon: Icon(Icons.edit),
            )
          : null,
    );
  }
}
