import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:usinsaapp/MyHomePage.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Colors.grey,
      dotsDecorator: DotsDecorator(
        size: Size(20,20),
        color: Colors.green,
        activeSize: Size(40,20),
        activeColor: Colors.red,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0)
        )
      ),

      done: Text("done"),
      onDone: (){
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context)=>MyHomePage())
        );
      },

      next: Icon(Icons.arrow_forward),
      showSkipButton: true,
      skip: Text("skip"),

      pages: [
        PageViewModel(
          title: "1 페이지",
          body: "1페이지 내용",
          decoration: getPageDecoration(),
          image: Image.asset("asset/mujin.jpg")
        ),
        PageViewModel(
            // title: "aaa",
            titleWidget: SizedBox(),
            // body: "2페이지 내용",
            bodyWidget: SizedBox(),
            decoration: getPageDecoration(),
            image: Image.asset("asset/mujin22.jpg",
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.fill,
            )
        ),
      ],
    );
  }

  getPageDecoration() {
    return PageDecoration(
      titleTextStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      bodyTextStyle: TextStyle(fontSize: 16, color: Colors.green),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.only(bottom: 20),
      titlePadding: EdgeInsets.only(bottom: 20),
      bodyAlignment: Alignment.bottomCenter,
      imageFlex: 1000,
      imageAlignment: Alignment.bottomCenter, // 이미지를 화면 바닥에 정렬
      // imageContainerPadding: EdgeInsets.symmetric(horizontal: 16),
    );
  }


}
