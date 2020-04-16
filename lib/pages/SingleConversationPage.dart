import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterchatapp/blocs/chats/Bloc.dart';
import 'package:flutterchatapp/blocs/config/Bloc.dart';
import 'package:flutterchatapp/config/Constants.dart';
import 'package:flutterchatapp/models/Contact.dart';
import 'package:flutterchatapp/utils/SharedObjects.dart';
import 'package:flutterchatapp/widgets/BottomSheetFixed.dart';
import 'package:flutterchatapp/widgets/InputWidget.dart';
import '../widgets/ConversationBottomSheet.dart';
import 'ConversationPage.dart';

class SingleConversationPage extends StatefulWidget {
  final Contact contact;
  @override
  _SingleConversationPageState createState() =>
      _SingleConversationPageState(contact);

  const SingleConversationPage({this.contact});
}

class _SingleConversationPageState extends State<SingleConversationPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Contact contact;
  ChatBloc chatBloc;
  bool isFirstLaunch = true;
  bool configMessagePeek = true;
  _SingleConversationPageState(this.contact);

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    chatBloc.dispatch(RegisterActiveChatEvent(contact.chatId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          body: Column(
            children: <Widget>[
             Expanded(child: ConversationPage(contact: contact,)),
              BlocBuilder<ConfigBloc,ConfigState>(
                  builder: (context, state) {
                    if(state is UnConfigState)
                      configMessagePeek = SharedObjects.prefs.getBool(Constants.configMessagePeek);
                    if(state is ConfigChangeState)
                      if(state.key == Constants.configMessagePeek) configMessagePeek = state.value;
                    return GestureDetector(
                        child: InputWidget(),
                        onPanUpdate: (details) {
                          if(!configMessagePeek)
                            return;
                          if (details.delta.dy < 100) {
                            showModalBottomSheetApp(context: context, builder: (context)=>ConversationBottomSheet());
                          }
                        });
                  }
              )
            ],
          ),
        ));
  }
}
