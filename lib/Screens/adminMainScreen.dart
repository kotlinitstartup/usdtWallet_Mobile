import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:usdtwalletmobile/api/api_service.dart';

import '../auth.dart';
import 'loginScreen.dart';

class AdminMainScreen extends StatefulWidget {

  @override
  _AdminMainScreenState createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  List<Map<dynamic, dynamic>> depositData = [];
  List<Map<dynamic, dynamic>> withdrawData = [];
  int userData = 0;
  Map<dynamic, dynamic>? selectedDeposit;
  Map<dynamic, dynamic>? selectedWithdraw;

  @override
  void initState() {
    super.initState();
    fetchDepositStats();
    fetchWithdrawalStats();
    fetchUserStats();
  }

  Future<void> fetchUserStats() async {
    final url = Uri.parse(ApiService.baseUrl + '/admin/user-stats');
    final accessToken = await getAccessToken();
    final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$accessToken',
        });
    if (response.statusCode == 200) {
      setState(() {
        userData = int.parse(json.decode(response.body)[0]["count_"]);
      });
    } else {
      // Handle server error
    }
  }

  Future<void> fetchWithdrawalStats() async {
    final url = Uri.parse(ApiService.baseUrl + '/admin/withdrawal-stats');
    final accessToken = await getAccessToken();
    final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$accessToken',
        });
    if (response.statusCode == 200) {
      setState(() {
        withdrawData = List<Map<dynamic, dynamic>>.from(
          json.decode(response.body).map(
                (data) => Map<dynamic, dynamic>.from(data),
          ),
        );
      });
    } else {
      // Handle server error
    }
  }

  Future<void> fetchDepositStats() async {
    final url = Uri.parse(ApiService.baseUrl + '/admin/deposit-stats');
    final accessToken = await getAccessToken();
    final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$accessToken',
        });
    if (response.statusCode == 200) {
      setState(() {
        depositData = List<Map<dynamic, dynamic>>.from(
          json.decode(response.body).map(
                (data) => Map<dynamic, dynamic>.from(data),
          ),
        );
      });
    } else {
      // Handle server error
    }
  }

  @override
  Widget build(BuildContext context) {
    final depositSeries = [
      charts.Series<Map<dynamic, dynamic>, DateTime>(
        id: 'Deposits',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (data, _) => DateTime.parse(data['date_']),
        measureFn: (data, _) => double.parse(data['amount_']),
        data: depositData,
      )
    ];

    void _onDepositSelectionChanged(charts.SelectionModel model) {
      setState(() {
        selectedDeposit = model.selectedDatum.first.datum;
      });
    }

    final depositChart = charts.TimeSeriesChart(
      depositSeries,
      animate: true,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      selectionModels: [
        charts.SelectionModelConfig(
          type: charts.SelectionModelType.info,
          changedListener: _onDepositSelectionChanged,
        ),
      ],
      primaryMeasureAxis: const charts.NumericAxisSpec(
        tickProviderSpec:
        charts.BasicNumericTickProviderSpec(zeroBound: false),
      ),
      domainAxis: const charts.DateTimeAxisSpec(
        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
          day: charts.TimeFormatterSpec(
            format: 'dd/MM',
            transitionFormat: 'dd/MM',
          ),
        ),
        tickProviderSpec: charts.DayTickProviderSpec(increments: [1]),
      ),
    );

    final withdrawSeries = [
      charts.Series<Map<dynamic, dynamic>, DateTime>(
        id: 'Withdraws',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (data, _) => DateTime.parse(data['date_']),
        measureFn: (data, _) => double.parse(data['amount_']),
        data: withdrawData,
      )
    ];

    void _onWithdrawSelectionChanged(charts.SelectionModel model) {
      setState(() {
        selectedWithdraw = model.selectedDatum.first.datum;
      });
    }

    final withdrawChart = charts.TimeSeriesChart(
      withdrawSeries,
      animate: true,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      selectionModels: [
        charts.SelectionModelConfig(
          type: charts.SelectionModelType.info,
          changedListener: _onWithdrawSelectionChanged,
        ),
      ],
      primaryMeasureAxis: const charts.NumericAxisSpec(
        tickProviderSpec:
        charts.BasicNumericTickProviderSpec(zeroBound: false),
      ),
      domainAxis: const charts.DateTimeAxisSpec(
        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
          day: charts.TimeFormatterSpec(
            format: 'dd/MM',
            transitionFormat: 'dd/MM',
          ),
        ),
        tickProviderSpec: charts.DayTickProviderSpec(increments: [1]),
      ),
    );


    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Main Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              clearAccessToken().then((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Count of users: ' + userData.toString(),
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Deposits by Day:',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 16.0),
              SizedBox(
                height: 200.0,
                child: depositChart,
              ),
              Text(
                selectedDeposit != null
                    ? 'Deposits for ${selectedDeposit!['date_']}: ${selectedDeposit!['amount_']}USDT'
                    : 'Tap on a deposit to see details',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 32.0),
              Text(
                'Withdrawals by Day:',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                height: 200.0,
                child: withdrawChart,
              ),
              Text(
                selectedWithdraw != null
                    ? 'Withdrawals for ${selectedWithdraw!['date_']}: ${selectedWithdraw!['amount_']}USDT'
                    : 'Tap on a withdraw to see details',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
    );
  }
}

