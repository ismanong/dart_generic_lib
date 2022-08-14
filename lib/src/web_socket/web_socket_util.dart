import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// 服务端
// void main() {
//   var handler = webSocketHandler((webSocket) {
//     webSocket.stream.listen((message) {
//       webSocket.sink.add("echo $message");
//     });
//   });
//
//   shelf_io.serve(handler, 'localhost', 8080).then((server) {
//     print('Serving at ws://${server.address.host}:${server.port}');
//   });
// }

/// 客户端
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/status.dart' as status;
//
// main() async {
//   var channel = IOWebSocketChannel.connect(Uri.parse('ws://localhost:1234'));
//
//   channel.stream.listen((message) {
//     channel.sink.add('received!');
//     channel.sink.close(status.goingAway);
//   });
// }
