import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_serverResponse != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('New Server Response \n $_serverResponse'),
              ),
            ElevatedButton(
              child: const Text('HTTP Request'),
              onPressed: () {
                _makeHTTPRequest();
              },
            ),
            ElevatedButton(
              child: const Text('Socket : Connect'),
              onPressed: () {
                _makeSocketRequest();
              },
            ),
            ElevatedButton(
              child: const Text('Socket Request: Random'),
              onPressed: () {
                final message =
                    'Socket MSG - ${DateTime.now().toIso8601String()}';
                print('Socket Sending $message');
                _socket?.write(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _serverResponse;

  void updateResponse(String message) {
    setState(() {
      _serverResponse = message;
    });
    Future.delayed(const Duration(seconds: 20), () {
      setState(() {
        _serverResponse = null;
      });
    });
  }

  String ip = '192.168.32.167';

  _makeHTTPRequest() async {
    final message = 'HTTP MSG - ${DateTime.now().toIso8601String()}';
    final uri = Uri.parse('http://$ip:12345/$message');
    print('_makeHTTPRequest - $uri');
    Response response = await get(uri);
    updateResponse(response.body);
  }

  Socket? _socket;

  _makeSocketRequest() async {
    final socket = await Socket.connect(ip, 54321);
    _socket = socket;
    print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
    // listen for responses from the server
    socket.listen(
      // handle data from the server
      (Uint8List data) {
        final serverResponse = String.fromCharCodes(data);
        print('Socket: $serverResponse');
        updateResponse('Socket: data: $serverResponse');
      },

      // handle errors
      onError: (error) {
        print(error);
        updateResponse('Socket: onError: $error');
        socket.destroy();
      },

      // handle server ending connection
      onDone: () {
        print('Server left.');
        updateResponse('Socket: onDone');
        socket.destroy();
      },
    );
  }
}
