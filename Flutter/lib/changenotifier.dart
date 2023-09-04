import 'package:flutter/material.dart';

class FavoriteModel with ChangeNotifier{

  bool? bookmark;

  FavoriteModel({this.bookmark});

  void changedBookmark(data){
    bookmark = data;
  }
}