import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finper/data/data.dart';
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
            return new _TransactionItem(transactions[index]);
          },
          itemCount: transactions.length,
        );
      }
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction _transaction;
  _TransactionItem(this._transaction);

  @override
  Widget build(BuildContext context) {
    final nF = new NumberFormat.currency(symbol: '\$',);
    final dF = new DateFormat("yyyy-MM-dd '@' HH:mm");
    return new Container(
      child: new Text(
        '${_transaction.vendor}: ${nF.format(_transaction.amount)}\n'
        '${_transaction.category}->${_transaction.subcategory}\n'
        '${dF.format(_transaction.dt)}\n'
        '${_transaction.account}'
      ),
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
    );
  }
}
