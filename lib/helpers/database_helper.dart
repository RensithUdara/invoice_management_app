import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'item_details.db'),
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE ItemDetails(code TEXT PRIMARY KEY, name TEXT, price REAL, quantity INTEGER, discount INTEGER, total REAL)''',
        );
        await _insertInitialData(db);
      },
      version: 1,
    );
  }

  Future<void> _insertInitialData(Database db) async {
    final items = [
      Item(code: '001', name: 'Item 1', price: 50.00),
      Item(code: '002', name: 'Item 2', price: 60.00),
      Item(code: '003', name: 'Item 3', price: 70.00),
    ];
    for (var item in items) {
      await db.insert('ItemDetails', item.toMap());
    }
  }

  Future<Item?> fetchItemByCode(String code) async {
    final db = await database;
    final result = await db.query('ItemDetails', where: 'code = ?', whereArgs: [code]);
    if (result.isNotEmpty) {
      return Item(
        code: result[0]['code'] as String,
        name: result[0]['name'] as String,
        price: result[0]['price'] as double,
      );
    }
    return null;
  }

  Future<void> saveItem(Item item) async {
    final db = await database;
    await db.insert('ItemDetails', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Item>> fetchItems() async {
    final db = await database;
    final maps = await db.query('ItemDetails');
    return List.generate(
      maps.length,
      (i) => Item(
        code: maps[i]['code'] as String,
        name: maps[i]['name'] as String,
        price: maps[i]['price'] as double,
        quantity: maps[i]['quantity'] as int?,
        discount: maps[i]['discount'] as int?,
        total: maps[i]['total'] as double?,
      ),
    );
  }
}
