import 'dart:convert';

GetDashboardWidgetDetailResponseModel
    getDashboardWidgetDetailResponseModelFromJson(Map<String, dynamic> json) =>
        GetDashboardWidgetDetailResponseModel.fromJson(json);

String getDashboardWidgetDetailResponseModelToJson(
        GetDashboardWidgetDetailResponseModel data) =>
    json.encode(data.toJson());

class GetDashboardWidgetDetailResponseModel {
  GetDashboardWidgetDetailResponseModel({
    this.message,
    this.statusCode,
    this.data,
  });

  factory GetDashboardWidgetDetailResponseModel.fromJson(
          Map<String, dynamic> json) =>
      GetDashboardWidgetDetailResponseModel(
        data: json["data"] == null
            ? null
            : GetDashboardWidgetDetailDataModel.fromJson(json["data"]),
      );

  String? message;
  int? statusCode;
  GetDashboardWidgetDetailDataModel? data;

  Map<String, dynamic> toJson() => {"data": data?.toJson()};

  GetDashboardWidgetDetailResponseModel copyWith({
    String? message,
    int? statusCode,
    GetDashboardWidgetDetailDataModel? data,
  }) =>
      GetDashboardWidgetDetailResponseModel(
        message: message ?? this.message,
        statusCode: statusCode ?? this.statusCode,
        data: data ?? this.data,
      );
}

class GetDashboardWidgetDetailDataModel {
  GetDashboardWidgetDetailDataModel({
    this.id,
    this.createdTime,
    this.tenantId,
    this.title,
    this.image,
    this.assignedCustomers,
    this.mobileHide,
    this.mobileOrder,
    this.externalId,
    this.configuration,
    this.name,
  });

  factory GetDashboardWidgetDetailDataModel.fromJson(
          Map<String, dynamic> json) =>
      GetDashboardWidgetDetailDataModel(
        id: json["id"] == null ? null : Id.fromJson(json["id"]),
        createdTime: json["createdTime"],
        tenantId:
            json["tenantId"] == null ? null : Id.fromJson(json["tenantId"]),
        title: json["title"],
        image: json["image"],
        assignedCustomers: json["assignedCustomers"] == null
            ? []
            : List<AssignedCustomer>.from(json["assignedCustomers"]!
                .map((x) => AssignedCustomer.fromJson(x))),
        mobileHide: json["mobileHide"],
        mobileOrder: json["mobileOrder"],
        externalId: json["externalId"],
        configuration: json["configuration"] == null
            ? null
            : WidgetConfiguration.fromJson(json["configuration"]),
        name: json["name"],
      );

  Id? id;
  int? createdTime;
  Id? tenantId;
  String? title;
  dynamic image;
  List<AssignedCustomer>? assignedCustomers;
  bool? mobileHide;
  dynamic mobileOrder;
  dynamic externalId;
  WidgetConfiguration? configuration;
  String? name;

  Map<String, dynamic> toJson() => {
        "id": id?.toJson(),
        "createdTime": createdTime,
        "tenantId": tenantId?.toJson(),
        "title": title,
        "image": image,
        "assignedCustomers": assignedCustomers == null
            ? []
            : List<dynamic>.from(assignedCustomers!.map((x) => x.toJson())),
        "mobileHide": mobileHide,
        "mobileOrder": mobileOrder,
        "externalId": externalId,
        "configuration": configuration?.toJson(),
        "name": name,
      };

  // add copy with
  GetDashboardWidgetDetailDataModel copyWith({
    Id? id,
    int? createdTime,
    Id? tenantId,
    String? title,
    dynamic image,
    List<AssignedCustomer>? assignedCustomers,
    bool? mobileHide,
    dynamic mobileOrder,
    dynamic externalId,
    WidgetConfiguration? configuration,
    String? name,
  }) =>
      GetDashboardWidgetDetailDataModel(
        id: id ?? this.id,
        createdTime: createdTime ?? this.createdTime,
        tenantId: tenantId ?? this.tenantId,
        title: title ?? this.title,
        image: image ?? this.image,
        assignedCustomers: assignedCustomers ?? this.assignedCustomers,
        mobileHide: mobileHide ?? this.mobileHide,
        mobileOrder: mobileOrder ?? this.mobileOrder,
        externalId: externalId ?? this.externalId,
        configuration: configuration ?? this.configuration,
        name: name ?? this.name,
      );
}

class AssignedCustomer {
  AssignedCustomer({
    this.customerId,
    this.title,
    this.public,
  });

  factory AssignedCustomer.fromJson(Map<String, dynamic> json) =>
      AssignedCustomer(
        customerId:
            json["customerId"] == null ? null : Id.fromJson(json["customerId"]),
        title: json["title"],
        public: json["public"],
      );

  Id? customerId;
  String? title;
  bool? public;

  Map<String, dynamic> toJson() => {
        "customerId": customerId?.toJson(),
        "title": title,
        "public": public,
      };
}

class Id {
  Id({
    this.entityType,
    this.id,
  });

  factory Id.fromJson(Map<String, dynamic> json) => Id(
        entityType: json["entityType"],
        id: json["id"],
      );

  String? entityType;
  String? id;

  Map<String, dynamic> toJson() => {
        "entityType": entityType,
        "id": id,
      };
}

class WidgetConfiguration {
  WidgetConfiguration({
    this.description,
    this.widgets,
    this.states,
    this.entityAliases,
    this.filters,
    this.timewindow,
    this.settings,
  });

  factory WidgetConfiguration.fromJson(Map<String, dynamic> json) => WidgetConfiguration(
        description: json["description"],
        widgets: json["widgets"],
        // json["widgets"] == null ? null : Widgets.fromJson(json["widgets"]),
        states: json["states"] == null ? null : States.fromJson(json["states"]),
        entityAliases: Map.from(json["entityAliases"]!).map((k, v) =>
            MapEntry<String, EntityAlias>(k, EntityAlias.fromJson(v))),
        filters:
            json["filters"] == null ? null : Filters.fromJson(json["filters"]),
        timewindow: json["timewindow"] == null
            ? null
            : ConfigurationTimewindow.fromJson(json["timewindow"]),
        settings: json["settings"] == null
            ? null
            : ConfigurationSettings.fromJson(json["settings"]),
      );

  String? description;

  // Widgets? widgets;
  Map<String, dynamic>? widgets;
  States? states;
  Map<String, EntityAlias>? entityAliases;
  Filters? filters;
  ConfigurationTimewindow? timewindow;
  ConfigurationSettings? settings;

