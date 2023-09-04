// To parse this JSON data, do
//
//     final order = orderFromJson(jsonString);

import 'dart:convert';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
  int id;
  String username;
  int productId;
  String productName;
  int qty;
  int unitPrice;
  int totalPrice;
  DateTime createDate;
  DateTime updateDate;
  int status;

  Order({
    required this.id,
    required this.username,
    required this.productId,
    required this.productName,
    required this.qty,
    required this.unitPrice,
    required this.totalPrice,
    required this.createDate,
    required this.updateDate,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"],
    username: json["username"],
    productId: json["productId"],
    productName: json["productName"],
    qty: json["qty"],
    unitPrice: json["unitPrice"],
    totalPrice: json["totalPrice"],
    createDate: DateTime.parse(json["createDate"]),
    updateDate: DateTime.parse(json["updateDate"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "productId": productId,
    "productName": productName,
    "qty": qty,
    "unitPrice": unitPrice,
    "totalPrice": totalPrice,
    "createDate": createDate.toIso8601String(),
    "updateDate": updateDate.toIso8601String(),
    "status": status,
  };
}
