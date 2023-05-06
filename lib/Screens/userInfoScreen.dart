import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:usdtwalletmobile/Screens/loginScreen.dart';
import 'dart:convert';
import '../AppMenu.dart';
import '../api/api_service.dart';
import '../auth.dart';
import '../models/user.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  User? user = null;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final accessToken = await getAccessToken();
    final response = await http.get(Uri.parse(ApiService.baseUrl + '/users/info'),
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
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
            title: const Text('User Info'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Info'),
            actions: [
              if (user != null)
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
                ),]
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              Text('Name: ${user!.username}'),
              const SizedBox(height: 8.0),
              Text('ID: ${user!.id}'),
              const SizedBox(height: 8.0),
              Text('Email: ${user!.email}'),
              const SizedBox(height: 8.0),
              Text('Wallet balance: ${user!.walletBalance} USDT'),
              const SizedBox(height: 8.0),
              Text('Wallet address: ${user!.walletAddress}'),
            ],
          ),
        ),
        drawer: AppMenu(),
      );
    }
  }
}
