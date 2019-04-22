import 'package:flutter/material.dart';

class CreateTransactionForm extends StatefulWidget {
  @override
  CreateTransactionFormState createState() => new CreateTransactionFormState();
}

class CreateTransactionFormState extends State<CreateTransactionForm> {
  final _formKey = new GlobalKey<FormState>();
  var _category = categories[0];
  Category _subcategory;

  @override
  Widget build(BuildContext context) {
    return new Form(
      key: _formKey,
      child: new Column(
        children: <Widget>[
          new TextFormField(
            validator: (value) {
              if (value.isEmpty) return 'Enter store!';
            },
          ),
          new DropdownButton<Category>(
            items: categories.map(categoryToDropdownMenuItem).toList(),
            value: _category,
            onChanged: (Category category) {
              setState(() {
                _category = category;
                _subcategory = _category != categories[0]
                    ? category.subcategories[0]
                    : null;
              });
            },
          ),
          new DropdownButton<Category>(
            items: _category.subcategories
                .map(categoryToDropdownMenuItem)
                .toList(),
            value: _subcategory,
            onChanged: (Category subcategory) {
              setState(() {
                _subcategory = subcategory;
              });
            },
          ),
        ],
      ),
    );
  }
}

class Category {
  String name;
  List<Category> subcategories;

  Category(this.name, this.subcategories);
  Category.subcategory(String name) : this(name, []);
  Category.all(String category, List<String> subcategories) {
    this.name = category;
    this.subcategories = [new Category.subcategory('Choose a subcategory')];
    this
        .subcategories
        .addAll(subcategories.map((String s) => new Category.subcategory(s)));
  }
}

DropdownMenuItem<Category> categoryToDropdownMenuItem(Category category) =>
    new DropdownMenuItem<Category>(
      value: category,
      child: new Text(category.name),
    );

List<Category> categories = [
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
