import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/message/message_bloc.dart';
import 'blocs/socket_io/socket_io_bloc.dart';

class FlightChat extends StatefulWidget {
  final int flightId;

  const FlightChat({super.key, required this.flightId});

  @override
  State<FlightChat> createState() => _FlightChatState();
}

class _FlightChatState extends State<FlightChat> {
  late SocketIoBloc _socketIoBloc;

  @override
  void initState() {
    super.initState();

    _socketIoBloc = context.read<SocketIoBloc>();

    context.read<MessageBloc>().add(MessageInitialized(flightId: widget.flightId));
  }

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: BlocBuilder<MessageBloc, MessageState>(
        builder: (context, state) {
          if (state.status == MessageStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == MessageStatus.loaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(state.messages[index].user.firstName),
                        subtitle: Text(state.messages[index].content),
                        trailing: Text(state.messages[index].createdAt),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Type a message",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _socketIoBloc.state.socket!.emit(
                            "newMessageBack",
                            jsonEncode({
                              "flightId": widget.flightId,
                              "content": _controller.text,
                            }),
                          );

                        },
                        child: const Text("Send"),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
