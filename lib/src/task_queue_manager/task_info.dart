import 'dart:async';
import 'package:app_youtube/util/task_queue_manager/progress_download_or_upload_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class TaskInfo extends ChangeNotifier {
  TaskInfo({required this.taskId, required this.task, this.onFinish}) {
    // _streamController.done.then((value) => _doneFunc());
    // _streamController.onCancel = () {};
    _streamController.stream.listen(_listenFunc);
  }
  final String _uuid = const Uuid().v1();
  String get uuid => _uuid; // 为了刷新列表缓存用的
  final String taskId;
  final StreamController<TaskProgressModel> _streamController =
      StreamController<TaskProgressModel>();
  StreamController<TaskProgressModel> get streamController => _streamController;
  Stream<TaskProgressModel> get stream => _streamController.stream;
  final void Function(TaskInfo) task;
  // 最后一次数据
  TaskProgressModel currentTaskProgress = TaskProgressModel(status: 0);
  final FutureOr<void> Function()? onFinish;
  // 未下载 等待下载
  bool get isNotDownloaded => currentTaskProgress.status == 0;
  // 下载中
  bool get isDownloading => currentTaskProgress.status == 1;
  // 下载完成
  bool get isDownloadCompleted => currentTaskProgress.status == 2;
  // 下载错误
  bool get isDownloadError =>
      currentTaskProgress.status == 3 || currentTaskProgress.status == 4;
  // 任务开始
  void start() {
    print('$taskId --> $uuid');
    _streamController.add(TaskProgressModel(status: 1));
  }

  void update(TaskProgressModel taskProgressModel) {
    // print('$taskId --> $uuid');
    _streamController.add(taskProgressModel);
  }

  // 任务结束
  void end() async {
    print(taskId);
    if (isDownloadCompleted) {
      if (onFinish != null) {
        await onFinish!(); // 这个方法 可能返回Future 也可能无返回
        // print('${onFinish is Function}');
        // print('${onFinish.toString()} --> ${onFinish.runtimeType.toString()} ');
        _finish.complete(true);
      }
    } else {
      _finish.complete(false);
    }
    _streamController.close();
    print('$taskId ${await _finish.future}');
  }

  void _listenFunc(TaskProgressModel event) {
    currentTaskProgress = event;
    // print('${taskId} --> streamC.stream.listen --> ${lastProgressInfo.status}');
    if (hasListeners) {
      notifyListeners();
    }
  }

  // final Completer<bool> _done = Completer<bool>();
  // Future<bool> get done => _done.future;
  // bool get isDone => _done.isCompleted;
  final Completer<bool> _finish = Completer<bool>(); // 所有任务完成 主动告诉任务完成 回调
  Future<bool> get finish => _finish.future;

  // void close() {
  //   dispose();
  //   removeListener(() {});
  // }

  //重置任务
  TaskInfo resetTask() {
    return TaskInfo(
      taskId: taskId,
      task: task,
      onFinish: onFinish,
    );
  }

  // void startDownload() {
  //   TaskQueueManager().startDownloadAt(taskId);
  // }

}
