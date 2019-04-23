import 'package:flutter/material.dart';
import 'data.dart';

class CreateTransactionForm extends StatefulWidget {
  @override
  _CreateTransactionFormState createState() =>
      new _CreateTransactionFormState();
}

class _CreateTransactionFormState extends State<CreateTransactionForm> {
  final _formKey = new GlobalKey<FormState>();
  Category _category;
  Category _subcategory;
  Future<List<Category>> _storedCategoriesFuture;

  @override
  void initState() {
    _storedCategoriesFuture = Category.categories;
    _storedCategoriesFuture.then((List<Category> cs) {
      _category = cs[0];
      _subcategory = cs[0].subcategories[0];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<List<Category>>(
      future: _storedCategoriesFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const Text('none');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return const Text('Waiting');
          case ConnectionState.done:
            if (snapshot.hasError)
              return new Text(snapshot.error);

            final categories = snapshot.data;

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
                    items: listToDropdownList(categories),
                    value: _category,
                    onChanged: (Category category) {
                      setState(() {
                        _category = category;
                        _subcategory = category.subcategories[0];
                      });
                    },
                  ),
                  new DropdownButton<Category>(
                    items: listToDropdownList(_category.subcategories),
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
      },
    );
  }
}

List<DropdownMenuItem<Category>> listToDropdownList(List<Category> categories) {
  return categories
      .map((Category category) => new DropdownMenuItem<Category>(
            value: category,
            child: new Text(category.name),
          ))
      .toList();
}
