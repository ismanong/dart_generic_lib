//typedef RetryCallback = Future<bool> Function();

class VersionUtil {
  /// https://pub.dev/packages/http#retrying-requests 重试请求
  // 函数重试
  // 返回值为 重试结果 任意次数内成功 即代表成功
  static Future<int> retry(int retry, Function cb, {int? intervalTime}) async {
    int status = 0;
    for (int i = 1; i <= retry; i++) {
      status = await cb();
      if (status != -2) {
        return status;
      } else {
        if (i < retry && intervalTime != null) {
          await Future.delayed(Duration(seconds: intervalTime));
        }
      }
    }
    return status;
  }

  static int getIntVersion(String version) {
    List partList = version.split('.');

    //版本号默认3位
    String value = "";
    for (int i = 0; i < 3; i++) {
      value += partList[i];
    }
    int intVersion = int.parse(value) * 10000;

    //预留第4位
    if (partList.length == 4) {
      intVersion += int.parse(partList[3]);
    }
    return intVersion;
  }

  /// 比较版本号 1.0.0 -> 主版本号.次版本号.修订号
  static int compareToVersion(String currentVersion, String compareVersion) {
    int currentIntVersion = getIntVersion(currentVersion);
    int latestIntVersion = getIntVersion(compareVersion);

    if (currentIntVersion == latestIntVersion) {
      return 0; //相等
    } else if (currentIntVersion < latestIntVersion) {
      return 1; //小于
    }
    return -1; //大于
  }

  // static int compareToVersion({String currentVersion, String latestVersion}) {
  //   List<int> ver1ListNum =
  //   currentVersion.split('.').map((String e) => int.parse(e)).toList();
  //   List<int> ver2ListNum =
  //   latestVersion.split('.').map((String e) => int.parse(e)).toList();
  //
  //   /// 0 不需要升级
  //   /// 1 需要升级
  //   /// -1 版本回退 错误 等。。。
  //   if (ver1ListNum[0] < ver2ListNum[0]) {
  //     return 1;
  //   } else if (ver1ListNum[0] > ver2ListNum[0]) {
  //     return -1;
  //   }
  //
  //   if (ver1ListNum[1] < ver2ListNum[1]) {
  //     return 1;
  //   } else if (ver1ListNum[1] > ver2ListNum[1]) {
  //     return -1;
  //   }
  //
  //   if (ver1ListNum[2] < ver2ListNum[2]) {
  //     return 1;
  //   } else if (ver1ListNum[2] > ver2ListNum[2]) {
  //     return -1;
  //   }
  //
  //   return 0;
  // }

  //版本比较
  bool compareVersion(String latestVersion, String currentVersion) {
    bool update = false;
    final List latestList = latestVersion.split('.');
    final List currentList = currentVersion.split('.');

    for (int i = 0; i < latestList.length; i++) {
      try {
        if (int.parse(latestList[i] as String) >
            int.parse(currentList[i] as String)) {
          update = true;
          break;
        }
      } catch (e) {
        break;
      }
    }
    return update;
  }

  // static String getMd5(String str) {
  //   var content = new Utf8Encoder().convert(str);
  //   String md5str = md5.convert(content).toString();
  //   return md5str;
  // }
}
