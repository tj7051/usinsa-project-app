import 'dart:convert';

Bookmark bookmarkFromJson(String str) => Bookmark.fromJson(json.decode(str));

String bookmarkToJson(Bookmark data) => json.encode(data.toJson());

class Bookmark {
  int id;
  String itemName;
  String username;
  String sellerName;
  int bid;
  DateTime createDate;

  Bookmark({
    required this.id,
    required this.itemName,
    required this.username,
    required this.sellerName,
    required this.bid,
    required this.createDate,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
    id: json["id"],
    itemName: json["itemName"],
    username: json["username"],
    sellerName: json["sellerName"],
    bid: json["bid"],
    createDate: DateTime.parse(json["createDate"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "itemName": itemName,
    "username": username,
    "sellerName": sellerName,
    "bid": bid,
    "createDate": createDate.toIso8601String(),
  };
}