  Map<String, dynamic> toJson() => {
        "description": description,
        // "widgets": widgets?.toJson(),
        "widgets": widgets,
        "states": states?.toJson(),
        "entityAliases": Map.from(entityAliases!)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "filters": filters?.toJson(),
        "timewindow": timewindow?.toJson(),
        "settings": settings?.toJson(),
      };

  // add copy with
  WidgetConfiguration copyWith({
    String? description,
    Map<String, dynamic>? widgets,
    States? states,
    Map<String, EntityAlias>? entityAliases,
    Filters? filters,
    ConfigurationTimewindow? timewindow,
    ConfigurationSettings? settings,
  }) =>
      WidgetConfiguration(
        description: description ?? this.description,
        widgets: widgets ?? this.widgets,
        states: states ?? this.states,
        entityAliases: entityAliases ?? this.entityAliases,
        filters: filters ?? this.filters,
        timewindow: timewindow ?? this.timewindow,
        settings: settings ?? this.settings,
      );
}

class EntityAlias {
  EntityAlias({
    this.id,
    this.alias,
    this.filter,
  });

  factory EntityAlias.fromJson(Map<String, dynamic> json) => EntityAlias(
        id: json["id"],
        alias: json["alias"],
        filter: json["filter"] == null ? null : Filter.fromJson(json["filter"]),
      );

  String? id;
  String? alias;
  Filter? filter;

  Map<String, dynamic> toJson() => {
        "id": id,
        "alias": alias,
        "filter": filter?.toJson(),
      };
}

class Filter {
  Filter({
    this.type,
    this.singleEntity,
    this.resolveMultiple,
  });

  factory Filter.fromJson(Map<String, dynamic> json) => Filter(
        type: json["type"],
        singleEntity: json["singleEntity"] == null
            ? null
            : Id.fromJson(json["singleEntity"]),
        resolveMultiple: json["resolveMultiple"],
      );

  String? type;
  Id? singleEntity;
  bool? resolveMultiple;

  Map<String, dynamic> toJson() => {
        "type": type,
        "singleEntity": singleEntity?.toJson(),
        "resolveMultiple": resolveMultiple,
      };
}

class Filters {
  Filters();

  factory Filters.fromJson(Map<String, dynamic> json) => Filters();

  Map<String, dynamic> toJson() => {};
}

class ConfigurationSettings {
  ConfigurationSettings({
    this.stateControllerId,
    this.showTitle,
    this.showDashboardsSelect,
    this.showEntitiesSelect,
    this.showDashboardTimewindow,
    this.showDashboardExport,
    this.toolbarAlwaysOpen,
    this.titleColor,
    this.showDashboardLogo,
    this.dashboardLogoUrl,
    this.hideToolbar,
    this.showFilters,
    this.showUpdateDashboardImage,
    this.dashboardCss,
  });

  factory ConfigurationSettings.fromJson(Map<String, dynamic> json) =>
      ConfigurationSettings(
        stateControllerId: json["stateControllerId"],
        showTitle: json["showTitle"],
        showDashboardsSelect: json["showDashboardsSelect"],
        showEntitiesSelect: json["showEntitiesSelect"],
        showDashboardTimewindow: json["showDashboardTimewindow"],
        showDashboardExport: json["showDashboardExport"],
        toolbarAlwaysOpen: json["toolbarAlwaysOpen"],
        titleColor: json["titleColor"],
        showDashboardLogo: json["showDashboardLogo"],
        dashboardLogoUrl: json["dashboardLogoUrl"],
        hideToolbar: json["hideToolbar"],
        showFilters: json["showFilters"],
        showUpdateDashboardImage: json["showUpdateDashboardImage"],
        dashboardCss: json["dashboardCss"],
      );

  String? stateControllerId;
  bool? showTitle;
  bool? showDashboardsSelect;
  bool? showEntitiesSelect;
  bool? showDashboardTimewindow;
  bool? showDashboardExport;
  bool? toolbarAlwaysOpen;
  String? titleColor;
  bool? showDashboardLogo;
  dynamic dashboardLogoUrl;
  bool? hideToolbar;
  bool? showFilters;
  bool? showUpdateDashboardImage;
  String? dashboardCss;

  Map<String, dynamic> toJson() => {
        "stateControllerId": stateControllerId,
        "showTitle": showTitle,
        "showDashboardsSelect": showDashboardsSelect,
        "showEntitiesSelect": showEntitiesSelect,
        "showDashboardTimewindow": showDashboardTimewindow,
        "showDashboardExport": showDashboardExport,
        "toolbarAlwaysOpen": toolbarAlwaysOpen,
        "titleColor": titleColor,
        "showDashboardLogo": showDashboardLogo,
        "dashboardLogoUrl": dashboardLogoUrl,
        "hideToolbar": hideToolbar,
        "showFilters": showFilters,
        "showUpdateDashboardImage": showUpdateDashboardImage,
        "dashboardCss": dashboardCss,
      };
}

class States {
  States({
    this.statesDefault,
  });

  factory States.fromJson(Map<String, dynamic> json) => States(
        statesDefault:
            json["default"] == null ? null : Default.fromJson(json["default"]),
      );

  Default? statesDefault;

  Map<String, dynamic> toJson() => {
        "default": statesDefault?.toJson(),
      };
}

class Default {
  Default({
    this.name,
    this.root,
    this.layouts,
  });

  factory Default.fromJson(Map<String, dynamic> json) => Default(
        name: json["name"],
        root: json["root"],
        layouts:
            json["layouts"] == null ? null : Layouts.fromJson(json["layouts"]),
      );

  String? name;
  bool? root;
  Layouts? layouts;

  Map<String, dynamic> toJson() => {
        "name": name,
        "root": root,
        "layouts": layouts?.toJson(),
      };
}

class Layouts {
  Layouts({
    this.main,
  });

  factory Layouts.fromJson(Map<String, dynamic> json) => Layouts(
        main: json["main"] == null ? null : Main.fromJson(json["main"]),
      );

  Main? main;

  Map<String, dynamic> toJson() => {
        "main": main?.toJson(),
      };
}

class Main {
  Main({
    this.widgets,
    this.gridSettings,
  });

  factory Main.fromJson(Map<String, dynamic> json) => Main(
        widgets: Map.from(json["widgets"]!)
            .map((k, v) => MapEntry<String, Widget>(k, Widget.fromJson(v))),
        gridSettings: json["gridSettings"] == null
            ? null
            : GridSettings.fromJson(json["gridSettings"]),
      );

