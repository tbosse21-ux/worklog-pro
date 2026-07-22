import '../models/customer.dart';
import 'database_service.dart';

class CustomerRepository {
  Future<void> insert(Customer customer) async {
    final db = await DatabaseService.database;

    await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> getAll() async {
    final db = await DatabaseService.database;

    final maps = await db.query('customers', orderBy: 'name ASC');

    return maps.map((e) => Customer.fromMap(e)).toList();
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final db = await DatabaseService.database;

    final maps = await db.query(
      'customers',
      where: 'LOWER(name) LIKE ?',
      whereArgs: ['%${query.toLowerCase()}%'],
      orderBy: 'name ASC',
      limit: 10,
    );

    return maps.map((e) => Customer.fromMap(e)).toList();
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await DatabaseService.database;

    final maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Customer.fromMap(maps.first);
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

    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  Future<Customer?> findByName(String name) async {
    final db = await DatabaseService.database;

    final maps = await db.query(
      'customers',
      where: 'LOWER(name) = ?',
      whereArgs: [name.trim().toLowerCase()],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Customer.fromMap(maps.first);
  }

  Future<Customer> getOrCreate(String name) async {
    final existing = await findByName(name);

    if (existing != null) {
      return existing;
    }

    final customer = Customer(name: name.trim());

    await insert(customer);

    return (await findByName(name))!;
  }
}
