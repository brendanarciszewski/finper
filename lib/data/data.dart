import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import 'db.dart';

mixin HasTable {
  Table get _table;
  dynamic get _primaryKey;
  Map<String, dynamic> toJson();

  Future<int> addToDB() async {
    return _table.newRowWith(await dbProvider.database, this.toJson());
  }

  Future<int> rmFromDB() async {
    var db = await dbProvider.database;
    return db.delete(_table.tableName,
        where: "${_table.params[0].name} = ?",
        whereArgs: [_primaryKey]);
  }
}

class Category with HasTable {
  int id;
  String name;
  List<Category> subcategories;
  static final __table = categoriesV1;

  String get _primaryKey => name;
  Table get _table => __table;

  Category(this.id, this.name, this.subcategories);
  Category.subcategory(String name) : this(null, name, []);
  Category.fromStr(this.id, this.name, List<String> subcategories) {
    this.subcategories = subcategories.map(
            (String s) => new Category.subcategory(s)
    ).toList();
  }
  factory Category.fromJson(Map<String, dynamic> map) {
    assert(__table.params.length == 3);
    return Category.fromStr(
        map[__table.params[0].name],
        map[__table.params[1].name],
        List<String>.from(jsonDecode(map[__table.params[2].name]))
    );
  }

  Map<String, dynamic> toJson() => {
    _table.params[0].name : id,
    _table.params[1].name : name,
    _table.params[2].name : jsonEncode(
        subcategories.map((Category c) => c.name).toList()
    )
  };

  static Future<List<Category>> get categories async {
    var res = await (await dbProvider.database).query(__table.tableName);
    var list = res.isNotEmpty
        ? res.map((Map<String, dynamic> map) => Category.fromJson(map)).toList()
        : [];
    return list;
  }

  static final defaultCategories = [
    new Category.fromStr(1, 'Employment/Education', [
      'Regular Pay',
      'Occasional/Bonus/Vacation Pay',
      'Grant',
      'Portfolio/Passive Income',
      'Social Services/Tax Payment/Refund',
      'Tuition',
      'Expense',
      'Other'
    ]),
    new Category.fromStr(2, 'Meals', [
      'Groceries',
      'Fast Food/Convenience',
      'Restaurant',
      'Alcohol',
      'Subscriptions',
      'Other'
    ]),
    new Category.fromStr(3, 'Health/Personal Care',
        ['Fitness/Sports', 'Insurance/Doctor/Pharmacy', 'Other']),
    new Category.fromStr(4,
        'Banking/Investment', ['Fees', 'Loans', 'Interest', 'Other']),
    new Category.fromStr(5, 'Transportation',
        ['Transportation Cost (Gas/Tolls)', 'Parking', 'Maintenance', 'Other']),
    new Category.fromStr(6, 'Pets', ['Meals', 'Health/Care', 'Other']),
    new Category.fromStr(7, 'Shopping', [
      'Clothing',
      'Electronics',
      'Sporting Goods',
      'Gifts',
      'Subscriptions',
      'Travel',
      'Other'
    ]),
    new Category.fromStr(8, 'Entertainment', [
      'Theatre/Cinema/Concert',
      'Physical/Digital Media',
      'Sports',
      'Subscriptions',
      'Other'
    ]),
    new Category.fromStr(9, 'Other Bills', [
      'Phone/Internet',
      'Insurance',
      'Electricity/Gas/Water',
      'Rent/Mortgage/Property Tax',
      'Legal',
      'Charity',
      'Other'
    ]),
  ];
}

class Account with HasTable {
  int id;
  String name;
  double amount;
  static final  __table = accountsV1;

  String get _primaryKey => name;
  Table get _table => __table;

  Account(this.id, this.name, this.amount);
  Account.initial(int id, String name) : this(id, name, 0.0);
  factory Account.fromJson(Map<String, dynamic> map) {
    assert(__table.params.length == 3);
    return Account(
      map[__table.params[0].name],
      map[__table.params[1].name],
      map[__table.params[2].name]
    );
  }

  Map<String, dynamic> toJson() => {
    _table.params[0].name : id,
    _table.params[1].name : name,
    _table.params[2].name : amount
  };

  static Future<List<Account>> get accounts async {
    var res = await (await dbProvider.database).query(__table.tableName);
    var list = res.isNotEmpty
        ? res.map((Map<String, dynamic> map) => Account.fromJson(map)).toList()
        : [];
    return list;
  }
}

class Transaction with HasTable {
  int id;
  double amount;
  String account;
  String vendor;
  DateTime dt;
  String category;
  String subcategory;
  Object receipt;
  int transferId;
  static final __table = transactionsV1;

  int get _primaryKey => id;
  Table get _table => __table;

  Transaction(this.id, this.amount, this.account, this.vendor, this.dt,
      this.category, this.subcategory, [this.receipt, this.transferId]);
  factory Transaction.fromJson(Map<String, dynamic> map) {
    assert(__table.params.length == 9);
    return Transaction(
      map[__table.params[0].name],
      map[__table.params[1].name],
      map[__table.params[2].name],
      map[__table.params[3].name],
      DateTime.parse(map[__table.params[4].name]).toLocal(),
      map[__table.params[5].name],
      map[__table.params[6].name],
      map[__table.params[7].name],
      map[__table.params[8].name]
    );
  }

  Map<String, dynamic> toJson() => {
    _table.params[0].name : id,
    _table.params[1].name : amount,
    _table.params[2].name : account,
    _table.params[3].name : vendor,
    _table.params[4].name : dt.toUtc().toIso8601String(),
    _table.params[5].name : category,
    _table.params[6].name : subcategory,
    _table.params[7].name : receipt,
    _table.params[8].name : transferId
  };

  static Future<List<Transaction>> get transactions async {
    var res = await (await dbProvider.database).query(__table.tableName);
    var list = res.isNotEmpty
        ? res.map((Map<String, dynamic> map) => Transaction.fromJson(map)).toList()
        : [];
    return list;
  }
}
