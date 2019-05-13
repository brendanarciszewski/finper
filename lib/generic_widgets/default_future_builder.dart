/*
 * File: default_future_builder.dart in finper
 * Copyright 2019 Brendan Arciszewski
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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