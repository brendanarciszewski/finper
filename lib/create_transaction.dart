import 'package:flutter/material.dart';
import 'data/data.dart';

class CreateTransactionForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      new _CreateTransactionFormState();
}

class _CreateTransactionFormState extends State<CreateTransactionForm> {
  final _formKey = new GlobalKey<FormState>();
  Category _category;
  Category _subcategory;
  DateTime _time;
  Future<List<Category>> _storedCategoriesFuture;

  @override
  void initState() {
    _storedCategoriesFuture = Category.categories;
    _storedCategoriesFuture.then((List<Category> cs) {
      /*this._category = cs[0];
      this._subcategory = cs[0].subcategories[0];*/
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<List<Category>>(
      future: this._storedCategoriesFuture,
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
              key: this._formKey,
              child: new Column(
                children: <Widget>[
                  new TextFormField(
                    validator: (value) {
                      if (value.isEmpty) return 'Enter cost!';
                    },
                    keyboardType: TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    decoration: new InputDecoration(
                      icon: new Icon(Icons.attach_money),
                      hintText: 'Enter the Total',
                    ),
                  ),
                  new DropdownButton<Category>(
                    items: listToDropdownList(categories),
                    value: this._category,
                    hint: const Text('Choose a Category'),
                    onChanged: (Category category) {
                      setState(() {
                        this._category = category;
                        this._subcategory = null;
                      });
                    },
                  ),
                  new DropdownButton<Category>(
                    items: listToDropdownList(this._category != null
                        ? this._category.subcategories
                        : []),
                    value: this._subcategory,
                    hint: const Text('Choose a Subcategory'),
                    onChanged: (Category subcategory) {
                      setState(() {
                        this._subcategory = subcategory;
                      });
                    },
                  ),
                  new RaisedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1970),
                          initialDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 367)),
                      );
                      final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now()
                      );
                      _time = DateTime(date.year, date.month, date.day,
                          time.hour, time.minute);
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
