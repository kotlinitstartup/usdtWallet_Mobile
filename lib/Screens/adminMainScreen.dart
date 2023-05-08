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
  List<Map<dynamic, dynamic>> transferData = [];
  int userData = 0;
  Map<dynamic, dynamic>? selectedDeposit;
  Map<dynamic, dynamic>? selectedWithdraw;
  Map<dynamic, dynamic>? selectedTransfer;

  @override
  void initState() {
    super.initState();
    fetchDepositStats();
    fetchWithdrawalStats();
    fetchTransferStats();
    fetchUserStats();
  }

  Future<void> fetchUserStats() async {
    try{
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Server error. Please try again later.'),
      ));
    }
  }

  Future<void> fetchWithdrawalStats() async {
    try{
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Server error. Please try again later.'),
      ));
    }
  }

  Future<void> fetchDepositStats() async {
    try {
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
    }catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('Server error. Please try again later.'),
    ));
    }
  }

  Future<void> fetchTransferStats() async {
    try {
      final url = Uri.parse(ApiService.baseUrl + '/admin/transfer-stats');
      final accessToken = await getAccessToken();
      final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '$accessToken',
          });
      if (response.statusCode == 200) {
        setState(() {
          transferData = List<Map<dynamic, dynamic>>.from(
            json.decode(response.body).map(
                  (data) => Map<dynamic, dynamic>.from(data),
            ),
          );
        });
      } else {
        // Handle server error
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Server error. Please try again later.'),
      ));
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

    final transferSeries = [
      charts.Series<Map<dynamic, dynamic>, DateTime>(
        id: 'Transfers',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (data, _) => DateTime.parse(data['date_']),
        measureFn: (data, _) => double.parse(data['amount_']),
        data: transferData,
      )
    ];

    void _onTransferSelectionChanged(charts.SelectionModel model) {
      setState(() {
        selectedTransfer = model.selectedDatum.first.datum;
      });
    }

    final transferChart = charts.TimeSeriesChart(
      transferSeries,
      animate: true,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      selectionModels: [
        charts.SelectionModelConfig(
          type: charts.SelectionModelType.info,
          changedListener: _onTransferSelectionChanged,
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
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
                  SizedBox(height: 32.0),
                  Text(
                    'Transfers by Day:',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  SizedBox(
                    height: 200.0,
                    child: transferChart,
                  ),
                  Text(
                    selectedTransfer != null
                        ? 'Transfers for ${selectedTransfer!['date_']}: ${selectedTransfer!['amount_']}USDT'
                        : 'Tap on a transfer to see details',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),// your widgets here
          ],
        ),
      ),

    );
  }
}

