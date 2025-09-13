import 'dart:convert';

SettingsModel settingsModelFromJson(String str) => SettingsModel.fromJson(json.decode(str));

String settingsModelToJson(SettingsModel data) => json.encode(data.toJson());

class SettingsModel {
  InitialState? initialState;
  UpdateState? onUpdateState;
  UpdateState? offUpdateState;
  DisabledState? disabledState;
  String? layout;
  String? mainColorOn;
  String? backgroundColorOn;
  String? mainColorOff;
  String? backgroundColorOff;
  String? mainColorDisabled;
  String? backgroundColorDisabled;
  Background? background;

  SettingsModel({
    this.initialState,
    this.onUpdateState,
    this.offUpdateState,
    this.disabledState,
    this.layout,
    this.mainColorOn,
    this.backgroundColorOn,
    this.mainColorOff,
    this.backgroundColorOff,
    this.mainColorDisabled,
    this.backgroundColorDisabled,
    this.background,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        initialState: json["initialState"] == null ? null : InitialState.fromJson(json["initialState"]),
        onUpdateState: json["onUpdateState"] == null ? null : UpdateState.fromJson(json["onUpdateState"]),
        offUpdateState: json["offUpdateState"] == null ? null : UpdateState.fromJson(json["offUpdateState"]),
        disabledState: json["disabledState"] == null ? null : DisabledState.fromJson(json["disabledState"]),
        layout: json["layout"],
        mainColorOn: json["mainColorOn"],
        backgroundColorOn: json["backgroundColorOn"],
        mainColorOff: json["mainColorOff"],
        backgroundColorOff: json["backgroundColorOff"],
        mainColorDisabled: json["mainColorDisabled"],
        backgroundColorDisabled: json["backgroundColorDisabled"],
        background: json["background"] == null ? null : Background.fromJson(json["background"]),
      );

  Map<String, dynamic> toJson() => {
        "initialState": initialState?.toJson(),
        "onUpdateState": onUpdateState?.toJson(),
        "offUpdateState": offUpdateState?.toJson(),
        "disabledState": disabledState?.toJson(),
        "layout": layout,
        "mainColorOn": mainColorOn,
        "backgroundColorOn": backgroundColorOn,
        "mainColorOff": mainColorOff,
        "backgroundColorOff": backgroundColorOff,
        "mainColorDisabled": mainColorDisabled,
        "backgroundColorDisabled": backgroundColorDisabled,
        "background": background?.toJson(),
      };
}

class Background {
  String? type;
  String? color;
  Overlay? overlay;

  Background({
    this.type,
    this.color,
    this.overlay,
  });

