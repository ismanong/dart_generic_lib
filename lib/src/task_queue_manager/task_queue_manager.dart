import 'dart:async';
import 'package:app_youtube/util/task_queue_manager/task_info.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import "package:intl/intl.dart";

// downloadQueueManager.addListener(() async {
//   print(' --> downloadQueueManager.percentString --> ${downloadQueueManager.percentString}');
//   await _calculation();
//   // setState(() {});
// });
///
/// 任务队列开启
/// 开始任务 跳过暂停任务
/// 添加初始任务
/// 添加一个任务
/// 添加一个任务
/// 添加一个任务
/// 添加一个任务
///
class TaskQueueManager extends ChangeNotifier {
  static final TaskQueueManager _singleton = TaskQueueManager._internal();
  factory TaskQueueManager() => _singleton;
  TaskQueueManager._internal();

  bool autoDownload = true;

  /// 并发数量
  int concurrencyCount = 2;
  final List<TaskInfo> _totalTasks = []; // 全部任务
  final List<TaskInfo> _surplusTasks = []; // 剩余任务
  final List<TaskInfo> _successTasks = []; // 成功任务
  final List<TaskInfo> _failTasks = []; // 失败任务
  final List<TaskInfo> _currentTasks = []; // 当前任务
  String get percent => NumberFormat.percentPattern()
      .format(_successTasks.length / _totalTasks.length);
  FutureOr<void> Function(TaskInfo)? onSuccessTask;
  FutureOr<void> Function(TaskInfo)? onRestartTask;
  var uuid = const Uuid();

  /// 下载全部任务
  void startDownload() {
    /// 考虑是否需要考虑失败的情况 也可以不需要
    if (_failTasks.isNotEmpty) {
      _surplusTasks.addAll(_failTasks);
      _failTasks.clear();
    }
    _executeQueue();
  }

  /// 下载某个任务
  void startDownloadAt(String taskId) {
    // 获取相关未下载任务
    var taskInfo = _surplusTasks.firstWhere((e) => e.taskId == taskId);
    _executeTask(taskInfo, false);
  }

  void restartTaskAt(String taskId) {
    // , void Function(TaskInfo) callback
    // 获取相关未下载任务
    var taskInfo = _failTasks.firstWhere((e) => e.taskId == taskId);
    var newTaskInfo = taskInfo.resetTask();
    _failTasks.removeWhere((element) => element.taskId == taskId);
    _totalTasks.removeWhere((element) => element.taskId == taskId);
    _totalTasks.add(newTaskInfo);
    // 回调子组件去渲染
    // callback(newTaskInfo);
    if (onRestartTask != null) {
      onRestartTask!(newTaskInfo);
    }
    _executeTask(newTaskInfo, false);
  }

  /// 执行下载队列 主要的
  void _executeQueue() {
    if (_surplusTasks.isNotEmpty) {
      // 相差的数量
      var diffCount = concurrencyCount - _currentTasks.length;
      for (int i = 0; i < diffCount; i++) {
        if (_surplusTasks.isNotEmpty) {
          // 删除第一个剩余任务
          var taskInfo = _surplusTasks.removeAt(0);
          // 添加刚删除的任务 到当前任务
          _executeTask(taskInfo, true);
        }
      }
    }
  }

  /// 执行一个任务
  void _executeTask(TaskInfo taskInfo, bool isContinue) {
    // 添加到当前任务
    _currentTasks.add(taskInfo);
    taskInfo.task(taskInfo);
    taskInfo.start();
    // 监听任务结果 单个任务完成
    taskInfo.finish.then((value) => _finish(taskInfo, isContinue, value));
    print(
        '全部任务(${_totalTasks.length}) ${_totalTasks.map((e) => e.taskId).toList()}');
    print(
        '成功任务(${_successTasks.length}) ${_successTasks.map((e) => e.taskId).toList()}');
    print(
        '失败任务(${_failTasks.length}) ${_failTasks.map((e) => e.taskId).toList()}');
    print(
        '剩余任务(${_surplusTasks.length}) ${_surplusTasks.map((e) => e.taskId).toList()}');
    print(
        '当前任务(${_currentTasks.length}) ${_currentTasks.map((e) => e.taskId).toList()}');
  }

