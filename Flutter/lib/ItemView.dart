import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:usinsaapp/ImageBuilder.dart';
import 'package:usinsaapp/ItemDetailPage.dart';
import 'package:usinsaapp/ItemUpdatePage.dart';
import 'package:usinsaapp/Member.dart';
import 'package:usinsaapp/MyHomePage.dart';
import 'package:usinsaapp/SearchPopup.dart';
import 'package:usinsaapp/filterButtonPressed.dart';

Item itemFromJson(String str) => Item.fromJson(json.decode(str));

String itemToJson(Item data) => json.encode(data.toJson());

class Item {
  int id;
  String itemName;
  int price;
  dynamic discount;
  dynamic salePrice;
  dynamic totalPrice;
  String username;
  int ea;
  String itemDescribe;
  String itemType;
  dynamic replyList;
  DateTime createDate;
  DateTime updateDate;

  Item({
    required this.id,
    required this.itemName,
    required this.price,
    this.discount,
    this.salePrice,
    this.totalPrice,
    required this.username,
    required this.ea,
    required this.itemDescribe,
    required this.itemType,
    this.replyList,
    required this.createDate,
    required this.updateDate,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"],
    itemName: json["itemName"],
    price: json["price"],
    discount: json["discount"],
    salePrice: json["salePrice"],
    totalPrice: json["totalPrice"],
    username: json["username"],
    ea: json["ea"],
    itemDescribe: json["itemDescribe"],
    itemType: json["itemType"],
    replyList: json["replyList"],
    createDate: DateTime.parse(json["createDate"]),
    updateDate: DateTime.parse(json["updateDate"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "itemName": itemName,
    "price": price,
    "discount": discount,
    "salePrice": salePrice,
    "totalPrice": totalPrice,
    "username": username,
    "ea": ea,
    "itemDescribe": itemDescribe,
    "itemType": itemType,
    "replyList": replyList,
    "createDate": createDate.toIso8601String(),
    "updateDate": updateDate.toIso8601String(),
  };
}

class ItemView extends StatefulWidget {
  const ItemView({Key? key}) : super(key: key);

  @override
  State<ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
  int id =0;
  int totalPage = 1;
  int currentPage = 0;
  List<Item> items = [];
  bool isLoading = false;

  Map<int, Uint8List?> imageBytesMap = {};
  final ScrollController _scrollController = ScrollController();

  Future<void> _loadImageFromServer(String id) async {
    try {
      Uint8List? imageBytes = await ImageBuilder.loadImageFromServer(id);
      setState(() {
        imageBytesMap[int.parse(id)] = imageBytes;
      });
    } catch (e) {
      print('Failed to load image: $e');
    }
  }

  Future<void> loadData(int page) async {
    if (!isLoading && page <= totalPage) {
      setState(() {
        isLoading = true;
      });

      String url =
          'http://10.0.2.2:8000/item-service/items/list?pageNum=$page';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept-Charset": "utf-8",
        },
      );

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = jsonDecode(responseBody);
        final List<dynamic> itemList = data['result']['content'];

        for (var itemJson in itemList) {
          Item item = Item.fromJson(itemJson);
          items.add(item);
          _loadImageFromServer(item.id.toString());
        }

        final int totalCount = data['result']['totalElements'];
        final int itemsPerPage = data['result']['size'];
        totalPage = (totalCount / itemsPerPage).ceil();
      }

      setState(() {
        isLoading = false;
      });
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
    loadData(currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text("전체 상품", style: TextStyle( fontFamily: 'Jalnan'),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => MyHomePage()));
          },
        ),
        actions: [
          IconButton(
              onPressed: (){
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context)=>MyHomePage()));
              },
              icon: Icon(Icons.home)
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              SearchPopup(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list_rounded),
            onPressed: () => filterButtonPressed(context),
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
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  Item item = items[index];
                  Uint8List? imageBytes = imageBytesMap[item.id];
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ItemDetail("${item.id}");
                        },
                      );
                    },
                    child: Card(
                      child: Column(
                        children: [
                          Expanded(
                            child: ImageBuilder.buildItemImage(imageBytes),
                          ),
                          ListTile(
                            key: ValueKey(item.id),
                            title: Text(
                              "상품명: " + item.itemName,
                              textAlign: TextAlign.center,
                                style: TextStyle( fontFamily: 'Jalnan'),
                            ),
                            subtitle: Text(
                              "가격: ${(item.price * (100 - item.discount) / 100).toStringAsFixed(0)}원",
                              textAlign: TextAlign.center
                                , style: TextStyle( fontFamily: 'Jalnan'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: currentPage > 0 ? () => changePage(currentPage - 1) : null,
                ),
                Text("페이지 ${currentPage+1}", style: TextStyle(fontFamily: 'Jalnan')),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: currentPage < totalPage-1 ? () => changePage(currentPage + 1) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}