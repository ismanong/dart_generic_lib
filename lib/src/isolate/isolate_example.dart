import 'dart:async';
import 'dart:isolate';
import 'package:async/async.dart';

/// send() 本身不会阻塞，会立即发送，但可能需要线性时间成本用于复制数据。
/// exit() 则是在退出隔离中保存消息的内存，不会被复制，而是被传输到主 isolate。这种传输很快，并且在恒定的时间内完成。
/// 使用 exit() 替代 SendPort.send，可规避数据复制，节省耗时。

/// 方法一：使用compute
///如上所述，有几种方法可以在 Flutter 中创建隔离区。最简单的方法之一是使用该compute功能。这将在不同的隔离中执行我们的代码并将结果返回给我们的主隔离。
///这将在内部产生一个隔离，在其中运行解码逻辑，并将结果返回给我们的主隔离。这适用于不频繁或一次性的任务，因为我们不能重用隔离。
// class Person {
//   final String name;
//   Person(this.name);
// }
// Person deserializePerson(String data) {
//   // JSON decoding is a costly thing its preferable
//   // if we did this off the main thread
//   Map<String, dynamic> dataMap = jsonDecode(data);
//   return Person(dataMap["name"]);
// }
// Future<Person> fetchUser() async {
//   String userData = await Api.getUser();
//   return await compute(deserializePerson, userData);
// }

/// 方法二：使用Isolate.spawn
///这个方法是处理隔离物的基本方法之一，而且compute方法也是使用这个方法实现。
///
/// 我们将端口和序列化数据组合成一个列表并发送出去。接下来，我们使用将值返回给主隔离并等待与 相同。最后，我们杀死隔离物以完成清理。sendPort.sendport.first
// Future<Person> fetchUser() async {
//   ReceivePort port = ReceivePort();
//   String userData = await Api.getUser();
//   final isolate = await Isolate.spawn<List<dynamic>>(
//       deserializePerson, [port.sendPort, userData]);
//   final person = await port.first;
//   isolate.kill(priority: Isolate.immediate);
//   return person;
// }
// void deserializePerson(List<dynamic> values) {
//   SendPort sendPort = values[0];
//   String data = values[1];
//   Map<String, dynamic> dataMap = jsonDecode(data);
//   sendPort.send(Person(dataMap["name"]));
// }
/// 重用 Flutter 隔离
/// 虽然前面的示例最适合用于单次任务，但我们可以通过设置两个端口进行双向通信，并在侦听port流以获取结果时发送更多数据以进行反序列化，从而轻松重用我们在上面创建的隔离。
// void deserializePerson(SendPort sendPort) {
//   ReceivePort receivePort = ReceivePort();
//   sendPort.send(receivePort.sendPort);
//   receivePort.listen((message) {
//     Map<String, dynamic> dataMap = jsonDecode(message);
//     sendPort.send(Person(dataMap["name"]));
//   });
// }

void main() async {
  ConcurrencyTask.test();
}

class ConcurrencyTask {
  /// 运行例子
  static void test() async {
    final numbs = [10000, 20000, 30000, 40000];
    await for (final jsonData in _sendAndReceive(numbs)) {
      print('Received $jsonData');
    }
  }

  /// 执行的任务
  static Future<int> _executeTask(int num) async {
    int count = 0;
    while (num > 0) {
      if (num % 2 == 0) {
        count++;
      }
      num--;
    }
    await Future.delayed(const Duration(seconds: 1));
    return count;
  }

  /// 具体的iso实现（主线程）
  // 生成一个隔离器，并异步地发送一个文件名列表，供其
  // 读取和解码。等待包含解码后的JSON的响应。
  // 然后再发送下一个。
  //
  // 返回一个流，该流将每个文件的JSON解码后的内容发射出来。
  static Stream<int> _sendAndReceive(List<int> filenames) async* {
    final p = ReceivePort();
    await Isolate.spawn(_subThreadService, p.sendPort);

    // 将 ReceivePort 转换为 StreamQueue，以接收来自于
    // 使用基于拉动的接口生成的隔离器。事件被存储在这个
    //队列中，直到它们被`events.next`访问。
    final events = StreamQueue<dynamic>(p);

    // 从产卵的隔离体发出的第一个消息是一个SendPort。这个端口是
    // 用来与生成的隔离区进行通信。
    SendPort sendPort = await events.next;

    for (var filename in filenames) {
      // 发送下一个要读取和解析的文件名
      sendPort.send(filename);

      // 接收解析后的JSON
      int message = await events.next;

      // 将结果添加到这个异步*函数返回的流中。
      yield message;
    }

    // 向生成的隔离体发送一个信号，指示它应该退出。
    sendPort.send(null);

    // Dispose the StreamQueue.
    await events.cancel();
  }

  ///具体的iso实现（子线程）
  // 在被催生的隔离区上运行的入口。接收来自
  // 读取文件的内容，对JSON进行解码，并将结果发送至主隔离区。
  // 将结果发回给主隔离区。
  static Future<void> _subThreadService(SendPort p) async {
    print('Spawned isolate started.');

    // 向主隔离区发送一个 SendPort，这样它就可以将 JSON 字符串发送到
    // 此隔离区。
    final commandPort = ReceivePort();
    p.send(commandPort.sendPort);

    // 等待来自主隔离区的消息。
    await for (final message in commandPort) {
      if (message is int) {
        // 读取并解码该文件。
        final contents = await _executeTask(message);

        // 将结果发送到主隔离区。
        p.send(contents);
      } else if (message == null) {
        // 如果主隔离区发出空信息，表明没有其他文件可供读取和解析，则退出。
        // 更多的文件需要读取和解析。
        break;
      }
    }

    print('Spawned isolate finished.');
    Isolate.exit();
  }
}
