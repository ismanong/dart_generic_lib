import 'dart:core';
import 'package:intl/intl.dart';

/// 字符串转bool
extension BoolParsing on String {
  bool parseBool() {
    return toLowerCase() == 'true';
  }
}

extension DateTimeFormatExtension on DateTime {
  String to_yyyy_MM_dd_HH_mm_ss() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this);
  }
}

extension DoubleFormatExtension on double {
  String toPercent() {
    // 0.0 - 1.0
    return NumberFormat.percentPattern().format(this);
  }
}

// extension UrlParse on double {
//   String toPercent() {
//     // 0.0 - 1.0
//     return NumberFormat.percentPattern().format(this);
//   }
// }
// class UrlUtil {
//   static String? getQueryValue(String url, String key) {
//     Uri u = Uri.parse(url); // dart core的Uri库, queryParameters成员返回一张地图
//     Map<String, String> qp = u.queryParameters;
//     String? value = qp[key];
//     return value;
//   }
// }
