import 'dart:io';
import 'package:path/path.dart' as path;
///
/// 执行dart文件命令:
/// dart run bin/xxx.dart     可用
/// dart run :xxx             可用   xxx 要与 pubspec.yaml 的 name 不匹配
/// dart run xxx              不可用  xxx 要与 pubspec.yaml 的 name 匹配
///
// 待研究
// ArgResults argResults; // 声明ArgResults类型的全局变量，保存解析的参数结果
// 同时，argResults也是ArgResults的实例
// var argParser = ArgParser();

/// 此文件完整命令: dart run bin/app_build.dart [env,channel]
/// 默认:         dart run bin/app_build.dart release google
/// 例子:
/// dart run bin/app_build.dart 或 dart run :app_build
/// dart run bin/app_build.dart qa gta
/// dart run bin/app_build.dart prv gta

class BinUtil {
  // _debugScriptPath() {
  //   /// Platform.script.toString() 在命令行可以使用  经过编译后返回的项目目录
  //   print('当前目录: ${Directory.current.path}'); // 当前目录: D:\_mine\flutter_demo_all_platform
  //   print('当前文件: ${path.current}'); // 当前文件: D:\_mine\flutter_demo_all_platform
  //   print('当前平台的路径分隔符: ${path.separator}'); // 当前平台的路径分隔符: \
  //
  //   print('命令行获取脚本当前路径: ${Platform.script.toString()}'); // file:///D:/_mine/flutter_demo_all_platform/bin/app_build.dart
  //   print('命令行获取脚本当前路径目录: ${path.dirname(Platform.script.toString())}'); // file:///D:/_mine/flutter_demo_all_platform/bin
  //   print('命令行获取脚本当前路径2: ${Platform.script.toFilePath()}'); // D:\_mine\flutter_demo_all_platform\bin\app_build.dart
  //   print('命令行获取脚本当前路径目录2: ${path.dirname(Platform.script.toFilePath())}'); // D:\_mine\flutter_demo_all_platform\bin
  // }

  static String get binDir => path.dirname(Platform.script.toFilePath());
  static String get projectDir => Directory.current.path;
  static String get buildDir => path.join(projectDir, 'build');
  static String get buildWebDir => path.join(projectDir, 'build', 'web');
  static String get buildApkDir => path.join(projectDir, 'build', 'app');

  /// 项目的父目录
  static String get projectParentDir => Directory.current.parent.path;
}

/// 获取环境参数
/// .channel.google
/// APP_NAME=Gtarcade
/// APP_CHANNEL=000
// String _dartDefine() {
//   String cPath = path.join(Directory.current.path, 'bin', '.channel.$channel');
//   String? text = FileUtil.readFile(cPath);
//   if (text == null) {
//     throw '获取环境参数 失败';
//   }
//   text = text.split('\r\n').map((e) {
//     if (e.contains('APP_NAME') && env != 'release') {
//       e = 'APP_NAME=$env-$channel';
//     }
//     return ' --dart-define=$e';
//   }).join();
//   return text;
// }