import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dart_generic_lib/dart_generic_lib.dart';

class LocalLogger with DenseIsolateInterface {
  String dir;
  LocalLogger({
    required this.dir,
  });

  @override
  Map get args => {
        'storageDirectory': dir,
      };

  /// 子线程要执行的 顶级函数 和 静态函数
  @override
  Future<void> createSubThreadTask(
      Map args, DenseIsolateCallback callback) async {
    try {
      callback(exitCode: 0);
    } catch (e) {
      print('$e');
      callback(exitCode: 1);
    }
  }

  @override
  void receive(Map data) {
    var count = data['count'];
    var total = data['total'];
    var exitCode = data['exitCode'];
    var log = data['log'];
    if (log != null) {
      print('$log');
      return;
    }
  }
}
