import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:usinsaapp/ItemTypeView.dart';
import 'package:usinsaapp/ItemView.dart';

void filterButtonPressed(BuildContext context) {
  // 필터 아이콘을 눌렀을 때 수행할 동작 처리
  // 예를 들어, 아이템 종류 선택 버튼을 나타내는 다이얼로그를 띄울 수 있습니다.
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("필터", style: TextStyle(fontFamily: 'Jalnan')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // 첫 번째 아이템 종류 선택 시 동작 처리
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ItemTypeView('상의')),
                    );
                  },
                  child: Text("상의", style: TextStyle(fontFamily: 'Jalnan')),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // 두 번째 아이템 종류 선택 시 동작 처리
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ItemTypeView('하의')),
                    );
                  },
                  child: Text("하의", style: TextStyle(fontFamily: 'Jalnan')),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // 세 번째 아이템 종류 선택 시 동작 처리
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ItemTypeView('모자')),
                    );
                  },
                  child: Text("모자", style: TextStyle(fontFamily: 'Jalnan')),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // 네 번째 아이템 종류 선택 시 동작 처리
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ItemTypeView('가방')),
                    );
                  },

                  child: Text("가방", style: TextStyle(fontFamily: 'Jalnan'),),

                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ItemView()),
                );
              },
              child: Text("전체", style: TextStyle(fontFamily: 'Jalnan')),
            ),
            // 추가적인 아이템 종류 버튼을 여기에 추가할 수 있습니다.
          ],
        )
        ,
      );
    },
  );
}
