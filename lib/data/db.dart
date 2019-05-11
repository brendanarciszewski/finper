import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' as f;
import 'package:csv/csv.dart' as c;
import 'dart:io';
import 'dart:convert';
import 'data.dart';

final dbProvider = new _DBProvider();
final accountsV1 = new _AccountsTable.v1();
final categoriesV1 = new _CategoriesTable.v1();
final transactionsV1 = new _TransactionsTable.v1();

class _DBProvider {
  _DBProvider();
  static Database _database;
  final tables = <Table>[
    accountsV1,
    categoriesV1,
    transactionsV1
  ];

  Future<Database> get db async {
    if (_database != null) return _database;
    _database = await _getDB();
    return _database;
  }

  Future<Database> _getDB() async {
    var documentsDir = await pp.getApplicationDocumentsDirectory();
    // TODO remove print
    f.debugPrint(documentsDir.path);
    var path = p.join(documentsDir.path, "finper.db");
    return openDatabase(path, version: 1,
      //onConfigure: (Database db) async {},
      onCreate: (Database db, int version) async {
        for (var table in tables) {
          await db.execute(table.sqlCreateStr());
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

mixin Table {
  List<Param> get params;
  String get tableName;

  String paramsAsStr() {
    return params.map((Param p) => p.asStr()).join(',');
  }

  String sqlCreateStr() => "CREATE TABLE $tableName (${paramsAsStr()});";

  Future<int> newRowWith(DatabaseExecutor db, Map<String, dynamic> serializedObj) {
    return db.insert(tableName, serializedObj);
  }

  Future<String> export() async {
    final db = await dbProvider.db;
    final query = await db.query(tableName);
    List<List<dynamic>> list = [];
    list.add(params.map((Param p) => p.name).toList());
    list.addAll(query.map((Map<String, dynamic> map) {
      return map.values.toList();
    }));
    return c.ListToCsvConverter().convert(list);
  }

  Future<void> import(String csvPath, [void callback(List<dynamic> l)]) async {
    final db = await dbProvider.db;
    await db.transaction((txn) async {
      await txn.execute("DROP TABLE IF EXISTS $tableName;");
      await txn.execute(sqlCreateStr());
      final fileStream = new File(csvPath).openRead();
      List<List<dynamic>> csv = await fileStream.transform(utf8.decoder)
          .transform(c.CsvToListConverter()).toList();

      for (List<dynamic> row in csv.skip(1)) {
        if (callback != null) callback(row);
        final query = "INSERT INTO $tableName VALUES(${row.map((i) {
          if (i == "null")
            return null;
          else if (i.runtimeType == String)
            return '"$i"';
          return i;
        }).join(',')});";
        await txn.execute(query);
      }
    });
  }
}

class _AccountsTable with Table {
  _AccountsTable.v1() : tableName = 'Accounts_v1',
        params = [
          Param.id(),
          Param('name', SQLTypes.TEXT, isUnique: true),
          Param('amount', SQLTypes.REAL),
        ];
  final tableName;
  final params;
}

class _CategoriesTable with Table {
  _CategoriesTable.v1() : tableName = 'Categories_v1',
        params = [
          Param.id(),
          Param('category', SQLTypes.TEXT, isUnique: true),
          Param('subcategories', SQLTypes.TEXT)
        ];
  final tableName;
  final params;
}

class _TransactionsTable with Table {
  _TransactionsTable.v1() : tableName = 'Transactions_v1',
        params = [
          Param.id(),
          Param('amount', SQLTypes.REAL),
          Param('account', SQLTypes.TEXT),
          Param('vendor', SQLTypes.TEXT),
          Param('datetime_ISO8601', SQLTypes.TEXT),
          Param('category', SQLTypes.TEXT),
          Param('subcategory', SQLTypes.TEXT),
          Param('receipt', SQLTypes.BLOB, isNullable: true),
          Param('transferId', SQLTypes.INTEGER, isNullable: true)
        ];
  final tableName;
  final params;
}

class Param {
  final String name;
  final bool isNullable;
  final bool isPrimary;
  final bool isUnique;
  final SQLTypes type;

  Param(this.name, this.type, {this.isNullable=false, this.isPrimary=false,
    this.isUnique=false});
  Param.id() : this('id', SQLTypes.INTEGER, isPrimary: true);

  String get typeAsStr {
    switch (type) {
      case SQLTypes.INTEGER: return 'INTEGER';
      case SQLTypes.REAL: return 'REAL';
      case SQLTypes.TEXT: return 'TEXT';
      case SQLTypes.BLOB: return 'BLOB';
    }
    return null; // Not possible to reach, but suppresses warning
  }

  String get notNullStr => isNullable ? '' : 'NOT NULL';

  String get primaryStr => isPrimary ? 'PRIMARY KEY' : '';

  String get uniqueStr => isUnique ? 'UNIQUE' : '';

  String asStr() => '$name $typeAsStr $primaryStr $uniqueStr $notNullStr';
}

enum SQLTypes {
  INTEGER, REAL, TEXT, BLOB
}
