// import 'dart:async';
//
// class TaskInfo {
//   TaskInfo(this.taskId, this.task);
//
//   // final String _uuid = const Uuid().v1();
//   // String get uuid => _uuid; // 为了刷新列表缓存用的
//   final String taskId;
//   final Future<T> Function() task;
//
//   // final Completer<bool> _done = Completer<bool>();
//   // Future<bool> get done => _done.future;
//   // bool get isDone => _done.isCompleted;
//
//   // 所有任务完成 主动告诉任务完成 回调
//   // 只有任务成功或者失败
//   final Completer<bool> finishCompleter = Completer<bool>();
//   Future<bool> get finish => finishCompleter.future;
//
//   //重置任务
//   TaskInfo resetTask() => TaskInfo(taskId, task);
//
//   // 任务开始
//   void start() {}
// }
