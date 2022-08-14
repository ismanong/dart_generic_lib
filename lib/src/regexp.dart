// /// 返回符合的范围内 数组
// List regExpReplaceAll(String str) {
//   List<String> list = [];
//   // 字符串前加字母"r"，字符串不会解析转义""
//   // RegExp reg = new RegExp("\"(//img.alicdn.com/.*?)\"");
//   // RegExp reg = new RegExp("(=@[^\s]@=)"); // 有的行有的不行
//   // RegExp reg = new RegExp("(=@[^\s]*!![^\s]@=)");
//   RegExp reg = new RegExp(r"=@(\S*)@=");
//
//   // 简单说是贪婪匹配与非贪婪匹配的区别。
//   // 比如说匹配输入串A: 101000000000100
//   // 使用 1.*1 将会匹配到1010000000001, 匹配方法: 先匹配至输入串A的最后, 然后向前匹配, 直到可以匹配到1, 称之为贪婪匹配。
//   // 使用 1.*?1 将会匹配到101, 匹配方法: *匹配下一个1之前的所有字符, 称之为非贪婪匹配。
//   // 所有带有量词的都是非贪婪匹配: .*?, .+?, .{2,6}? 甚至 .??
//
//   // 调用allMatches函数，对字符串应用正则表达式
//   // 返回包含所有匹配的迭代器
//   Iterable<Match> matches = reg.allMatches(str);
//   for (Match m in matches) {
//     // groupCount返回正则表达式的分组数
//     // 由于group(0)保存了匹配信息，因此字符串的总长度为: 分组数+1
//     // 查看
//     // for (int i = 0; i < m.groupCount + 1; i++) {
//     //   String match = m.group(i);
//     //   print("Group[$i]: $match");
//     // }
//     // 取值
//     String? value = m.group(1);
//     if(value != null){
//       list.add(value);
//     }
//   }
//   print('结果: $list');
//   return list;
// }
//
// /// TODO 返回失败
// /// RegExp reg = new RegExp(r"=@(\S*)@=");
// /// String val = getRegMatchingContent(reg,'=@value@=');
// String getRegMatchingContent(RegExp reg, String str) {
//   String val = '';
//   // 返回包含所有匹配的迭代器
//   Match match = reg.firstMatch(str) as Match;
//   if (match != null) {
//     // 查看
//     // for (int i = 0; i < match.groupCount + 1; i++) {
//     //   String s = match.group(i);
//     //   print("Group[$i]: $s");
//     // }
//     // match.group(0); // 匹配的全部字符串
//     val = match.group(1)!; // 取值
//   }
//   return val;
// }
//
// // 取出匹配的内容
// // const String regMatchingContent = new RegExp(r"=@(\S*)@=");
// const String reg_matching_content = r"=@(\S*)@=";
// // 以多条件分割字符串时 多用于 split
// // RegExp regOr = new RegExp(r"=@|@=");
// const String reg_or = r"=@|@=";