  Map<String, Widget>? widgets;
  GridSettings? gridSettings;

  Map<String, dynamic> toJson() => {
        "widgets": Map.from(widgets!)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "gridSettings": gridSettings?.toJson(),
      };
}

class GridSettings {
  GridSettings({
    this.backgroundColor,
    this.columns,
    this.margin,
    this.outerMargin,
    this.backgroundSizeMode,
    this.autoFillHeight,
    this.backgroundImageUrl,
    this.mobileAutoFillHeight,
    this.mobileRowHeight,
  });

  factory GridSettings.fromJson(Map<String, dynamic> json) => GridSettings(
        backgroundColor: json["backgroundColor"],
        columns: json["columns"],
        margin: json["margin"],
        outerMargin: json["outerMargin"],
        backgroundSizeMode: json["backgroundSizeMode"],
        autoFillHeight: json["autoFillHeight"],
        backgroundImageUrl: json["backgroundImageUrl"],
        mobileAutoFillHeight: json["mobileAutoFillHeight"],
        mobileRowHeight: json["mobileRowHeight"],
      );

  String? backgroundColor;
  int? columns;
  int? margin;
  bool? outerMargin;
  String? backgroundSizeMode;
  bool? autoFillHeight;
  dynamic backgroundImageUrl;
  bool? mobileAutoFillHeight;
  int? mobileRowHeight;

  Map<String, dynamic> toJson() => {
        "backgroundColor": backgroundColor,
        "columns": columns,
        "margin": margin,
        "outerMargin": outerMargin,
        "backgroundSizeMode": backgroundSizeMode,
        "autoFillHeight": autoFillHeight,
        "backgroundImageUrl": backgroundImageUrl,
        "mobileAutoFillHeight": mobileAutoFillHeight,
        "mobileRowHeight": mobileRowHeight,
      };
}

class Widget {
  Widget({
    this.sizeX,
    this.sizeY,
    this.row,
    this.col,
  });

  factory Widget.fromJson(Map<String, dynamic> json) => Widget(
        sizeX: json["sizeX"],
        sizeY: json["sizeY"],
        row: json["row"],
        col: json["col"],
      );

  int? sizeX;
  int? sizeY;
  int? row;
  int? col;

  Map<String, dynamic> toJson() => {
        "sizeX": sizeX,
        "sizeY": sizeY,
        "row": row,
        "col": col,
      };
}

class ConfigurationTimewindow {
  ConfigurationTimewindow({
    this.displayValue,
    this.hideInterval,
    this.hideLastInterval,
    this.hideQuickInterval,
    this.hideAggregation,
    this.hideAggInterval,
    this.hideTimezone,
    this.selectedTab,
    this.realtime,
    this.history,
    this.aggregation,
  });

  factory ConfigurationTimewindow.fromJson(Map<String, dynamic> json) =>
      ConfigurationTimewindow(
        displayValue: json["displayValue"],
        hideInterval: json["hideInterval"],
        hideLastInterval: json["hideLastInterval"],
        hideQuickInterval: json["hideQuickInterval"],
        hideAggregation: json["hideAggregation"],
        hideAggInterval: json["hideAggInterval"],
        hideTimezone: json["hideTimezone"],
        selectedTab: json["selectedTab"],
        realtime: json["realtime"] == null
            ? null
            : Realtime.fromJson(json["realtime"]),
        history:
            json["history"] == null ? null : History.fromJson(json["history"]),
        aggregation: json["aggregation"] == null
            ? null
            : Aggregation.fromJson(json["aggregation"]),
      );

  String? displayValue;
  bool? hideInterval;
  bool? hideLastInterval;
  bool? hideQuickInterval;
  bool? hideAggregation;
  bool? hideAggInterval;
  bool? hideTimezone;
  int? selectedTab;
  Realtime? realtime;
  History? history;
  Aggregation? aggregation;

  Map<String, dynamic> toJson() => {
        "displayValue": displayValue,
        "hideInterval": hideInterval,
        "hideLastInterval": hideLastInterval,
        "hideQuickInterval": hideQuickInterval,
        "hideAggregation": hideAggregation,
        "hideAggInterval": hideAggInterval,
        "hideTimezone": hideTimezone,
        "selectedTab": selectedTab,
        "realtime": realtime?.toJson(),
        "history": history?.toJson(),
        "aggregation": aggregation?.toJson(),
      };
}

class Aggregation {
  Aggregation({
    this.type,
    this.limit,
  });

  factory Aggregation.fromJson(Map<String, dynamic> json) => Aggregation(
        type: json["type"],
        limit: json["limit"],
      );

  String? type;
  int? limit;

  Map<String, dynamic> toJson() => {
        "type": type,
        "limit": limit,
      };
}

class History {
  History({
    this.historyType,
    this.interval,
    this.timewindowMs,
    this.fixedTimewindow,
    this.quickInterval,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
        historyType: json["historyType"],
        interval: json["interval"],
        timewindowMs: json["timewindowMs"],
        fixedTimewindow: json["fixedTimewindow"] == null
            ? null
            : FixedTimewindow.fromJson(json["fixedTimewindow"]),
        quickInterval: json["quickInterval"],
      );

  int? historyType;
  int? interval;
  int? timewindowMs;
  FixedTimewindow? fixedTimewindow;
  String? quickInterval;

  Map<String, dynamic> toJson() => {
        "historyType": historyType,
        "interval": interval,
        "timewindowMs": timewindowMs,
        "fixedTimewindow": fixedTimewindow?.toJson(),
        "quickInterval": quickInterval,
      };
}

class FixedTimewindow {
  FixedTimewindow({
    this.startTimeMs,
    this.endTimeMs,
  });

  factory FixedTimewindow.fromJson(Map<String, dynamic> json) =>
      FixedTimewindow(
        startTimeMs: json["startTimeMs"],
        endTimeMs: json["endTimeMs"],
      );

  int? startTimeMs;
  int? endTimeMs;

  Map<String, dynamic> toJson() => {
        "startTimeMs": startTimeMs,
        "endTimeMs": endTimeMs,
      };
}

class Realtime {
  Realtime({
    this.realtimeType,
    this.interval,
    this.timewindowMs,
    this.quickInterval,
  });

