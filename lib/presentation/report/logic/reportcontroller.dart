// ignore_for_file: unused_local_variable

import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReportController extends GetxController {
  final Future<List<Map<String, dynamic>>> Function() getCars;
  final Future<List<Map<String, dynamic>>> Function(int) getSalesForCar;
  final Future<List<Map<String, dynamic>>> Function(int) getLoadsForCar;
  final Future<List<Map<String, dynamic>>> Function(int) getDiscountsForCar;
  final Future<List<Map<String, dynamic>>> Function(int) getReturnsForCar;
  final Future<List<Map<String, dynamic>>> Function() getProducts;
  final Future<List<Map<String, dynamic>>> Function(int) getProductsInCar;
  final Future<List<Map<String, dynamic>>> Function(int) getHistoryProductsInCar;
  ReportController({
    required this.getCars,
    required this.getSalesForCar,
    required this.getLoadsForCar,
     required this.getDiscountsForCar,
    required this.getReturnsForCar,
    required this.getProducts,
        required this.getProductsInCar,
    required this.getHistoryProductsInCar
  });

  var carsFuture = Future.value(<Map<String, dynamic>>[]).obs;
  var selectedCarId = (-1).obs;
  var weeklyReport = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCars();
  }

  void updateSelectedCarId(int? value) {
    selectedCarId.value = value ?? -1;
    if (selectedCarId.value != -1) {
      fetchWeeklyReport();
    }
  }

  Future<void> fetchCars() async {
    carsFuture.value = getCars();
  }

  Future<void> fetchWeeklyReport() async {
  isLoading.value = true;
  weeklyReport.clear();

  var now = DateTime.now();
  // Set the end of the week to the current day
  DateTime endOfWeek = now;
  // Set the start of the week to 5 days before the current day
  DateTime startOfWeek = endOfWeek.subtract(const Duration(days: 5));

  print('Start of Week: $startOfWeek'); // Debug log
  print('End of Week: $endOfWeek'); // Debug log

  final sales = await getSalesForCar(selectedCarId.value);
  final loads = await getLoadsForCar(selectedCarId.value);
  final discounts = await getDiscountsForCar(selectedCarId.value);
  final returns = await getReturnsForCar(selectedCarId.value);
  final currentProductsInCar = await getProductsInCar(selectedCarId.value);
  final allProducts = await getProducts();
  final historyProducts = await getHistoryProductsInCar(selectedCarId.value);

  Map<int, int> previousWeekQuantities = {};
  for (var item in historyProducts) {
    if (item['end_of_week_date'] != null &&
        DateTime.parse(item['end_of_week_date']).isBefore(startOfWeek)) {
      int productId = item['product_id'];
      int quantity = item['quantity'];
      previousWeekQuantities[productId] = quantity;
    }
  }

  Map<int, int> currentWeekQuantities = {};
  for (var item in currentProductsInCar) {
    int productId = item['product_id'];
    int quantity = item['quantity'];
    currentWeekQuantities[productId] = quantity;
  }

  // Loop through the last 6 days (5 days before + current day)
  for (int i = 0; i < 6; i++) {
    DateTime currentDate = startOfWeek.add(Duration(days: i));
    var formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    print('Processing Date: $formattedDate'); // Debug log

    double totalSalesForDay = 0.0;
    double totalLoadsForDay = 0.0;
    double totalDiscountsForDay = 0.0;
    double productDifference = 0.0;
    double previousWeekTotal = 0.0;
    double currentWeekTotal = 0.0;

    // Calculate sales for the day
    for (var sale in sales) {
      if (sale['sale_date'] != null) {
        DateTime saleDate = DateTime.parse(sale['sale_date']);
        if (DateFormat('yyyy-MM-dd').format(saleDate) == formattedDate) {
          totalSalesForDay += sale['total_amount'] as double;
        }
      }
    }

    // Calculate loads for the day
    for (var load in loads) {
      if (load['load_date'] != null) {
        if (load['load_date'] == formattedDate) {
          totalLoadsForDay += (load['quantity'] as int) * (load['product_price'] as double);
        }
      }
    }

    // Calculate discounts for the day
    for (var discount in discounts) {
      if (discount['discount_date'] != null) {
        DateTime discountDate = DateTime.parse(discount['discount_date']);
        if (DateFormat('yyyy-MM-dd').format(discountDate) == formattedDate) {
          totalDiscountsForDay += discount['discount_amount'] as double;
        }
      }
    }

    // Calculate product differences for the day
    for (var product in allProducts) {
      int productId = product['id'];
      int previousWeekQuantity = previousWeekQuantities[productId] ?? 0;
      int currentWeekQuantity = currentWeekQuantities[productId] ?? 0;
      double loadedAmount = 0.0;

      // Calculate loaded amount for the day
      for (var load in loads) {
        if (load['load_date'] != null) {
          if (DateFormat('yyyy-MM-dd').format(DateTime.parse(load['load_date'])) == formattedDate &&
              load['product_id'] == productId) {
            loadedAmount += (load['quantity'] as int) * (load['product_price'] as double);
          }
        }
      }

      // Calculate return amount for the day
      double returnAmount = 0.0;
      for (var ret in returns) {
        if (ret['return_date'] != null) {
          if (DateFormat('yyyy-MM-dd').format(DateTime.parse(ret['return_date'])) == formattedDate &&
              ret['product_id'] == productId) {
            returnAmount += (ret['quantity'] as int) * (product['price'] as double);
          }
        }
      }

      // Accumulate previousWeek and currentWeek values
      previousWeekTotal += previousWeekQuantity * (product['price'] as double);
      currentWeekTotal += currentWeekQuantity * (product['price'] as double);

      // Calculate product difference
      productDifference +=
          (previousWeekQuantity - currentWeekQuantity) * (product['price'] as double) + loadedAmount + returnAmount;
    }

    // Add the daily report to the weekly report
    weeklyReport.add({
      'date': formattedDate,
      'sales': totalSalesForDay,
      'loads': totalLoadsForDay,
      'discount': totalDiscountsForDay,
      'productDifference': productDifference,
      'previousWeek': previousWeekTotal,
      'currentWeek': currentWeekTotal,
    });
  }

  isLoading.value = false;
}
}