import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usinsaapp/ItemView.dart';
import 'package:http/http.dart' as http;
import 'package:usinsaapp/Member.dart';

class ItemInsertPage extends StatefulWidget {
  const ItemInsertPage({Key? key}) : super(key: key);

  @override
  State<ItemInsertPage> createState() => _ItemInsertPageState();
}

class _ItemInsertPageState extends State<ItemInsertPage> {
  final Future<SharedPreferences> future_prefs =  SharedPreferences.getInstance();

  late Item _item;
  bool _isLoading = false;
  int salePrice = 0;
  String token = "";
  String username = "";
  int viewCount = 0;

  late TextEditingController _usernameController = TextEditingController();
  late TextEditingController _itemnameController = TextEditingController();
  late TextEditingController _discountController = TextEditingController();
  late TextEditingController _priceController = TextEditingController();
  late TextEditingController _eaController = TextEditingController();
  late TextEditingController _itemDescribeController = TextEditingController();
  late TextEditingController _itemTypeController = TextEditingController();


  List<String> itemTypes = ['상의', '하의', '모자', '가방'];
  List<bool> isCheckedList = [];

  @override
  void initState() {
    loadingPrefs();
    isCheckedList = List<bool>.filled(itemTypes.length, false);
    super.initState();
  }

  void loadingPrefs() async{

    SharedPreferences prefs = await future_prefs;
    token = prefs.getString("token") ?? "";
    username = prefs.getString("username") ?? "";

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("상품 등록"),
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ItemView()));
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              insertItem();
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('asset/image2.jpg'),
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.2), BlendMode.dstATop)
            )
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 20,),
                Text(
                  "등록자: ${username}",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _itemnameController,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: '상품 이름',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _discountController,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: '할인률',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _priceController,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: '상품 가격',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _eaController,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: '상품 재고',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _itemDescribeController,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: '상품 설명',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    showItemTypesDialog();
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _itemTypeController,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        labelText: '상품 종류',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> insertItem() async {

    // int username = int.tryParse(_usernameController.text) ?? 0;
    String itemName = _itemnameController.text;
    int discount = int.tryParse(_discountController.text) ?? 0;
    int price = int.tryParse(_priceController.text) ?? 0;
    int ea = int.tryParse(_eaController.text) ?? 0;
    String itemDescribe = _itemDescribeController.text;
    String itemType = _itemTypeController.text;

    setState(() {
      _isLoading = true;
    });

    String url = "http://10.0.2.2:8000/item-service/item/manager";
    try {
      Map<String, dynamic> body = {
        "username": username,
        "itemName": itemName,
        "discount": discount,
        "price": price,
        "ea": ea,
        "itemDescribe": itemDescribe,
        "itemType": itemType,
        "viewCount": viewCount
      };
      final response = await http.post(Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Authorization": token,
          },
          body: jsonEncode(body));

      if (response.statusCode != 200) {
        print(response.statusCode);
        throw Exception();
      }
      // Item item = Item.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      dynamic item = jsonDecode(utf8.decode(response.bodyBytes));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ItemView()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("상품등록 성공", style: TextStyle(fontSize: 20),),
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

  void showItemTypesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('상품 종류 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(itemTypes.length, (index) {
              bool value = isCheckedList[index];
              return CheckboxListTile(
                title: Text(itemTypes[index]),
                value: value,
                onChanged: (newValue) {
                  setState(() {
                    for (int i = 0; i < isCheckedList.length; i++) {
                      isCheckedList[i] = (i == index && newValue!);
                    }
                    _itemTypeController.text = getSelectedType();
                  });
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
              );
            }),
          ),
        );
      },
    );
  }

  String getSelectedType() {
    for (int i = 0; i < isCheckedList.length; i++) {
      if (isCheckedList[i]) {
        return itemTypes[i];
      }
    }
    return '';
  }


}