  factory Realtime.fromJson(Map<String, dynamic> json) => Realtime(
        realtimeType: json["realtimeType"],
        interval: json["interval"],
        timewindowMs: json["timewindowMs"],
        quickInterval: json["quickInterval"],
      );

  int? realtimeType;
  int? interval;
  int? timewindowMs;
  String? quickInterval;

  Map<String, dynamic> toJson() => {
        "realtimeType": realtimeType,
        "interval": interval,
        "timewindowMs": timewindowMs,
        "quickInterval": quickInterval,
      };
}

class Widgets {
  The7Dc62D631DffCf9B9B1D67F1C4D12975? facf5D9873A68Ef437C684642C3728F7;
  A784F1592F3BD7A950Bd905629Fb9E9B? a784F1592F3BD7A950Bd905629Fb9E9B;
  The7Dc62D631DffCf9B9B1D67F1C4D12975? the7Dc62D631DffCf9B9B1D67F1C4D12975;

  Widgets({
    this.facf5D9873A68Ef437C684642C3728F7,
    this.a784F1592F3BD7A950Bd905629Fb9E9B,
    this.the7Dc62D631DffCf9B9B1D67F1C4D12975,
  });

  factory Widgets.fromJson(Map<String, dynamic> json) => Widgets(
        facf5D9873A68Ef437C684642C3728F7:
            json["facf5d98-73a6-8ef4-37c6-84642c3728f7"] == null
                ? null
                : The7Dc62D631DffCf9B9B1D67F1C4D12975.fromJson(
                    json["facf5d98-73a6-8ef4-37c6-84642c3728f7"]),
        a784F1592F3BD7A950Bd905629Fb9E9B:
            json["a784f159-2f3b-d7a9-50bd-905629fb9e9b"] == null
                ? null
                : A784F1592F3BD7A950Bd905629Fb9E9B.fromJson(
                    json["a784f159-2f3b-d7a9-50bd-905629fb9e9b"]),
        the7Dc62D631DffCf9B9B1D67F1C4D12975:
            json["7dc62d63-1dff-cf9b-9b1d-67f1c4d12975"] == null
                ? null
                : The7Dc62D631DffCf9B9B1D67F1C4D12975.fromJson(
                    json["7dc62d63-1dff-cf9b-9b1d-67f1c4d12975"]),
      );

  Map<String, dynamic> toJson() => {
        "facf5d98-73a6-8ef4-37c6-84642c3728f7":
            facf5D9873A68Ef437C684642C3728F7?.toJson(),
        "a784f159-2f3b-d7a9-50bd-905629fb9e9b":
            a784F1592F3BD7A950Bd905629Fb9E9B?.toJson(),
        "7dc62d63-1dff-cf9b-9b1d-67f1c4d12975":
            the7Dc62D631DffCf9B9B1D67F1C4D12975?.toJson(),
      };
}

class A784F1592F3BD7A950Bd905629Fb9E9B {
  A784F1592F3BD7A950Bd905629Fb9E9B({
    this.typeFullFqn,
    this.type,
    this.sizeX,
    this.sizeY,
    this.config,
    this.row,
    this.col,
    this.id,
  });

  factory A784F1592F3BD7A950Bd905629Fb9E9B.fromJson(
          Map<String, dynamic> json) =>
      A784F1592F3BD7A950Bd905629Fb9E9B(
        typeFullFqn: json["typeFullFqn"],
        type: json["type"],
        sizeX: json["sizeX"],
        sizeY: json["sizeY"],
        config: json["config"] == null
            ? null
            : A784F1592F3BD7A950Bd905629Fb9E9BConfig.fromJson(json["config"]),
        row: json["row"],
        col: json["col"],
        id: json["id"],
      );

  String? typeFullFqn;
  String? type;
  int? sizeX;
  int? sizeY;
  A784F1592F3BD7A950Bd905629Fb9E9BConfig? config;
  int? row;
  int? col;
  String? id;

  Map<String, dynamic> toJson() => {
        "typeFullFqn": typeFullFqn,
        "type": type,
        "sizeX": sizeX,
        "sizeY": sizeY,
        "config": config?.toJson(),
        "row": row,
        "col": col,
        "id": id,
      };
}

class A784F1592F3BD7A950Bd905629Fb9E9BConfig {
  A784F1592F3BD7A950Bd905629Fb9E9BConfig({
    this.datasources,
    this.timewindow,
    this.showTitle,
    this.backgroundColor,
    this.color,
    this.padding,
    this.settings,
    this.title,
    this.dropShadow,
    this.enableFullscreen,
    this.titleStyle,
    this.units,
    this.decimals,
    this.useDashboardTimewindow,
    this.showLegend,
    this.widgetStyle,
    this.actions,
    this.configMode,
    this.displayTimewindow,
    this.margin,
    this.borderRadius,
    this.widgetCss,
    this.pageSize,
    this.noDataDisplayMessage,
    this.showTitleIcon,
    this.titleTooltip,
    this.titleFont,
    this.titleIcon,
    this.iconColor,
    this.iconSize,
    this.timewindowStyle,
  });

  factory A784F1592F3BD7A950Bd905629Fb9E9BConfig.fromJson(
          Map<String, dynamic> json) =>
      A784F1592F3BD7A950Bd905629Fb9E9BConfig(
        datasources: json["datasources"] == null
            ? []
            : List<Datasource>.from(
                json["datasources"]!.map((x) => Datasource.fromJson(x))),
        timewindow: json["timewindow"] == null
            ? null
            : ConfigTimewindow.fromJson(json["timewindow"]),
        showTitle: json["showTitle"],
        backgroundColor: json["backgroundColor"],
        color: json["color"],
        padding: json["padding"],
        settings: json["settings"] == null
            ? null
            : FluffySettings.fromJson(json["settings"]),
        title: json["title"],
        dropShadow: json["dropShadow"],
        enableFullscreen: json["enableFullscreen"],
        titleStyle: json["titleStyle"] == null
            ? null
            : TitleStyle.fromJson(json["titleStyle"]),
        units: json["units"],
        decimals: json["decimals"],
        useDashboardTimewindow: json["useDashboardTimewindow"],
        showLegend: json["showLegend"],
        widgetStyle: json["widgetStyle"] == null
            ? null
            : Filters.fromJson(json["widgetStyle"]),
        actions:
            json["actions"] == null ? null : Filters.fromJson(json["actions"]),
        configMode: json["configMode"],
        displayTimewindow: json["displayTimewindow"],
        margin: json["margin"],
        borderRadius: json["borderRadius"],
        widgetCss: json["widgetCss"],
        pageSize: json["pageSize"],
        noDataDisplayMessage: json["noDataDisplayMessage"],
        showTitleIcon: json["showTitleIcon"],
        titleTooltip: json["titleTooltip"],
        titleFont:
            json["titleFont"] == null ? null : Font.fromJson(json["titleFont"]),
        titleIcon: json["titleIcon"],
        iconColor: json["iconColor"],
        iconSize: json["iconSize"],
        timewindowStyle: json["timewindowStyle"] == null
            ? null
            : TimewindowStyle.fromJson(json["timewindowStyle"]),
      );

