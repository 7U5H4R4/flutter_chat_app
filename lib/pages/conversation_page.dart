import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterchatapp/widgets/chat_appbar.dart';
import 'package:flutterchatapp/widgets/chat_list_widget.dart';
import 'package:flutterchatapp/widgets/input_widget.dart';

class ConversationPage extends StatefulWidget {
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
	  child: Scaffold(
		appBar: ChatAppBar(),
		body: Stack(
		  children: <Widget>[
		    Column(
			  children: <Widget>[
			    ChatListWidget(),
				InputWidget()
			  ],
			)
		  ],
		),
	  ),
	);
  }
}
