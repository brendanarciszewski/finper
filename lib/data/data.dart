import 'dart:convert';
import 'db.dart';

class Category {
  String name;
  List<Category> subcategories;

  Category(this.name, this.subcategories);
  Category.subcategory(String name) : this(name, []);
  Category.fromStr(this.name, List<String> subcategories) {
    this.subcategories = subcategories.map(
            (String s) => new Category.subcategory(s)
    ).toList();
  }
  factory Category.fromJson(Map<String, dynamic> map) {
    assert(categoriesV1.params.length == 2);
    return Category.fromStr(
        map[categoriesV1.params[0].name],
        List<String>.from(jsonDecode(map[categoriesV1.params[1].name]))
    );
  }

  Map<String, String> toJson() => {
    categoriesV1.params[0].name : name,
    categoriesV1.params[1].name : jsonEncode(
        subcategories.map((Category c) => c.name).toList()
    )
  };

  static Future<List<Category>> get categories async {
    var res = await (await dbProvider.database).query(categoriesV1.tableName);
    var list = res.isNotEmpty
        ? res.map((Map<String, dynamic> map) => Category.fromJson(map)).toList()
        : [];
    return list;
  }

  static final defaultCategories = [
    new Category.fromStr('Employment/Education', [
      'Regular Pay',
      'Occasional/Bonus/Vacation Pay',
      'Grant',
      'Portfolio/Passive Income',
      'Social Services/Tax Payment/Refund',
      'Tuition',
      'Expense',
      'Other'
    ]),
    new Category.fromStr('Meals', [
      'Groceries',
      'Fast Food/Convenience',
      'Restaurant',
      'Alcohol',
      'Subscriptions',
      'Other'
    ]),
    new Category.fromStr('Health/Personal Care',
        ['Fitness/Sports', 'Insurance/Doctor/Pharmacy', 'Other']),
    new Category.fromStr(
        'Banking/Investment', ['Fees', 'Loans', 'Interest', 'Other']),
    new Category.fromStr('Transportation',
        ['Transportation Cost (Gas/Tolls)', 'Parking', 'Maintenance', 'Other']),
    new Category.fromStr('Pets', ['Meals', 'Health/Care', 'Other']),
    new Category.fromStr('Shopping', [
      'Clothing',
      'Electronics',
      'Sporting Goods',
      'Gifts',
      'Subscriptions',
      'Travel',
      'Other'
    ]),
    new Category.fromStr('Entertainment', [
      'Theatre/Cinema/Concert',
      'Physical/Digital Media',
      'Sports',
      'Subscriptions',
      'Other'
    ]),
    new Category.fromStr('Other Bills', [
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

class Account {
  String name;
  double amount;

  Account(this.name, this.amount);
  Account.initial(String name) : this(name, 0.0);
  factory Account.fromJson(Map<String, dynamic> map) {
    assert(accountsV1.params.length == 2);
    return Account(
      map[accountsV1.params[0].name],
      map[accountsV1.params[1].name]
    );
  }

  Map<String, dynamic> toJson() => {
    accountsV1.params[0].name : name,
    accountsV1.params[1].name : amount
  };

  static Future<List<Account>> get accounts async {
    var res = await (await dbProvider.database).query(accountsV1.tableName);
    var list = res.isNotEmpty
        ? res.map((Map<String, dynamic> map) => Account.fromJson(map)).toList()
        : [];
    return list;
  }
}

class Transaction {
  int id;
  double amount;
  String account;
  String vendor;
  String category;
  String subcategory;
  Object receipt;
  int transferId;

  Transaction(this.id, this.amount, this.account, this.vendor, this.category,
      this.subcategory, [this.receipt, this.transferId]);
  factory Transaction.fromJson(Map<String, dynamic> map) {
    assert(transactionsV1.params.length == 8);
    return Transaction(
      map[transactionsV1.params[0].name],
      map[transactionsV1.params[1].name],
      map[transactionsV1.params[2].name],
      map[transactionsV1.params[3].name],
      map[transactionsV1.params[4].name],
      map[transactionsV1.params[5].name],
      map[transactionsV1.params[6].name],
      map[transactionsV1.params[7].name]
    );
  }

  Map<String, dynamic> toJson() => {
    transactionsV1.params[0].name : id,
    transactionsV1.params[1].name : amount,
    transactionsV1.params[2].name : account,
    transactionsV1.params[3].name : vendor,
    transactionsV1.params[4].name : category,
    transactionsV1.params[5].name : subcategory,
    transactionsV1.params[6].name : receipt,
    transactionsV1.params[7].name : transferId
  };

  static Future<List<Transaction>> get transactions async {
    var res = await (await dbProvider.database).query(transactionsV1.tableName);
    var list = res.isNotEmpty
        ? res.map((Map<String, dynamic> map) => Transaction.fromJson(map)).toList()
        : [];
    return list;
  }
}
