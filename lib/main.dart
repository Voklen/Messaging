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
  final List<Connection> _connections = [];

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
    var socket = await Socket.connect("localhost", 4567);
    var connection = Connection(socket, removeConnection);
    _connections.add(connection);
  }

  // void showMessage(String message) {
  //   setState(() {
  //     _messages.add(message);
  //   });
  // }

  void removeConnection(Connection con) {
    _connections.remove(con);
  }

  @override
  Widget build(BuildContext context) {
    List<String> messages = [];
    for (var i in _connections) {
      messages.addAll(i.messages);
    }
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
            Text(messages.toString())
          ],
        ),
      ),
    );
  }
}

class Connection {
  final Socket _socket;
  final Function _remove;

  List<String> messages = [];

  Connection(this._socket, this._remove) {
    _socket.listen(messageHandler,
        onError: errorHandler, onDone: finishedHandler);
  }

  void messageHandler(Uint8List data) {
    String message = String.fromCharCodes(data).trim();
    messages.add(message);
  }

  void errorHandler(error) {
    _remove(this);
    _socket.close();
  }

  void finishedHandler() {
    // _remove(this);
    // _socket.close();
  }

  void write(String message) {
    _socket.write(message);
  }
}
