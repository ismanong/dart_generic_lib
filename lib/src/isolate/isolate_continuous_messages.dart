// import 'dart:async';
// import 'dart:io';
// import 'dart:isolate';
//
// main() async {
//   await IsolateContinuousMessages.create();
//   IsolateContinuousMessages.send();
//   IsolateContinuousMessages.send();
//   IsolateContinuousMessages.send();
//   IsolateContinuousMessages.send();
//   IsolateContinuousMessages.send();
//   IsolateContinuousMessages.send();
//   IsolateContinuousMessages.send();
// }
//
// /// 持续任务
// class IsolateContinuousMessages {
//   static late SendPort childSendPort;
//   static void send() async {
//     childSendPort.send('receivePort.sendPort');
//   }
//
//   ///
//   static Future<void> close() async {}
//
//   ///
//   static Future<void> create() async {
//     ReceivePort receivePort = ReceivePort();
//     var newIsolate = await Isolate.spawn<List<dynamic>>(
//       _entryPoint,
//       [receivePort.sendPort, {}],
//       onExit: receivePort.sendPort,
//     );
//
//     /// 获取子线程通讯方式
//     // SendPort childSendPort = await receivePort.first;
//     childSendPort = await receivePort.first;
//
//     /// 销毁
//     // 可以在适当的时候，调用以下方法杀死创建的 isolate
//     // newIsolate.kill(priority: Isolate.immediate);
//   }
//
//   /// 子线程的入口点函数
//   static Future<void> _entryPoint(List<dynamic> message) async {
//     /// 获取主线程通讯方式
//     var mainSendPort = message[0] as SendPort;
//
//     /// 初始化参数
//     // var args = message[1];
//
//     /// 创建监听 子线程监听主线程的消息
//     ReceivePort receivePort = ReceivePort();
//     mainSendPort.send(receivePort.sendPort); //把子线程对象转递给主线程
//     receivePort.listen((data) async {
//       print('主线程 -> 子线程: $data');
//       processRequest(data);
//     });
//   }
//
//   static Future<void> processRequest(dynamic data) async {
//
//     var file = File(outputPath);
//
//     // 在 writeAppend 中打开文件。
//     var output = file.openWrite(mode: FileMode.writeOnlyAppend);
//
//     // 跟踪文件下载状态。
//     var len = audio.size.totalBytes;
//     var count = 0;
//     // _totalSize = len;
//
//     // Listen for data received.
//     // var progressBar = ProgressBar();
//     await for (final data in audioStream) {
//       // 跟踪当前下载的数据。
//       count += data.length;
//       callback(data: {
//         'count': count,
//         'total': len,
//       });
//       // Write to file.
//       output.add(data);
//     }
//     // await output.flush(); // 验证是否要调用
//     await output.close();
//   }
// }
