import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usinsaapp/ItemDetailPage.dart';
import 'package:usinsaapp/ItemView.dart';
import 'package:usinsaapp/MyHomePage.dart';

class OrderItem extends StatefulWidget {
  const OrderItem(this.id, {Key? key}) : super(key: key);
  final String id;

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  final Future<SharedPreferences> future_prefs =
      SharedPreferences.getInstance();
  late Item item;
  bool _isLoading = false;
  String username = "";
  String token = "";

  late TextEditingController _qtyController = TextEditingController();

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
            updateDate: DateTime.parse(data["createDate"]),
          );
        });
      } else {
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
    username = prefs.getString("username") ?? "";
    token = prefs.getString("token") ?? "";
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
    loadingPrefs();
    loadData(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text("상품 주문"),
        actions: [
          IconButton(
              onPressed: (){
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context)=>MyHomePage()));
              },
              icon: Icon(Icons.home)
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
                  "주문자: ${username}",
                  style: TextStyle(fontSize: 25, fontFamily: 'Jalnan'),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "상품번호: ${item.id}",
                  style: TextStyle(fontSize: 25, fontFamily: 'Jalnan'),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "상품이름: ${item.itemName}",
                  style: TextStyle(fontSize: 25, fontFamily: 'Jalnan'),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "가격: ${item.price}",
                  style: TextStyle(fontSize: 25, fontFamily: 'Jalnan'),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  width: 200,
                  alignment: Alignment.center,
                  child: TextFormField(
                    controller: _qtyController,
                    decoration: InputDecoration(
                        labelText: '수량',
                        // contentPadding: EdgeInsets.symmetric(horizontal: 80),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(fontSize: 30, color: Colors.black)),
                    style: TextStyle(fontSize: 25, fontFamily: 'Jalnan'),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.black),
                    onPressed: () {
                      // orderItem();
                      showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: MediaQuery.of(context).size.height * 0.2,
                                child: Column(
                                  children: [
                                    Text(
                                      "총 가격은 ${item.price * (int.tryParse(_qtyController.text) ?? 0)}원 입니다.",
                                      style: TextStyle(fontSize: 25, fontFamily: 'Jalnan'),
                                    ),
                                    Text(
                                      "구매 하시겠습니까?",
                                      style: TextStyle(fontSize: 25, fontFamily: 'Jalnan'),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 40,
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            orderItem();
                                          },
                                          child: Text(
                                            "예",
                                            style: TextStyle(fontSize: 30),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.black),
                                        ),
                                        SizedBox(
                                          width: 30,
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "아니요",
                                            style: TextStyle(fontSize: 30, fontFamily: 'Jalnan'),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.black),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                    child: Text(
                      "주문 완료",
                      style: TextStyle(fontSize: 30),
                    )),
              ],
            ),
          ),
        ),
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
        "productId": widget.id,
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ItemView()));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("상품 주문 성공",
          style: TextStyle(fontSize: 20),),
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
}
