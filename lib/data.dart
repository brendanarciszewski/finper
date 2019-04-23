import 'dart:convert';
import 'db.dart';


class Category {
  String name;
  List<Category> subcategories;

  Category(this.name, this.subcategories);

  Category.subcategory(String name) : this(name, []);

  Category.all(String category, List<String> subcategories) {
    this.name = category;
    this.subcategories = subcategories.map(
            (String s) => new Category.subcategory(s)
    ).toList();
  }

  factory Category.fromJson(Map<String, dynamic> map) {
    return Category.all(
        map[categoriesV1.params[0].name],
        List<String>.from(jsonDecode(map[categoriesV1.params[1].name]))
    );
  }

  Map<String, String> toJson() =>
      {
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
    new Category.all('Employment/Education', [
      'Regular Pay',
      'Occasional/Bonus/Vacation Pay',
      'Grant',
      'Portfolio/Passive Income',
      'Social Services/Tax Payment/Refund',
      'Tuition',
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