import 'package:flutter/material.dart';

class CreateTransactionForm extends StatefulWidget {
  @override
  CreateTransactionFormState createState() => new CreateTransactionFormState();
}

class CreateTransactionFormState extends State<CreateTransactionForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return new Form(
      key: _formKey,
      child: TextFormField(
        validator: (value) {
          if (value.isEmpty) return 'Enter text!';
        },
      ),
    );
  }
}