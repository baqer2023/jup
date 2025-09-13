class CredentialRequestModel {
  CredentialRequestModel({
    this.ssid,
    this.password,
  });

  String? ssid;
  String? password;
 //tring? name;

  Map<String, dynamic> toJson() => {
        "ssid": ssid,
        //ame": name
        "password": password,
      };
}
