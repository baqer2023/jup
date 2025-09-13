import 'package:my_app32/features/dashboard_item_detail/models/settings_model.dart';

class PowerItemModel {
  PowerItemModel({
    required this.title,
    required this.deviceId,
    required this.settings,
    required this.switchState,
  });

  String title;
  String deviceId;
  SettingsModel settings;
  bool switchState;
}
