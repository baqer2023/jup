class CustomCmdRequestModel {
  CustomCmdRequestModel({
    this.atributte,
    this.value,
  });

  String? atributte;
  String? value;

  Map<String, dynamic> toJson() => {
        "atributte": atributte,
        "value": value,
      };
}
