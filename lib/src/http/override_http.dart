import 'dart:io';

void overrideHttp() {
  HttpOverrides.global = MyHttpOverrides();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..findProxy = (uri) {
        // String proxy = Platform.isAndroid ? '<YOUR_LOCAL_IP>:8888' : 'localhost:8888';
        String proxy = 'localhost:1080';
        // String proxy = '$ip:$port';
        return "PROXY $proxy;";
      }
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    // ..badCertificateCallback = ((X509Certificate cert, String host, int port) => Platform.isAndroid);
  }
}

/// 如果你扩展了HttpOverrides，那么在该类中super.createHttpClient(context)会给你dart:io的HttpClient。
/// 因此，举例来说，如果你想在整个应用程序中拦截所有的HttpClient调用，你会这样做。
// class MyHttpClient implements HttpClient {
//   HttpClient _realClient;
//   MyHttpClient(this._realClient);
//   ...
// }
// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext context) {
//     return new MyHttpClient(super.createHttpClient(context));
//   }
// }
