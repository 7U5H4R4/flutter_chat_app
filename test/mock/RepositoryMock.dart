import 'package:flutterchatapp/repositories/AuthenticationRepository.dart';
import 'package:flutterchatapp/repositories/StorageRepository.dart';
import 'package:flutterchatapp/repositories/UserDataRepository.dart';
import 'package:mockito/mockito.dart';

class AuthenticationRepositoryMock extends Mock implements AuthenticationRepository{}
class UserDataRepositoryMock extends Mock implements UserDataRepository{}
class StorageRepositoryMock extends Mock implements StorageRepository{}