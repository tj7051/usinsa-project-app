import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:usinsaapp/ItemDetailPage.dart';
import 'package:usinsaapp/Order.dart';
import 'package:intl/intl.dart';

class MemberOrderListPage extends StatefulWidget {
  const MemberOrderListPage({Key? key}) : super(key: key);

  @override
  State<MemberOrderListPage> createState() => _MemberOrderListPageState();
}

class _MemberOrderListPageState extends State<MemberOrderListPage> {
  List<Order> orders = [];
  bool _isLoading = false;
  bool _isDeleting = false;
  String token = "";
  String username = "";
  final Future<SharedPreferences> future_prefs =
      SharedPreferences.getInstance();
  final ScrollController _scrollController = ScrollController();

  void loadingPrefs() async {
    SharedPreferences prefs = await future_prefs;
    token = prefs.getString("token") ?? "";
    username = prefs.getString("username") ?? "";
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String url = 'http://10.0.2.2:8000/order-service/orders/user/${username}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept-Charset": "utf-8",
          "Authorization": token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> orderList =
            jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          orderList.forEach((orderJson) {
            Order order = Order.fromJson(orderJson);
            orders.add(order);
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

  @override
  void initState() {
    super.initState();
    loadingPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text("장바구니", style: TextStyle(fontFamily: 'Jalnan')),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('asset/image2.jpg'),
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.2), BlendMode.dstATop))),
                child: Column(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        Order order = orders[index];
                        final formattedDate =
                            DateFormat('yyyy-MM-dd').format(order.createDate);

                        return Padding(
                          padding: EdgeInsets.all(20),
                          child: Card(
                            color: Colors.white30,
                            child: Column(
                              children: [
                                Text(
                                  "주문 번호: ${order.id}",
                                  style: TextStyle(fontSize: 20,fontFamily: 'Jalnan'),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "상품 이름: ${order.productName}",
                                  style: TextStyle(fontSize: 20,fontFamily: 'Jalnan'),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "수량: ${order.qty}",
                                  style: TextStyle(fontSize: 20,fontFamily: 'Jalnan'),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "개당 가격: ${order.unitPrice}",
                                  style: TextStyle(fontSize: 20,fontFamily: 'Jalnan'),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "총 가격: ${order.totalPrice}",
                                  style: TextStyle(fontSize: 20,fontFamily: 'Jalnan'),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "주문일: ${formattedDate}",
                                  style: TextStyle(fontSize: 20,fontFamily: 'Jalnan'),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ItemDetail(order.productId
                                                        .toString()))).then(
                                            (value) => Navigator.pop(context));
                                      },
                                      child: Text(
                                        "상품 자세히 보기",
                                        style: TextStyle(fontSize: 16,fontFamily: 'Jalnan'),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.black),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        bool? confirmed =
                                            await showDeleteConfirmationDialog(
                                                order.id.toString(),
                                                order.productId.toString(),
                                                order.qty.toString());
                                        if (confirmed == true) {
                                          setState(() {
                                            orders.removeAt(index);
                                          });
                                        }
                                      },
                                      child: Text(
                                        "주문취소",
                                        style: TextStyle(fontSize: 16,fontFamily: 'Jalnan'),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void deleteOrder(String id, String productId, String qty) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      String url = "http://10.0.2.2:8000/order-service/orders";
      Map<String, String> body = {"id": id, "productId": productId, "qty": qty};

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
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  Future<bool?> showDeleteConfirmationDialog(
      String id, String productId, String qty) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("주문 취소"),
          content: Text("주문을 취소하시겠습니까?"),
          actions: [
            TextButton(
              child: Text("취소"),
              onPressed: () {
                Navigator.of(context).pop(false); // 취소를 선택했을 때 false 반환
              },
            ),
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.of(context).pop(true); // 확인을 선택했을 때 true 반환
              },
            ),
          ],
        );
      },
    );
  }
}
