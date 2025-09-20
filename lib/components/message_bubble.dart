import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final String time;
  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('$sender ($time)', style: TextStyle(fontSize: 12.0)),
          Material(
            elevation: 10.0,
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(30.0),
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
