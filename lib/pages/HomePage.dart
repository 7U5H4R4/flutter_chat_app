import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterchatapp/blocs/home/HomeBloc.dart';
import 'package:flutterchatapp/blocs/home/HomeEvent.dart';
import 'package:flutterchatapp/blocs/home/HomeState.dart';
import 'package:flutterchatapp/config/Transitions.dart';
import 'package:flutterchatapp/models/Conversation.dart';
import 'package:flutterchatapp/widgets/ChatRowWidget.dart';
import 'package:flutterchatapp/widgets/GradientFab.dart';

import 'ContactListPage.dart';
import 'SettingsPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeBloc homeBloc;
  List<Conversation> conversations = List();

  @override
  void initState() {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    homeBloc.dispatch(FetchHomeChatsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: CustomScrollView(slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 180.0,
                pinned: true,
                elevation: 0,
                centerTitle: true,
                actions: <Widget>[
                 IconButton(
                   icon: Icon(Icons.settings),
                   color: Theme.of(context).accentColor,
                   onPressed: (){
                     Navigator.push(context, SlideLeftRoute(page:SettingsPage()));
                   },
                 )
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text("Chats", style: Theme.of(context).textTheme.title),
                ),
              ),
              BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
                if (state is FetchingHomeChatsState) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: (MediaQuery.of(context).size.height),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                } else if (state is FetchedHomeChatsState) {
                  conversations = state.conversations;
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (context, index) => ChatRowWidget(conversations[index]),
                      childCount: conversations.length),
                );
              })
            ]),
            floatingActionButton: GradientFab(
              child: Icon(Icons.contacts, color: Theme.of(context).primaryColor,),
              onPressed: () => Navigator.push(
                  context, SlideLeftRoute(page: ContactListPage())),
            )));
  }
}
