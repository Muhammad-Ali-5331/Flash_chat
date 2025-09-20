import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static String id = "chatScreen";

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  late User loggedInUser;
  String? messageText;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    getCurrentUser();
    messagesStream();
  }

  void getCurrentUser() async {
    final user = await _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
      print(loggedInUser.email);
    } else {
      Navigator.pop(context);
    }
  }

  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
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
              _auth.signOut();
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
          children: <Widget>[streamBuilder(), messageEntryField(context)],
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
              controller: _messageController,
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
                if (messageText != '') {
                  _firestore.collection('messages').add({
                    'text': messageText,
                    'sender': loggedInUser.email,
                  });
                  _messageController.clear();
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
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData) {
          return Center(
            child: Text('No Messages..', style: TextStyle(color: Colors.black)),
          );
        } else {
          final messages = snapshot.data!.docs;
          List<MessageBubble> messagesBubbles = [];
          for (var message in messages) {
            var data = message.data() as Map<String, dynamic>;
            messagesBubbles.add(
              MessageBubble(sender: data['sender'], text: data['text']),
            );
          }
          return Expanded(child: ListView(children: messagesBubbles));
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;

  MessageBubble({required this.sender, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(sender, style: TextStyle(fontSize: 12.0)),
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
