import 'package:get/get.dart';

class ReportController extends GetxController {
  final Future<List<Map<String, dynamic>>> Function() getCars;
  final Future<List<Map<String, dynamic>>> Function(int) getSalesForCar;
  final Future<List<Map<String, dynamic>>> Function(int) getLoadsForCar;
  final Future<List<Map<String, dynamic>>> Function(int) getDiscountsForCar;
  final Future<List<Map<String, dynamic>>> Function(int) getReturnsForCar;
  final Future<List<Map<String, dynamic>>> Function() getProducts;

  ReportController({
    required this.getCars,
    required this.getSalesForCar,
    required this.getLoadsForCar,
    required this.getDiscountsForCar,
    required this.getReturnsForCar,
    required this.getProducts,
  });

  RxInt selectedCarId = RxInt(-1);
  RxList<Map<String, dynamic>> weeklyReport = <Map<String, dynamic>>[].obs;
  late Rx<Future<List<Map<String, dynamic>>>> carsFuture;
  late Rx<Future<List<Map<String, dynamic>>> >productsFuture ;


  @override
  void onInit() {
    super.onInit();
    loadCars();
    loadProducts();
  }

  Future<void> loadProducts() async {
    productsFuture = Rx(getProducts());
  }

  Future<void> loadCars() async {
    carsFuture = Rx(getCars());
  }


  Future<void> generateWeeklyReport() async {
    if (selectedCarId.value == -1) {
      return;
    }
    weeklyReport.clear();

    DateTime now = DateTime.now();
    List<Map<String, dynamic>> products = await productsFuture.value;

    List<Map<String, dynamic>> sales =
    await getSalesForCar(selectedCarId.value);
    List<Map<String, dynamic>> loads =
    await getLoadsForCar(selectedCarId.value);

    List<Map<String, dynamic>> discounts =
    await getDiscountsForCar(selectedCarId.value);

    for (int i = 0; i < 6; i++) {
      DateTime currentDate = now.subtract(Duration(days: i));
      String currentDateString =
          currentDate.toIso8601String().substring(0, 10);

      double dailySales = sales
          .where((sale) =>
          (sale['sale_date'] as String).substring(0, 10) ==
              currentDateString)
          .fold(0, (sum, sale) => sum + (sale['total_amount'] as double));

        double dailyLoads = loads
            .where((load) => (load['load_date'] as String) == currentDateString)
            .fold(0, (sum, load) {
        final product = products.firstWhere((product) => product['id'] == load['product_id'], orElse: () => {});
        final productPrice = product['price'] as double? ?? 0.0;
        return sum + ((load['quantity'] as int) * productPrice);
      });

      double dailyDiscount = discounts
          .where((discount) =>
          (discount['discount_date'] as String).substring(0, 10) ==
              currentDateString)
          .fold(
          0,
              (sum, discount) =>
              sum + (discount['discount_amount'] as double));

      weeklyReport.add({
        'date': currentDate,
        'sales': dailySales,
        'loads': dailyLoads,
        'discount': dailyDiscount,
      });
    }
  }

  void updateSelectedCarId(int? value) {
    selectedCarId.value = value ?? -1;
    generateWeeklyReport();
  }
}