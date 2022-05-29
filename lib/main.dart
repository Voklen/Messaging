import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => RECEIVE();
}

class RECEIVE extends State<MyHomePage> {
  late Socket _socket;
  String _message = "";

  // SERVER SEND
  Future<String> _serverSend() async {
    ServerSocket.bind(InternetAddress.anyIPv6, 4567)
        .then((ServerSocket server) {
      server.listen(handleClient);
    });
    return "Server running";
  }

  void handleClient(Socket client) {
    client.write("Hello from simple server!\n");
    client.close();
  }

  // CLIENT RECEIVE
  void _clientReceive() async {
    _socket = await Socket.connect("localhost", 4567);
    start(_socket);
  }

  void start(Socket s) {
    var _socket = s;
    var _address = _socket.remoteAddress.address;
    var _port = _socket.remotePort;

    _socket.listen(messageHandler,
        onError: errorHandler, onDone: finishedHandler);
  }

  void messageHandler(Uint8List data) {
    String message = String.fromCharCodes(data).trim();
    setState(() {
      _message = 'Message: $message';
    });
  }

  void errorHandler(error) {
    setState(() {
      _message = 'Message: $error';
    });
    _socket.close();
  }

  void finishedHandler() {
    // setState(() {
    //   _message = 'Disconnected';
    // });
    _socket.close();
  }

  void write(String message) {
    _socket.write(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: _clientReceive,
                child: const Text('Receive message (Client)')),
            ElevatedButton(
                onPressed: _serverSend,
                child: const Text('Send message (Server)')),
            const Text('The message is:'),
            Text(_message)
          ],
        ),
      ),
    );
  }
}
