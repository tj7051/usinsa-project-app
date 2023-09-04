import 'dart:typed_data';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usinsaapp/AppDrawer.dart';
import 'package:usinsaapp/ImageBuilder.dart';
import 'package:usinsaapp/ItemDetailPage.dart';
import 'package:usinsaapp/ItemView.dart';
import 'package:usinsaapp/SearchPopup.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:usinsaapp/filterButtonPressed.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CarouselController controller = CarouselController();
  bool showList = false;
  int current = 0;
  List<Item> items = [];
  bool isLoading = false;
  Map<int, Uint8List?> imageBytesMap = {};
  List imageList = ["asset/image2.png", "asset/image2.jpg", "asset/image3.jpg"];

  Future<void> _loadImageFromServer(String id) async {
    try {
      Uint8List? imageBytes = await ImageBuilder.loadImageFromServer(id);
      setState(() {});
      imageBytesMap[int.parse(id)] = imageBytes;
    } catch (e) {
      print('Failed to load image: $e');
    }
  }

  Future<void> loadData() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      String url = 'http://10.0.2.2:8000/item-service/items/all';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept-Charset": "utf-8",
        },
      );

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> itemList = jsonDecode(responseBody);

        for (var itemJson in itemList) {
          Item item = Item.fromJson(itemJson);
          items.add(item);
          _loadImageFromServer(item.id.toString());
        }

        setState(() {
          items.clear();
          itemList.forEach((itemJson) {
            Item item = Item.fromJson(itemJson);
            items.add(item);
          });
        });
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    List<Item> sortedItems = List.from(items.reversed);

    return Scaffold(
      appBar: AppBar(
        title: Text("USINSA", style: TextStyle( fontFamily: 'Jalnan'),),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
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
      drawer: AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('asset/image2.jpg'),
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.2), BlendMode.dstATop))),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 350,
                child: Stack(
                  children: [
                    sliderWidget(),
                    sliderIndicator(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 100),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "최신 상품",
                            style: TextStyle(
                              fontSize: 30,
                                fontFamily: 'Jalnan'
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ItemView()),
                          );
                        },
                        child: Text("전체보기", style: TextStyle( fontFamily: 'Jalnan'),),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 0.733,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= sortedItems.length) {
                    return null;
                  }

                  Item item = sortedItems[index];
                  Uint8List? imageBytes = imageBytesMap[item.id];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetail("${item.id}"),
                          ),
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
                                "상품명: ${item.itemName}",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20,fontFamily: 'Jalnan'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: 10, // 실제 아이템의 개수로 설정
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget sliderIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: imageList
            .asMap()
            .entries
            .map((e) => GestureDetector(
                  onTap: () => controller.animateToPage(e.key),
                  child: Container(
                    width: 12,
                    height: 12,
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black
                            .withOpacity(current == e.key ? 1 : 0.3)),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget sliderWidget() {
    return CarouselSlider(
        carouselController: controller,
        items: imageList
            .map((filename) => Builder(builder: (context) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Image(
                      fit: BoxFit.fill,
                      image: AssetImage(filename),
                    ),
                  );
                }))
            .toList(),
        options: CarouselOptions(
            height: 450,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 10),
            onPageChanged: (index, reason) {
              setState(() {
                current = index;
              });
            }));
  }
}
