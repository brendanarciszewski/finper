import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' as f;
import 'data.dart';

final dbProvider = new _DBProvider();
final accountsV1 = new _AccountsTable.v1();
final categoriesV1 = new _CategoriesTable.v1();
final transactionsV1 = new _TransactionsTable.v1();

class _DBProvider {
  _DBProvider();
  static Database _database;
  final tables = <_Table>[
    accountsV1,
    categoriesV1,
    transactionsV1
  ];

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _getDB();
    return _database;
  }

  Future<Database> _getDB() async {
    var documentsDir = await pp.getApplicationDocumentsDirectory();
    // TODO remove print
    f.debugPrint(documentsDir.path);
    var path = p.join(documentsDir.path, "finper.db");
    return await openDatabase(path, version: 1,
      //onConfigure: (Database db) async {},
      onCreate: (Database db, int version) async {
        for (var table in tables) {
          final query = "CREATE TABLE ${table.tableName} ("
              "${table.paramsAsStr()}"
              ")";
          // TODO remove print
          f.debugPrint(query);
          await db.execute(query);
        }

        for (var category in Category.defaultCategories) {
          await categoriesV1.newRowWith(db, category.toJson());
        }
      },
      //onUpgrade: (Database db, int oldVersion, int newVersion) async {},
      //onDowngrade: (Database db, int oldVersion, int newVersion) async {},
      //onOpen: (Database db) async {}
    );
  }
}

mixin _Table {
  List<Param> get params;
  String get tableName;

  String paramsAsStr() {
    return params.map((Param p) => p.asStr()).join(',');
  }

  Future<int> newRowWith(Database db, Map<String, dynamic> serializedObj) async {
    return await db.insert(tableName, serializedObj);
  }
}

class _AccountsTable with _Table {
  _AccountsTable.v1() : tableName = 'Accounts_v1',
        params = [
          Param('name', SQLTypes.TEXT, isPrimary: true),
          Param('amount', SQLTypes.INTEGER)
        ];
  final tableName;
  final params;
}

class _CategoriesTable with _Table {
  _CategoriesTable.v1() : tableName = 'Categories_v1',
        params = [
          Param('category', SQLTypes.TEXT, isPrimary: true),
          Param('subcategories', SQLTypes.TEXT)
        ];
  final tableName;
  final params;
}

class _TransactionsTable with _Table {
  _TransactionsTable.v1() : tableName = 'Transactions_v1',
        params = [
          Param('id', SQLTypes.INTEGER, isPrimary: true),
          Param('amount', SQLTypes.INTEGER),
          Param('category', SQLTypes.TEXT),
          Param('subcategory', SQLTypes.TEXT),
          Param('account', SQLTypes.TEXT),
          Param('transferId', SQLTypes.INTEGER, isNullable: true)
        ];
  final tableName;
  final params;
}

class Param {
  final String name;
  final bool isNullable;
  final bool isPrimary;
  final SQLTypes type;
  Param(this.name, this.type, {this.isNullable=false, this.isPrimary=false});

  String get typeAsStr {
    switch (type) {
      case SQLTypes.INTEGER: return 'INTEGER';
      case SQLTypes.REAL: return 'REAL';
      case SQLTypes.TEXT: return 'TEXT';
      case SQLTypes.BLOB: return 'BLOB';
    }
  }

  String get notNullStr {
    return isNullable ? '' : 'NOT NULL';
  }

  String get primaryStr {
    return isPrimary ? 'PRIMARY KEY' : '';
  }

  String asStr() {
    return '$name $typeAsStr $primaryStr $notNullStr';
  }
}

enum SQLTypes {
  INTEGER, REAL, TEXT, BLOB
}