  List<Datasource>? datasources;
  ConfigTimewindow? timewindow;
  bool? showTitle;
  String? backgroundColor;
  String? color;
  String? padding;
  FluffySettings? settings;
  String? title;
  bool? dropShadow;
  bool? enableFullscreen;
  TitleStyle? titleStyle;
  String? units;
  int? decimals;
  bool? useDashboardTimewindow;
  bool? showLegend;
  Filters? widgetStyle;
  Filters? actions;
  String? configMode;
  bool? displayTimewindow;
  String? margin;
  String? borderRadius;
  String? widgetCss;
  int? pageSize;
  String? noDataDisplayMessage;
  bool? showTitleIcon;
  String? titleTooltip;
  Font? titleFont;
  String? titleIcon;
  String? iconColor;
  String? iconSize;
  TimewindowStyle? timewindowStyle;

  Map<String, dynamic> toJson() => {
        "datasources": datasources == null
            ? []
            : List<dynamic>.from(datasources!.map((x) => x.toJson())),
        "timewindow": timewindow?.toJson(),
        "showTitle": showTitle,
        "backgroundColor": backgroundColor,
        "color": color,
        "padding": padding,
        "settings": settings?.toJson(),
        "title": title,
        "dropShadow": dropShadow,
        "enableFullscreen": enableFullscreen,
        "titleStyle": titleStyle?.toJson(),
        "units": units,
        "decimals": decimals,
        "useDashboardTimewindow": useDashboardTimewindow,
        "showLegend": showLegend,
        "widgetStyle": widgetStyle?.toJson(),
        "actions": actions?.toJson(),
        "configMode": configMode,
        "displayTimewindow": displayTimewindow,
        "margin": margin,
        "borderRadius": borderRadius,
        "widgetCss": widgetCss,
        "pageSize": pageSize,
        "noDataDisplayMessage": noDataDisplayMessage,
        "showTitleIcon": showTitleIcon,
        "titleTooltip": titleTooltip,
        "titleFont": titleFont?.toJson(),
        "titleIcon": titleIcon,
        "iconColor": iconColor,
        "iconSize": iconSize,
        "timewindowStyle": timewindowStyle?.toJson(),
      };
}

class Datasource {
  Datasource({
    this.type,
    this.name,
    this.deviceId,
    this.dataKeys,
    this.alarmFilterConfig,
  });

  factory Datasource.fromJson(Map<String, dynamic> json) => Datasource(
        type: json["type"],
        name: json["name"],
        deviceId: json["deviceId"],
        dataKeys: json["dataKeys"] == null
            ? []
            : List<DataKey>.from(
                json["dataKeys"]!.map((x) => DataKey.fromJson(x))),
        alarmFilterConfig: json["alarmFilterConfig"] == null
            ? null
            : AlarmFilterConfig.fromJson(json["alarmFilterConfig"]),
      );

  String? type;
  String? name;
  String? deviceId;
  List<DataKey>? dataKeys;
  AlarmFilterConfig? alarmFilterConfig;

  Map<String, dynamic> toJson() => {
        "type": type,
        "name": name,
        "deviceId": deviceId,
        "dataKeys": dataKeys == null
            ? []
            : List<dynamic>.from(dataKeys!.map((x) => x.toJson())),
        "alarmFilterConfig": alarmFilterConfig?.toJson(),
      };
}

class AlarmFilterConfig {
  AlarmFilterConfig({
    this.statusList,
  });

  factory AlarmFilterConfig.fromJson(Map<String, dynamic> json) =>
      AlarmFilterConfig(
        statusList: json["statusList"] == null
            ? []
            : List<String>.from(json["statusList"]!.map((x) => x)),
      );

  List<String>? statusList;

  Map<String, dynamic> toJson() => {
        "statusList": statusList == null
            ? []
            : List<dynamic>.from(statusList!.map((x) => x)),
      };
}

class DataKey {
  DataKey({
    this.name,
    this.type,
    this.label,
    this.color,
    this.settings,
    this.hash,
  });

  factory DataKey.fromJson(Map<String, dynamic> json) => DataKey(
        name: json["name"],
        type: json["type"],
        label: json["label"],
        color: json["color"],
        settings: json["settings"] == null
            ? null
            : Filters.fromJson(json["settings"]),
        hash: json["_hash"]?.toDouble(),
      );

  String? name;
  String? type;
  String? label;
  String? color;
  Filters? settings;
  double? hash;

  Map<String, dynamic> toJson() => {
        "name": name,
        "type": type,
        "label": label,
        "color": color,
        "settings": settings?.toJson(),
        "_hash": hash,
      };
}

class FluffySettings {
  FluffySettings({
    this.labelPosition,
    this.layout,
    this.showLabel,
    this.labelFont,
    this.labelColor,
    this.showIcon,
    this.iconSize,
    this.iconSizeUnit,
    this.icon,
    this.iconColor,
    this.valueFont,
    this.valueColor,
    this.showDate,
    this.dateFormat,
    this.dateFont,
    this.dateColor,
    this.background,
    this.autoScale,
  });

  factory FluffySettings.fromJson(Map<String, dynamic> json) => FluffySettings(
        labelPosition: json["labelPosition"],
        layout: json["layout"],
        showLabel: json["showLabel"],
        labelFont:
            json["labelFont"] == null ? null : Font.fromJson(json["labelFont"]),
        labelColor: json["labelColor"] == null
            ? null
            : Color.fromJson(json["labelColor"]),
        showIcon: json["showIcon"],
        iconSize: json["iconSize"],
        iconSizeUnit: json["iconSizeUnit"],
        icon: json["icon"],
        iconColor: json["iconColor"] == null
            ? null
            : Color.fromJson(json["iconColor"]),
        valueFont:
            json["valueFont"] == null ? null : Font.fromJson(json["valueFont"]),
        valueColor: json["valueColor"] == null
            ? null
            : Color.fromJson(json["valueColor"]),
        showDate: json["showDate"],
        dateFormat: json["dateFormat"] == null
            ? null
            : DateFormat.fromJson(json["dateFormat"]),
        dateFont:
            json["dateFont"] == null ? null : Font.fromJson(json["dateFont"]),
        dateColor: json["dateColor"] == null
            ? null
            : Color.fromJson(json["dateColor"]),
        background: json["background"] == null
            ? null
            : Background.fromJson(json["background"]),
        autoScale: json["autoScale"],
      );

