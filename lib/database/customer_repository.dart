import '../models/customer.dart';
import 'database_service.dart';

class CustomerRepository {
  Future<void> insert(Customer customer) async {
    final db = await DatabaseService.database;

    await db.insert(
      'customers',
      customer.toMap(),
    );
  }

  Future<List<Customer>> getAll() async {
    final db = await DatabaseService.database;

    final maps = await db.query(
      'customers',
      orderBy: 'name ASC',
    );

    return maps.map((e) => Customer.fromMap(e)).toList();
  }

  Future<void> update(Customer customer) async {
    final db = await DatabaseService.database;

    await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await DatabaseService.database;

    await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}