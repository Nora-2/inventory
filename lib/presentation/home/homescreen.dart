// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/database/databasehelber.dart';
import 'package:inventory/core/utilis/sizedbox/sizedbox.dart';
import 'package:inventory/core/widgets/CustomButton.dart';
import 'package:inventory/presentation/cars/carscreen.dart';
import 'package:inventory/presentation/discountcar/discountscreen.dart';
import 'package:inventory/presentation/jard/jardscreen.dart';
import 'package:inventory/presentation/payment/paymentscrenn.dart';
import 'package:inventory/presentation/plots/carplotsales.dart';
import 'package:inventory/presentation/plots/productplotsale.dart';
import 'package:inventory/presentation/product/productscreen.dart';
import 'package:inventory/presentation/product/productsincar.dart';
import 'package:inventory/presentation/report/reportscreen.dart';
import 'package:inventory/presentation/returns/returnsscreen.dart';
import 'package:inventory/presentation/salescares.dart/caresalesdaily.dart';
import 'package:inventory/presentation/load/selectcarscreen.dart';
import 'package:inventory/presentation/werehouse/werehouse.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    await _databaseHelper.database;
    await _databaseHelper.insertInitialCategories();
    await _databaseHelper.insertInitialProducts();
  }

  Future<List<Map<String, dynamic>>> _getCars() async {
    return await _databaseHelper.getCars();
  }

  Future<void> _addCar(String name) async {
    await _databaseHelper.addCar(name);
    setState(() {});
  }

  Future<void> _updateCar(int id, String name) async {
    await _databaseHelper.updateCar(id, name);
    setState(() {});
  }

  Future<void> _deleteCar(int id) async {
    await _databaseHelper.deleteCar(id);
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> _getProducts() async {
    return await _databaseHelper.getProducts();
  }

  Future<void> _updateProductPrice(int id, double price) async {
    await _databaseHelper.updateProductPrice(id, price);
    setState(() {});
  }

  Future<void> _addLoad(int carId, int productId, int quantity) async {
    await _databaseHelper.addLoad(carId, productId, quantity);
  }

  Future<void> _addSale(int carId, double totalAmount) async {
    await _databaseHelper.addSale(carId, totalAmount);
  }

  Future<void> _addDiscount(int carId, double discountAmount) async {
    await _databaseHelper.addDiscount(carId, discountAmount);
  }

  Future<void> addReturn(int productId, int quantity, int carid) async {
    await _databaseHelper.addReturn(productId, quantity, carid);
  }

  Future<List<Map<String, dynamic>>> _getLoadsForCar(int carId) async {
    return await _databaseHelper.getLoadsForCar(carId);
  }

  Future<List<Map<String, dynamic>>> _getSalesForCar(int carId) async {
    return await _databaseHelper.getSalesForCar(carId);
  }

  Future<List<Map<String, dynamic>>> _getDiscountsForCar(int carId) async {
    return await _databaseHelper.getDiscountsForCar(carId);
  }

  Future<List<Map<String, dynamic>>> _getReturns() async {
    return await _databaseHelper.getReturns();
  }
  Future<void> _clearDatabase() async {
    final db = await _databaseHelper.database;
    final List<String> tableNames = [
      'cars',
      'categories',
      'products',
      'car_loads',
      'sales',
      'discounts',
      'returns',
      'weekly_payments',
      'reminder',
       'products_in_car',
        'products_in_car_history'
    ];

    for (final tableName in tableNames) {
      await db.delete(tableName); // Delete all rows from each table
    }
       // ignore: use_build_context_synchronously
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف جميع البيانات بنجاح')));
  }

 Future<void> _showClearConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد حذف البيانات'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('هل أنت متأكد أنك تريد حذف جميع البيانات؟ هذا الإجراء لا يمكن التراجع عنه.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
             TextButton(
              child: const Text('تأكيد الحذف', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog
                 await  _clearDatabase();
                  setState(() {});
                },
            )
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/logoframe.png'), // Replace with your image path
            fit: BoxFit.fill, // Adjust fit as needed
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  sized.s20,
                  Row(children: [IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            onPressed: (){
             _showClearConfirmationDialog();
            },
          ),],),
                  sized.s10,    
                  Custombutton(
                    text: 'إدارة السيارات',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CarsScreen(
                                onAddCar: _addCar,
                                onUpdateCar: _updateCar,
                                onDeleteCar: _deleteCar,
                                getCars: _getCars)),
                      );
                    },
                  ),
          sized.s10,
                  Custombutton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductsScreen(
                                getProducts: _getProducts,
                                onUpdateProductPrice: _updateProductPrice)),
                      );
                    },
                    text: 'أسعار المنتجات',
                  ),
                  sized.s10,
                  Custombutton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SelectCarScreen(
                                    onAddLoad: _addLoad,
                                    getProducts: _getProducts,
                                    getCars: _getCars,
                                    getCategories: _databaseHelper.getCategories,
                                  )),
                        );
                      },
                      text: 'إضافة حمولة'),
                  sized.s10,
        
                  Custombutton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SelectCarForSalesScreen(
                                    onAddSale: _addSale,
                                    getCars: _getCars,
                                  )),
                        );
                      },
                      text: 'نقديات يومية'),
                  sized.s10,
                  Custombutton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SelectCarForDiscountScreen(
                                    onAddDiscount: _addDiscount,
                                    getCars: _getCars,
                                  )),
                        );
                      },
                      text: 'خصومات يومية'),
                  sized.s10,
                  Custombutton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReturnScreen(
                                    getCars: _getCars,
                                    onAddReturn: addReturn,
                                    getProducts: _getProducts,
                                  )),
                        );
                      },
                      text: 'إضافة مرتجعات'),
                                sized.s10,
                  Custombutton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductsInCarScreen(
            getCars: DatabaseHelper().getCars,
            getProducts: DatabaseHelper().getProducts,
            onAddProductToCar: DatabaseHelper().addProductToCar,
          ),),
                        );
                      },
                      text: 'عهده في العربيه'),
                              sized.s10,
                  Custombutton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WeeklyPaymentScreen(
                                  getCars: _getCars,
                                  databaseHelper: _databaseHelper,
                                )),
                      );
                    },
                    text: ' النقديات الأسبوعية',
                  ),
                  
                  sized.s10,
                  Custombutton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReportScreen(
                                  getCars: _getCars,
                                  
                                  getSalesForCar: _getSalesForCar,
                                  getLoadsForCar: _getLoadsForCar,
                                  getDiscountsForCar: _getDiscountsForCar,
                                  getProducts: _getProducts,
                                  getReturnsForCar: (carId) {
                                   return _databaseHelper.getReturnsForCar(carId);
                                  }, getProductsInCar: (id) { return _databaseHelper.getProductsInCar(id); }, getPreviousWeekProductsInCar: (id  ) { return _databaseHelper.getHistoryProductsInCar(id,); },
                                )),
                      );
                    },
                    
                    text: 'التقارير',
                  ),
                  sized.s10,
                  Custombutton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => JurdScreen(
                                  getLoadsForCar: _getLoadsForCar,
                                  getProductsInCar: (id) { return _databaseHelper.getProductsInCar(id); },
                                  getHistoryProductsInCar: (id) { return _databaseHelper.getHistoryProductsInCar(id); },
                                  getDiscountsForCar: _getDiscountsForCar,
                                  getReturnsForCar: (id){ return _databaseHelper.getReturnsForCar(id); },
                                  getReturns: _getReturns,
                                  getCars: _getCars,
                                  getProducts: _getProducts,
                                  databaseHelper: _databaseHelper, getSalesForCar: (id ) { return _getSalesForCar(id); },
                                )),
                      );
                    },
                    text: 'الجرد',
                  ),
        sized.s10,
         Custombutton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WarehouseScreen()),
                    );
                  },
                  text:'المخزن'),
                  sized.s10,
            Custombutton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>  ProductSalesPlotScreen(
                        getProducts: DatabaseHelper().getProducts,
                       getLoadsForCar: DatabaseHelper().getLoadsForCar,
                          getCars: DatabaseHelper().getCars, getProductsInCar: (id ) { return _databaseHelper.getProductsInCar(id); },
                    ),
                              ),
                            );
                          },
                          text: 'رسم بياني منتجات',
                        ),
                        sized.s10,
                        Custombutton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CarSalesPlotScreen(
                                    getCars: _getCars,
                                    getSalesForCar: _getSalesForCar,
                                  )),);
                      },
                      text: 'رسم بياني السيارات',
                    ),
        
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