  String? labelPosition;
  String? layout;
  bool? showLabel;
  Font? labelFont;
  Color? labelColor;
  bool? showIcon;
  int? iconSize;
  String? iconSizeUnit;
  String? icon;
  Color? iconColor;
  Font? valueFont;
  Color? valueColor;
  bool? showDate;
  DateFormat? dateFormat;
  Font? dateFont;
  Color? dateColor;
  Background? background;
  bool? autoScale;

  Map<String, dynamic> toJson() => {
        "labelPosition": labelPosition,
        "layout": layout,
        "showLabel": showLabel,
        "labelFont": labelFont?.toJson(),
        "labelColor": labelColor?.toJson(),
        "showIcon": showIcon,
        "iconSize": iconSize,
        "iconSizeUnit": iconSizeUnit,
        "icon": icon,
        "iconColor": iconColor?.toJson(),
        "valueFont": valueFont?.toJson(),
        "valueColor": valueColor?.toJson(),
        "showDate": showDate,
        "dateFormat": dateFormat?.toJson(),
        "dateFont": dateFont?.toJson(),
        "dateColor": dateColor?.toJson(),
        "background": background?.toJson(),
        "autoScale": autoScale,
      };
}

class Background {
  Background({
    this.type,
    this.color,
    this.overlay,
  });

  factory Background.fromJson(Map<String, dynamic> json) => Background(
        type: json["type"],
        color: json["color"],
        overlay:
            json["overlay"] == null ? null : Overlay.fromJson(json["overlay"]),
      );

  String? type;
  String? color;
  Overlay? overlay;

  Map<String, dynamic> toJson() => {
        "type": type,
        "color": color,
        "overlay": overlay?.toJson(),
      };
}

class Overlay {
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

  bool? enabled;
  String? color;
  int? blur;

  Map<String, dynamic> toJson() => {
        "enabled": enabled,
        "color": color,
        "blur": blur,
      };
}

class Color {
  Color({
    this.type,
    this.color,
    this.colorFunction,
  });

  factory Color.fromJson(Map<String, dynamic> json) => Color(
        type: json["type"],
        color: json["color"],
        colorFunction: json["colorFunction"],
      );

  String? type;
  String? color;
  String? colorFunction;

  Map<String, dynamic> toJson() => {
        "type": type,
        "color": color,
        "colorFunction": colorFunction,
      };
}

class Font {
  Font({
    this.size,
    this.sizeUnit,
    this.family,
    this.weight,
    this.style,
    this.lineHeight,
  });

  factory Font.fromJson(Map<String, dynamic> json) => Font(
        size: json["size"],
        sizeUnit: json["sizeUnit"],
        family: json["family"],
        weight: json["weight"],
        style: json["style"],
        lineHeight: json["lineHeight"],
      );

  int? size;
  String? sizeUnit;
  String? family;
  String? weight;
  String? style;
  String? lineHeight;

  Map<String, dynamic> toJson() => {
        "size": size,
        "sizeUnit": sizeUnit,
        "family": family,
        "weight": weight,
        "style": style,
        "lineHeight": lineHeight,
      };
}

class DateFormat {
  DateFormat({
    this.format,
    this.lastUpdateAgo,
    this.custom,
  });

  factory DateFormat.fromJson(Map<String, dynamic> json) => DateFormat(
        format: json["format"],
        lastUpdateAgo: json["lastUpdateAgo"],
        custom: json["custom"],
      );

  dynamic format;
  bool? lastUpdateAgo;
  bool? custom;

  Map<String, dynamic> toJson() => {
        "format": format,
        "lastUpdateAgo": lastUpdateAgo,
        "custom": custom,
      };
}

class ConfigTimewindow {
  ConfigTimewindow({
    this.displayValue,
    this.selectedTab,
    this.realtime,
    this.history,
    this.aggregation,
  });

  factory ConfigTimewindow.fromJson(Map<String, dynamic> json) =>
      ConfigTimewindow(
        displayValue: json["displayValue"],
        selectedTab: json["selectedTab"],
        realtime: json["realtime"] == null
            ? null
            : Realtime.fromJson(json["realtime"]),
        history:
            json["history"] == null ? null : History.fromJson(json["history"]),
        aggregation: json["aggregation"] == null
            ? null
            : Aggregation.fromJson(json["aggregation"]),
      );

  String? displayValue;
  int? selectedTab;
  Realtime? realtime;
  History? history;
  Aggregation? aggregation;

  Map<String, dynamic> toJson() => {
        "displayValue": displayValue,
        "selectedTab": selectedTab,
        "realtime": realtime?.toJson(),
        "history": history?.toJson(),
        "aggregation": aggregation?.toJson(),
      };
}

class TimewindowStyle {
  TimewindowStyle({
    this.showIcon,
    this.iconSize,
    this.icon,
    this.iconPosition,
    this.font,
    this.color,
  });

  factory TimewindowStyle.fromJson(Map<String, dynamic> json) =>
      TimewindowStyle(
        showIcon: json["showIcon"],
        iconSize: json["iconSize"],
        icon: json["icon"],
        iconPosition: json["iconPosition"],
        font: json["font"] == null ? null : Font.fromJson(json["font"]),
        color: json["color"],
      );

  bool? showIcon;
  String? iconSize;
  String? icon;
  String? iconPosition;
  Font? font;
  dynamic color;

  Map<String, dynamic> toJson() => {
        "showIcon": showIcon,
        "iconSize": iconSize,
        "icon": icon,
        "iconPosition": iconPosition,
        "font": font?.toJson(),
        "color": color,
      };
}

class TitleStyle {
  TitleStyle({
    this.fontSize,
    this.fontWeight,
  });

  factory TitleStyle.fromJson(Map<String, dynamic> json) => TitleStyle(
        fontSize: json["fontSize"],
        fontWeight: json["fontWeight"],
      );

