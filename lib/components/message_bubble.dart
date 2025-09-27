import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final String time;
  final bool isMe;
  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          isMe
              ? Text('You ($time)', style: TextStyle(fontSize: 12.0))
              : Text('$sender ($time)', style: TextStyle(fontSize: 12.0)),
          Material(
            elevation: 8.0,
            color: isMe ? Colors.grey : Colors.blueAccent,
            borderRadius: isMe ? isMeStyle : isNotMeStyle,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20.0,
              ),
              child: Text(text, style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}
