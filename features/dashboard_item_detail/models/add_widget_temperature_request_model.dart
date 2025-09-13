class AddWidgetTemperatureRequestModel {
  AddWidgetTemperatureRequestModel({
    required this.typeFullFqn,
    required this.id,
    required this.title,
    required this.deviceId,
  });

  String typeFullFqn;
  String id;
  String title;
  String deviceId;

  Map<String, dynamic> toJson() => {
        "typeFullFqn": typeFullFqn,
        "type": "timeseries",
        "sizeX": 4.5,
        "sizeY": 2,
        "config": {
          "datasources": [
            {
              "type": "device",
              "name": "",
              "deviceId": deviceId,
              "dataKeys": [
                {"name": "temperature", "type": "timeseries", "label": title, "color": "rgba(0, 0, 0, 0.87)", "settings": {}, "_hash": 0.5087530596998853}
              ],
              "alarmFilterConfig": {
                "statusList": ["ACTIVE"]
              },
              "latestDataKeys": [
                {
                  "name": "temperature",
                  "type": "timeseries",
                  "label": "Latest",
                  "color": "rgba(0, 0, 0, 0.87)",
                  "settings": {},
                  "_hash": 0.5087530596998853,
                  "units": null,
                  "decimals": null
                }
              ]
            }
          ],
          "showTitle": true,
          "backgroundColor": "rgba(0, 0, 0, 0)",
          "color": null,
          "padding": "0",
          "settings": {
            "layout": "left",
            "autoScale": true,
            "showValue": true,
            "valueFont": {"family": "Roboto", "size": 28, "sizeUnit": "px", "style": "normal", "weight": "500", "lineHeight": "32px"},
            "valueColor": {
              "type": "range",
              "color": "rgba(0, 0, 0, 0.87)",
              "rangeList": {
                "advancedMode": false,
                "range": [
                  {"from": null, "to": 18, "color": "#234CC7"},
                  {"from": 18, "to": 24, "color": "#3FA71A"},
                  {"from": 24, "to": null, "color": "#D81838"}
                ]
              },
              "colorFunction":
                  "var temperature = value;\nif (typeof temperature !== undefined) {\n  var percent = (temperature + 60)/120 * 100;\n  return tinycolor.mix('blue', 'red', percent).toHexString();\n}\nreturn 'blue';"
            },
            "background": {
              "type": "color",
              "color": "#fff",
              "overlay": {"enabled": false, "color": "rgba(255,255,255,0.72)", "blur": 3}
            },
            "padding": "12px"
          },
          "title": title,
          "dropShadow": true,
          "enableFullscreen": false,
          "titleStyle": null,
          "mobileHeight": null,
          "configMode": "basic",
          "actions": {},
          "showTitleIcon": true,
          "titleIcon": "thermostat",
          "iconColor": "rgba(0, 0, 0, 0.87)",
          "titleFont": {"size": 16, "sizeUnit": "px", "family": "Roboto", "weight": "500", "style": "normal", "lineHeight": "24px"},
          "iconSize": "18px",
          "titleTooltip": "",
          "widgetStyle": {},
          "widgetCss": "",
          "pageSize": 1024,
          "noDataDisplayMessage": "",
          "useDashboardTimewindow": true,
          "decimals": 0,
          "titleColor": "rgba(0, 0, 0, 0.87)",
          "borderRadius": null,
          "units": "°C",
          "displayTimewindow": true,
          "timewindow": {
            "hideAggregation": false,
            "hideAggInterval": false,
            "hideTimezone": false,
            "selectedTab": 1,
            "history": {
              "historyType": 2,
              "timewindowMs": 60000,
              "interval": 43200000,
              "fixedTimewindow": {"startTimeMs": 1697382151041, "endTimeMs": 1697468551041},
              "quickInterval": "CURRENT_MONTH_SO_FAR"
            },
            "aggregation": {"type": "AVG", "limit": 25000}
          },
          "timewindowStyle": {
            "showIcon": false,
            "iconSize": "24px",
            "icon": "query_builder",
            "iconPosition": "left",
            "font": {"size": 12, "sizeUnit": "px", "family": "Roboto", "weight": "400", "style": "normal", "lineHeight": "16px"},
            "color": "rgba(0, 0, 0, 0.38)",
            "displayTypePrefix": true
          }
        },
        "row": 0,
        "col": 0,
        "id": id
      };
}
