import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:usdtwalletmobile/Screens/userInfoScreen.dart';
import 'package:usdtwalletmobile/api/api_service.dart';
import '../auth.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordRepeatController = TextEditingController();

  Future<void> _register() async {
    try{

    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final passwordRepeat = _passwordRepeatController.text;

    if (password != passwordRepeat) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Passwords do not match'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    void _onRegistrationSuccess(String token) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserInfoScreen(),
        ),
      );
    }

    final url = ApiService.baseUrl + '/users/register';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username,'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final accessToken = jsonDecode(response.body)['accessToken'];
      await saveAccessToken(accessToken);
      _onRegistrationSuccess(accessToken);
    } else {
      final body = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(body['message']),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('Server Error. Try again later'),
    ));
    setState(() {

    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return 'Email is required';
                    }
                    if (value != null && !EmailValidator.validate(value)) {
                      return 'Invalid email format';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value != null && value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordRepeatController,
                  decoration: InputDecoration(labelText: 'Repeat password'),
                  obscureText: true,
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return 'Repeat password is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  child: Text('Register'),
                  onPressed: () {
                    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                      _register();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(200, 50), // set button size
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}