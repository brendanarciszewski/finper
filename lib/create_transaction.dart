import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
  Account _account; // TODO implement
  DateTime _dateTime;
  double _amount, _sign = 0.0;
  String _vendor;
  bool _submitted = false;

  Future<List<Category>> _storedCategoriesFuture;

  @override
  void initState() {
    _storedCategoriesFuture = Category.categories;
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
            return new ListView(
              children: <Widget>[
                new Form(
                  key: this._formKey,
                  child: new Column(
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          const Spacer(),
                          const Text('Expense'),
                          const Spacer(),
                          new FormField<SliderTheme>(
                            builder: (FormFieldState<SliderTheme> field) {
                              return new SliderTheme(
                                data: new SliderThemeData(
                                  trackHeight: 5,
                                  activeTrackColor: Colors.green[700],
                                  inactiveTrackColor: Colors.red[600],
                                  disabledActiveTrackColor: Colors.grey,
                                  disabledInactiveTrackColor: Colors.grey,
                                  activeTickMarkColor: Colors.green[700],
                                  inactiveTickMarkColor: Colors.red[600],
                                  disabledActiveTickMarkColor: Colors.grey,
                                  disabledInactiveTickMarkColor: Colors.grey,
                                  thumbColor: Colors.black,
                                  disabledThumbColor: Colors.grey,
                                  overlayColor: Colors.grey,
                                  valueIndicatorColor: Colors.grey,
                                  trackShape: RectangularSliderTrackShape(),
                                  tickMarkShape: RoundSliderTickMarkShape(),
                                  thumbShape: RoundSliderThumbShape(),
                                  overlayShape: RoundSliderOverlayShape(),
                                  valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                                  showValueIndicator: ShowValueIndicator.never,
                                  valueIndicatorTextStyle: TextStyle(),
                                ),
                                child: new Slider(
                                  onChanged: (double value) {
                                    setState(() {
                                      this._sign = value;
                                    });
                                  },
                                  min: -1.0,
                                  max: 1.0,
                                  divisions: 1,
                                  value: this._sign,
                                )
                              );
                            },
                            /*validator: (SliderTheme data) {
                              if (this._sign != 1.0 || this._sign != -1.0)
                                return 'Is this an expense or income?';
                            },*/
                          ),
                          const Spacer(),
                          const Text('Income'),
                          const Spacer(),
                        ]
                      ),
                      new TextFormField(
                        validator: (String value) {
                          if (value.isEmpty) return 'Enter cost!';
                          if (double.tryParse(value) == null) return 'Enter cost!';
                        },
                        onSaved: (String value) {
                          setState(() {
                            this._amount = double.parse(value);
                          });
                        },
                        keyboardType: TextInputType.numberWithOptions(
                            signed: false, decimal: true),
                        decoration: new InputDecoration(
                          icon: new Icon(Icons.attach_money),
                          hintText: 'Enter the Total',
                        ),
                      ),
                      new TextFormField(
                        validator: (String value) {
                          if (value.isEmpty) return 'Enter vendor!';
                        },
                        onSaved: (String value) {
                          setState(() {
                            this._vendor = value;
                          });
                        },
                        keyboardType: TextInputType.text,
                        decoration: new InputDecoration(
                          icon: new Icon(Icons.business),
                          hintText: "Enter the Vendor's Name",
                        ),
                      ),
                      new DropdownButtonFormField<Category>(
                        items: listToDropdownList(snapshot.data),
                        value: this._category,
                        onChanged: (Category category) {
                          setState(() {
                            this._category = category;
                            this._subcategory = null;
                          });
                        },
                        validator: (Category category) {
                          if (category == null) return 'Choose a Category';
                        },
                        decoration: new InputDecoration(
                          icon: new Icon(Icons.category),
                          hintText: "Choose a Category",
                        ),
                      ),
                      new DropdownButtonFormField<Category>(
                        items: listToDropdownList(this._category != null
                            ? this._category.subcategories
                            : []),
                        value: this._subcategory,
                        onChanged: (Category subcategory) {
                          setState(() {
                            this._subcategory = subcategory;
                          });
                        },
                        validator: (Category category) {
                          if (category == null) return 'Choose a Subcategory';
                        },
                        decoration: new InputDecoration(
                          icon: new Icon(Icons.category),
                          hintText: "Choose a Subcategory",
                        ),
                      ),
                      new FormField<RaisedButton>(
                        builder: (FormFieldState<RaisedButton> field) {
                          return new RaisedButton(
                            child: Text('${ this._dateTime != null
                                ? new DateFormat("yyyy-MM-dd '@' HH:mm")
                                .format(this._dateTime)
                                : 'Pick Date'}'),
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
                              setState(() {
                                this._dateTime = DateTime(date.year, date.month,
                                    date.day, time.hour, time.minute);
                              });
                            },
                          );
                        },
                        /*validator: (RaisedButton val) {
                          if (this._dateTime == null) return 'Pick Date & Time!';
                        },*/
                      ),
                      new RaisedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              _submitted = true;
                            });
                            Scaffold
                                .of(context)
                                .showSnackBar(
                                SnackBar(content: Text('Processing Data')));
                          }
                        },
                        child: new Text('Submit $_submitted'),
                      ),
                    ],
                  ),
                ),
              ],
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
