import 'dart:convert';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:file_picker/file_picker.dart';
import 'db.dart';

final disallowedStrs = ["null"];

mixin Named {
  String get name;
}

mixin HasTable {
  Table get _table;
  int get id;
  set _id(int newId);
  Map<String, dynamic> toJson();

  Future<int> nextId() async {
    var db = await dbProvider.db;
    final colName = 'MAX(${Param.id().name})';
    final curIdResp = await db.query(_table.tableName, columns: [colName]);
    return (curIdResp[0][colName] ?? 0) + 1;
  }

  Future<void> addToDb() async {
    var newId = _table.newRowWith(await dbProvider.db, this.toJson());
    this._id = await newId;
  }

  Future<int> rmFromDb() async {
    var db = await dbProvider.db;
    return db.delete(_table.tableName,
        where: "${Param.id().name} = ?", whereArgs: [id]);
  }

  Future<int> updateInDb() async {
    var db = await dbProvider.db;
    return db.update(_table.tableName, this.toJson(),
        where: "${Param.id().name} = ?", whereArgs: [this.id]);
  }

  Future<void> shareData() async {
    String csv = await _table.export();
    await Share.file(_table.tableName, '${_table.tableName}.csv', utf8.encode(csv), 'text/csv');
  }

  Future<void> importData() async {
    String filePath = await FilePicker.getFilePath(
      //type: FileType.CUSTOM,
      //fileExtension: 'csv'
    );
    if (filePath != null) {
      Map<String, double> accounts = {};
      await _table.import(filePath, (List<dynamic> row) {
        accounts.putIfAbsent(row[2], () => 0.0);
        accounts[row[2]] += row[1];
      });

      await (await dbProvider.db).transaction((txn) {
        txn.execute("DROP TABLE IF EXISTS ${Account.table.tableName};");
        txn.execute(Account.table.sqlCreateStr());
        for (var entry in accounts.entries) {
          Account.table.newRowWith(txn, Account(entry.key, entry.value).toJson());
        }
      });
    }
  }
}

Future<void> shareDatabase() async {
  Map<String, List<int>> files = {};

  await Future.wait(dbProvider.tables.map((Table t) async {
    files['${t.tableName}.csv'] = utf8.encode(await t.export());
  }));

  Share.files('Database', files, 'text/csv');
}

class Category with HasTable, Named {
  int _id;
  int get id => _id;
  final String name;

  List<Category> subcategories;
  static final table = categoriesV1;

  Table get _table => table;

  Category(String name, List<String> subcategories) :
        this._(null, name, subcategories);
  Category.subcategory(String name) : this(name, []);
  Category._(this._id, this.name, List<String> subcategories) {
    this.subcategories =
        subcategories.map((String s) => new Category.subcategory(s)).toList();
  }
  Category._ofNull() : this._(0, null, null);
  factory Category.fromJson(Map<String, dynamic> map) {
    assert(table.params.length == 3);
    return Category._(
        map[table.params[0].name],
        map[table.params[1].name],
        List<String>.from(jsonDecode(map[table.params[2].name])));
  }

  Map<String, dynamic> toJson() => {
        _table.params[0].name: _id,
        _table.params[1].name: name,
        _table.params[2].name:
            jsonEncode(subcategories.map((Category c) => c.name).toList())
      };

  static Future<int> getNextId() => Category._ofNull().nextId();

  static Future<List<Category>> get categories async {
    final res = await (await dbProvider.db).query(table.tableName);
    List<Category> list = res.isNotEmpty
        ? res.map((Map<String, dynamic> map) => Category.fromJson(map)).toList()
        : [];
    return list;
  }

  static final defaultCategories = [
    new Category('Employment/Education', [
      'Regular Income',
      'Occasional Income',
      'Grant/Bursary',
      'Tax Payment/Refund',
      'Tuition/Books',
      'Expense',
      'Other'
    ]),
    new Category('Meals', [
      'Groceries',
      'Fast Food/Convenience',
      'Restaurant',
      'Alcohol',
      'Subscriptions',
      'Other'
    ]),
    new Category('Health/Personal Care',
        ['Fitness/Sports', 'Insurance/Doctor/Pharmacy', 'Other']),
    new Category('Banking/Investment',
        ['Fees', 'Loans', 'Portfolio/Passive Income', 'Other']),
    new Category('Transportation', [
      'Public Transit',
      'Gas',
      'Tolls',
      'Parking',
      'Insurance',
      'Maintenance',
      'Other'
    ]),
    new Category('Pets', ['Meals', 'Health/Care', 'Other']),
    new Category('Shopping', [
      'Clothing',
      'Electronics',
      'Sporting Goods',
      'Gifts',
      'Subscriptions',
      'Travel',
      'Other'
    ]),
    new Category('Entertainment', [
      'Theatre/Cinema/Concert',
      'Physical/Digital Media',
      'Sports',
      'Subscriptions',
      'Other'
    ]),
    new Category('Home', [
      'Phone/Internet',
      'Insurance',
      'Electricity/Gas/Water',
      'Rent/Mortgage/Property Tax',
      'Other'
    ]),
    new Category('Other', [
      'Legal',
      'Charity',
      'Credit',
      'Transfer',
      'Other'
    ]),
  ];
}

