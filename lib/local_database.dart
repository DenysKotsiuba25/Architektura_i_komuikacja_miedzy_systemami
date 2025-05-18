import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'product_data.dart';

class LocalDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'products.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            code TEXT PRIMARY KEY,
            name TEXT,
            brand TEXT,
            ingredients TEXT,
            imageUrl TEXT
          )
        ''');
      },
    );
    return _database!;
  }

  static Future<void> insertProduct(String code, Product product) async {
    final db = await database;
    await db.insert(
      'products',
      {
        'code': code,
        'name': product.name,
        'brand': product.brand,
        'ingredients': product.ingredients,
        'imageUrl': product.imageUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Product?> getProduct(String code) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'code = ?',
      whereArgs: [code],
    );
    if (result.isNotEmpty) {
      final row = result.first;
      return Product(
        name: row['name'] as String,
        brand: row['brand'] as String,
        ingredients: row['ingredients'] as String,
        imageUrl: row['imageUrl'] as String,
      );
    }
    return null;
  }
}