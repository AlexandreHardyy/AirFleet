import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/storage/user.dart';
import 'package:intl/intl.dart';

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

            if (!state.isModuleEnabled) {
              return Center(child: Text(translate('chat.module_disabled')));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final isCurrentUser = state.messages[index].user.id == UserStore.user?.id;
                      final DateTime parsedDate = DateTime.parse(state.messages[index].createdAt);
                      final String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(parsedDate);

                      return Align(
                        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(
                            top: 4.0,
                            bottom: 4.0,
                            left: isCurrentUser ? 50.0 : 8.0,
                            right: isCurrentUser ? 8.0 : 50.0,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isCurrentUser ? const Color(0xFFDCA200) : const Color(0xFF131141),
                          ),
                          child: Column(
                            crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.messages[index].user.firstName,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                state.messages[index].content,
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                formattedDate,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: translate('chat.text_field_label'),
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

                          _controller.clear();
                        },
                        child: Text(translate('chat.send_button')),
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
