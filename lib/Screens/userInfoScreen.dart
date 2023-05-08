import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to fetch user info. Please try again later.'),
      ));
    }
  }


  void _copyWalletAddress() {
    Clipboard.setData(ClipboardData(text: user!.walletAddress)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Wallet address copied to clipboard'),
      ));
    });
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
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),

              Center(
                child: Column(
                  children: [
                    Text(
                      '${user!.walletBalance} USDT',
                      style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Wallet Balance',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16.0),
              Text(
                'Wallet Address',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${user!.walletAddress}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'monospace',
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: _copyWalletAddress,
                  ),
                ],
              ),
              Text(
                'Name',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${user!.username}',
                style: TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                'ID',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${user!.id}',
                style: TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${user!.email}',
                style: TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
        drawer: AppMenu(),
      );
    }
  }

}
