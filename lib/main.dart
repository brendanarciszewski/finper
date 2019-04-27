import 'package:flutter/material.dart';
import 'views/create_transaction.dart';
import 'views/accounts_list.dart';
import 'views/transactions_list.dart';
import 'views/add_account.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Welcome to Flutter',
      theme: new ThemeData(
        primaryColor: Colors.orange[600],
      ),
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _currentIndex = 0;
  final _children = <Widget>[
    new CreateTransactionForm(),
    new TransactionsList(),
    new AccountsList(),
  ];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Fin(ancial) Per(sistence)'),
        actions: <Widget>[
          new IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (BuildContext context) {
                    return new Scaffold(
                      appBar: new AppBar(
                        title: const Text('Create an Account'),
                      ),
                      body: new AddAccountForm(),
                    );
                  }
                )
              );
            },
          ),
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: new BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          const BottomNavigationBarItem(
            icon: const Icon(Icons.create),
            title: const Text('Create'),
          ),
          const BottomNavigationBarItem(
            icon: const Icon(Icons.view_stream),
            title: const Text('Transactions'),
          ),
          const BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance),
            title: const Text('Accounts'),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
