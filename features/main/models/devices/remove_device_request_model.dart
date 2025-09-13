// class RemoveDeviceRequestModel {
//   final String id;
//
//   RemoveDeviceRequestModel({required this.id});
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//     };
//   }
// }

class RemoveDeviceRequestModel {

  final String id;

  RemoveDeviceRequestModel({required this.id});

  Map<String, dynamic> toJson() {
    return{
      'id': id,
    };
  }
}