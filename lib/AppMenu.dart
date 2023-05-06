import 'package:flutter/material.dart';
import 'package:usdtwalletmobile/Screens/withdrawScreen.dart';

import 'Screens/depositScreen.dart';
import 'Screens/historyScreen.dart';
import 'Screens/transferScreen.dart';
import 'Screens/userInfoScreen.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(''),
            decoration: BoxDecoration(
              color: Colors.black,
            ),
          ),
          ListTile(
            title: Text('User Info'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserInfoScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Deposit'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DepositScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Withdraw'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WithdrawScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Transfer'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransferScreen()),
              );
            },
          ),
          ListTile(
            title: Text('History'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
