import 'dart:core';
import 'dart:io';

void main(List<String> arguments) {
  print('Hello world!');
  startHTTPServer();
}

typedef MessageCallback = Function(String message);

HttpServer? _httpServer;

MessageCallback? _callback;

void addListener(MessageCallback callback) {
  _callback = callback;
}

void startHTTPServer() async {
  var server = await HttpServer.bind(
    InternetAddress.anyIPv4,
    12345,
  );
  _httpServer = server;
  // 192.168.32.167:12345
  print('Listening on ${server.address.host}:${server.port}');

  await for (HttpRequest request in server) {
    print('HttpRequest - $request');
    final message = 'HTTP RES - ${DateTime.now().toIso8601String()}';

    _callback?.call('New HTTP Request: ${request.uri}');
    request.response
      ..write(message)
      ..close();
  }
}

void closeHTTPServer() {
  _httpServer?.close();
}

ServerSocket? _serverSocket;

void startSocketServer() async {
  final server = await ServerSocket.bind('0.0.0.0', 54321);
  _serverSocket = server;
  print(server);
  print(
      'server - ${server.address.host} ${server.address.address} ${server.port}');
  server.listen((Socket socket) {
    print(
        'socket - ${socket.address.host} ${socket.address.address} ${socket.port}');
    socket.listen((List<int> data) {
      String result = String.fromCharCodes(data);
      String message = result.substring(0, result.length - 1);
      print('Socket Listen - $message');
      _callback?.call('New Socket Message: $message');
      final response = 'Socket RES - ${DateTime.now().toIso8601String()}';
      socket.write(response);
    });
  });
}

void closeSocketServer() {
  _serverSocket?.close();
}
