// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// abstract class BaseView<Controller extends GetxController> extends StatelessWidget {
//   const BaseView({super.key});
//
//   Controller get controller => GetInstance().find<Controller>();
//
//   @override
//   Widget build(BuildContext context) {
//     return GetX<Controller>(builder: (Controller controller) {
//       return Scaffold(
//         body: SafeArea(child: body()),
//         floatingActionButton: floatingActionButton(),
//         resizeToAvoidBottomInset: resizeToAvoidBottomInset(),
//       );
//     });
//   }
//
//   Widget body();
//
//   Widget? floatingActionButton() => null;
//
//   bool? resizeToAvoidBottomInset() => true;
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class BaseView<Controller extends GetxController> extends StatelessWidget {
  const BaseView({super.key});

  Controller get controller => GetInstance().find<Controller>();

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(child: body()), // ← اینجا context اضافه شد
    floatingActionButton: floatingActionButton(),
    resizeToAvoidBottomInset: resizeToAvoidBottomInset(),
  );
}


  Widget body();

  Widget? floatingActionButton() => null;

  bool resizeToAvoidBottomInset() => true;
}
