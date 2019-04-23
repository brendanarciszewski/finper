import 'dart:convert';
import 'db.dart';


class Category {
  String name;
  List<Category> subcategories;

  Category(this.name, this.subcategories);

  Category.subcategory(String name) : this(name, []);

  Category.all(String category, List<String> subcategories) {
    this.name = category;
    this.subcategories = [new Category.subcategory('Choose a subcategory')];
    this.subcategories
        .addAll(subcategories.map((String s) => new Category.subcategory(s)));
  }

  factory Category.fromJson(Map<String, dynamic> map) {
    return Category.all(
        map[accountsV1.params[0].name],
        jsonDecode(map[accountsV1.params[1].name])
    );
  }

  static Future<List<Category>> get categories async {
    var res = await (await dbProvider.database).query(accountsV1.tableName);
    return res.isNotEmpty
        ? res.map((map) => Category.fromJson(map)).toList()
        : [];
  }

  /*
  static List<Category> get currentStored {
    List<Category> _categories;
    categories.then((lc) {_categories = lc;});
    while (_categories == null) {}
    return _categories;
  }*/

  Map<String, String> toJson() =>
      {
        "${accountsV1.params[0].name}": name,
        "${accountsV1.params[1].name}": jsonEncode(
            subcategories.skip(1).map((Category c) => c.name).toList()
        )
      };

  static final defaultCategories = [
    new Category('Choose a Category', []),
    new Category.all('Income', [
      'Regular Pay',
      'Occasional/Bonus/Vacation Pay',
      'Grant',
      'Portfolio/Passive Income',
      'Social Services/Tax Payment/Refund',
      'Expense',
      'Other'
    ]),
    new Category.all('Meals', [
      'Groceries',
      'Fast Food/Convenience',
      'Restaurant',
      'Alcohol',
      'Subscriptions',
      'Other'
    ]),
    new Category.all('Health/Personal Care',
        ['Fitness/Sports', 'Insurance/Doctor/Pharmacy', 'Other']),
    new Category.all(
        'Banking/Investment', ['Fees', 'Loans', 'Interest', 'Other']),
    new Category.all('Education', ['Tuition', 'Other']),
    new Category.all('Transportation',
        ['Transportation Cost (Gas/Tolls)', 'Parking', 'Maintenance', 'Other']),
    new Category.all('Pets', ['Meals', 'Health/Care', 'Other']),
    new Category.all('Shopping', [
      'Clothing',
      'Electronics',
      'Sporting Goods',
      'Gifts',
      'Subscriptions',
      'Travel',
      'Other'
    ]),
    new Category.all('Entertainment', [
      'Theatre/Cinema/Concert',
      'Physical/Digital Media',
      'Sports',
      'Subscriptions',
      'Other'
    ]),
    new Category.all('Other Bills', [
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