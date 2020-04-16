import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutterchatapp/models/User.dart';
import 'package:flutterchatapp/repositories/ChatRepository.dart';
import 'package:flutterchatapp/repositories/UserDataRepository.dart';
import 'package:flutterchatapp/utils/Exceptions.dart';

import './Bloc.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  UserDataRepository userDataRepository;
  ChatRepository chatRepository;
  StreamSubscription subscription;

  ContactsBloc({this.userDataRepository, this.chatRepository})
      : assert(userDataRepository != null),
        assert(chatRepository != null);

  @override
  ContactsState get initialState => InitialContactsState();

  @override
  Stream<ContactsState> mapEventToState(
    ContactsEvent event,
  ) async* {
    if (event is FetchContactsEvent) {
      try {
        yield FetchingContactsState();
        subscription?.cancel();
        subscription = userDataRepository.getContacts().listen((contacts) => {
              print('dispatching $contacts'),
              dispatch(ReceivedContactsEvent(contacts))
            });
      } on ChatException catch (exception) {
        print(exception.errorMessage());
        yield ErrorState(exception);
      }
    }
    if (event is ReceivedContactsEvent) {
      yield FetchedContactsState(event.contacts);
    }
    if (event is AddContactEvent) {
      userDataRepository.getUser(event.username);
      yield* mapAddContactEventToState(event.username);
    }
  
  }

  Stream<ContactsState> mapFetchContactsEventToState() async* {
    try {
      yield FetchingContactsState();
      subscription?.cancel();
      subscription = userDataRepository.getContacts().listen((contacts) => {
            print('dispatching $contacts'),
            dispatch(ReceivedContactsEvent(contacts))
          });
    } on ChatException catch (exception) {
      print(exception.errorMessage());
      yield ErrorState(exception);
    }
  }

  Stream<ContactsState> mapAddContactEventToState(String username) async* {
    try {
      yield AddContactProgressState();
      await userDataRepository.addContact(username);
      User user = await userDataRepository.getUser(username);
      await chatRepository.createChatIdForContact(user);
      yield AddContactSuccessState();
    } on ChatException catch (exception) {
      print(exception.errorMessage());
      yield AddContactFailedState(exception);
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
