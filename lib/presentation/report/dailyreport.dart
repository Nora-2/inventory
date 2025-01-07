import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';
import 'package:inventory/core/utilis/database/databasehelber.dart';

class CarWeeklyReportScreen extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() getCars;
  final Future<List<Map<String, dynamic>>> Function() getProducts;
  final Future<List<Map<String, dynamic>>> Function(int) getSalesForCar;
  final Future<List<Map<String, dynamic>>> Function(int) getProductsInCar;
  final Future<List<Map<String, dynamic>>> Function(int) getLoadsForCar;

  CarWeeklyReportScreen({
    required this.getCars,
    required this.getProducts,
    required this.getSalesForCar,
    required this.getProductsInCar,
    required this.getLoadsForCar,
  });

  @override
  _CarWeeklyReportScreenState createState() => _CarWeeklyReportScreenState();
}

class _CarWeeklyReportScreenState extends State<CarWeeklyReportScreen> {
  late List<Map<String, dynamic>> carWeeklyReport = [];
  late Map<int, String> _productNames = {};
  late List<Map<String, dynamic>> _allCars = [];
  late List<String> _productNamesList = [];
  int? _selectedCarId;
  Map<String, int> weeklyLoads = {};
  Map<String, int> weeklySales = {};
  Map<String, int> productsInCarQuantities = {};

  late DatabaseHelper _databaseHelper;
  @override
  void initState() {
    super.initState();
    _loadData();
    _databaseHelper = DatabaseHelper();
  }

  Future<void> _loadData() async {
    await _loadProductNames();
    _allCars = await widget.getCars();
    setState(() {
      _productNamesList = _productNames.values.toList();
    });
  }

  Future<void> _loadProductNames() async {
    final products = await widget.getProducts();
    setState(() {
      _productNames = {
        for (var product in products)
          product['id'] as int: product['name'] as String,
      };
    });
  }

  Future<void> _generateCarWeeklyReport() async {
    carWeeklyReport = [];
    weeklyLoads = {};
    weeklySales = {};
    productsInCarQuantities = {};
    Map<String, int> previousWeekProductsInCarQuantities = {};


    if (_selectedCarId != null) {
      final car = _allCars.firstWhere((car) => car['id'] == _selectedCarId);
      final carId = car['id'] as int;
        final db = await _databaseHelper.database;

       // Get the previous week data from products_in_car_history
    final previousWeekData = await db.query(
      'products_in_car_history',
      where: 'car_id = ?',
      whereArgs: [carId],
    );

    for(final productInCar in previousWeekData){
           String productName =
            _productNames[productInCar['product_id']] ?? 'Unknown';
      previousWeekProductsInCarQuantities[productName] = productInCar['quantity'] as int;
    }
      List<Map<String, dynamic>> productsInCar =
          await widget.getProductsInCar(carId);
      List<Map<String, dynamic>> loads = await widget.getLoadsForCar(carId);
      
     

      for (final productInCar in productsInCar) {
        String productName =
            _productNames[productInCar['product_id']] ?? 'Unknown';
        productsInCarQuantities[productName] = productInCar['quantity'] as int;
      }
      for (final load in loads) {
         String productName = _productNames[load['product_id']] ?? 'Unknown';
        weeklyLoads[productName] =
            (weeklyLoads[productName] ?? 0) + (load['quantity'] as int);
      }
      
       // Calculate weekly sales for all products
         for (var productName in _productNamesList) {
        int loadQuantity = weeklyLoads[productName] ?? 0;
        int previousWeekQuantity = previousWeekProductsInCarQuantities[productName] ?? 0;
        int quantityInCar = productsInCarQuantities[productName] ?? 0;
         weeklySales[productName] = (loadQuantity+previousWeekQuantity )- ( quantityInCar) ;
    }

      carWeeklyReport.add({
        'carName': car['name'],
        'productsInCarQuantities': productsInCarQuantities,
        'loads': weeklyLoads,
         'previousWeekProductsInCarQuantities': previousWeekProductsInCarQuantities,
        'weeklySales': weeklySales
      });
    }

    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير السيارات الأسبوعي'),
        backgroundColor: Appcolors.primarycolor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: _selectedCarId,
              items: _allCars.map((car) {
                return DropdownMenuItem<int>(
                  value: car['id'] as int,
                  child: Text(car['name'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCarId = value;
                  _generateCarWeeklyReport();
                });
              },
              decoration: InputDecoration(
                hintText: 'اختر السيارة',
                prefixIconColor: Appcolors.secondarycolor,
                hintStyle: TextStyle(color: Appcolors.seccolor, fontSize: 16),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Appcolors.secondarycolor)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Appcolors.transcolor,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Appcolors.transcolor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Appcolors.seccolor,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: carWeeklyReport.isNotEmpty
                    ? DataTable(
                        columns: _createTableColumns(),
                        rows: _createTableRows(),
                      )
                    : const Center(child: Text('لا يوجد بيانات')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataColumn> _createTableColumns() {
    List<DataColumn> columns = [
      const DataColumn(
        label: Text(' ', style: TextStyle(fontWeight: FontWeight.bold)),
      ), // Empty header for row labels
      for (var product in _productNamesList)
        DataColumn(
            label: Text(product,
                style: const TextStyle(fontWeight: FontWeight.bold))),
    ];
    return columns;
  }

  List<DataRow> _createTableRows() {
    if (carWeeklyReport.isEmpty) {
      return [];
    }
    Map<String, dynamic> report = carWeeklyReport.first;
    List<DataRow> rows = [];
 print(report);
    rows.add(DataRow(cells: [
      const DataCell(Text('كمية المنتجات في الحمولة',
          style: TextStyle(fontWeight: FontWeight.bold))),
      ..._productNamesList
          .map((product) => DataCell(Center(
                child: Text('${report['loads'][product] ?? 0}',
                    style: const TextStyle(fontSize: 12)),
              )))
          .toList(),
    ]));

    rows.add(DataRow(cells: [
      const DataCell(Text('كمية المنتجات في السيارة',
          style: TextStyle(fontWeight: FontWeight.bold))),
      ..._productNamesList
          .map((product) => DataCell(Center(
                child: Text(
                  '${report['productsInCarQuantities'][product] ?? 0}',
                  style: const TextStyle(fontSize: 12),
                ),
              )))
          .toList(),
    ]));
    rows.add(DataRow(cells: [
      const DataCell(Text('كمية المنتجات في السيارة الأسبوع الماضي',
          style: TextStyle(fontWeight: FontWeight.bold))),
      ..._productNamesList
          .map((product) => DataCell(Center(
                child: Text(
                  '${report['previousWeekProductsInCarQuantities'][product] ?? 0}',
                  style: const TextStyle(fontSize: 12),
                ),
              )))
          .toList(),
    ]));
    rows.add(DataRow(cells: [
      const DataCell(
          Text('المبيعات', style: TextStyle(fontWeight: FontWeight.bold))),
      ..._productNamesList
          .map((product) => DataCell(Center(
                child: Text('${report['weeklySales'][product] ?? 0}',
                    style: const TextStyle(fontSize: 12)),
              )))
          .toList(),
    ]));

    return rows;
  }
}
