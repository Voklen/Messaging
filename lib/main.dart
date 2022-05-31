import 'dart:io';
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
      home: const Chat(title: 'Flutter Demo Home Page'),
    );
  }
}

class Chat extends StatefulWidget {
  const Chat({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final List<ActiveConnection> _connections = [];
  final List<String> _messages = [];

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
    var connection = ActiveConnection(client, showMessage, removeConnection);
    _connections.add(connection);
  }

  // CLIENT RECEIVE
  void _clientReceive() async {
    var socket = await Socket.connect("localhost", 4567);
    var connection = ActiveConnection(socket, showMessage, removeConnection);
    _connections.add(connection);
  }

  void showMessage(String message) {
    setState(() {
      _messages.add(message);
    });
  }

  void _sendMessage() {
    _connections[0].sendMessage("heloooo");
  }

  void removeConnection(ActiveConnection con) {
    _connections.remove(con);
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
                child: const Text(
                    'Establish connection and receive message (Client)')),
            ElevatedButton(
                onPressed: _sendMessage,
                child: const Text('Send message (both)')),
            ElevatedButton(
                onPressed: _serverSend,
                child: const Text(
                    'Establish connection and send message (Server)')),
            const Text('The message is:'),
            Text(_messages.toString())
          ],
        ),
      ),
    );
  }
}

class ActiveConnection {
  final Socket _socket;
  final Function _onMessage;
  final Function _remove;

  ActiveConnection(this._socket, this._onMessage, this._remove) {
    _socket.listen(_messageHandler,
        onError: _errorHandler, onDone: _finishedHandler);
  }

  void _messageHandler(Uint8List data) {
    // This is where the message decoding will be
    // `message` will also be changed from a String to a `Message` class
    // To account for things like time sent and formatting
    String message = String.fromCharCodes(data).trim();
    _onMessage(message);
  }

  void _errorHandler(error) {
    _socket.close();
    _remove(this);
  }

  void _finishedHandler() {
    _socket.close();
    _remove(this);
  }

  void sendMessage(String message) {
    _socket.write(message);
  }
}

class StandbyConnection {
  final Socket _socket;
  final Function _remove;

  List<String> messages = [];

  StandbyConnection(this._socket, this._remove) {
    _socket.listen(_messageHandler,
        onError: _errorHandler, onDone: _finishedHandler);
  }

  void _messageHandler(Uint8List data) {
    // This should send a notification and write the message to disk
    String message = String.fromCharCodes(data).trim();
    messages.add(message);
  }

  void _errorHandler(error) {
    _socket.close();
    _remove(this);
  }

  void _finishedHandler() {
    // _socket.close();
    // _remove(this);
  }
}
