import 'dart:async';

typedef RetryCallback = Future<bool> Function();

class CycleExecuteHelper {
  late Timer _timer;
  late RetryCallback cb;
  late int intervalTime;
  // 连续执行 是否阻塞 待验证
  CycleExecuteHelper(this.cb, {this.intervalTime = 1}) {
    _createTimer();
  }
  execute() async {
    var bo = await cb();
    if (bo) {
      _cleanTimer();
    } else {
      _createTimer();
    }
  }
  void _cleanTimer() => _timer.cancel();

  void _createTimer() {
    _timer = Timer(Duration(seconds: intervalTime), execute);
  }

  // 连续执行 是否阻塞 待验证
  /// while(ture)+sleep() 与 Timer作为定时查询的比较
  /// 一种是的等待一分钟，一种是到了一分钟之后触发执行某个事情
  static void continuous(RetryCallback cb, {int? intervalTime}) async {
    while (true) {
      var bo = await cb();
      if (bo) {
        return;
      }
      if (intervalTime != null) {
        await Future.delayed(Duration(seconds: intervalTime));
      }
    }
  }

  // 按次数执行 时间次数
  static Future<bool> count(int count, RetryCallback cb,
      {int? intervalTime}) async {
    for (int i = 1; i <= count; i++) {
      var bo = await cb();
      if (bo) {
        return true;
      }
      if (i < count && intervalTime != null) {
        await Future.delayed(Duration(seconds: intervalTime));
      }
    }
    return false;
  }
}
