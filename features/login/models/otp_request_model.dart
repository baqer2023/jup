class OtpRequestModel {
  OtpRequestModel({
    this.phoneNumber,
    this.verifyCode,
  });

  String? phoneNumber;
  String? verifyCode;

  Map<String, dynamic> toJson() => {
        "phoneNumber": phoneNumber,
        "verifyCode": verifyCode,
      };
}
