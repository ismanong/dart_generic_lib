import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as p;

import '../base/date_util.dart';
import '../base/file_util.dart';

// main() async {
//   // var filename = '${DateUtil.currentYYYYMMDD()}.log';
//   // var filepath = p.join('C:\\Users\\52644\\Desktop\\test',filename);
//   // var file = File(filepath);
//   // file.create();
//   await LocalLogger.create('C:\\Users\\52644\\Desktop\\test');
//   LocalLogger.send('111');
//   LocalLogger.send('222');
//   LocalLogger.send('333');
//   LocalLogger.send('444');
//   LocalLogger.send('555');
//
//   await Future.delayed(const Duration(seconds: 100));
// }

/// 持续任务
class LocalLogger {
  static Future<List<String>> getLogs7Days() async {
    List<String> fs = await FileUtil.getAllFilePath(logsDir);
    // 应该至少有一个
    if(fs.isNotEmpty){
      var maxIndex = fs.length >= 7 ? 7 : fs.length;
      var newFs = fs.reversed.toList().sublist(0, maxIndex);
      return newFs;
    }else{
      return [];
    }
  }

  static late String logsDir;
  static late SendPort childSendPort;
  static Isolate? newIsolate;
  static void send(String log) async {
    childSendPort.send(log);
  }

  ///
  static Future<void> close() async {}

  ///
  static Future<void> create(String dir) async {
    final completer = Completer();
    if(newIsolate != null){
      return;
    }
    logsDir = dir;
    ReceivePort receivePort = ReceivePort();
    newIsolate = await Isolate.spawn<List<dynamic>>(
      _entryPoint,
      [
        receivePort.sendPort,
        {'storageDirectory': dir},
      ],
      // onExit: receivePort.sendPort,
      // onError: receivePort.sendPort,
    );

    /// 获取子线程通讯方式
    // SendPort childSendPort = await receivePort.first;
    childSendPort = await receivePort.first;
    // receivePort.listen((data) {
    //   if (data is SendPort) {
    //     childSendPort = data;
    //     completer.complete();
    //   }
    // });

    /// 销毁
    // 可以在适当的时候，调用以下方法杀死创建的 isolate
    // newIsolate!.kill(priority: Isolate.immediate);
    // await completer.future;
  }

  /// 子线程的入口点函数
  static Future<void> _entryPoint(List<dynamic> message) async {
    /// 获取主线程通讯方式
    var mainSendPort = message[0] as SendPort;

    /// 初始化参数
    var args = message[1];
    String storageDirectory = args['storageDirectory'];

    /// 创建监听 子线程监听主线程的消息
    ReceivePort receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort); //把子线程对象转递给主线程
    // receivePort.listen((data) {
    //   print('主线程 -> 子线程: $data');
    //   processRequest(storageDirectory, data);
    // });
    await for (var data in receivePort) {
      print('主线程 -> 子线程: $data');
      await processRequest(storageDirectory, data);
    }
  }

  static Future<void> processRequest(String storageDirectory, data) async {
    var filename = '${DateUtil.currentYYYYMMDD()}.log';
    var filepath = p.join(storageDirectory, filename);
    var file = File(filepath);
    // file.create();
    var value = '$data\n'.codeUnits;

    // 在 writeAppend 中打开文件。
    var output = file.openWrite(mode: FileMode.writeOnlyAppend);
    output.add(value);
    // await output.flush(); // 验证是否要调用
    await output.close();
  }
}
