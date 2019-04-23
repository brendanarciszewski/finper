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

DropdownMenuItem<Category> categoryToDropdownMenuItem(Category category) =>
    new DropdownMenuItem<Category>(
      value: category,
      child: new Text(category.name),
    );
