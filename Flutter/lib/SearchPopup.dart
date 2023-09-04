import 'package:flutter/material.dart';
import 'package:usinsaapp/SearchViewPage.dart';

void SearchPopup(BuildContext context) {
  // 입력창에서 입력한 키워드를 저장하는 변수
  String keyword = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Theme(
                data: ThemeData(
                  inputDecorationTheme: InputDecorationTheme(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,  // 검정색으로 변경
                      ),
                    ),
                  ),
                ),
                child: TextField(
                  onChanged: (value) {
                    // 입력값이 변경될 때마다 keyword 변수에 저장
                    keyword = value;
                  },
                  decoration: InputDecoration(
                    hintText: "검색어를 입력하세요",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              SizedBox(height: 16),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                ),
                onPressed: () {
                  // 검색 버튼 클릭 시 동작 처리
                  Navigator.pop(context);
                  // 네 번째 아이템 종류 선택 시 동작 처리
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchViewPage(keyword)),
                  );
                },
                child: Text("검색"),
              ),
            ],
          ),
        ),
      );
    },
  );
}