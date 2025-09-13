class AddWidgetRequestModel {
  AddWidgetRequestModel({
    required this.typeFullFqn,
    required this.id,
    required this.title,
    required this.powerOn,
    required this.powerOff,
    required this.initialValue,
    required this.deviceId,
  });

  String typeFullFqn;
  String id;
  String title;
  String powerOn;
  String powerOff;
  String initialValue;
  String deviceId;

  Map<String, dynamic> toJson() => {
        "typeFullFqn": typeFullFqn,
        "type": "rpc",
        "sizeX": 3.5,
        "sizeY": 3.5,
        "config": {
          "showTitle": true,
          "backgroundColor": "#ffffff",
          "color": "rgba(0, 0, 0, 0.87)",
          "padding": "0px",
          "settings": {
            "initialState": {
              "action": "GET_ATTRIBUTE",
              "defaultValue": false,
              "executeRpc": {"method": "getState", "requestTimeout": 5000, "requestPersistent": false, "persistentPollingInterval": 1000},
              "getAttribute": {"scope": "SHARED_SCOPE", "key": "state"},
              "getTimeSeries": {"key": "state"},
              "dataToValue": {"type": "NONE", "dataToValueFunction": "/* Should return boolean value */\nreturn data;", "compareToValue": initialValue}
            },
            "onUpdateState": {
              "action": "SET_ATTRIBUTE",
              "executeRpc": {"method": "setState", "requestTimeout": 5000, "requestPersistent": false, "persistentPollingInterval": 1000},
              "setAttribute": {"scope": "SHARED_SCOPE", "key": "state"},
              "putTimeSeries": {"key": "state"},
              "valueToData": {
                "type": "CONSTANT",
                "constantValue": powerOn,
                "valueToDataFunction": "/* Convert input boolean value to RPC parameters or attribute/time-series value */\nreturn value;"
              }
            },
            "offUpdateState": {
              "action": "SET_ATTRIBUTE",
              "executeRpc": {"method": "setState", "requestTimeout": 5000, "requestPersistent": false, "persistentPollingInterval": 1000},
              "setAttribute": {"scope": "SHARED_SCOPE", "key": "state"},
              "putTimeSeries": {"key": "state"},
              "valueToData": {
                "type": "CONSTANT",
                "constantValue": powerOff,
                "valueToDataFunction": "/* Convert input boolean value to RPC parameters or attribute/time-series value */ \n return value;"
              }
            },
            "disabledState": {
              "action": "DO_NOTHING",
              "defaultValue": false,
              "getAttribute": {"key": "state", "scope": null},
              "getTimeSeries": {"key": "state"},
              "dataToValue": {"type": "NONE", "compareToValue": true, "dataToValueFunction": "/* Should return boolean value */\nreturn data;"}
            },
            "layout": "default",
            "mainColorOn": "#3F52DD",
            "backgroundColorOn": "#FFFFFF",
            "mainColorOff": "#A2A2A2",
            "backgroundColorOff": "#FFFFFF",
            "mainColorDisabled": "rgba(0,0,0,0.12)",
            "backgroundColorDisabled": "#FFFFFF",
            "background": {
              "type": "color",
              "color": "#fff",
              "overlay": {"enabled": false, "color": "rgba(255,255,255,0.72)", "blur": 3}
            }
          },
          "title": title,
          "dropShadow": true,
          "enableFullscreen": false,
          "widgetStyle": {},
          "actions": {},
          "widgetCss": "",
          "noDataDisplayMessage": "",
          "titleFont": {"size": 16, "sizeUnit": "px", "family": "Roboto", "weight": "500", "style": null, "lineHeight": "1.6"},
          "showTitleIcon": false,
          "titleTooltip": "",
          "titleStyle": {"fontSize": "16px", "fontWeight": 400},
          "pageSize": 1024,
          "titleIcon": "mdi:lightbulb-outline",
          "iconColor": "rgba(0, 0, 0, 0.87)",
          "iconSize": "24px",
          "configMode": "basic",
          "targetDevice": {"type": "device", "deviceId": deviceId},
          "titleColor": null,
          "borderRadius": null,
          "datasources": []
        },
        "row": 0,
        "col": 0,
        "id": id
      };
}
