import 'dart:async';
import 'dart:isolate';

///
/// 避免阻塞主线程渲染
///
/// 用于 download upload progress
///
// enum SubThreadExitState {
//   success,
//   fail,
// }

typedef DenseIsolateStaticMethod = Future<void> Function(
  Map args,
  DenseIsolateCallback dataCallback,
);
typedef DenseIsolateCallback = void Function({Map? data, int? exitCode});

abstract class DenseIsolateInterface {
  // /// 最终完成的future
  // final Completer<int> _result = Completer<int>(); // 1成功 2失败
  // Future<int> get result => _result.future;

  /// 访问接收流 创建流 流控制器
  Stream<Map> get valueStream => _streamController.stream;

  /// 创建流 流控制器
  // StreamController<Map> get streamController => _streamController;
  final StreamController<Map> _streamController = StreamController<Map>();

  /// 开启线程执行 下载/上传
  Future<void> startTask() async {
    _createParentThreadReceivesData();
    _streamController.stream.listen(receive);
  }

  /// 重写 传递参数
  Map get args;

  /// 重写 接收数据
  void receive(Map data);

  /// 重写 子线程任务
  // SubThreadTaskStaticMethod get createSubThreadTask;
  Future<void> createSubThreadTask(Map args, DenseIsolateCallback callback);

  ///
  /// 创建父线程接收数据的执行函数
  ///
  /// TODO 自己实现 子线程的顶级函数或静态函数
  ///
  Future<void> _createParentThreadReceivesData() async {
    // 创建父线程访问
    ReceivePort port = ReceivePort();

    /// TODO 不能在widget里使用Isolate !!!!!!!!!!!!!!!!
    /// 如果把此类实现放在widget里，然后又通过回调或者点击事件去调用，就会发生问题。
    /// 但是可以在点击事件里生成此实例 然后直接执行 目前可行 待确认和分析
    /// [ERROR:flutter/lib/ui/ui_dart_state.cc(198)] Unhandled Exception: Invalid argument(s): Illegal argument in isolate message: (object extends NativeWrapper - Library:'dart:ui' Class: EngineLayer)
    ///
    /// 好像是运行Isolate之前，当前类里不能再上下文上关联到widget里的变量等等。
    /// 报错：
    /// var y = YoutubeDownloadHelper(
    ///           output: item.filepath,
    ///           id: item.playId,
    ///         );
    ///         y.valueStream.listen((event)  {
    ///           print(1);
    ///           _listDownloadMap[item.playId]!.add(event); // widget里的变量
    ///         });
    ///         y.start2();
    /// 正确：
    /// var y = YoutubeDownloadHelper(
    ///           output: item.filepath,
    ///           id: item.playId,
    ///         );
    ///         y.start2(); // 替换顺序
    ///         y.valueStream.listen((event)  {
    ///           print(1);
    ///           _listDownloadMap[item.playId]!.add(event); // widget里的变量
    ///         });
    ///
    ///
    Isolate isolate = await Isolate.spawn<List<dynamic>>(
      _createSubThreadTask,
      [port.sendPort, args, createSubThreadTask],
    );
    await for (final Map data in port) {
      // 优化 进度有变化 再传递 避免重复数据
      _streamController.sink.add(data); // 向流里面添加数据
    }
    _streamController.sink.close(); // 关闭流
    // _result.complete(1);
    isolate.kill(priority: Isolate.immediate);
  }

  /// 静态 子线程要执行的任务 必须为 顶级函数 或 静态函数
  static Future<void> _createSubThreadTask(List<dynamic> message) async {
    var mainSendPort = message[0] as SendPort;
    var args = message[1] as Map;
    var task = message[2] as DenseIsolateStaticMethod;
    task(
      args,
      ({Map? data, int? exitCode}) {
        if (exitCode == 0) {
          Isolate.exit();
        } else if (exitCode == 1) {
          // 错误
          mainSendPort.send({'exitCode': 1});
          Isolate.exit();
        } else if (exitCode == 2) {
          // 超时
          mainSendPort.send({'exitCode': 2});
          Isolate.exit();
        } else if (data != null) {
          mainSendPort.send(data);
        } else {
          throw UnsupportedError('参数必须有一个');
        }
      },
    );
  }
}
