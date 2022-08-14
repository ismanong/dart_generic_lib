import 'package:intl/intl.dart';

// void main() {
//   const duration = Duration(seconds: 3, milliseconds: 125, microseconds: 369);
//   print(DateUtil.durationToString(duration, useMilliseconds: true)); // 3125369
// }

class DateUtil {
  // 当前时间 返回年月日
  static String currentYYYYMMDD() {
    var now = DateTime.now();
    var str =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return str;
  }

  // 转换时间 返回年-月-日
  // 例子: 2022-01-08 16:33:47 => 2021-01-01
  // 例子: 2022/01/08 16:33:47 => 2021-01-01
  static String convertYYYYMMDD(String dateStr) {
    var sort = dateStr.split(' ')[0].split(RegExp(r"-|/"));
    return "${sort[0]}-${sort[1].padLeft(2, '0')}-${sort[2].padLeft(2, '0')}";
    // var date = DateTime.tryParse(dateStr) ?? DateTime.tryParse(dateStr.replaceAll('/', '-'));
    // if (date != null) {
    //   return "${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    // } else {
    //   return dateStr.substring(0, dateStr.indexOf(' '));
    // }
  }

  static String dateFormatTimestamp(int timestamp,
      {bySecond = false, format = 'yyyy-MM-dd HH:mm'}) {
    // 默认接收毫秒时间戳 如果服务按秒返回 则设置bySecond:true
    if (bySecond) {
      timestamp = timestamp * 1000;
    }
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat(format).format(dateTime);
  }

  static String dateTimeFormat([DateTime? dateTime, String? format]) {
    dateTime ??= DateTime.now();
    format ??= 'yyyy-MM-dd HH:mm:ss';
    return DateFormat(format).format(dateTime);
  }

  /// 返回时间距离 如：几分钟前
  static String formatDistanceToNow(int millisecondsValue) {
    Duration d = Duration(
        milliseconds:
            DateTime.now().millisecondsSinceEpoch - millisecondsValue);
    var seconds = d.inSeconds;
    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;
    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;
    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final List<String> tokens = [];
    if (days != 0) {
      // tokens.add('${days}d');
      return '$days days ago';
    }
    if (tokens.isNotEmpty || hours != 0) {
      // tokens.add('${hours}h');
      return '$hours hours ago';
    }
    if (tokens.isNotEmpty || minutes != 0) {
      // tokens.add('${minutes}m');
      return '$minutes minutes ago';
    }
    // tokens.add('${seconds}s');
    return '$seconds seconds ago';

    // return tokens.join(':');
  }

  static String durationToString(
    Duration d, {
    bool useDay = false, // 123:01:01
    useMilliseconds = false, // 123:01:01.456
  }) {
    var dList = [
      d.inHours,
      d.inMinutes.remainder(60),
      d.inSeconds.remainder(60),
    ];
    if (useDay) {
      dList = [
        d.inDays,
        d.inHours.remainder(24),
        d.inMinutes.remainder(60),
        d.inSeconds.remainder(60),
      ];
    }
    var dStr = dList.map((int seg) => seg.toString().padLeft(2, '0')).join(':');
    if (useMilliseconds) {
      return '$dStr.${d.inMilliseconds.remainder(1000)}';
    } else {
      return dStr;
    }
  }

  /// 0:00:00.000000 to 00:00:00
  /// extension DurationFormatter on Duration {
  ///   String dayHourMinuteSecondFormatted() {
  ///     this.toString();
  ///     return [
  ///       this.inDays,
  ///       this.inHours.remainder(24),
  ///       this.inMinutes.remainder(60),
  ///       this.inSeconds.remainder(60)
  ///     ].map((seg) {
  ///       return seg.toString().padLeft(2, '0');
  ///     }).join(':');
  ///   }
  /// }

  /// 00:10:20 to 10:20
  static String durationToString2(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    //  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    // 下面代码是stackoverflow加工的 避免显示00小时
    List<String> output = [];
    if (duration.inHours > 0) {
      output.add(twoDigits(duration.inHours).toString());
    }
    if (int.parse(twoDigitSeconds) > 0) {
      output.add(twoDigitMinutes);
      output.add(twoDigitSeconds);
    }
    return output.join(':');
  }

  // 跟当前时间比较 比现在时间大 返回true
  static bool dateNowDiff(int timestamp) {
    timestamp = timestamp.toString().length > 10 ? timestamp : timestamp * 1000;
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(dateTime).inSeconds <= 0;
  }

  // static String dateAndTimeToString(var timestamp,
  //     {Map<String, String> formart}) {
  //   if (timestamp == null || timestamp == "") {
  //     return "";
  //   }
  //   String targetString = "";
  //   final date = new DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
  //
  //   String year = date.year.toString();
  //   String month = date.month.toString();
  //   if (date.month <= 9) {
  //     month = "0" + month;
  //   }
  //   String day = date.day.toString();
  //   if (date.day <= 9) {
  //     day = "0" + day;
  //   }
  //   String hour = date.hour.toString();
  //   if (date.hour <= 9) {
  //     hour = "0" + hour;
  //   }
  //   String minute = date.minute.toString();
  //   if (date.minute <= 9) {
  //     minute = "0" + minute;
  //   }
  //   String second = date.second.toString();
  //   if (date.second <= 9) {
  //     second = "0" + second;
  //   }
  //
  //   String morningOrafternoon = "上午";
  //   if (date.hour >= 12) {
  //     morningOrafternoon = "下午";
  //   }
  //
  //   if (formart["y-m"] != null && formart["m-d"] != null) {
  //     targetString = year + formart["y-m"] + month + formart["m-d"] + day;
  //   } else if (formart["y-m"] == null && formart["m-d"] != null) {
  //     targetString = month + formart["m-d"] + day;
  //   } else if (formart["y-m"] != null && formart["m-d"] == null) {
  //     targetString = year + formart["y-m"] + month;
  //   }
  //
  //   targetString += " ";
  //
  //   if (formart["m-a"] != null) {
  //     targetString += morningOrafternoon + " ";
  //   }
  //
  //   if (formart["h-m"] != null && formart["m-s"] != null) {
  //     targetString += hour + formart["h-m"] + minute + formart["m-s"] + second;
  //   } else if (formart["h-m"] == null && formart["m-s"] != null) {
  //     targetString += minute + formart["m-s"] + second;
  //   } else if (formart["h-m"] != null && formart["m-s"] == null) {
  //     targetString += hour + formart["h-m"] + minute;
  //   }
  //
  //   return targetString;
  // }

  /// 转换为当天的0点的时间戳
  static int convertToDayTimestamp(int timestamp, {bySecond: true}) {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(timestamp * (bySecond ? 1000 : 1));
    DateTime newDate = DateTime(date.year, date.month, date.day);
    return (newDate.millisecondsSinceEpoch / 1000).round();
  }

  ///
  /// 返回 可读的 剩余的持续时间
  ///
  /// 修改Duration().toString()的默认实现 丢掉毫秒 和 忽略小时为0
  /// 下面代码是复制Duration().toString()实现 修改的
  /// 可以直接扩展Duration
  static String mp3PlayTimeText(Duration? duration) {
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
    return (hours > 0 ? "$hours:" : "") +
        "$minutesPadding$minutes:$secondsPadding$seconds";
  }
}
