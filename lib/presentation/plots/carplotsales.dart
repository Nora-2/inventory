// ignore_for_file: unused_field, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class CarSalesPlotScreen extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() getCars;
  final Future<List<Map<String, dynamic>>> Function(int) getSalesForCar;

 const CarSalesPlotScreen({super.key, 
    required this.getCars,
    required this.getSalesForCar,
  });

  @override
  _CarSalesPlotScreenState createState() => _CarSalesPlotScreenState();
}

class _CarSalesPlotScreenState extends State<CarSalesPlotScreen> {
  late Future<List<Map<String, dynamic>>> _carsFuture;
  List<Map<String, dynamic>> _carSalesData = [];
  Map<int, String> _carNames = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _carsFuture = widget.getCars();
    await _loadCarNames();
  }

  Future<void> _loadCarNames() async {
    final cars = await widget.getCars();
    setState(() {
      _carNames = {
        for (var car in cars) car['id'] as int: car['name'] as String,
      };
    });
     await _generateCarSalesData();
  }

  Future<void> _generateCarSalesData() async {
   
    List<Map<String, dynamic>> allCars = await widget.getCars();
    Map<String, double> carSalesMap = {};
    for (final car in allCars) {
      List<Map<String, dynamic>> sales =
      await widget.getSalesForCar(car['id'] as int);
      double totalSales =
          sales.fold(0.0, (sum, sale) => sum + (sale['total_amount'] as double));
      carSalesMap[_carNames[car['id']] ?? 'Unknown'] = totalSales;
    }
    setState(() {
      _carSalesData = carSalesMap.entries
          .map((entry) => {'carName': entry.key, 'totalSales': entry.value})
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مبيعات السيارات'),
        backgroundColor: Appcolors.primarycolor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_carSalesData.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: _buildBarChart(),
                ),
              ),
            if (_carSalesData.isEmpty) const Center(child: Text('لا يوجد بيانات')),
          ],
        ),
      ),
    );
  }

   Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxSalesValue(),
        barTouchData: BarTouchData(
          enabled: true,
           touchTooltipData: BarTouchTooltipData(
             tooltipBgColor: Colors.blueGrey,
             getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                      'المبلغ:  ${rod.toY.toStringAsFixed(2)} \n  السيارة : ${_carSalesData[groupIndex]['carName']}',
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
                      if (index >= 0 && index < _carSalesData.length){
                          return RotatedBox(
                              quarterTurns: 3,
                              child: Text( _carSalesData[index]['carName'],
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
          barGroups: _carSalesData.asMap().entries.map((entry) {
              final index = entry.key;
             final sale = entry.value;
               return  BarChartGroupData(
                 x: index,
                 barRods: [
                   BarChartRodData(
                     toY: (sale['totalSales'] as num).toDouble() , color: Colors.blue, width: 18,
                   )
                 ]
               );
           }).toList()
      ),
    );
  }

  double _getMaxSalesValue() {
    if (_carSalesData.isEmpty) return 100;
    return _carSalesData
        .map((sale) => (sale['totalSales'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b) +
        100;
  }
}