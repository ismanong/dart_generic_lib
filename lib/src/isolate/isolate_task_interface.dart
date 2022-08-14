// import 'dart:async';
// import 'dart:isolate';
//
// ///
// /// 用于避免阻塞主线程渲染的操作
// ///
// /// 如下载： download upload progress 大文件读取
// ///
// ///
// class ProgressDownloadOrUploadData {
//   final double progress;
//   final int total; // 下载/上传 总数据
//   final int received; // 已 下载/上传 数据
//   ProgressDownloadOrUploadData({
//     this.progress = 0.0,
//     this.total = 0,
//     this.received = 0,
//   });
// }
//
// typedef SubThreadTaskStaticFunc = Future<void> Function(
//     Map args, SubThreadTaskCallback data);
// typedef SubThreadTaskCallback = void Function(int count, int total);
//
// abstract class IsolateTaskInterface {
//   IsolateTaskInterface() {
//     _start();
//   }
//
//   final StreamController<Map> _streamController =
//       StreamController<Map>(); // 创建流 流控制器
//   Stream<Map> get valueStream => _streamController.stream;
//   Map get value => {};
//   double _progress = 0.0;
//
//
//   /// 开启线程执行 下载/上传
//   Future<void> _start() async {
//     _createParentThreadReceivesData();
//   }
//
//   /// 重写 传递参数
//   Map get args;
//
//   /// 重写 子线程任务
//   // SubThreadTaskStaticFunc get createSubThreadTask;
//   Future<void> createSubThreadTask(Map args, SubThreadTaskCallback callback);
//
//   ///
//   /// 创建父线程接收数据的执行函数
//   ///
//   /// TODO 自己实现 子线程的顶级函数或静态函数
//   ///
//   Future<void> _createParentThreadReceivesData() async {
//     // 创建父线程访问
//     ReceivePort port = ReceivePort();
//     Isolate isolate = await Isolate.spawn<List<dynamic>>(
//       _createSubThreadTask,
//       [port.sendPort, args, createSubThreadTask],
//     );
//     await for (final ProgressDownloadOrUploadData data in port) {
//       // _progress = data.progress;
//       // _receivedSize = data.received;
//       // _totalSize = data.total;
//       // if (_progress == 100.0 || _progress > 100.0) {
//       //   _status = 1;
//       //   _timer.cancel();
//       //   _streamController.sink.add(value);// 最后一次添加数据到流
//       //   _streamController.close();// 关闭流
//       // }
//       // _streamController.sink.add(value); // 优化 每秒传递一次 通过下面的速度定时器
//     }
//     isolate.kill(priority: Isolate.immediate);
//   }
//
//   /// 静态 子线程要执行的任务 必须为 顶级函数 或 静态函数
//   static Future<void> _createSubThreadTask(List<dynamic> message) async {
//     var mainSendPort = message[0] as SendPort;
//     var args = message[1] as Map;
//     var task = message[2] as SubThreadTaskStaticFunc;
//     task(args, (int count, int total) {
//       // var valProgress = (count / total * 100).truncateToDouble() / 100; // 0.0 ~ 1.0
//       var progress = (count / total * 100).truncateToDouble(); // 0.0 ~ 100.0
//       var data = ProgressDownloadOrUploadData(
//         progress: progress,
//         received: count,
//         total: total,
//       );
//       mainSendPort.send(data);
//       if (count == total) {
//         Isolate.exit();
//       }
//     });
//   }
//
// }
