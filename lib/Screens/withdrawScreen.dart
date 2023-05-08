import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:usdtwalletmobile/AppMenu.dart';
import '../api/api_service.dart';
import '../auth.dart';
import '../models/user.dart';

class WithdrawScreen extends StatefulWidget {
  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _addressController = TextEditingController();
  User? user = null;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final accessToken = await getAccessToken();
      final response = await http.get(
          Uri.parse(ApiService.baseUrl + '/users/info'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '$accessToken',
          });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          user = User(
            id: responseData['user']['id'],
            username: responseData['user']['username'],
            email: responseData['user']['email'],
            walletBalance: responseData['user']['walletBalance'],
            walletAddress: responseData['user']['walletAddress'],
          );
        });
      } else {
        throw Exception('Failed to fetch user info');
      }
    }catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Server error. Please try again later.'),
      ));
    }
  }

  Future<void> _makeWithdraw() async {
    try {
      if (_addressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter an address')),
        );
        return;
      }

      final url = ApiService.baseUrl + '/wallet/withdraw';
      final accessToken = await getAccessToken();
      final headers = {
        'Authorization': '$accessToken',
      };
      final body = {
        'amount': _amountController.text,
        'address': _addressController.text,
      };

      final response = await http.post(
          Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Withdraw successful')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Withdraw failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Server error. Please try again later.'),
      ));
    }
  }


  @override
  void dispose() {
    _amountController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make a Withdraw'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount of USDT',
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
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'External Address',
                ),

              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _makeWithdraw();
                  }
                },
                child: Text('Make a Withdraw'),
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
