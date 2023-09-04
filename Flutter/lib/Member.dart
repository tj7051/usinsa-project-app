// To parse this JSON data, do
//
//     final member = memberFromJson(jsonString);

import 'dart:convert';

Member memberFromJson(String str) => Member.fromJson(json.decode(str));

String memberToJson(Member data) => json.encode(data.toJson());

class Member {

  String? id;
  String username;
  String name;
  DateTime createDate;
  DateTime updateDate;
  String? password;
  String? token;
  int role;
  String phoneNumber;
  String address;
  String height;
  String weight;

  Member({
    this.id,
    required this.username,
    required this.name,
    required this.createDate,
    required this.updateDate,
    this.password,
    this.token,
    required this.role,
     this.phoneNumber="",
     this.address="",
     this.height="",
     this.weight="",
  });

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    id: json["id"],
    username: json["username"],
    name: json["name"],
    createDate: DateTime.parse(json["createDate"]),
    updateDate: DateTime.parse(json["updateDate"]),
    password: json["password"],
    token: json["token"],
    role: json["role"],
    phoneNumber: json["phoneNumber"]??"",
    address: json["address"]??"",
    height: json["height"]??"",
    weight: json["weight"]??"",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "name": name,
    "createDate": createDate.toIso8601String(),
    "updateDate": updateDate.toIso8601String(),
    "password": password,
    "token": token,
    "role": role,
    "phoneNumber": phoneNumber,
    "address": address,
    "height": height,
    "weight": weight,
  };
}
