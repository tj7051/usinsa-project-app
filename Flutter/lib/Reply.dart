// To parse this JSON data, do
//
//     final reply = replyFromJson(jsonString);

import 'dart:convert';

Reply replyFromJson(String str) => Reply.fromJson(json.decode(str));

String replyToJson(Reply data) => json.encode(data.toJson());

class Reply {
  int id;
  String username;
  String content;
  String productName;
  DateTime createDate;
  DateTime updateDate;
  int bid;

  Reply({
    required this.id,
    required this.username,
    required this.content,
    required this.productName,
    required this.createDate,
    required this.updateDate,
    required this.bid,
  });

  factory Reply.fromJson(Map<String, dynamic> json) => Reply(
    id: json["id"],
    username: json["username"],
    content: json["content"],
    productName: json["productName"],
    createDate: DateTime.parse(json["createDate"]),
    updateDate: DateTime.parse(json["updateDate"]),
    bid: json["bid"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "content": content,
    "productName": productName,
    "createDate": createDate.toIso8601String(),
    "updateDate": updateDate.toIso8601String(),
    "bid": bid,
  };
}
