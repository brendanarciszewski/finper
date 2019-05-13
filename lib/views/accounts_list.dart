/*
 * File: accounts_list.dart in finper
 * Copyright 2019 Brendan Arciszewski
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
          return const Center(child: Text('Create an Account'),);
        return new ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            if (index >= accounts.length)
              return const ListTile();
            return new _AccountItem(accounts[index]);
          },
          itemCount: accounts.length + 1,
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
    return new ListTile(
      title: new Text('${_account.name}'),
      trailing: new Text('${f.format(_account.amount)}'),
    );
  }
}
