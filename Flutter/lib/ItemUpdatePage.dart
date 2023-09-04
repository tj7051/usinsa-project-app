import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usinsaapp/ItemView.dart';

class ItemUpdatePage extends StatefulWidget {
  const ItemUpdatePage(this.id, {Key? key}) : super(key: key);
  final String id;

  @override
  State<ItemUpdatePage> createState() => _ItemUpdatePageState();
}

class _ItemUpdatePageState extends State<ItemUpdatePage> {
  final Future<SharedPreferences> future_prefs =
      SharedPreferences.getInstance();
  late Item _item;
  bool _isLoading = false;
  bool _isDeleting = false;
  int salePrice = 0;
  String token = "";

  late TextEditingController _idController;
  TextEditingController _itemnameController = TextEditingController();
  TextEditingController _discountController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _eaController = TextEditingController();
  TextEditingController _itemDescribeController = TextEditingController();
  TextEditingController _itemTypeController = TextEditingController();

  List<String> itemTypes = ['상의', '하의', '모자', '가방'];
  List<bool> isCheckedList = [];

  @override
  void initState() {
    loadingPrefs();
    loadData();
    isCheckedList = List<bool>.filled(itemTypes.length, false);
    super.initState();
  }

  void loadingPrefs() async {
    SharedPreferences prefs = await future_prefs;
    token = prefs.getString("token") ?? "";

    setState(() {});
  }

  Future<void> loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String url = "http://10.0.2.2:8000/item-service/item/id/${widget.id}";
      final response = await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
      });

      if (response.statusCode != 200) {
        throw Exception();
      }
      setState(() {
        _item = Item.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        _idController = TextEditingController(text: _item.id.toString());
        _itemnameController.text = _item.itemName;
        _discountController.text = _item.discount.toString();
        _priceController.text = _item.price.toString();
        _eaController.text = _item.ea.toString();
        _itemDescribeController.text = _item.itemDescribe;
        _itemTypeController.text = _item.itemType;
      });
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : Scaffold(
            appBar: AppBar(
              title: Text("수정: (상품코드) ${widget.id}"),
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
                    itemUpdate();
                  },
                  icon: Icon(Icons.check),
                ),
                IconButton(
                  onPressed: () {
                    _showDeleteConfirmationDialog(widget.id);
                    ;
                  },
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('asset/image2.jpg'),
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                          Colors.white.withOpacity(0.2), BlendMode.dstATop))),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
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

  Future<void> itemUpdate() async {
    int id = int.parse(_idController.text);
    String itemName = _itemnameController.text;
    int discount = int.parse(_discountController.text);
    int price = int.parse(_priceController.text);
    int ea = int.parse(_eaController.text);
    String itemDescribe = _itemDescribeController.text;
    String itemType = _itemTypeController.text;

    setState(() {
      _isLoading = true;
    });

    String url = "http://10.0.2.2:8000/item-service/item/manager/update";
    try {
      Map<String, dynamic> body = {
        "id": id,
        "itemName": itemName,
        "discount": discount,
        "price": price,
        "ea": ea,
        "itemDescribe": itemDescribe,
        "itemType": itemType
      };
      final response = await http.put(Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Authorization": token,
          },
          body: jsonEncode(body));

      if (response.statusCode != 200) {
        print(response.statusCode);
        throw Exception();
      }
      Item item = Item.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ItemView()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "상품 수정 성공",
            style: TextStyle(fontSize: 20),
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

  void deleteItem(String id) async {
    setState(() {
      _isDeleting = true;
    });

    String url = "http://10.0.2.2:8000/item-service/item/manager";

    Map<String, String> body = {"id": id};

    try {
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ItemView()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "상품삭제 성공",
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

  Future<void> _showDeleteConfirmationDialog(String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 창 외부를 터치해도 닫히지 않도록 설정합니다.
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('상품 삭제'),
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
                deleteItem(widget.id); // 회원 삭제 메서드 호출
                Navigator.of(context).pop(); // 창을 닫습니다.
              },
            ),
          ],
        );
      },
    );
  }
}