  String? fontSize;
  int? fontWeight;

  Map<String, dynamic> toJson() => {
        "fontSize": fontSize,
        "fontWeight": fontWeight,
      };
}

class The7Dc62D631DffCf9B9B1D67F1C4D12975 {
  The7Dc62D631DffCf9B9B1D67F1C4D12975({
    this.typeFullFqn,
    this.type,
    this.sizeX,
    this.sizeY,
    this.config,
    this.row,
    this.col,
    this.id,
  });

  factory The7Dc62D631DffCf9B9B1D67F1C4D12975.fromJson(
          Map<String, dynamic> json) =>
      The7Dc62D631DffCf9B9B1D67F1C4D12975(
        typeFullFqn: json["typeFullFqn"],
        type: json["type"],
        sizeX: json["sizeX"]?.toDouble(),
        sizeY: json["sizeY"]?.toDouble(),
        config: json["config"] == null
            ? null
            : The7Dc62D631DffCf9B9B1D67F1C4D12975Config.fromJson(
                json["config"]),
        row: json["row"],
        col: json["col"],
        id: json["id"],
      );

  String? typeFullFqn;
  String? type;
  double? sizeX;
  double? sizeY;
  The7Dc62D631DffCf9B9B1D67F1C4D12975Config? config;
  int? row;
  int? col;
  String? id;

  Map<String, dynamic> toJson() => {
        "typeFullFqn": typeFullFqn,
        "type": type,
        "sizeX": sizeX,
        "sizeY": sizeY,
        "config": config?.toJson(),
        "row": row,
        "col": col,
        "id": id,
      };
}

class The7Dc62D631DffCf9B9B1D67F1C4D12975Config {
  The7Dc62D631DffCf9B9B1D67F1C4D12975Config({
    this.showTitle,
    this.backgroundColor,
    this.color,
    this.padding,
    this.settings,
    this.title,
    this.dropShadow,
    this.enableFullscreen,
    this.widgetStyle,
    this.actions,
    this.widgetCss,
    this.noDataDisplayMessage,
    this.titleFont,
    this.showTitleIcon,
    this.titleTooltip,
    this.titleStyle,
    this.pageSize,
    this.titleIcon,
    this.iconColor,
    this.iconSize,
    this.configMode,
    this.targetDevice,
    this.titleColor,
    this.borderRadius,
    this.datasources,
  });

  factory The7Dc62D631DffCf9B9B1D67F1C4D12975Config.fromJson(
          Map<String, dynamic> json) =>
      The7Dc62D631DffCf9B9B1D67F1C4D12975Config(
        showTitle: json["showTitle"],
        backgroundColor: json["backgroundColor"],
        color: json["color"],
        padding: json["padding"],
        settings: json["settings"] == null
            ? null
            : PurpleSettings.fromJson(json["settings"]),
        title: json["title"],
        dropShadow: json["dropShadow"],
        enableFullscreen: json["enableFullscreen"],
        widgetStyle: json["widgetStyle"] == null
            ? null
            : Filters.fromJson(json["widgetStyle"]),
        actions:
            json["actions"] == null ? null : Filters.fromJson(json["actions"]),
        widgetCss: json["widgetCss"],
        noDataDisplayMessage: json["noDataDisplayMessage"],
        titleFont:
            json["titleFont"] == null ? null : Font.fromJson(json["titleFont"]),
        showTitleIcon: json["showTitleIcon"],
        titleTooltip: json["titleTooltip"],
        titleStyle: json["titleStyle"] == null
            ? null
            : TitleStyle.fromJson(json["titleStyle"]),
        pageSize: json["pageSize"],
        titleIcon: json["titleIcon"],
        iconColor: json["iconColor"],
        iconSize: json["iconSize"],
        configMode: json["configMode"],
        targetDevice: json["targetDevice"] == null
            ? null
            : TargetDevice.fromJson(json["targetDevice"]),
        titleColor: json["titleColor"],
        borderRadius: json["borderRadius"],
        datasources: json["datasources"] == null
            ? []
            : List<dynamic>.from(json["datasources"]!.map((x) => x)),
      );

  bool? showTitle;
  String? backgroundColor;
  String? color;
  String? padding;
  PurpleSettings? settings;
  String? title;
  bool? dropShadow;
  bool? enableFullscreen;
  Filters? widgetStyle;
  Filters? actions;
  String? widgetCss;
  String? noDataDisplayMessage;
  Font? titleFont;
  bool? showTitleIcon;
  String? titleTooltip;
  TitleStyle? titleStyle;
  int? pageSize;
  String? titleIcon;
  String? iconColor;
  String? iconSize;
  String? configMode;
  TargetDevice? targetDevice;
  dynamic titleColor;
  dynamic borderRadius;
  List<dynamic>? datasources;

  Map<String, dynamic> toJson() => {
        "showTitle": showTitle,
        "backgroundColor": backgroundColor,
        "color": color,
        "padding": padding,
        "settings": settings?.toJson(),
        "title": title,
        "dropShadow": dropShadow,
        "enableFullscreen": enableFullscreen,
        "widgetStyle": widgetStyle?.toJson(),
        "actions": actions?.toJson(),
        "widgetCss": widgetCss,
        "noDataDisplayMessage": noDataDisplayMessage,
        "titleFont": titleFont?.toJson(),
        "showTitleIcon": showTitleIcon,
        "titleTooltip": titleTooltip,
        "titleStyle": titleStyle?.toJson(),
        "pageSize": pageSize,
        "titleIcon": titleIcon,
        "iconColor": iconColor,
        "iconSize": iconSize,
        "configMode": configMode,
        "targetDevice": targetDevice?.toJson(),
        "titleColor": titleColor,
        "borderRadius": borderRadius,
        "datasources": datasources == null
            ? []
            : List<dynamic>.from(datasources!.map((x) => x)),
      };
}

class PurpleSettings {
  PurpleSettings({
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
    this.padding,
  });

