class SignupRequestModel {
  SignupRequestModel({this.phoneNumber});

  String? phoneNumber;

  Map<String, dynamic> toJson() => {"phoneNumber": phoneNumber};
}
