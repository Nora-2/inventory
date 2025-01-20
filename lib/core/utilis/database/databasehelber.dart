import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
    Database? _database;
  
    Future<Database> get database async {
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database!;
    }
  
Future<Database> _initDatabase() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'store.db');
  return await openDatabase(
    path,
    version: 2, // Increment the version number
    onCreate: (db, version) async {
      await db.execute(
        'CREATE TABLE cars (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)',
      );
      await db.execute(
        'CREATE TABLE categories (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)',
      );
      await db.execute(
        'CREATE TABLE products (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, category_id INTEGER, price REAL, FOREIGN KEY (category_id) REFERENCES categories(id))',
      );
      await db.execute(
        'CREATE TABLE warehouse_products (id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER, quantity INTEGER, FOREIGN KEY (product_id) REFERENCES products(id))',
      );
      await db.execute(
        'CREATE TABLE car_loads (id INTEGER PRIMARY KEY AUTOINCREMENT, car_id INTEGER, product_id INTEGER, quantity INTEGER, load_date TEXT, product_price REAL, FOREIGN KEY (car_id) REFERENCES cars(id), FOREIGN KEY (product_id) REFERENCES products(id))', //Added product_price
      );
      await db.execute(
        'CREATE TABLE sales (id INTEGER PRIMARY KEY AUTOINCREMENT, car_id INTEGER, sale_date TEXT, total_amount REAL, FOREIGN KEY (car_id) REFERENCES cars(id))',
      );
      await db.execute(
        'CREATE TABLE discounts (id INTEGER PRIMARY KEY AUTOINCREMENT, car_id INTEGER, discount_date TEXT, discount_amount REAL, FOREIGN KEY (car_id) REFERENCES cars(id))',
      );
      await db.execute(
        'CREATE TABLE returns (id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER, return_date TEXT, quantity INTEGER,car_id INTEGER, FOREIGN KEY (product_id) REFERENCES products(id),  FOREIGN KEY (car_id) REFERENCES cars(id))',
      );
      await db.execute(
        'CREATE TABLE weekly_payments (id INTEGER PRIMARY KEY AUTOINCREMENT, car_id INTEGER, payment_date TEXT, amount REAL, FOREIGN KEY (car_id) REFERENCES cars(id))',
      );
       await db.execute(
        'CREATE TABLE reminder (id INTEGER PRIMARY KEY AUTOINCREMENT, car_id INTEGER, payment_date TEXT, amount REAL, FOREIGN KEY (car_id) REFERENCES cars(id))',
      );
      await db.execute(
        'CREATE TABLE products_in_car (id INTEGER PRIMARY KEY AUTOINCREMENT, car_id INTEGER, product_id INTEGER, quantity INTEGER, FOREIGN KEY (car_id) REFERENCES cars(id), FOREIGN KEY (product_id) REFERENCES products(id))',
      );
     await db.execute(
        'CREATE TABLE products_in_car_history (id INTEGER PRIMARY KEY AUTOINCREMENT, car_id INTEGER, product_id INTEGER, quantity INTEGER, end_of_week_date TEXT, FOREIGN KEY (car_id) REFERENCES cars(id), FOREIGN KEY (product_id) REFERENCES products(id))',
      );
    },
    onUpgrade: (db, oldVersion, newVersion) async {
       if (oldVersion < 2) {
        await db.execute(
       'ALTER TABLE car_loads ADD COLUMN product_price REAL;'
     );
   }
    }
  );
}
      Future<List<Map<String, dynamic>>> getHistoryProductsInCar(int carId) async {
      final db = await database;
      return await db.query(
        'products_in_car_history',
        where: 'car_id = ?',
        whereArgs: [carId],
      );
    }
    Future<void> _copyCurrentWeekDataToHistory() async {
        final db = await database;
    
        // 1. Get data from products_in_car
        final List<Map<String, dynamic>> currentProductsInCar =
            await db.query('products_in_car');
        // Check if there is data in products_in_car
    if (currentProductsInCar.isEmpty) {
          print('There is no data in products_in_car yet');
          return;
    }

        // Insert into products_in_car_history
        for (var item in currentProductsInCar) {
          await db.insert('products_in_car_history', {
            'car_id': item['car_id'],
            'product_id': item['product_id'],
            'quantity': item['quantity'],
            'end_of_week_date':
                DateTime.now().toIso8601String(), // Optional: Add a timestamp
          });
        }
         // Clear the current data from products_in_car table
        await db.delete('products_in_car');
    
        print('Current week data copied to history and products_in_car is clear.');
      }
    
     Future<void> addWeeklyPayment(int carId, double amount) async {
      final db = await database;
      await db.insert('weekly_payments', {
        'car_id': carId,
        'payment_date': DateTime.now().toIso8601String().substring(0, 10),
        'amount': amount,
      });
    }
  // ... (rest of your DatabaseHelper)
  
  Future<void> addReminder(int carId, double amount) async {
      final db = await database;
      final existingReminders = await getRemindersForCar(carId);
          if (existingReminders.isEmpty) {
             await db.insert('reminder', {
              'car_id': carId,
              'payment_date': DateTime.now().toIso8601String().substring(0, 10),
              'amount': amount,
            });
      }
    }
      Future<List<Map<String, dynamic>>> getRemindersForCar(int carId) async {
        final db = await database;
        return await db.query('reminder', where: 'car_id = ?', whereArgs: [carId]);
      }
   
     Future<double> getPreviousReminderForCar(int carId) async {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.rawQuery(
          'SELECT  amount FROM reminder WHERE car_id = ? ORDER BY payment_date DESC LIMIT 1',
          [carId]);
  
      if (results.isNotEmpty) {
        return results.first['amount'] as double;
      } else {
         return 0.0;
      }
    }
     Future<void> updateReminder(int carId, double amount) async {
      final db = await database;
      await db.update('reminder', {
        'amount': amount,
         'payment_date': DateTime.now().toIso8601String().substring(0, 10),
      }, where: 'car_id = ?', whereArgs: [carId]);
    }
    Future<List<Map<String, dynamic>>> getCategories() async {
      final db = await database;
      return await db.query('categories');
    }
  
     Future<List<Map<String, dynamic>>> getWeeklyPaymentsForCar(int carId) async {
      final db = await database;
      return await db
          .query('weekly_payments', where: 'car_id = ?', whereArgs: [carId]);
    }
    
   Future<void> insertInitialCategories() async {
      final db = await database;
      // Check if categories are already added
      var count = await db.rawQuery('SELECT COUNT(*) FROM categories');
      if (count.first['COUNT(*)'] == 0) {
        // Insert categories
        List<String> categoryNames = [
          'فئة الكيلو',
          'فئة الطرد',
          'فئة العصير',
           'فئة المنوعات'
        ];
        for (var categoryName in categoryNames) {
          await db.insert('categories', {'name': categoryName});
        }
      }
    }
    
     Future<void> insertInitialProducts() async {
        final db = await database;
        // Check if products are already added
        var count = await db.rawQuery('SELECT COUNT(*) FROM products');
        if (count.first['COUNT(*)'] == 0) {
          // Get Category IDs
          var categories = await db.query('categories');
           var kiloCategory = categories.firstWhere(
              (category) => category['name'] == 'فئة الكيلو')['id'] as int;
          var tartCategory = categories.firstWhere(
              (category) => category['name'] == 'فئة الطرد')['id'] as int;
          var juiceCategory = categories.firstWhere(
              (category) => category['name'] == 'فئة العصير')['id'] as int;
           var varietyCategory = categories.firstWhere(
              (category) => category['name'] == 'فئة المنوعات')['id'] as int;

          // Insert products
          List<Map<String, dynamic>> products = [
            {'name': 'سودانى', 'category_id': kiloCategory, 'price': 110},
           {'name': 'لب ابيض', 'category_id': kiloCategory, 'price': 220},
           {'name': 'لب سوبر عالي', 'category_id': kiloCategory, 'price': 150},
            {'name': 'لب عباد عالي', 'category_id': kiloCategory, 'price': 80},
            {'name': 'لب سوبر وسط', 'category_id': kiloCategory, 'price': 125},
            {'name': 'لب عباد وسط', 'category_id': kiloCategory, 'price': 70},
            {'name': 'حمص عشره', 'category_id': tartCategory, 'price': 800},
             {'name': 'مشكل خمسه', 'category_id': tartCategory, 'price': 370},
              {'name': 'سوبر خمسه', 'category_id': tartCategory, 'price': 370},
               {'name': 'حمص خمسه', 'category_id': tartCategory, 'price': 370},
                 {'name': 'عباد جنيه', 'category_id': tartCategory, 'price': 170},
                  {'name': 'سوبر جنيه', 'category_id': tartCategory, 'price': 170},
                 {'name': 'فسدق جنيه', 'category_id': tartCategory, 'price': 170},
                   {'name': 'مقرمش جنيه', 'category_id': tartCategory, 'price': 170},
                     {'name': 'حمص جنيه', 'category_id': tartCategory, 'price': 170},
                   {'name': 'شكوبون جنيه', 'category_id': tartCategory, 'price': 170},
               {'name': 'صلاح', 'category_id': juiceCategory, 'price': 38},
              {'name': 'اخضر', 'category_id': juiceCategory, 'price': 38},
             {'name': 'مسطره جنيه', 'category_id': juiceCategory, 'price': 38},
             {'name': 'مسطره نص جنيه', 'category_id': juiceCategory, 'price': 38},
                {'name': 'بيبو', 'category_id': juiceCategory, 'price': 38},
            {'name': 'دماس', 'category_id': varietyCategory, 'price': 320},
            {'name': 'كونو', 'category_id': varietyCategory, 'price': 95},
             {'name': 'كولا', 'category_id': varietyCategory, 'price': 48},
              {'name': 'لبناني', 'category_id': varietyCategory, 'price': 270},
              {'name': 'جردل شوكولاته', 'category_id': varietyCategory, 'price': 340},
               {'name': 'جردل شكوبون', 'category_id': varietyCategory, 'price': 340},
                {'name': 'جردل كرسبي', 'category_id': varietyCategory, 'price': 150},
            {'name': 'كيري', 'category_id': varietyCategory, 'price': 270},
           {'name': ' مصاصه الربيع', 'category_id': varietyCategory, 'price': 210},
             {'name': 'توفي', 'category_id': varietyCategory, 'price': 200},
             {'name': 'عسليه جنيه', 'category_id': varietyCategory, 'price': 110},
                   {'name': ' مصاصه كيكي', 'category_id': varietyCategory, 'price':550},
             {'name': 'عسليه خمسه جنيه', 'category_id': varietyCategory, 'price': 190},
             {'name': 'لب مقشر', 'category_id': varietyCategory, 'price': 950},
          ];
          for (var product in products) {
            await db.insert('products', product);
          }
        }
      }
    
   Future<List<Map<String, dynamic>>> getCars() async {
      final db = await database;
      return await db.query('cars');
    }
  
    Future<void> addCar(String name) async {
      final db = await database;
      await db.insert('cars', {'name': name});
    }
  
     Future<void> updateCar(int id, String name) async {
      final db = await database;
      await db.update('cars', {'name': name}, where: 'id = ?', whereArgs: [id]);
    }
  
    Future<void> deleteCar(int id) async {
      final db = await database;
      await db.delete('cars', where: 'id = ?', whereArgs: [id]);
    }
  
   Future<List<Map<String, dynamic>>> getProducts() async {
      final db = await database;
      return await db.query('products');
    }
    Future<List<Map<String, dynamic>>> getWarehouseProducts() async {
        final db = await database;
      return await db.query('warehouse_products');
    }
  
     Future<void> updateProductPrice(int id, double price) async {
        final db = await database;
        await db.update('products', {'price': price},
            where: 'id = ?', whereArgs: [id]);
      }
   //new method for adding and update warehouse
    Future<void> updateWarehouseQuantity(int productId, int quantity) async {
        final db = await database;
          var existingProduct = await db.query('warehouse_products',
            where: 'product_id = ?', whereArgs: [productId]);
              if (existingProduct.isNotEmpty) {
              // If the product exists, update the quantity
              int existingQuantity = (existingProduct.first['quantity'] as int?) ?? 0;
                int newQuantity = existingQuantity + quantity;
                await db.update('warehouse_products', {'quantity': newQuantity}, where: 'product_id = ?', whereArgs: [productId]);
             print('update done for product $productId, newQuantity $newQuantity');
      } else {
        // If the product doesn't exist, insert it with the given quantity
              await db.insert('warehouse_products', {
                'product_id': productId,
                'quantity': quantity,
              });
              print('insert done for product $productId with given quantity $quantity');
            }
      }
  
  
   Future<void> addProduct(String name, int categoryId, double price) async {
        final db = await database;
        await db.insert('products', {
          'name': name,
          'category_id': categoryId,
          'price': price,
        });
    }
  
  Future<void> addLoad(int carId, int productId, int quantity) async {
  final db = await database;
  print(
      "Adding load: carId=$carId, productId=$productId, quantity=$quantity");
      //updated here to decrease quantity
      await updateWarehouseQuantity(productId, -quantity);
  final productData = await db.query('products',
      where: 'id = ?', whereArgs: [productId]);
  double productPrice = productData.first['price'] as double? ?? 0.0;
  await db.insert('car_loads', {
    'car_id': carId,
    'product_id': productId,
    'quantity': quantity,
    'load_date': DateTime.now().toIso8601String().substring(0, 10),
    'product_price': productPrice, // include the price
  });
}
    
     Future<void> addProductToCar(int carId, int productId, int quantity) async {
        final db = await database;
    
        var existingProduct = await db.query(
          'products_in_car',
          where: 'car_id = ? AND product_id = ?',
          whereArgs: [carId, productId],
        );
    
        if (existingProduct.isNotEmpty) {
          // If the product exists, update the quantity
    
          int newQuantity = quantity;
          await db.update(
            'products_in_car',
            {'quantity': newQuantity},
            where: 'car_id = ? AND product_id = ?',
            whereArgs: [carId, productId],
          );
          print('update done for product $productId, newQuantity $newQuantity');
        } else {
          // If the product doesn't exist, insert it with the given quantity
          await db.insert('products_in_car', {
            'car_id': carId,
            'product_id': productId,
            'quantity': quantity,
          });
           print('insert done for product $productId with given quantity $quantity');
        }
      }
  
    Future<void> addSale(int carId, double totalAmount) async {
      final db = await database;
      await db.insert('sales', {
        'car_id': carId,
        'sale_date': DateTime.now().toIso8601String(),
        'total_amount': totalAmount,
      });
    }
    
    Future<void> addDiscount(int carId, double discountAmount) async {
          final db = await database;
          await db.insert('discounts', {
            'car_id': carId,
            'discount_date': DateTime.now().toIso8601String(),
            'discount_amount': discountAmount
          });
        }
    
    Future<List<Map<String, dynamic>>> getLoadsForCar(int carId) async {
        final db = await database;
        return await db.query('car_loads', where: 'car_id = ?', whereArgs: [carId]);
      }
  
      Future<List<Map<String, dynamic>>> getSalesForCar(int carId) async {
        final db = await database;
        return await db.query('sales', where: 'car_id = ?', whereArgs: [carId]);
      }
      
      Future<List<Map<String, dynamic>>> getDiscountsForCar(int carId) async {
        final db = await database;
        return await db.query('discounts', where: 'car_id = ?', whereArgs: [carId]);
      }
    
    Future<List<Map<String, dynamic>>> getReturns() async {
        final db = await database;
        return await db.query('returns');
      }
    
    Future<void> addReturn(int productId, int quantity, int carId) async {
        final db = await database;
        await db.insert('returns', {
          'product_id': productId,
          'return_date': DateTime.now().toIso8601String(),
           'quantity': quantity,
           'car_id': carId
        });
      }
  
  Future<List<Map<String, dynamic>>> getReturnsForCar(int carId) async {
      final db = await database;
    return await db.query('returns', where: 'car_id = ?', whereArgs: [carId]);
  }
     
  Future<List<Map<String, dynamic>>> getProductsInCar(int carId) async {
      final db = await database;
      return await db.query(
        'products_in_car',
        where: 'car_id = ?',
        whereArgs: [carId],
      );
    }
    
   Future<void> copyCurrentWeekDataToHistory() async {
        await _copyCurrentWeekDataToHistory();
      }
  }