  /// 一个任务完成的回调
  void _finish(TaskInfo taskInfo, bool isContinue, bool isSuccess) async {
    // notifyListeners();
    if (isSuccess) {
      print('${taskInfo.taskId}');
      _successTasks.add(taskInfo); // 记录已经成功的任务
      if (onSuccessTask != null) {
        onSuccessTask!(taskInfo);
      }
    } else {
      print('${taskInfo.taskId}');
      _failTasks.add(taskInfo); // 记录已经失败的任务
    }
    // 从当前任务 删除已经完成或已经失败的 留出位置
    _currentTasks.removeWhere((element) => element.taskId == taskInfo.taskId);
    if (isContinue) {
      _executeQueue();
    }
  }

  /// 所有任务完成的回调
  void done() async {
    throw UnimplementedError();
  }

  /// 添加下载任务
  /// 任务回调 Future Function() task
  /// 必须保证添加新任务不能重复，避免二次进入页面 会创建新任务 所以不能放在外面
  TaskInfo addTask(TaskInfo taskInfo) {
    var c = checkExistTask(taskInfo.taskId);
    if (c != null) {
      return c;
    }
    // final String taskId = uuid.v1();
    _totalTasks.add(taskInfo);
    _surplusTasks.add(taskInfo);
    // 是否自动下载
    if (autoDownload) {
      _executeQueue();
    }
    return taskInfo;
  }

  /// 添加多个下载任务
  /// 任务回调列表 List<Future Function()> allTasks;
  // void addAllTask(List<Future Function()> initTasks) {
  //   _surplusTasks = initTasks
  //       .map((e) => QueueTaskInfo(uuid.v1(), e))
  //       .toList(); // 初始任务 转为 剩余任务
  //   _totalTasks.addAll(_surplusTasks); // 记录任务总数
  // }

  /// 从所有任务里删除一个任务
  void removeTaskAt(String taskId) {
    _totalTasks.removeWhere((element) => element.taskId == taskId);
    _failTasks.removeWhere((element) => element.taskId == taskId);
  }

  TaskInfo? getTask(String taskId) {
    var w = _totalTasks.where((element) => element.taskId == taskId);
    return w.isNotEmpty ? w.first : null;
  }

  TaskInfo? checkExistTask(String taskId) {
    var w = _totalTasks.where((element) => element.taskId == taskId);
    return w.isNotEmpty ? w.first : null;
  }

  // void taskLog() {}

  // final static boolean DEBUG = true;//调试用
  // private static int BUFFER_SIZE = 8096;//缓冲区大小
  // private Vector vDownLoad = new Vector();//URL列表
  // private Vector vFileList = new Vector();//下载后的保存文件名列表
  /// 清除下载列表
  void resetList() {
    // vDownLoad.clear();
    // vFileList.clear();
  }

  /// 增加下载列表项
  void addItem(String url, String filename) {
    // vDownLoad.add(url);
    // vFileList.add(filename);
  }

  /// 根据列表下载资源
  void downLoadByList() {}

  /// 将HTTP资源另存为文件
  void saveToFile(String destUrl, String fileName) {}

  /// 设置代理服务器
  void setProxyServer(String proxy, String proxyPort) {}

  /// 设置认证用户名与密码
  void setAuthenticator(String uid, String pwd) {}
}

// void main() async {
//   // Completer<bool> complete = Completer<bool>();
//   // Future.delayed(Duration(seconds: 2), () {
//   //   complete.complete(true);
//   // });
//   // complete.future.then((value) {
//   //   print(value);
//   // }).catchError((e) {
//   //   print(e);
//   // });
//   var d = DownloadQueueManager([
//     () => Future.delayed(Duration(seconds: 2)),
//     () => Future.delayed(Duration(seconds: 4)),
//     () => Future.delayed(Duration(seconds: 5)),
//     () => Future.delayed(Duration(seconds: 6)),
//     () => Future.delayed(Duration(seconds: 7)),
//     () => Future.delayed(Duration(seconds: 2)),
//   ]);
//   // var d = DownloadQueueManager();
//   d.start();
// }
