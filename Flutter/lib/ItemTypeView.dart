import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usinsaapp/ImageBuilder.dart';
import 'package:usinsaapp/ItemDetailPage.dart';
import 'package:usinsaapp/ItemUpdatePage.dart';
import 'package:usinsaapp/ItemView.dart';
import 'package:usinsaapp/Member.dart';
import 'package:usinsaapp/MyHomePage.dart';
import 'package:usinsaapp/SearchPopup.dart';
import 'package:usinsaapp/filterButtonPressed.dart';

class ItemTypeView extends StatefulWidget {
  final String itemType; // itemType 매개변수 추가

  const ItemTypeView(this.itemType, {Key? key}) : super(key: key);

  @override
  State<ItemTypeView> createState() => _ItemTypeViewState();
}

class _ItemTypeViewState extends State<ItemTypeView> {
  int totalPage = 1;
  int currentPage = 0;
  List<Item> items = [];
  List<Item> filteredItems = [];
  bool isLoading = false;
  String token = "";
  final Future<SharedPreferences> future_prefs =  SharedPreferences.getInstance();

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

  Future<void> fetchItemsByType(int page, String itemType) async {
    if (!isLoading && page <= totalPage) {
      setState(() {
        isLoading = true;
      });

      String url = 'http://10.0.2.2:8000/item-service/itemtype/itemtype?itemType=$itemType&pageNum=$page'; // itemType과 page를 URL에 포함
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept-Charset": "utf-8",
          "Authorization": token,
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


        setState(() {
          if (page == 0) { // 첫 페이지일 경우에만 items 리스트를 초기화
            items.clear();
            filteredItems.clear();
          }

          itemList.forEach((itemJson) {
            Item item = Item.fromJson(itemJson);
            items.add(item);
            filteredItems.add(item);
          });
          final int totalCount = data['result']['totalElements'];
          final int itemsPerPage = data['result']['size'];
          totalPage = (totalCount / itemsPerPage).ceil();
        });
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

      fetchItemsByType(page, widget.itemType); // itemType 매개변수 전달
    }
  }

  void loadingPrefs() async{

    SharedPreferences prefs = await future_prefs;
    token = prefs.getString("token") ?? "";

    setState(() {});

  }

  @override
  void initState() {
    super.initState();
    fetchItemsByType(currentPage, widget.itemType); // itemType 매개변수 전달
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text("${widget.itemType} 상품", style: TextStyle(fontFamily: 'Jalnan')),
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
                  childAspectRatio: 0.7,
                ),
                itemCount: filteredItems.length, // filteredItems 리스트의 길이로 수정
                itemBuilder: (BuildContext context, int index) {
                  final Item item = filteredItems[index]; // filteredItems 리스트에서 아이템 가져오도록 수정
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
                                style: TextStyle(fontFamily: 'Jalnan')
                            ),
                            subtitle: Text(
                              "가격: ${(item.price * (100 - item.discount) / 100).toStringAsFixed(0)}원",
                                 style: TextStyle(fontFamily: 'Jalnan'),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isLoading)
              CircularProgressIndicator(), // 데이터 로딩 중이면 로딩 표시
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