import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';
import 'dart:async';

///
/// 关于写入内容
/// File(path).openWrite() path里如果父目录不存在 则会报错 (OS Error: No such file or directory, errno = 2) 常用于stream流的写入
/// File(path).createSync(recursive: true) 会首先创建所有不存在的父目录 所以不会报错
///
class FileUtil {
  /// 代理
  /// 返回文件名
  /// '/some/path/to/file/file.dart' => 'file.dart'
  static String getFilename(filepath) => p.basename(filepath);

  static String getFilenameOnly(filepath) =>
      p.basename(filepath).replaceAll(extension(filepath), '');

  /// 代理
  /// 返回文件扩展名(后最)
  /// '/some/path/to/file/file.dart' => '.dart'
  static String extension(filepath) => p.extension(filepath);

  /// 代理
  /// 路径拼接 兼容各个平台路径分隔符
  /// 并检查是否存在，不存咋则创建
  static String join(String part1,
          [String? part2,
          String? part3,
          String? part4,
          String? part5,
          String? part6,
          String? part7,
          String? part8]) =>
      p.join(part1, part2, part3, part4, part5, part6, part7, part8);

  static String joinDirAndCreate(String part1,
          [String? part2,
          String? part3,
          String? part4,
          String? part5,
          String? part6,
          String? part7,
          String? part8]) =>
      checkDir(p.join(part1, part2, part3, part4, part5, part6, part7, part8));

  /// 递归方式获取目录大小
  static Future<int> getTotalSizeOfFilesInDirectory(
      final FileSystemEntity file) async {
    bool isExist = await file.exists();
    if (isExist) {
      if (file is File) {
        int length = await file.length();
        return length;
      }
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        int total = 0;
        if (isExist) {
          for (final FileSystemEntity child in children) {
            total += await getTotalSizeOfFilesInDirectory(child);
          }
        }
        return total;
      }
    }
    return 0;
  }

  /// 递归方式删除目录
  static Future<void> deleteDirectory(FileSystemEntity file) async {
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      for (final FileSystemEntity child in children) {
        await deleteDirectory(child);
      }
    } else {
      if (file.existsSync()) {
        await file.delete();
      }
    }
  }

  /// 递归方式获取目录的文件列表
  static Future<List<String>> getAllFilePath(String dirPath) async {
    // List<FileSystemEntity> fs = [];
    // if (await FileSystemEntity.isDirectory(dirPath)) {
    //   fs.addAll(Directory(dirPath).listSync());
    // }
    List<String> list = [];
    await for (var entity
        in Directory(dirPath).list(recursive: true, followLinks: false)) {
      // print(entity.path);
      if (entity is File) {
        list.add(entity.path);
      }
    }
    return list;
  }

  static String? readFile(String filePath) {
    File file = File(filePath);
    if (file.existsSync() == false) {
      return null;
    }
    String text = file.readAsStringSync();
    return text;
  }

  static String writeFile(String saveFilePath, List<int> data) {
    File saveFile = File(saveFilePath); // 需要保存的文件
    if (saveFile.existsSync() == false) {
      saveFile.createSync(recursive: true);
    }
    saveFile.writeAsBytesSync(data, flush: true);
    return saveFile.path;
  }

  // 通过文件的lengthSync()返回值 计算出以单位为MB的字符串值
  /// 返回 可读的 文件大小
  static String calculateSizeMB(int size, [String unit = 'MB']) {
    return FileSize(size).toString();

    /// 网速 Kbit/s Mbit/s
    String val;
    if (unit == 'MB') {
      val = (size / 1024 / 1024).toStringAsFixed(2);
    } else if (unit == 'KB') {
      val = (size / 1024).toStringAsFixed(0);
    } else {
      throw '计算字节大小的单位类型错误';
    }
    return '$val$unit'; // 1.23MB
  }

  //  --------------------------------------------------------------------------
  /// 复制单个目录  fromDirectory 到 toDirectory
  static void copyDirectory(String fromDirPath, String toDirPath) {
    Directory(fromDirPath)
        .listSync(recursive: true)
        .forEach((FileSystemEntity element) {
      if (FileSystemEntity.isDirectorySync(element.path)) {
        var dir = Directory(element.path);
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
      } else {
        File file = File(element.path);
        String filename =
            p.basename(element.path); // xxx.xxx  TODO 这里实现BUG 没有文件层级 待修复
        String newFilePath = p.join(toDirPath, filename);
        file.copy(newFilePath); //如果文件存在 则先删除文件 再复制
      }
    });
  }

  /// 复制单个文件
  static Future<File> copyFile(String fromFilePath, String toFilePath) {
    File file = new File(fromFilePath);
    // if(filename == null){
    //   filename = path.basename(filePath); // app-release.apk
    // }
    // String newFilePath = path.join(to, filename);
    return file.copy(toFilePath); //如果文件存在 则先删除文件 再复制
  }

  /// 检测 文件夹是否存在 不存在则创建
  /// 返回原目录
  static String checkDir(String directoryPath) {
    var dir = Directory(directoryPath);
    bool exists = dir.existsSync();
    if (!exists) {
      dir.createSync(recursive: true);
    }
    return directoryPath;
  }
  //--------------------------------------------------------------------------end

  /// fileExt 文件后缀名
  // static MediaType getMediaType(final String fileExt) {
  //   switch (fileExt.toLowerCase()) {
  //     case ".jpg":
  //     case ".jpeg":
  //     case ".jpe":
  //       return new MediaType("image", "jpeg");
  //     case ".png":
  //       return new MediaType("image", "png");
  //     case ".bmp":
  //       return new MediaType("image", "bmp");
  //     case ".gif":
  //       return new MediaType("image", "gif");
  //     case ".json":
  //       return new MediaType("application", "json");
  //     case ".svg":
  //     case ".svgz":
  //       return new MediaType("image", "svg+xml");
  //     case ".mp3":
  //       return new MediaType("audio", "mpeg");
  //     case ".mp4":
  //       return new MediaType("video", "mp4");
  //     case ".mov":
  //       return new MediaType("video", "mov");
  //     case ".htm":
  //     case ".html":
  //       return new MediaType("text", "html");
  //     case ".css":
  //       return new MediaType("text", "css");
  //     case ".csv":
  //       return new MediaType("text", "csv");
  //     case ".txt":
  //     case ".text":
  //     case ".conf":
  //     case ".def":
  //     case ".log":
  //     case ".in":
  //       return new MediaType("text", "plain");
  //   }
  //   return null;
  // }

  static void writeJsonFile(String filepath, Map<String, dynamic> json) {
    // var file = File(filepath);
    // if (file.existsSync()) {
    //   file.delete();
    // }
    String prettyJsonStr = new JsonEncoder.withIndent('    ').convert(json);
    List<int> bytes = utf8.encode(prettyJsonStr);
    writeFile(filepath, bytes);
  }

  /// 计算文件 md5 值
  static Future<String> calculateFileMd5(File file,
      [bool short = false]) async {
    final String md5Str = md5.convert(await file.readAsBytes()).toString();
    if (short) {
      final String shortMd5 = md5Str.substring(md5Str.length - 6);
      return shortMd5;
    } else {
      return md5Str;
    }
  }
}

