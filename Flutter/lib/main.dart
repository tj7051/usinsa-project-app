import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usinsaapp/MyHomePage.dart';
import 'package:usinsaapp/changenotifier.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool? bookmark;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => FavoriteModel(bookmark: bookmark)
        ),
      ],
      child: MaterialApp(
        title: "USINSA",
        home: MyHomePage(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: TextTheme(
            bodyText1: TextStyle(
              fontFamily: 'Jalnan', // 폰트 이름으로 변경하세요
            ),
          ),
        ),
      ),
    );
  }
}
