import 'package:flutter/material.dart';
import 'data.dart';

List<Category> categories = Category.defaultCategories;

class CreateTransactionForm extends StatefulWidget {
  @override
  _CreateTransactionFormState createState() =>
      new _CreateTransactionFormState();
}

class _CreateTransactionFormState extends State<CreateTransactionForm> {
  final _formKey = new GlobalKey<FormState>();
  var _category = categories[0];
  var _subcategory = categories[0].subcategories[0];

  @override
  Widget build(BuildContext context) {
    var a = Category.categories;
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
                _subcategory = category.subcategories[0];
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

DropdownMenuItem<Category> categoryToDropdownMenuItem(Category category) =>
    new DropdownMenuItem<Category>(
      value: category,
      child: new Text(category.name),
    );
