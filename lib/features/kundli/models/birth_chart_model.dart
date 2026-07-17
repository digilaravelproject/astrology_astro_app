class BirthChartModel {
  final bool success;
  final BirthChartData? data;

  BirthChartModel({required this.success, this.data});

  factory BirthChartModel.fromJson(Map<String, dynamic> json) {
    return BirthChartModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? BirthChartData.fromJson(json['data']) : null,
    );
  }
}

class BirthChartData {
  final ChartSvgData? chart;

  BirthChartData({this.chart});

  factory BirthChartData.fromJson(Map<String, dynamic> json) {
    return BirthChartData(
      chart: json['chart'] != null ? ChartSvgData.fromJson(json['chart']) : null,
    );
  }
}

class ChartSvgData {
  final String? format;
  final String? northIndian;
  final String? southIndian;

  ChartSvgData({this.format, this.northIndian, this.southIndian});

  factory ChartSvgData.fromJson(Map<String, dynamic> json) {
    return ChartSvgData(
      format: json['format'],
      northIndian: json['northIndian'],
      southIndian: json['southIndian'],
    );
  }
}
