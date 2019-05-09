import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finper/data/data.dart';
import 'package:finper/generic_widgets/default_future_builder.dart';

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

        var seenIds = <int>[];
        return new ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            final temp = transactions[index];
            if (seenIds.contains(temp.id))
              return const SizedBox.shrink();

            seenIds.add(temp.id);
            if (temp.transferId != null) {
              seenIds.add(temp.transferId);
              Transaction from, to;
              if (temp.amount.isNegative) {
                from = temp;
                to = transactions.singleWhere(
                        (Transaction t) => t.transferId == temp.id);
              } else {
                to = temp;
                from = transactions.singleWhere(
                        (Transaction t) => t.transferId == temp.id);
              }
              return new _TransactionTransferItem(from, to);
            }
            return new _TransactionItem(temp);
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
    final dir = _transaction.isExpense() ? '<-' : '->';
    return new ListTile(
      isThreeLine: true,
      trailing: new Text('${nF.format(_transaction.amount)}'),
      title: new Text('${_transaction.vendor}$dir${_transaction.account}'),
      subtitle: new Text(
        '${dF.format(_transaction.dt)}\n'
        '${_transaction.category}->${_transaction.subcategory}'
      ),
    );
  }
}

class _TransactionTransferItem extends StatelessWidget {
  final Transaction _transactionFrom, _transactionTo;
  _TransactionTransferItem(this._transactionFrom, this._transactionTo);

  @override
  Widget build(BuildContext context) {
    final nF = new NumberFormat.currency(symbol: '\$',);
    final dF = new DateFormat("yyyy-MM-dd '@' HH:mm");
    return new ListTileTheme(
      child: new ListTile(
        isThreeLine: true,
        trailing: new Text('${nF.format(_transactionTo.amount)}'),
        title: new Text('Transfer: ${_transactionFrom.account}->${_transactionTo.account}'),
        subtitle: new Text(
          '${dF.format(_transactionFrom.dt)}\n'
          '${_transactionFrom.category}->${_transactionFrom.subcategory}'
        ),
      ),
      textColor: Colors.grey,
    );
  }
}
