abstract class ChatException implements Exception{
    String errorMessage();
}
class UserNotFoundException extends ChatException{
  @override
  String errorMessage() => 'No user found for provided uid/username';

}
class UsernameMappingUndefinedException extends ChatException{
  @override
  String errorMessage() =>'User not found';

}
class ContactAlreadyExistsException extends ChatException{
  @override
  String errorMessage() => 'Contact already exists!';
}