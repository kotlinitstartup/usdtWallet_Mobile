import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:usdtwalletmobile/AppMenu.dart';
import '../api/api_service.dart';
import '../auth.dart';

class TransferScreen extends StatefulWidget {
  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  Future<void> _submitTransferRequest() async {
    try {
      final accessToken = await getAccessToken();
      final url = Uri.parse(ApiService.baseUrl + '/wallet/transfer');
      final body = {
        'id': _idController.text,
        'amount': _amountController.text,
      };

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      };

      final response = await http.post(
          url, headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transfer successful')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transfer failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Server error. Please try again later.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer USDT'),
      ),
      body: Padding(
      padding: const EdgeInsets.all(16.0),
        child: Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'Recipient ID',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an ID';
                  }
                  if (double.tryParse(value) == null || double.parse(value) < 0) {
                    return 'Please enter a valid ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount of USDT to transfer',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) < 1) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: (){
                  if (_formKey.currentState!.validate()) {
                    _submitTransferRequest();
                  }
                },
                child: Text('Transfer'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size(200, 50),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: AppMenu(),
    );
  }
}
