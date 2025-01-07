// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class ProductSalesPlotScreen extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() getProducts;
  final Future<List<Map<String, dynamic>>> Function(int) getLoadsForCar;
    final Future<List<Map<String, dynamic>>> Function(int) getProductsInCar;
  final Future<List<Map<String, dynamic>>> Function() getCars;


  ProductSalesPlotScreen({
    required this.getProducts,
    required this.getLoadsForCar,
      required this.getProductsInCar,
       required this.getCars,
  });

  @override
  _ProductSalesPlotScreenState createState() => _ProductSalesPlotScreenState();
}

class _ProductSalesPlotScreenState extends State<ProductSalesPlotScreen> {
  late Future<List<Map<String, dynamic>>> _productsFuture;
    late Future<List<Map<String, dynamic>>> _carsFuture;
  List<Map<String, dynamic>> _productSalesData = [];

    @override
    void initState() {
      super.initState();
      _loadData();
    }

   Future<void> _loadData() async {
        _productsFuture = widget.getProducts();
        _carsFuture = widget.getCars();
          await _generateProductSalesData();
   }


Future<void> _generateProductSalesData() async {
       List<Map<String, dynamic>> allCars = await widget.getCars();
       
        Map<String, int> productQuantities = {};
         for (final car in allCars) {
             List<Map<String, dynamic>> loads = await widget.getLoadsForCar(car['id'] as int);
             List<Map<String, dynamic>> productsInCar = await widget.getProductsInCar(car['id'] as int);

             Map<String, int> productsInCarQuantities = {};
             List<Map<String, dynamic>> products = await widget.getProducts();

               for (final productInCar in productsInCar) {
                   String productName = products.firstWhere((product) => product['id'] == productInCar['product_id'])['name']?? 'Unknown';
                   productsInCarQuantities[productName] =  productInCar['quantity'] as int;
                }
            for(final load in loads){
                 String productName = products.firstWhere((product) => product['id'] == load['product_id'])['name']?? 'Unknown';
                productQuantities[productName] = (productQuantities[productName] ?? 0 ) + (load['quantity'] as int) ;
            }
             for (final productInCar in productsInCar) {
                   String productName = products.firstWhere((product) => product['id'] == productInCar['product_id'])['name']?? 'Unknown';
                 int difference = (productQuantities[productName] ?? 0) - (productsInCarQuantities[productName]  ?? 0) ;
                    if (difference >= 0) {
                       productQuantities[productName] = difference;
                    }else {
                      productQuantities.remove(productName);
                    }

                }

         }


      setState(() {
        _productSalesData = productQuantities.entries.map((entry) => ({'productName': entry.key, 'quantity': entry.value})).toList();
        print(_productSalesData);
      });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مبيعات المنتجات'),
          backgroundColor: Appcolors.primarycolor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
              if(_productSalesData.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: _buildBarChart(),
                ),
              ),
             if(_productSalesData.isEmpty)
               const Center(child: Text('لا يوجد بيانات')),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxQuantity(),
          barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.blueGrey,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                      'الكمية:  ${rod.toY.toStringAsFixed(0)} \n المنتج : ${_productSalesData[groupIndex]['productName']}',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  );
                }
              )
          ),
          titlesData: FlTitlesData(
              show: true,
               bottomTitles: AxisTitles(
                   sideTitles: SideTitles(
                      showTitles: true,
                       getTitlesWidget: (value, meta) {
                         final index = value.toInt();
                          if(index >= 0 && index < _productSalesData.length){
                              return  RotatedBox(
                                 quarterTurns: 3,
                                  child: Text(_productSalesData[index]['productName'],
                                     style: const TextStyle(fontSize: 10)),
                              );
                          }
                         return const Text('');
                       }
                   )
               ),
               leftTitles: const AxisTitles(
                   sideTitles: SideTitles(showTitles: false),
               )
          ),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
           borderData: FlBorderData(show: true),
           barGroups: _productSalesData.asMap().entries.map((entry) {
              final index = entry.key;
               final sale = entry.value;
              return  BarChartGroupData(
                  x: index,
                  barRods: [
                      BarChartRodData(
                        toY: (sale['quantity'] as num).toDouble() , color: Colors.blue, width: 18,
                      )
                  ]
              );
            }).toList()
      ),
    );
  }

    double _getMaxQuantity() {
       if(_productSalesData.isEmpty) return 100;
        return _productSalesData.map((sale) => (sale['quantity'] as num).toDouble()).reduce((a, b) => a > b ? a : b).abs() + 100;
    }
}