/// 名字可能冲突
class FileSize with Comparable<FileSize> {
  final int totalBytes;
  const FileSize(this.totalBytes);

  static const FileSize unknown = FileSize(0);

  @override
  int compareTo(FileSize other) => totalBytes.compareTo(other.totalBytes);

  /// Total kilobytes.
  double get totalKiloBytes => totalBytes / 1024;

  /// Total megabytes.
  double get totalMegaBytes => totalKiloBytes / 1024;

  /// Total gigabytes.
  double get totalGigaBytes => totalMegaBytes / 1024;

  String _getLargestSymbol() {
    if (totalGigaBytes.abs() >= 1) {
      return 'GB';
    }
    if (totalMegaBytes.abs() >= 1) {
      return 'MB';
    }
    if (totalKiloBytes.abs() >= 1) {
      return 'KB';
    }
    return 'B';
  }

  num _getLargestValue() {
    if (totalGigaBytes.abs() >= 1) {
      return totalGigaBytes;
    }
    if (totalMegaBytes.abs() >= 1) {
      return totalMegaBytes;
    }
    if (totalKiloBytes.abs() >= 1) {
      return totalKiloBytes;
    }
    return totalBytes;
  }

  @override
  String toString([int? toStringAsFixed]) =>
      '${_getLargestValue().toStringAsFixed(toStringAsFixed ?? 2)} ${_getLargestSymbol()}';
}

/// file扩展
extension DirectoryExtension on Directory {
  /// Recursively lists all the present [File]s inside the [Directory].
  ///
  /// * Safely handles long file-paths on Windows (https://github.com/dart-lang/sdk/issues/27825).
  /// * Does not terminate on errors e.g. an encounter of `Access Is Denied`.
  /// * Does not follow links.
  /// * Returns only [List] of [File]s.
  ///
  Future<List<File>> list_() async {
    final prefix =
        Platform.isWindows && !path.startsWith('\\\\') ? r'\\?\' : '';
    final completer = Completer();
    final files = <File>[];
    Directory(prefix + path)
        .list(
      recursive: true,
      followLinks: false,
    )
        .listen(
      (event) {
        // Explicitly restricting to [kSupportedFileTypes] for avoiding long iterations in later operations.
        /// TODO
        // if (event is File && kSupportedFileTypes.contains(event.extension)) {
        //   files.add(File(event.path.substring(prefix.isNotEmpty ? 4 : 0)));
        // }
      },
      onError: (error) {
        // For debugging. In case any future error is reported.
        print('Directory.list_: ${error}');
      },
      onDone: completer.complete,
    );
    await completer.future;
    return files;
  }
}

extension FileSystemEntityExtension on FileSystemEntity {
  /// 安全删除 [FileSystemEntity]。
  FutureOr<void> delete_() async {
    if (await exists_()) {
      final prefix =
          Platform.isWindows && !path.startsWith('\\\\') ? r'\\?\' : '';
      if (this is File) {
        await File(prefix + path).delete();
      } else if (this is Directory) {
        await Directory(prefix + path).delete();
      }
    }
  }

  /// 安全地检查 [FileSystemEntity] 是否存在。
  FutureOr<bool> exists_() {
    final prefix =
        Platform.isWindows && !path.startsWith('\\\\') ? r'\\?\' : '';
    if (this is File) {
      return File(prefix + path).exists();
    } else if (this is Directory) {
      return Directory(prefix + path).exists();
    } else {
      return false;
    }
  }

  /// 安全地检查 [FileSystemEntity] 是否存在。
  bool existsSync_() {
    final prefix =
        Platform.isWindows && !path.startsWith('\\\\') ? r'\\?\' : '';
    if (this is File) {
      return File(prefix + path).existsSync();
    } else if (this is Directory) {
      return Directory(prefix + path).existsSync();
    } else {
      return false;
    }
  }
}