  factory PurpleSettings.fromJson(Map<String, dynamic> json) => PurpleSettings(
        initialState: json["initialState"] == null
            ? null
            : InitialState.fromJson(json["initialState"]),
        onUpdateState: json["onUpdateState"] == null
            ? null
            : UpdateState.fromJson(json["onUpdateState"]),
        offUpdateState: json["offUpdateState"] == null
            ? null
            : UpdateState.fromJson(json["offUpdateState"]),
        disabledState: json["disabledState"] == null
            ? null
            : DisabledState.fromJson(json["disabledState"]),
        layout: json["layout"],
        mainColorOn: json["mainColorOn"],
        backgroundColorOn: json["backgroundColorOn"],
        mainColorOff: json["mainColorOff"],
        backgroundColorOff: json["backgroundColorOff"],
        mainColorDisabled: json["mainColorDisabled"],
        backgroundColorDisabled: json["backgroundColorDisabled"],
        background: json["background"] == null
            ? null
            : Background.fromJson(json["background"]),
        padding: json["padding"],
      );

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
  String? padding;

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
        "padding": padding,
      };
}

class DisabledState {
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
        getAttribute: json["getAttribute"] == null
            ? null
            : EtAttribute.fromJson(json["getAttribute"]),
        getTimeSeries: json["getTimeSeries"] == null
            ? null
            : TTimeSeries.fromJson(json["getTimeSeries"]),
        dataToValue: json["dataToValue"] == null
            ? null
            : DisabledStateDataToValue.fromJson(json["dataToValue"]),
      );

  String? action;
  bool? defaultValue;
  EtAttribute? getAttribute;
  TTimeSeries? getTimeSeries;
  DisabledStateDataToValue? dataToValue;

  Map<String, dynamic> toJson() => {
        "action": action,
        "defaultValue": defaultValue,
        "getAttribute": getAttribute?.toJson(),
        "getTimeSeries": getTimeSeries?.toJson(),
        "dataToValue": dataToValue?.toJson(),
      };
}

class DisabledStateDataToValue {
  DisabledStateDataToValue({
    this.type,
    this.compareToValue,
    this.dataToValueFunction,
  });

  factory DisabledStateDataToValue.fromJson(Map<String, dynamic> json) =>
      DisabledStateDataToValue(
        type: json["type"],
        compareToValue: json["compareToValue"],
        dataToValueFunction: json["dataToValueFunction"],
      );

  String? type;
  bool? compareToValue;
  String? dataToValueFunction;

  Map<String, dynamic> toJson() => {
        "type": type,
        "compareToValue": compareToValue,
        "dataToValueFunction": dataToValueFunction,
      };
}

class EtAttribute {
  EtAttribute({
    this.key,
    this.scope,
  });

  factory EtAttribute.fromJson(Map<String, dynamic> json) => EtAttribute(
        key: json["key"],
        scope: json["scope"],
      );

  String? key;
  String? scope;

  Map<String, dynamic> toJson() => {
        "key": key,
        "scope": scope,
      };
}

class TTimeSeries {
  TTimeSeries({
    this.key,
  });

  factory TTimeSeries.fromJson(Map<String, dynamic> json) => TTimeSeries(
        key: json["key"],
      );

  String? key;

  Map<String, dynamic> toJson() => {
        "key": key,
      };
}

class InitialState {
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
        executeRpc: json["executeRpc"] == null
            ? null
            : ExecuteRpc.fromJson(json["executeRpc"]),
        getAttribute: json["getAttribute"] == null
            ? null
            : EtAttribute.fromJson(json["getAttribute"]),
        getTimeSeries: json["getTimeSeries"] == null
            ? null
            : TTimeSeries.fromJson(json["getTimeSeries"]),
        dataToValue: json["dataToValue"] == null
            ? null
            : InitialStateDataToValue.fromJson(json["dataToValue"]),
      );

  String? action;
  bool? defaultValue;
  ExecuteRpc? executeRpc;
  EtAttribute? getAttribute;
  TTimeSeries? getTimeSeries;
  InitialStateDataToValue? dataToValue;

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
  InitialStateDataToValue({
    this.type,
    this.compareToValue,
    this.dataToValueFunction,
  });

  factory InitialStateDataToValue.fromJson(Map<String, dynamic> json) =>
      InitialStateDataToValue(
        type: json["type"],
        compareToValue: json["compareToValue"],
        dataToValueFunction: json["dataToValueFunction"],
      );

  String? type;
  String? compareToValue;
  String? dataToValueFunction;

  Map<String, dynamic> toJson() => {
        "type": type,
        "compareToValue": compareToValue,
        "dataToValueFunction": dataToValueFunction,
      };
}

class ExecuteRpc {
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

  String? method;
  int? requestTimeout;
  bool? requestPersistent;
  int? persistentPollingInterval;

  Map<String, dynamic> toJson() => {
        "method": method,
        "requestTimeout": requestTimeout,
        "requestPersistent": requestPersistent,
        "persistentPollingInterval": persistentPollingInterval,
      };
}

class UpdateState {
  UpdateState({
    this.action,
    this.executeRpc,
    this.setAttribute,
    this.putTimeSeries,
    this.valueToData,
  });

  factory UpdateState.fromJson(Map<String, dynamic> json) => UpdateState(
        action: json["action"],
        executeRpc: json["executeRpc"] == null
            ? null
            : ExecuteRpc.fromJson(json["executeRpc"]),
        setAttribute: json["setAttribute"] == null
            ? null
            : EtAttribute.fromJson(json["setAttribute"]),
        putTimeSeries: json["putTimeSeries"] == null
            ? null
            : TTimeSeries.fromJson(json["putTimeSeries"]),
        valueToData: json["valueToData"] == null
            ? null
            : ValueToData.fromJson(json["valueToData"]),
      );

  String? action;
  ExecuteRpc? executeRpc;
  EtAttribute? setAttribute;
  TTimeSeries? putTimeSeries;
  ValueToData? valueToData;

  Map<String, dynamic> toJson() => {
        "action": action,
        "executeRpc": executeRpc?.toJson(),
        "setAttribute": setAttribute?.toJson(),
        "putTimeSeries": putTimeSeries?.toJson(),
        "valueToData": valueToData?.toJson(),
      };
}

class ValueToData {
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

  String? type;
  String? constantValue;
  String? valueToDataFunction;

  Map<String, dynamic> toJson() => {
        "type": type,
        "constantValue": constantValue,
        "valueToDataFunction": valueToDataFunction,
      };
}

class TargetDevice {
  TargetDevice({
    this.type,
    this.deviceId,
  });

  factory TargetDevice.fromJson(Map<String, dynamic> json) => TargetDevice(
        type: json["type"],
        deviceId: json["deviceId"],
      );

  String? type;
  String? deviceId;

  Map<String, dynamic> toJson() => {
        "type": type,
        "deviceId": deviceId,
      };
}
