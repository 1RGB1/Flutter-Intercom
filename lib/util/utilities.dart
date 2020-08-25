import '../models/userModel.dart';

class Utilities {
  //Mapping user profile to user model
  static UserModel userProfileToUserModelMapping(Map<String, dynamic> user) {
    return UserModel(
      email: user['email'],
      flatNumber: user['flat_number'],
      isDoorClosed: user['isDoorClosed'],
      password: user['password'],
      username: user['username'],
      lastOpendDate: user['last_opend'].toString(),
    );
  }

  //Mapping user profile to user model
  static Map<String, dynamic> userModelToUserProfileMapping(UserModel user) {
    Map<String, dynamic> userProfile = {
      'email': user.email,
      'flat_number': user.flatNumber,
      'isDoorClosed': user.isDoorClosed,
      'password': user.password,
      'username': user.username,
      'last_opend': user.lastOpendDate
    };
    return userProfile;
  }
}
