import 'package:flutter/material.dart';

typedef SuccessStateBuilder<T> = Widget Function(BuildContext, T);

class DefaultFutureBuilder<T> extends StatelessWidget {
  final Future<T> _future;
  final SuccessStateBuilder<T> _builder;
  DefaultFutureBuilder(this._future, this._builder);

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<T>(
      future: this._future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const Text('none');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return const Text('Waiting');
          case ConnectionState.done:
            if (snapshot.hasError)
              return new Text(snapshot.error);
            return this._builder(context, snapshot.data);
        }
      },
    );
  }
}