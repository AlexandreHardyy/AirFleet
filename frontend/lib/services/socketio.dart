import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// TODO Move this
class SocketProvider extends InheritedWidget {
  final IO.Socket socket;

  const SocketProvider({super.key, required this.socket, required super.child});

  @override
  bool updateShouldNotify(SocketProvider oldWidget) {
    return socket != oldWidget.socket;
  }

  static SocketProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SocketProvider>();
  }
}