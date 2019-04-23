import 'package:flutter/material.dart';
import 'create_transaction.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Welcome to Flutter',
      theme: new ThemeData(
        primaryColor: Colors.blue,
      ),
      home: new HomePage(),
    );
  }
}

class _HomePageState extends State<HomePage> {
  var _currentIndex = 0;
  final _children = <Widget>[
    new CreateTransactionForm(),
    new PlaceholderWidget(Colors.green),
  ];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Fin(ancial) Per(sistence)'),
        actions: <Widget>[
          new IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {},
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
            icon: const Icon(Icons.toc),
            title: const Text('List'),
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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class PlaceholderWidget extends StatelessWidget {
  final Color color;

  PlaceholderWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: color,
    );
  }
}
