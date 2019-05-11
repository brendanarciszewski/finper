import 'package:finper/data/data.dart';
import 'package:flutter/material.dart';
import 'views/create_transaction.dart';
import 'views/accounts_list.dart';
import 'views/transactions_list.dart';
import 'views/add_account.dart';
import 'views/data_import.dart';

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

  @override
  Widget build(BuildContext context) {
    final _children = <List<Widget>>[
      [new CreateTransactionForm(), null],
      [new TransactionsList(), null],
      [new AccountsList(), FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.orangeAccent,
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
      )],
    ];

    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Fin(ancial) Per(sistence)'),
      ),
      body: _children[_currentIndex][0],
      floatingActionButton: _children[_currentIndex][1],
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
      drawer: new Drawer(
        child: new ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              child: const Text('Extra Options'),
              decoration: const BoxDecoration(
                color: Colors.orangeAccent,
              ),
            ),
            new ListTile(
              title: const Text('Export Data'),
              onTap: () {
                Navigator.pop(context);
                shareDatabase();
              },
            ),
            new ListTile(
              title: const Text('Import Data'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (BuildContext context) {
                      return new Scaffold(
                        appBar: new AppBar(
                          title: const Text('Import'),
                        ),
                        body: new DataImportView(),
                      );
                    }
                  )
                );
              },
            ),
            new ListTile(
              title: const Text('Open Source Software Licenses'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) {
                          return new Scaffold(
                            appBar: new AppBar(
                              title: const Text('Licenses'),
                            ),
                            body: new ListView(
                              children: <Widget>[
                                const Text("""
                                  sqflite
                                """),
                                const Text("""
                                  path_provider
                                """),
                                const Text("""
                                  path
                                """),
                                const Text("""
                                  csv
                                """),
                                const Text("""
                                  esys_flutter_share
                                """),
                                const Text("""
                                  file_picker
                                """),
                              ],
                            ),
                          );
                        }
                    )
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
