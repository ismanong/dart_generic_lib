import 'dart:async';
import 'package:intl/intl.dart';
import 'package:ansicolor/ansicolor.dart'; // 支持终端日志消息的颜色
import 'package:stack_trace/stack_trace.dart'; // 解析堆栈
/// dart:developer库包含允许调试器在对象上打开检查器的检查功能。
/// import 'dart:developer';
/// inspect(message);

// import 'override_debug_print.dart';

/*
 runZonedHelper(() async {
    // 打印一句话
    print("myZone run task...");
    // 生成一个异步错误
    Future.error("generate error");
    runApp(const MyApp());
  });
* */
/// 通过将runApp包装在runZoned中来捕获Dart错误
void runZonedHelper(
  Future<void> Function() executeFunctionBlock, [
  Future<void> Function(Object error, StackTrace stackTrace)? onError,
]) {
  /// 开启log颜色
  ansiColorDisabled = false;

  /// 覆盖debugPrint
  // overrideDebugPrint();

  /// 它基本上就是一个异步操作的执行上下文，在错误处理和分析时非常有用。
  /// 更简单说，它就是一个沙箱环境，可以使函数在这个沙箱环境中执行。
  /// 注：
  /// 在Zone里那些没有被我们捕获的异常，都会走到onError回调里。
  /// 那么如果这个Zone的specification里实现了handleUncaughtError或者是实现了onError回调，那么这个 Zone就变成了一个error-zone。
  runZonedGuarded<Future<void>>(
    // () async { },
    executeFunctionBlock,
    onError ??
        (Object error, StackTrace stackTrace) async {
          /// 设置后无法检测到UI错误，也需要拦截UI错误，输出到控制台。
          print(
              '\n\n\nTODO 测试这个怎么流向\n\n\n \nDart错误: \nerror: $error\nstackTrace:\n$stackTrace\n');
        },

    ///
    /// 拦截并修改print函数的行为
    ///
    zoneSpecification: ZoneSpecification(
      /// 关于拦截器中的参数
      /// self 处理回调函数的Zone
      /// parent 该委托表示父Zone，通过它将操作转发给父Zone
      /// zone 表示执行run操作的 zone。很多操作需要明确该操作是在哪个Zone中被调用
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        /// print('---- $line'); // 会死循环
        var message = prettyLine(line);
        // logBackend.writeLog(message);
        parent.print(zone, message);
      },

      /// 处理未捕获的异常
      handleUncaughtError: (
        Zone self,
        ZoneDelegate parent,
        Zone zone,
        Object error,
        StackTrace stackTrace,
      ) {
        print('处理未捕获的异常 $error');
      },
    ),
  );

  // runZoned(() async {
  //   await _loadAppConfigurations();
  //   await FlutterSystem.beforeRunApp();
  //   runApp(const MyApp());
  // }, zoneSpecification: ZoneSpecification(
  //   print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
  //     parent.print(zone, '${DateTime.now().toIso8601String()} | $line');
  //   },
  // ));
}

const unknownLog = '???';
const rnEnter = '\r\n';
String prettyLine(String message) {
  final trace = Trace.from(StackTrace.current);
  final frame = trace.frames[5]; // 当前执行的代码片段 2 5 根据实际情况 可以作为参数
  final date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  String member = frame.member ?? unknownLog;
  // // ------------------------------- 兼容
  // if (member == 'debugPrintSynchronously') {
  //   member = trace.frames[8].member ?? unknownLog;
  // }
  // // ------------------------------- 兼容end
  if (frame.isCore) {
    AnsiPen pen = AnsiPen()..magenta(bold: true);
    member = pen(member);
  } else {
    AnsiPen pen = AnsiPen()..yellow(bold: true);
    member = pen(member);
  }
  if (message.contains('TODO')) {
    AnsiPen pen = AnsiPen()..green();
    message = pen(message);
  } else if (message.contains('#0')) {
    AnsiPen pen = AnsiPen()..red();
    message = "\n${pen(message)}";
  }
  return "[$date - $member]: $message";
}
