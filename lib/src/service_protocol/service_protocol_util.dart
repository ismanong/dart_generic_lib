import 'dart:developer';

/// 服务端
void main() {
  Service.getInfo().then((info) {
    final serviceUri = info.serverUri;
    if (serviceUri == null) {
      print('╔════════════════════════════════════════╗');
      print('║      ERROR STARTING ???? CONNECT       ║');
      print('╚════════════════════════════════════════╝');
      return;
    }
    final host = serviceUri.host;
    final port = serviceUri.port;
    var path = serviceUri.path;
    if (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    if (path.endsWith('=')) {
      path = path.substring(0, path.length - 1);
    }
    print('╔══════════════════════════════════════════════╗');
    print('║ https://$host/#/$port$path ║');
    print('╚══════════════════════════════════════════════╝');
  });
}
