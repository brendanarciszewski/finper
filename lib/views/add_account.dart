import 'package:flutter/material.dart';
import 'package:finper/data/data.dart';

class CreateTransactionForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      new _CreateTransactionFormState();
}

class _CreateTransactionFormState extends State<CreateTransactionForm> {
  final _formKey = new GlobalKey<FormState>();

  double _amount;
  double _sign = 1.0;
  String _name;

  @override
  Widget build(BuildContext context) {
    return new ListView(
      children: <Widget>[
        new Form(
          key: this._formKey,
          child: new Column(
            children: _visibleWidgets(),
          ),
        ),
      ],
    );
  }

  List<Widget> _visibleWidgets() {
    return <Widget>[
      new Row(
          children: <Widget>[
            const Spacer(),
            const Text('Negative'),
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
            const Text('Positive'),
            const Spacer(),
          ]
      ),
      new TextFormField(
        validator: (String value) {
          if (value.isEmpty) return 'Enter cost!';
          if (double.tryParse(value) == null) return 'Enter cost!';
        },
        onSaved: (String value) {
          this._amount = double.parse(value);
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
          if (value.isEmpty) return 'Enter account!';
        },
        onSaved: (String value) {
          this._name = value;
        },
        keyboardType: TextInputType.text,
        decoration: new InputDecoration(
          icon: new Icon(Icons.business),
          hintText: "Enter the Account Name",
        ),
      ),
      new RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();

            Account.getNextId().then((int id) async {
              final account = Account(id, _name, _amount*_sign);
              await account.addToDb();
            });

            Scaffold
                .of(context)
                .showSnackBar(
                SnackBar(content: Text('Processing Data')));
          }
        },
        child: new Text('Add Account'),
      ),
    ];
  }
}