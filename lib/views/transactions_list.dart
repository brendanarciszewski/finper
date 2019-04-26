import 'package:flutter/material.dart';
import '../data/data.dart';
import 'package:finper/widgets/default_future_builder.dart';

class TransactionsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  Future<List<Transaction>> _transactionsFuture;

  @override
  void initState() {
    _transactionsFuture = Transaction.transactions;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultFutureBuilder<List<Transaction>>(
      this._transactionsFuture,
      (BuildContext context, List<Transaction> transactions) {
        if (transactions.length == 0)
          return Center(child: Text('Create a Transaction'),);
        return new ListView.builder(
          itemBuilder: (BuildContext context, int index) {

          },
          itemCount: transactions.length,
        );
      }
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Account _transaction;
  _TransactionItem(this._transaction);

  @override
  Widget build(BuildContext context) {
    return new Text('TODO');
  }
}
