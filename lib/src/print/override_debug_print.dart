// import 'package:flutter/foundation.dart';
//
// /// 覆盖debugPrint
// /// 问: 如何覆盖dart顶级函数print()
// /// 答: 顶层不能被子类化，所以重写是不可能的。
// void overrideDebugPrint() {
//   /// 覆盖debugPrint
//   // final DebugPrintCallback oldCallback = debugPrint;
//   debugPrint = (String? s, {int? wrapWidth}) {
//     // String? message
//     _debugPrintSynchronouslyWithText(s, wrapWidth: wrapWidth);
//   };
// }
//
// /// 自定义debugPrintCallback输出文案和样式
// // https://medium.com/flutter-community/debugprint-and-the-power-of-hiding-and-customizing-your-logs-in-dart-86881df05929
// void _debugPrintSynchronouslyWithText(String? message, {int? wrapWidth}) {
//   debugPrintSynchronously('来源debugPrint(找到替换为print): $message', wrapWidth: wrapWidth);
// }