class Account with HasTable, Named {
  int _id;
  int get id => _id;
  String name;
  double amount;
  static final table = accountsV1;

  Table get _table => table;

  Account._(this._id, this.name, this.amount);
  Account(String name, double amount) : this._(null, name, amount);
  Account._ofNull() : this._(0, null, null);
  factory Account.fromJson(Map<String, dynamic> map) {
    assert(table.params.length == 3);
    return Account._(
        map[table.params[0].name],
        map[table.params[1].name],
        map[table.params[2].name]
    );
  }

  Map<String, dynamic> toJson() => {
        _table.params[0].name: _id,
        _table.params[1].name: name,
        _table.params[2].name: amount
      };

  static Future<List<Account>> get accounts async {
    final res = await (await dbProvider.db).query(table.tableName);
    List<Account> list = res.isNotEmpty
        ? res.map((Map<String, dynamic> map) => Account.fromJson(map)).toList()
        : [];
    return list;
  }

  static Future<int> getNextId() => Account._ofNull().nextId();
}

class Transaction with HasTable {
  int get id => _id;
  int _id;
  double amount;
  String account;
  String vendor;
  DateTime dt;
  String category;
  String subcategory;
  /*List<int>*/ Object receipt;
  int transferId;
  static final table = transactionsV1;

  Table get _table => table;

  Transaction._(this._id, this.amount, this.account, this.vendor, this.dt,
      this.category, this.subcategory, [this.receipt, this.transferId]);
  Transaction(this.amount, this.account, this.vendor, this.dt,
      this.category, this.subcategory, [this.receipt, this.transferId]);
  Transaction._ofNull() : this._(0, null, null, null, null, null, null);
  Transaction.transferFrom(this.amount, this.account, Transaction t) {
    this._id = null;
    this.vendor = t.vendor;
    this.dt = t.dt;
    this.category = t.category;
    this.subcategory = t.subcategory;
    this.receipt = t.receipt;
    this.transferId = t._id;
  }
  factory Transaction.fromJson(Map<String, dynamic> map) {
    assert(table.params.length == 9);
    return Transaction._(
        map[table.params[0].name],
        map[table.params[1].name],
        map[table.params[2].name],
        map[table.params[3].name],
        DateTime.parse(map[table.params[4].name]).toLocal(),
        map[table.params[5].name],
        map[table.params[6].name],
        /*json.decode(*/map[table.params[7].name]/*)*/,
        map[table.params[8].name]);
  }

  static Future<int> getNextId() => Transaction._ofNull().nextId();
  static Future<void> import() => Transaction._ofNull().importData();

  bool isExpense() => amount < 0;
  bool isIncome() => amount > 0;

  Map<String, dynamic> toJson() => {
        _table.params[0].name: id,
        _table.params[1].name: amount,
        _table.params[2].name: account,
        _table.params[3].name: vendor,
        _table.params[4].name: dt.toUtc().toIso8601String(),
        _table.params[5].name: category,
        _table.params[6].name: subcategory,
        _table.params[7].name: /*json.encode(*/receipt/*)*/,
        _table.params[8].name: transferId
      };

  static Future<List<Transaction>> withId(int id) async {
    final res = await (await dbProvider.db).query(table.tableName,
        where: '${Param.id().name} = ?',
        whereArgs: [id],);
    return res.isNotEmpty
        ? res.map((Map<String, dynamic> map) => Transaction.fromJson(map))
        : <Transaction>[];
  }

  static Future<List<Transaction>> get transactions async {
    final res = await (await dbProvider.db).query(table.tableName,
        orderBy: "${table.params[4].name} DESC");
    List<Transaction> list = res.isNotEmpty
        ? res.map((Map<String, dynamic> map) => Transaction.fromJson(map))
             .toList()
        : [];
    return list;
  }
}
