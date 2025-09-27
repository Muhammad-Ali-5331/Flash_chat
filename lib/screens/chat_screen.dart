import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/constants.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static String id = "chatScreen";

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  late User loggedInUser;
  String? messageText;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    getCurrentUser();
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  void getCurrentUser() async {
    final user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      loggedInUser = user;
    } else {
      Navigator.pop(context);
    }
  }

  String getFormattedCurrentTime() {
    final now = DateTime.now();
    final formatter = DateFormat("MMM d, yyyy - hh:mm a");
    return formatter.format(now);
  }

  String formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat("MMM d, yyyy - hh:mm a").format(dateTime).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          ),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(child: streamBuilder()),
            messageEntryField(context),
          ],
        ),
      ),
    );
  }

  Container messageEntryField(BuildContext context) {
    return Container(
      decoration: kMessageContainerDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: messageController,
              style: TextStyle(color: Colors.black),
              onChanged: (value) {
                messageText = value;
              },
              decoration: kMessageTextFieldDecoration,
            ),
          ),
          TextButton(
            onPressed: () {
              try {
                if (messageText != null && messageText!.isNotEmpty) {
                  FirebaseFirestore.instance.collection('messages').add({
                    'message': messageText,
                    'sender': loggedInUser.email,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  messageController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('[!] Message should contain some text'),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('[!] Error Occurred: $e')),
                );
              }
            },
            child: Text('Send', style: kSendButtonTextStyle),
          ),
        ],
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> streamBuilder() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData) {
          return Center(
            child: Text('No Messages..', style: TextStyle(color: Colors.black)),
          );
        } else {
          final currentUser = loggedInUser.email;
          final messages = snapshot.data!.docs;
          List<MessageBubble> messagesBubbles = [];
          for (var message in messages) {
            var data = message.data() as Map<String, dynamic>;
            messagesBubbles.add(
              MessageBubble(
                sender: data['sender'],
                text: data['message'],
                time: data['timestamp'] != null
                    ? formatTimestamp(data['timestamp'])
                    : 'Fetching Time...',
                isMe: data['sender'] == currentUser,
              ),
            );
          }
          return ListView(reverse: true, children: messagesBubbles);
        }
      },
    );
  }
}
