import 'dart:convert';
import 'dart:io';

import 'package:dart_generic_lib/dart_generic_lib.dart';

/// 调用shell命令行 编译apk ipa

class ShellUtil {
  /// 快捷windows的删除命令
  /// 此命令不删除执行路径的根目录 因为rd删除包含根目录 所以用md在创建一次
  /// 如果需要删除自行修改
  static void deleteDir(String directory) async =>
      await execShell('rd /s /q $directory && md $directory');

  /// 快捷windows的复制拷贝命令
  static void copyDir(String fromDirPath, String toDirPath) async =>
      await execShell('xcopy $fromDirPath $toDirPath /s /y /i');

  static Future<void> execShell(String exec) async {
    print('\nshell: \n$exec');
    String executable = exec;
    Process process;
    if (Platform.isMacOS) {
      // https://stackoverflow.com/questions/25567795/why-cant-darts-process-start-execute-an-ubuntu-command-when-the-command-work
      // https://stackoverflow.com/questions/13938217/set-environment-variable-using-process-start
      process =
          await Process.start("bash", ["-c", executable], runInShell: true);
    } else if (Platform.isWindows) {
      if (executable.contains('\n')) {
        executable = executable
            .split('\n')
            .map((e) => e.trim())
            .toList()
            .where((e) => e.isNotEmpty)
            .toList()
            .join(' ; ');
      }

      /// 强制修改windows的命令行窗口输出编码格式为UTF-8 避免utf8.decoder解码中文结果错误
      const winUseUtf8 = 'chcp 65001 ; ';
      executable = winUseUtf8 + executable;
      process = await Process.start('Powershell.exe', ['-command', executable],
          runInShell: true);
      // process = await Process.start('Powershell.exe', ['-File', scriptPath], runInShell: true);
    } else {
      throw UnsupportedError('不支持此平台');
    }
    //如果用户未读取流上的所有数据，则由于仍存在未决数据，因此不会释放基础系统资源。
    // ------------------------- 必须读取stdout和stderr的所有数据, 缺少任意一个则不会退出
    void print2(str) => print("$str".trim());
    process.stdout.transform(utf8.decoder).forEach(print2);
    process.stderr.transform(utf8.decoder).forEach(print2);
    // ------------------------- end
    final exitCode = await process.exitCode; // 等待结束
    if (exitCode != 0) throw 'ShellUtil.execShell() 出错了';
    print('Exit code: $exitCode\n');
  }

  /// 老版本cmd
  static Future<void> execShellCmd(String exec) async {
    print('\nshell: \n$exec');
    String executable = exec;
    Process process;
    if (Platform.isMacOS) {
      // https://stackoverflow.com/questions/25567795/why-cant-darts-process-start-execute-an-ubuntu-command-when-the-command-work
      // https://stackoverflow.com/questions/13938217/set-environment-variable-using-process-start
      process =
          await Process.start("bash", ["-c", executable], runInShell: true);
    } else if (Platform.isWindows) {
      // cmd终端不支持多行 只能用 &(并行)、&&(串行)、|| 等命令
      String executableCmd = executable;
      if (executable.contains('\n')) {
        executableCmd = executable
            .split('\n')
            .map((e) => e.trim())
            .toList()
            .where((e) => e.isNotEmpty)
            .toList()
            .join(' && ');
      }

      /// 强制修改windows的CMD窗口输出编码格式为UTF-8 避免utf8.decoder解码中文结果错误
      const cmdUseUtf8 = 'chcp 65001 && ';
      executableCmd = cmdUseUtf8 + executableCmd;
      process = await Process.start(executableCmd, [], runInShell: true);
    } else {
      throw UnsupportedError('不支持此平台');
    }
    //如果用户未读取流上的所有数据，则由于仍存在未决数据，因此不会释放基础系统资源。
    // ------------------------- 必须读取stdout和stderr的所有数据, 缺少任意一个则不会退出
    void print2(str) => print("$str".trim());
    process.stdout.transform(utf8.decoder).forEach(print2);
    process.stderr.transform(utf8.decoder).forEach(print2);
    // ------------------------- end
    final exitCode = await process.exitCode; // 等待结束
    if (exitCode != 0) throw 'ShellUtil.execShell() 出错了';
    print('Exit code: $exitCode\n');
  }

  static Future<String> result(String exec) async {
    print('\nshell: \n$exec');
    String executable = exec;
    ProcessResult process;
    if (Platform.isWindows) {
      // cmd终端不支持多行 只能用 &(并行)、&&(串行)、|| 等命令
      String executableCmd = executable;
      if (executable.contains('\n')) {
        executableCmd = executable
            .split('\n')
            .map((e) => e.trim())
            .toList()
            .where((e) => e.isNotEmpty)
            .toList()
            .join(' && ');
      }
      // /// 强制修改windows的CMD窗口输出编码格式为UTF-8 避免utf8.decoder解码中文结果错误
      // const cmdUseUtf8 = 'chcp 65001 && ';
      // executableCmd = cmdUseUtf8 + executableCmd;
      process = await Process.run(executableCmd, [], runInShell: true);
    } else {
      throw '';
    }
    if (process.exitCode == 0) {
      return process.stdout.trim();
    } else {
      return process.stderr;
    }
  }

  /// 打开目录
  static void openDirectory(String directory) async {
    String executable = '';
    if (Platform.isWindows) {
      executable = 'start $directory';
    } else if (Platform.isMacOS) {
      executable = 'open $directory';
    } else {
      return;
    }
    // 执行shell
  }

  /// git当前分支
  /// result(gitCurrBranchCmd('git dir'))
  static String gitCurrBranchCmd(String gitDir) {
    return '''
      cd $gitDir
      git rev-parse --abbrev-ref HEAD
    ''';
  }

  /// git提交代码推送到远端
  static String gitPushCmd(String gitDir) {
    return '''
      cd $gitDir
      git pull
      git add --all
      git commit -m "自动提交 - Dart命令行 - ${DateTime.now().to_yyyy_MM_dd_HH_mm_ss()}"
      git push
    ''';
    // '''
    //   cd $gitDir
    //   git pull
    //   git add --all
    //   git commit -m "$currBranch - 自动提交 - Dart命令行"
    //   git push origin $pushBranch
    // '''
  }

  static String removeDirInPowerShell(String dir) {
    // cmd
    // rd /s /q ${toDirPath} && md ${toDirPath}
    return 'Remove-Item -Path "$dir" -Recurse';
  }

  static String copyDirInPowerShell(String fromDir, String toDir) {
    // cmd
    // xcopy ${fromDirPath} ${toDirPath} /s /y /i
    return 'Copy-Item "$fromDir" -Recurse "$toDir"';
  }

  static void log(String message) {
    print('==========================================');
    print('$message');
    print('==========================================');
  }
}
