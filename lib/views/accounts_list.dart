import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finper/data/data.dart';
import 'package:finper/generic_widgets/default_future_builder.dart';

class AccountsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AccountsListState();
}

class _AccountsListState extends State<AccountsList> {
  Future<List<Account>> _accountsFuture;

  @override
  void initState() {
    _accountsFuture = Account.accounts;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultFutureBuilder<List<Account>>(
      this._accountsFuture,
      (BuildContext context, List<Account> accounts) {
        if (accounts.length == 0)
          return Center(child: Text('Create an Account'),);
        return new ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return new _AccountItem(accounts[index]);
          },
          itemCount: accounts.length,
        );
      }
    );
  }
}

class _AccountItem extends StatelessWidget {
  final Account _account;
  _AccountItem(this._account);

  @override
  Widget build(BuildContext context) {
    final f = new NumberFormat.currency(symbol: '\$',);
    return new Container(
      child: new Text('${_account.name}: ${f.format(_account.amount)}'),
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
    );
  }
}
