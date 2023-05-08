import 'dart:convert';
import 'package:http/http.dart' as http;

import '../auth.dart';

class ApiService {
  static const String baseUrl = 'http://8.210.33.51:3000';

  static Future<http.Response> fetchUserCounts() async {
    final url = baseUrl + 'admin/user-counts';
    final accessToken = await getAccessToken();
    final headers = {
      'Authorization': '$accessToken',
    };
    final response = await http.get(Uri.parse(url), headers: headers);
    return response;
  }

  static Future<http.Response> makeDeposit(body) async {
    final url = baseUrl + '/wallet/deposit';
    final accessToken = await getAccessToken();
    final headers = {
      'Authorization': '$accessToken',
    };
    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    return response;
  }

  static Future<int> getTotalUsers() async {
    final response = await http.get(Uri.parse(baseUrl + 'users/total'));
    if (response.statusCode == 200) {
      return int.parse(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch total users');
    }
  }

  static Future<double> getTotalDeposits() async {
    final response = await http.get(Uri.parse(baseUrl + 'deposits/total'));
    if (response.statusCode == 200) {
      return double.parse(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch total deposits');
    }
  }

  static Future<double> getTotalWithdrawals() async {
    final response = await http.get(Uri.parse(baseUrl + 'withdrawals/total'));
    if (response.statusCode == 200) {
      return double.parse(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch total withdrawals');
    }
  }

  static Future<List<ChartData>> getTransactionChartData() async {
    final response =
    await http.get(Uri.parse(baseUrl + 'transactions/chart-data'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final chartDataList =
      (jsonData as List).map((e) => ChartData.fromJson(e)).toList();
      return chartDataList;
    } else {
      throw Exception('Failed to fetch transaction chart data');
    }
  }
}

class ChartData {
  final String label;
  final double value;

  ChartData({required this.label, required this.value});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(label: json['label'], value: json['value'].toDouble());
  }
}
