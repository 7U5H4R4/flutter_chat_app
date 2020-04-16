import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterchatapp/blocs/attachments/AttachmentsBloc.dart';
import 'package:flutterchatapp/blocs/chats/Bloc.dart';
import 'package:flutterchatapp/blocs/config/Bloc.dart';
import 'package:flutterchatapp/blocs/contacts/Bloc.dart';
import 'package:flutterchatapp/blocs/home/Bloc.dart';
import 'package:flutterchatapp/config/Constants.dart';
import 'package:flutterchatapp/config/Themes.dart';
import 'package:flutterchatapp/pages/HomePage.dart';
import 'package:flutterchatapp/repositories/AuthenticationRepository.dart';
import 'package:flutterchatapp/repositories/ChatRepository.dart';
import 'package:flutterchatapp/repositories/StorageRepository.dart';
import 'package:flutterchatapp/repositories/UserDataRepository.dart';
import 'package:flutterchatapp/utils/SharedObjects.dart';
import 'package:path_provider/path_provider.dart';
import 'blocs/authentication/Bloc.dart';
import 'pages/RegisterPage.dart';
void main() async {
  //create instances of the repositories to supply them to the app
  final AuthenticationRepository authRepository = AuthenticationRepository();
  final UserDataRepository userDataRepository = UserDataRepository();
  final StorageRepository storageRepository = StorageRepository();
  final ChatRepository chatRepository = ChatRepository();
  SharedObjects.prefs = await CachedSharedPreferences.getInstance();
  Constants.cacheDirPath = (await getTemporaryDirectory()).path;
  Constants.downloadsDirPath =
      (await DownloadsPathProvider.downloadsDirectory).path;
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<AuthenticationBloc>(
        builder: (context) => AuthenticationBloc(
            authenticationRepository: authRepository,
            userDataRepository: userDataRepository,
            storageRepository: storageRepository)
          ..dispatch(AppLaunched()),
      ),
      BlocProvider<ContactsBloc>(
        builder: (context) => ContactsBloc(
            userDataRepository: userDataRepository,
            chatRepository: chatRepository),
      ),
      BlocProvider<ChatBloc>(
        builder: (context) => ChatBloc(
            userDataRepository: userDataRepository,
            storageRepository: storageRepository,
            chatRepository: chatRepository),
      ),
      BlocProvider<AttachmentsBloc>(
        builder: (context) => AttachmentsBloc(chatRepository: chatRepository),
      ),
      BlocProvider<HomeBloc>(
        builder: (context) => HomeBloc(chatRepository: chatRepository),
      ),
      BlocProvider<ConfigBloc>(
        builder: (context) => ConfigBloc(storageRepository: storageRepository,userDataRepository: userDataRepository),
      )
    ],
    child: MyApp(),
  ));
}



// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData theme;
  Key key = UniqueKey();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigBloc, ConfigState>(builder: (context, state) {
      if (state is UnConfigState) {
        theme = SharedObjects.prefs.getBool(Constants.configDarkMode)
            ? Themes.dark
            : Themes.light;
      }
      if(state is RestartedAppState){
        key = UniqueKey();
      }
      if (state is ConfigChangeState && state.key == Constants.configDarkMode) {
        theme = state.value ? Themes.dark : Themes.light;
      }
      return MaterialApp(
        title: 'Messio',
        theme: theme,
        key: key,
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is UnAuthenticated) {
              return RegisterPage();
            } else if (state is ProfileUpdated) {
              if(SharedObjects.prefs.getBool(Constants.configMessagePaging))
                BlocProvider.of<ChatBloc>(context).dispatch(FetchChatListEvent());
              return HomePage();
            } else {
              return RegisterPage();
            }
          },
        ),
      );
    });
  }
}
