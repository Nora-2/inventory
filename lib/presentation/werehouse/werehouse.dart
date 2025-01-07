import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';
import 'package:inventory/core/utilis/database/databasehelber.dart';
import 'package:inventory/presentation/werehouse/addtowerehouse.dart';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({Key? key}) : super(key: key);

  @override
  _WarehouseScreenState createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  late Future<List<Map<String, dynamic>>> _warehouseProductsFuture;
  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadData();
  }

  Future<void> _loadData() async {
    _warehouseProductsFuture = _getWarehouseProducts();
  }

  Future<List<Map<String, dynamic>>> _getWarehouseProducts() async {
    return await _databaseHelper.getWarehouseProducts();
  }

  Future<List<Map<String, dynamic>>> _getProducts() async {
    return await _databaseHelper.getProducts();
  }

  void _refreshWarehouse() {
    setState(() {
      _warehouseProductsFuture = _getWarehouseProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المخزن'),
        backgroundColor: Appcolors.primarycolor,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddToWarehouseScreen(
                      refreshWarehouse: _refreshWarehouse,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _warehouseProductsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('المخزن فارغ'));
          } else {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _getProducts(),
              builder: (context, productsSnapshot) {
                if (productsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (productsSnapshot.hasError) {
                  return Center(child: Text('Error: ${productsSnapshot.error}'));
                } else if (!productsSnapshot.hasData ||
                    productsSnapshot.data!.isEmpty) {
                  return const Center(child: Text('لا يوجد منتجات'));
                } else {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('المنتج')),
                        DataColumn(label: Text('الكمية')),
                      ],
                      rows: snapshot.data!.map((warehouseProduct) {
                         final product = productsSnapshot.data!.firstWhere(
                            (element) =>
                                element['id'] == warehouseProduct['product_id'],
                            orElse: () => {'name': 'unknown'});
                          return DataRow(cells: [
                            DataCell(Text(product['name'] as String)),
                             DataCell(Text(warehouseProduct['quantity'].toString())),
                         ]);
                      }).toList(),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}