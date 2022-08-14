import 'dart:async';
import 'package:dart_generic_lib/dart_generic_lib.dart';

///
/// 避免阻塞主线程渲染
///
/// 用于 download upload progress
///
abstract class ProgressDownloadOrUploadInterface {
  // StreamController<TaskProgressModel> get progressStreamController => _progressStreamController;
  final _progressStreamController = StreamController<TaskProgressModel>();
  Stream<TaskProgressModel> get outProgress => _progressStreamController.stream;

  /// 人类可读的进度值 1% 50% 100%
  String get percentString => (_currentProgress.progress / 100).toPercent();

  /// 值
  double _progress = 0.0;

  /// 计算时间
  int _totalSize = 0; // 下载/上传 总数据
  int _receivedSize = 0; // 已 下载/上传 数据
  int _nSecondAgoSize = 0; // 保存 _intervalSec 秒前 下载/上传 的大小
  final int _intervalSec = 1; // 间隔几秒计算一次
  late Timer _timer; // 定时器

  /// 返回的具体信息
  String _speed = '0/s Mbps'; // 下载速度
  String get _size =>
      _totalSize == 0.0 ? '0MB' : FileSize(_totalSize).toString(); // 文件大小
  int _status = 1; // 状态 TODO 会影响上层的 不能设置 0 最后把状态提出去
  String _timeLeft = '00:00'; // 剩余时间

  bool get isProgressDone => _currentProgress.status == 2;
  TaskProgressModel get currentProgress => _currentProgress;
  TaskProgressModel _currentProgress = TaskProgressModel(
    sizeText: '',
    speedText: '',
    timeLeftText: '',
    progress: 0.0,
    status: 0,
  );
  TaskProgressModel get loadingProgress => TaskProgressModel(
        sizeText: _currentProgress.sizeText,
        speedText: _currentProgress.speedText,
        timeLeftText: _currentProgress.timeLeftText,
        progress: _currentProgress.progress,
        status: 1,
      );
  TaskProgressModel get successProgress => TaskProgressModel(
        sizeText: _currentProgress.sizeText,
        speedText: _currentProgress.speedText,
        timeLeftText: _currentProgress.timeLeftText,
        progress: _currentProgress.progress,
        status: 2,
      );
  TaskProgressModel get errorProgress => TaskProgressModel(
        sizeText: _currentProgress.sizeText,
        speedText: _currentProgress.speedText,
        timeLeftText: _currentProgress.timeLeftText,
        progress: _currentProgress.progress,
        status: 3,
      );
  TaskProgressModel get timeOutProgress => TaskProgressModel(
        sizeText: _currentProgress.sizeText,
        speedText: _currentProgress.speedText,
        timeLeftText: _currentProgress.timeLeftText,
        progress: _currentProgress.progress,
        status: 4,
      );

  /// 开始计算
  void startProgress() {
    _startTimeout();
  }

  void updateProgress(int count, int total) {
    var progress = (count / total * 100).truncateToDouble(); // 0.0 ~ 100.0
    _receivedSize = count;
    _totalSize = total;
    _progress = progress;
    if (_progress == 100.0) {
      _status = 2;
      _timer.cancel();
    } else {
      _status = 1;
    }
    _currentProgress = TaskProgressModel(
      sizeText: _size,
      speedText: _speed,
      timeLeftText: _timeLeft,
      progress: _progress,
      status: _status,
    );
  }

  /// 创建速度计时器
  void _createSpeedTimer() {
    _nSecondAgoSize = _receivedSize;
    _timer = Timer(Duration(seconds: _intervalSec), _startTimeout);
    // 周期性定时器
    // _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer){
    //   handleTimeout();
    // });
    _progressStreamController.sink.add(_currentProgress);
  }

  /// 开始计时 并启动计时器
  void _startTimeout() {
    if (_receivedSize != 0) {
      int differenceValue = _receivedSize - _nSecondAgoSize; // 几秒内一共接收的数据量
      if (differenceValue != 0) {
        int everySecondValue = (differenceValue / _intervalSec).ceil(); // 每秒
        int surplusValue = _totalSize - _receivedSize; // 剩余
        int totalTimeValue = (surplusValue / everySecondValue).ceil();
        var ttText = mp3PlayTimeText(Duration(seconds: totalTimeValue));
        var speedText = FileSize(everySecondValue).toString(0);
        var txt = "$speedText/s"; // 32 KB/s Mbps
        _speed = txt;
        _timeLeft = ttText;
        // _timeLeft = _status == 1 ? '00:00' : ttText; // 优化显示
      } else {
        /// 不能从上面判断进度
        // print('什么都没有变化');
      }
      if (_receivedSize == _totalSize) {
        _timer.cancel();
        _progressStreamController.sink.add(successProgress);
        _progressStreamController.sink.close();
      } else {
        _timer.cancel();
        _createSpeedTimer();
      }
    } else {
      _createSpeedTimer();
    }
  }

  /// 返回 可读的 剩余的持续时间
  String mp3PlayTimeText(Duration? duration) {
    if (duration == null) return '00:00';
    var microseconds = duration.inMicroseconds;
    var hours = microseconds ~/ Duration.microsecondsPerHour;
    microseconds = microseconds.remainder(Duration.microsecondsPerHour);
    if (microseconds < 0) microseconds = -microseconds;
    var minutes = microseconds ~/ Duration.microsecondsPerMinute;
    microseconds = microseconds.remainder(Duration.microsecondsPerMinute);
    var minutesPadding = minutes < 10 ? "0" : "";
    var seconds = microseconds ~/ Duration.microsecondsPerSecond;
    microseconds = microseconds.remainder(Duration.microsecondsPerSecond);
    var secondsPadding = seconds < 10 ? "0" : "";
    return "${hours > 0 ? "$hours:" : ""}$minutesPadding$minutes:$secondsPadding$seconds";
  }
}

class ProgressDownloadOrUploadData {
  final double progress;
  final int total; // 下载/上传 总数据
  final int received; // 已 下载/上传 数据
  ProgressDownloadOrUploadData({
    this.progress = 0.0,
    this.total = 0,
    this.received = 0,
  });
}

class TaskProgressModel {
  final String sizeText;
  final String speedText;
  final String timeLeftText;
  final double progress;
  // 0 未开始
  // 1 已开始
  // 2 已完成
  final int status;
  TaskProgressModel({
    this.sizeText = '',
    this.speedText = '',
    this.timeLeftText = '',
    this.progress = 0.0,
    required this.status,
  });

  @override
  toString() {
    return '{ sizeText: $sizeText, speedText: $speedText, timeLeftText: $timeLeftText, progress: $progress, status: $status }';
  }
}