  factory Background.fromJson(Map<String, dynamic> json) => Background(
        type: json["type"],
        color: json["color"],
        overlay: json["overlay"] == null ? null : Overlay.fromJson(json["overlay"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "color": color,
        "overlay": overlay?.toJson(),
      };
}

class Overlay {
  bool? enabled;
  String? color;
  int? blur;

  Overlay({
    this.enabled,
    this.color,
    this.blur,
  });

  factory Overlay.fromJson(Map<String, dynamic> json) => Overlay(
        enabled: json["enabled"],
        color: json["color"],
        blur: json["blur"],
      );

  Map<String, dynamic> toJson() => {
        "enabled": enabled,
        "color": color,
        "blur": blur,
      };
}

class DisabledState {
  String? action;
  bool? defaultValue;
  EtAttribute? getAttribute;
  TTimeSeries? getTimeSeries;
  DisabledStateDataToValue? dataToValue;

  DisabledState({
    this.action,
    this.defaultValue,
    this.getAttribute,
    this.getTimeSeries,
    this.dataToValue,
  });

  factory DisabledState.fromJson(Map<String, dynamic> json) => DisabledState(
        action: json["action"],
        defaultValue: json["defaultValue"],
        getAttribute: json["getAttribute"] == null ? null : EtAttribute.fromJson(json["getAttribute"]),
        getTimeSeries: json["getTimeSeries"] == null ? null : TTimeSeries.fromJson(json["getTimeSeries"]),
        dataToValue: json["dataToValue"] == null ? null : DisabledStateDataToValue.fromJson(json["dataToValue"]),
      );

  Map<String, dynamic> toJson() => {
        "action": action,
        "defaultValue": defaultValue,
        "getAttribute": getAttribute?.toJson(),
        "getTimeSeries": getTimeSeries?.toJson(),
        "dataToValue": dataToValue?.toJson(),
      };
}

class DisabledStateDataToValue {
  String? type;
  bool? compareToValue;
  String? dataToValueFunction;

  DisabledStateDataToValue({
    this.type,
    this.compareToValue,
    this.dataToValueFunction,
  });

  factory DisabledStateDataToValue.fromJson(Map<String, dynamic> json) => DisabledStateDataToValue(
        type: json["type"],
        compareToValue: json["compareToValue"],
        dataToValueFunction: json["dataToValueFunction"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "compareToValue": compareToValue,
        "dataToValueFunction": dataToValueFunction,
      };
}

class EtAttribute {
  String? key;
  String? scope;

  EtAttribute({
    this.key,
    this.scope,
  });

  factory EtAttribute.fromJson(Map<String, dynamic> json) => EtAttribute(
        key: json["key"],
        scope: json["scope"],
      );

  Map<String, dynamic> toJson() => {
        "key": key,
        "scope": scope,
      };
}

class TTimeSeries {
  String? key;

  TTimeSeries({
    this.key,
  });

  factory TTimeSeries.fromJson(Map<String, dynamic> json) => TTimeSeries(
        key: json["key"],
      );

  Map<String, dynamic> toJson() => {
        "key": key,
      };
}

class InitialState {
  String? action;
  bool? defaultValue;
  ExecuteRpc? executeRpc;
  EtAttribute? getAttribute;
  TTimeSeries? getTimeSeries;
  InitialStateDataToValue? dataToValue;

  InitialState({
    this.action,
    this.defaultValue,
    this.executeRpc,
    this.getAttribute,
    this.getTimeSeries,
    this.dataToValue,
  });

  factory InitialState.fromJson(Map<String, dynamic> json) => InitialState(
        action: json["action"],
        defaultValue: json["defaultValue"],
        executeRpc: json["executeRpc"] == null ? null : ExecuteRpc.fromJson(json["executeRpc"]),
        getAttribute: json["getAttribute"] == null ? null : EtAttribute.fromJson(json["getAttribute"]),
        getTimeSeries: json["getTimeSeries"] == null ? null : TTimeSeries.fromJson(json["getTimeSeries"]),
        dataToValue: json["dataToValue"] == null ? null : InitialStateDataToValue.fromJson(json["dataToValue"]),
      );

  Map<String, dynamic> toJson() => {
        "action": action,
        "defaultValue": defaultValue,
        "executeRpc": executeRpc?.toJson(),
        "getAttribute": getAttribute?.toJson(),
        "getTimeSeries": getTimeSeries?.toJson(),
        "dataToValue": dataToValue?.toJson(),
      };
}

class InitialStateDataToValue {
  String? type;
  String? dataToValueFunction;
  String? compareToValue;

  InitialStateDataToValue({
    this.type,
    this.dataToValueFunction,
    this.compareToValue,
  });

  factory InitialStateDataToValue.fromJson(Map<String, dynamic> json) => InitialStateDataToValue(
        type: json["type"],
        dataToValueFunction: json["dataToValueFunction"],
        compareToValue: json["compareToValue"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "dataToValueFunction": dataToValueFunction,
        "compareToValue": compareToValue,
      };
}

class ExecuteRpc {
  String? method;
  int? requestTimeout;
  bool? requestPersistent;
  int? persistentPollingInterval;

  ExecuteRpc({
    this.method,
    this.requestTimeout,
    this.requestPersistent,
    this.persistentPollingInterval,
  });

  factory ExecuteRpc.fromJson(Map<String, dynamic> json) => ExecuteRpc(
        method: json["method"],
        requestTimeout: json["requestTimeout"],
        requestPersistent: json["requestPersistent"],
        persistentPollingInterval: json["persistentPollingInterval"],
      );

  Map<String, dynamic> toJson() => {
        "method": method,
        "requestTimeout": requestTimeout,
        "requestPersistent": requestPersistent,
        "persistentPollingInterval": persistentPollingInterval,
      };
}

class UpdateState {
  String? action;
  ExecuteRpc? executeRpc;
  EtAttribute? setAttribute;
  TTimeSeries? putTimeSeries;
  ValueToData? valueToData;

  UpdateState({
    this.action,
    this.executeRpc,
    this.setAttribute,
    this.putTimeSeries,
    this.valueToData,
  });

  factory UpdateState.fromJson(Map<String, dynamic> json) => UpdateState(
        action: json["action"],
        executeRpc: json["executeRpc"] == null ? null : ExecuteRpc.fromJson(json["executeRpc"]),
        setAttribute: json["setAttribute"] == null ? null : EtAttribute.fromJson(json["setAttribute"]),
        putTimeSeries: json["putTimeSeries"] == null ? null : TTimeSeries.fromJson(json["putTimeSeries"]),
        valueToData: json["valueToData"] == null ? null : ValueToData.fromJson(json["valueToData"]),
      );

  Map<String, dynamic> toJson() => {
        "action": action,
        "executeRpc": executeRpc?.toJson(),
        "setAttribute": setAttribute?.toJson(),
        "putTimeSeries": putTimeSeries?.toJson(),
        "valueToData": valueToData?.toJson(),
      };
}

class ValueToData {
  String? type;
  String? constantValue;
  String? valueToDataFunction;

  ValueToData({
    this.type,
    this.constantValue,
    this.valueToDataFunction,
  });

  factory ValueToData.fromJson(Map<String, dynamic> json) => ValueToData(
        type: json["type"],
        constantValue: json["constantValue"],
        valueToDataFunction: json["valueToDataFunction"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "constantValue": constantValue,
        "valueToDataFunction": valueToDataFunction,
      };
}
