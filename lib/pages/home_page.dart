import 'package:chat_fire/pages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  void singout() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page'), actions: [
        IconButton(
          onPressed: singout,
          icon: Icon(Icons.logout),
        )
      ]),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Error");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }
            return ListView(
              children: snapshot.data!.docs
                  .map<Widget>((DocumentSnapshot document) =>
                      _buildUserListItem(document))
                  .toList(),
            );
          }),
    );
  }

  _buildUserListItem(DocumentSnapshot<Object?> document) {
    var data = document.data() as Map<String, dynamic>;
    if (_auth.currentUser!.email != data['email']) {
      return ListTile(
        title: Text(data['email']),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ChatPage(
              receiverUserEmail: data['email'],
              receiverUserId: data['uid'],
            );
          }));
        },
      );
    } else {
      return SizedBox();
    }
  }
}
