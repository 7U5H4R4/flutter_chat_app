import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutterchatapp/config/Constants.dart';
import 'package:flutterchatapp/config/Paths.dart';
import 'package:flutterchatapp/models/Message.dart';
import 'package:flutterchatapp/models/User.dart';
import 'package:flutterchatapp/repositories/ChatRepository.dart';
import 'package:flutterchatapp/repositories/StorageRepository.dart';
import 'package:flutterchatapp/repositories/UserDataRepository.dart';
import 'package:flutterchatapp/utils/Exceptions.dart';
import 'package:flutterchatapp/utils/SharedObjects.dart';
import 'package:path/path.dart';

import 'ChatEvent.dart';
import 'ChatState.dart';


class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final UserDataRepository userDataRepository;
  final StorageRepository storageRepository;
  Map<String, StreamSubscription> messagesSubscriptionMap = Map();
  StreamSubscription chatsSubscription;
  String activeChatId;

  ChatBloc(
      {this.chatRepository, this.userDataRepository, this.storageRepository})
      : assert(chatRepository != null),
        assert(userDataRepository != null),
        assert(storageRepository != null);

  @override
  ChatState get initialState => InitialChatState();

  @override
  Stream<ChatState> mapEventToState(
    ChatEvent event,
  ) async* {
    print(event);

    if (event is FetchChatListEvent) {
      yield* mapFetchChatListEventToState(event);
    }
    if(event is RegisterActiveChatEvent){
      activeChatId = event.activeChatId;
    }
    if (event is ReceivedChatsEvent) {
      yield FetchedChatListState(event.chatList);
    }
    if (event is PageChangedEvent) {
      activeChatId = event.activeChat.chatId;
      yield PageChangedState(event.index, event.activeChat);
    }
    if (event is FetchConversationDetailsEvent) {
      yield* mapFetchConversationDetailsEventToState(event);
    }
    if (event is FetchMessagesEvent) {
      yield* mapFetchMessagesEventToState(event);
    }
    if (event is FetchPreviousMessagesEvent) {
      yield* mapFetchPreviousMessagesEventToState(event);
    }
    if (event is ReceivedMessagesEvent) {
      print('dispatching received messages');
      yield FetchedMessagesState(event.messages, event.username,
          isPrevious: false);
    }
    if (event is SendTextMessageEvent) {
      Message message = TextMessage(
          event.message,
          DateTime.now().millisecondsSinceEpoch,
          SharedObjects.prefs.getString(Constants.sessionName),
          SharedObjects.prefs.getString(Constants.sessionUsername));
      await chatRepository.sendMessage(activeChatId, message);
    }
    if (event is SendAttachmentEvent) {
      await mapSendAttachmentEventToState(event);
    }

    if (event is ToggleEmojiKeyboardEvent) {
      yield ToggleEmojiKeyboardState(event.showEmojiKeyboard);
    }
  }

  Stream<ChatState> mapFetchChatListEventToState(
      FetchChatListEvent event) async* {
    try {
      chatsSubscription?.cancel();
      chatsSubscription = chatRepository
          .getChats()
          .listen((chats) => dispatch(ReceivedChatsEvent(chats)));
    } on ChatException catch (exception) {
      print(exception.errorMessage());
      yield ErrorState(exception);
    }
  }

  Stream<ChatState> mapFetchMessagesEventToState(
      FetchMessagesEvent event) async* {
    try {
      yield FetchingMessageState();
      String chatId =
          await chatRepository.getChatIdByUsername(event.chat.username);
      //  print('mapFetchMessagesEventToState');
      //  print('MessSubMap: $messagesSubscriptionMap');
      StreamSubscription messagesSubscription = messagesSubscriptionMap[chatId];
      messagesSubscription?.cancel();
      messagesSubscription = chatRepository.getMessages(chatId).listen((messages) => dispatch(ReceivedMessagesEvent(messages, event.chat.username)));

      messagesSubscriptionMap[chatId] = messagesSubscription;
    } on ChatException catch (exception) {
      print(exception.errorMessage());
      yield ErrorState(exception);
    }
  }

  Stream<ChatState> mapFetchPreviousMessagesEventToState(
      FetchPreviousMessagesEvent event) async* {
    try {
      String chatId =
          await chatRepository.getChatIdByUsername(event.chat.username);
      final messages =
          await chatRepository.getPreviousMessages(chatId, event.lastMessage);
      yield FetchedMessagesState(messages, event.chat.username,
          isPrevious: true);
    } on ChatException catch (exception) {
      print(exception.errorMessage());
      yield ErrorState(exception);
    }
  }

  Stream<ChatState> mapFetchConversationDetailsEventToState(
      FetchConversationDetailsEvent event) async* {
    print('fetching details fro ${event.chat.username}');
    User user = await userDataRepository.getUser(event.chat.username);
    yield FetchedContactDetailsState(user, event.chat.username);
    dispatch(FetchMessagesEvent(event.chat));
  }

  Future mapSendAttachmentEventToState(SendAttachmentEvent event) async {
    File file = event.file;
    String fileName = basename(file.path);
    String url = await storageRepository.uploadFile(
        file, Paths.getAttachmentPathByFileType(event.fileType));
    String username = SharedObjects.prefs.getString(Constants.sessionUsername);
    String name = SharedObjects.prefs.getString(Constants.sessionName);
    print('File Name: $fileName');
    Message message;
    if (event.fileType == FileType.image)
      message = ImageMessage(
          url, fileName, DateTime.now().millisecondsSinceEpoch, name, username);
    else if (event.fileType == FileType.video)
      message = VideoMessage(
          url, fileName, DateTime.now().millisecondsSinceEpoch, name, username);
    else
      message = FileMessage(
          url, fileName, DateTime.now().millisecondsSinceEpoch, name, username);
    await chatRepository.sendMessage(event.chatId, message);
  }

  @override
  void dispose() {
    messagesSubscriptionMap.forEach((_, subscription) => subscription.cancel());
    super.dispose();
  }
}
