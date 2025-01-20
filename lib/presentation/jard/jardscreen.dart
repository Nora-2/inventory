import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';
import 'package:inventory/core/utilis/database/databasehelber.dart';
import 'package:inventory/core/utilis/sizedbox/sizedbox.dart';
import 'package:inventory/core/widgets/CustomButton.dart';
import 'package:inventory/presentation/remindar/remindarscreen.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class JurdScreen extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function(int) getLoadsForCar;
  final Future<List<Map<String, dynamic>>> Function(int) getDiscountsForCar;
    final Future<List<Map<String, dynamic>>> Function(int) getReturnsForCar;
  final Future<List<Map<String, dynamic>>> Function() getReturns;
  final Future<List<Map<String, dynamic>>> Function(int) getSalesForCar;
  final Future<List<Map<String, dynamic>>> Function() getCars;
  final Future<List<Map<String, dynamic>>> Function() getProducts;
  final Future<List<Map<String, dynamic>>> Function(int) getProductsInCar;
  final Future<List<Map<String, dynamic>>> Function(int) getHistoryProductsInCar;
    final DatabaseHelper databaseHelper;


  JurdScreen({
    required this.getLoadsForCar,
    required this.getDiscountsForCar,
       required this.getReturnsForCar,
    required this.getReturns,
    required this.getSalesForCar,
    required this.getCars,
    required this.getProducts,
        required this.getProductsInCar,
    required this.getHistoryProductsInCar,
    required this.databaseHelper,
  });

  @override
  _JurdScreenState createState() => _JurdScreenState();
}

class _JurdScreenState extends State<JurdScreen> {
  late Future<List<Map<String, dynamic>>> _carsFuture;
  double _totalLoadsAllCars = 0.0;
  double _totalDiscountsAllCars = 0.0;
    double _totalReturnsAllCars = 0.0;
  double _totalPaymentsAllCars = 0.0;
  List<Map<String, dynamic>> _allCars = [];
  Map<int, Map<String, double>> _jurdDataCache = {};
  Map<int, double> _carryOverCache = {};
    Map<int, double> _reminderCache = {};
  bool _dataLoaded = false;
  late Future<List<Map<String, dynamic>>> _productsFuture;
  pw.Font? arabicFont;
  bool _fontLoaded = false;
  bool _isFirstTimeReminder = true;

  @override
  void initState() {
    super.initState();
    _carsFuture = widget.getCars();
    _productsFuture = widget.getProducts();
    _loadData();
    _loadFont();
        _loadReminders();
  }
  Future<void> _loadReminders() async {
    final cars = await widget.getCars();
    for (final car in cars) {
      final carId = car['id'] as int;
      final reminderAmount = await widget.databaseHelper.getPreviousReminderForCar(carId);
      _reminderCache[carId] = reminderAmount;
    }
    setState(() {});
  }

  Future<void> _loadFont() async {
    final fontData =
        await rootBundle.load('assets/fonts/Cairo-VariableFont_slnt,wght.ttf');
    arabicFont = pw.Font.ttf(fontData);
    setState(() {
      _fontLoaded = true;
    });
  }

  Future<void> _loadData() async {
    await _calculateAllCarsJurd();
  }


Future<void> _calculateAllCarsJurd() async {
    if (_dataLoaded) {
      return;
    }

    _totalLoadsAllCars = 0;
    _totalDiscountsAllCars = 0;
      _totalReturnsAllCars = 0;
    _totalPaymentsAllCars = 0;
    _allCars = await widget.getCars();
    _jurdDataCache.clear();
    _carryOverCache.clear();


    for (final car in _allCars) {
      final carId = car['id'] as int;
      final jurdData = await _calculateCarJurd(carId);
      _jurdDataCache[carId] = jurdData;
       double reminder = _reminderCache[carId] ?? 0.0;
      double carryOver = await _getCarryOverAmount(carId);
       _carryOverCache[carId] = carryOver;

      if(!_isFirstTimeReminder){
        reminder = ((jurdData['totalLoads'] ?? 0.0) -
             (jurdData['totalDiscounts'] ?? 0.0) -
            (jurdData['totalReturns'] ?? 0.0)-
             (jurdData['totalPayments'] ?? 0.0));
        if(reminder < 0){
              reminder = 0;
          }
          _reminderCache[carId] = reminder;
          await widget.databaseHelper.updateReminder(carId, reminder);

      }


      _jurdDataCache[carId]!['totalPayments'] =
            (_jurdDataCache[carId]!['totalPayments'] ?? 0);
      _totalLoadsAllCars += jurdData['totalLoads']!;
      _totalDiscountsAllCars += jurdData['totalDiscounts']!;
         _totalReturnsAllCars += jurdData['totalReturns']!;
      _totalPaymentsAllCars += (_jurdDataCache[carId]!['totalPayments'] ?? 0);
    }
    _dataLoaded = true;
    setState(() {});
  }


  Future<void> _printJurdReport() async {
    if (!_fontLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الخط العربي غير متوفر')));
      return;
    }
    final pdf = pw.Document();
    final cars = await widget.getCars();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData(
          defaultTextStyle: pw.TextStyle(font: arabicFont)
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('تقرير الجرد',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold,font: arabicFont),textDirection: pw.TextDirection.rtl),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                  border: pw.TableBorder.all(),
                  defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Center(child: pw.Text('اسم السيارة', style: pw.TextStyle(fontWeight: pw.FontWeight.bold,font: arabicFont),textDirection: pw.TextDirection.rtl)),
                        pw.Center(child: pw.Text('إجمالي الحمولات', style: pw.TextStyle(fontWeight: pw.FontWeight.bold,font: arabicFont),textDirection: pw.TextDirection.rtl)),
                        pw.Center(child: pw.Text('إجمالي الخصومات', style: pw.TextStyle(fontWeight: pw.FontWeight.bold,font: arabicFont),textDirection: pw.TextDirection.rtl)),
                          pw.Center(child: pw.Text('إجمالي المرتجعات', style: pw.TextStyle(fontWeight: pw.FontWeight.bold,font: arabicFont),textDirection: pw.TextDirection.rtl)),
                        pw.Center(child: pw.Text('إجمالي المدفوعات', style: pw.TextStyle(fontWeight: pw.FontWeight.bold,font: arabicFont),textDirection: pw.TextDirection.rtl)),
                        pw.Center(child: pw.Text('المتبقي من الاسبوع الماضي', style: pw.TextStyle(fontWeight: pw.FontWeight.bold,font: arabicFont),textDirection: pw.TextDirection.rtl)),
                        pw.Center(child: pw.Text('الناتج', style: pw.TextStyle(fontWeight: pw.FontWeight.bold,font: arabicFont),textDirection: pw.TextDirection.rtl)),
                      ],
                    ),
                    ...cars.map((car) {
                      final carId = car['id'] as int;
                      final jurdData = _jurdDataCache[carId] ??
                          {
                            'totalLoads': 0.0,
                            'totalDiscounts': 0.0,
                             'totalReturns': 0.0,
                            'totalPayments': 0.0,
                          };

                         final reminderAmount = _reminderCache[carId] ?? 0.0;

                      final total = (jurdData['totalLoads'] ?? 0.0) -
                          (jurdData['totalDiscounts'] ?? 0.0) -
                           (jurdData['totalReturns'] ?? 0.0) -
                          (jurdData['totalPayments'] ?? 0.0) + reminderAmount;
                      return pw.TableRow(
                        children: [
                          pw.Center(child: pw.Text(car['name'] as String,textDirection: pw.TextDirection.rtl)),
                           pw.Center(child: pw.Text('${jurdData['totalLoads'] ?? 'N/A'}',textDirection: pw.TextDirection.rtl)),
                          pw.Center(child: pw.Text('${jurdData['totalDiscounts'] ?? 'N/A'}',textDirection: pw.TextDirection.rtl)),
                              pw.Center(child: pw.Text('${jurdData['totalReturns'] ?? 'N/A'}',textDirection: pw.TextDirection.rtl)),
                           pw.Center(child: pw.Text('${jurdData['totalPayments'] ?? 'N/A'}',textDirection: pw.TextDirection.rtl)),
                            pw.Center(child: pw.Text('$reminderAmount',textDirection: pw.TextDirection.rtl)),
                            pw.Center(child: pw.Text('$total',textDirection: pw.TextDirection.rtl)),
                        ],
                      );
                    }).toList()
                  ]
                ),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text('الإجمالي لكل السيارات',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20,font: arabicFont),textDirection: pw.TextDirection.rtl),
                    pw.Table(
                      border: pw.TableBorder.all(),
                      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                      children: [
                        pw.TableRow(children: [
                          pw.Center(
                              child: pw.Text('إجمالي الحمولات',textDirection: pw.TextDirection.rtl)),
                          pw.Center(
                              child: pw.Text(_totalLoadsAllCars.toString(),textDirection: pw.TextDirection.rtl)),
                        ]),
                        pw.TableRow(children: [
                          pw.Center(
                              child: pw.Text('إجمالي الخصومات',textDirection: pw.TextDirection.rtl)),
                         pw.Center(
                              child: pw.Text(_totalDiscountsAllCars.toString(),textDirection: pw.TextDirection.rtl)),
                        ]),
                        pw.TableRow(children: [
                          pw.Center(
                              child: pw.Text('إجمالي المرتجعات',textDirection: pw.TextDirection.rtl)),
                         pw.Center(
                              child: pw.Text(_totalReturnsAllCars.toString(),textDirection: pw.TextDirection.rtl)),
                        ]),
                        pw.TableRow(children: [
                          pw.Center(
                              child: pw.Text('إجمالي المدفوعات',textDirection: pw.TextDirection.rtl)),
                          pw.Center(
                              child: pw.Text(_totalPaymentsAllCars.toString(),textDirection: pw.TextDirection.rtl)),
                        ]),
                        pw.TableRow(children: [
                          pw.Center(child: pw.Text('الناتج',textDirection: pw.TextDirection.rtl)),
                         pw.Center(
                              child: pw.Text((_totalLoadsAllCars -
                                  _totalDiscountsAllCars -
                                    _totalReturnsAllCars -
                                  _totalPaymentsAllCars)
                                  .toString(),textDirection: pw.TextDirection.rtl)),
                        ]),
                      ],
                    )
                  ],
                )),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الجرد'),
        backgroundColor: Appcolors.primarycolor,
        actions: [
          IconButton(onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddReminderScreen(
                      getCars: widget.getCars,
                      databaseHelper: widget.databaseHelper,
                    )));
          }, icon: const Icon(Icons.add_card))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Custombutton(
              onPressed: () {
                _printJurdReport();
              },
              text: 'طباعة الجرد',
            ),
            sized.s20,
    
            //  Here is the new button
            Custombutton(
              onPressed: () {
                _setReminderToTotal();
              },
              text: 'إضافة مبلغ ماضي',
            ),
             sized.s20,
            Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _carsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print("Error in cars FutureBuilder: ${snapshot.error}");
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('لا يوجد سيارات'));
                } else {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: _createTableColumns(),
                      rows: _createTableRows(snapshot.data!),
                    ),
                  );
                }
              },
            )),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('الإجمالي لكل السيارات',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Table(
                    border: TableBorder.all(),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(children: [
                        const TableCell(
                            child: Center(child: Text('إجمالي الحمولات'))),
                        TableCell(
                            child: Center(
                                child: Text(_totalLoadsAllCars.toString()))),
                      ]),
                      TableRow(children: [
                        const TableCell(
                            child: Center(child: Text('إجمالي الخصومات'))),
                        TableCell(
                            child: Center(
                                child:
                                    Text(_totalDiscountsAllCars.toString()))),
                      ]),
                       TableRow(children: [
                        const TableCell(
                            child: Center(child: Text('إجمالي المرتجعات'))),
                        TableCell(
                            child: Center(
                                child: Text(_totalReturnsAllCars.toString()))),
                      ]),
                      TableRow(children: [
                        const TableCell(
                            child: Center(child: Text('إجمالي المدفوعات'))),
                        TableCell(
                            child: Center(
                                child: Text(_totalPaymentsAllCars.toString()))),
                      ]),
                      TableRow(children: [
                        const TableCell(child: Center(child: Text('الناتج'))),
                        TableCell(
                            child: Center(
                                child: Text((_totalLoadsAllCars -
                                        _totalDiscountsAllCars -
                                         _totalReturnsAllCars -
                                        _totalPaymentsAllCars)
                                    .toString()))),
                      ]),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataColumn> _createTableColumns() {
    return [
      const DataColumn(
          label: Text('اسم السيارة',
              style: TextStyle(fontWeight: FontWeight.bold))),
      const DataColumn(
          label: Text('إجمالي الحمولات',
              style: TextStyle(fontWeight: FontWeight.bold))),
      const DataColumn(
          label: Text('إجمالي الخصومات',
              style: TextStyle(fontWeight: FontWeight.bold))),
          const DataColumn(
          label: Text('إجمالي المرتجعات',
              style: TextStyle(fontWeight: FontWeight.bold))),
      const DataColumn(
          label: Text('إجمالي المدفوعات',
              style: TextStyle(fontWeight: FontWeight.bold))),
           const DataColumn(
          label: Text('المتبقي من الاسبوع الماضي',
              style: TextStyle(fontWeight: FontWeight.bold))),
      const DataColumn(
          label: Text('الناتج', style: TextStyle(fontWeight: FontWeight.bold))),
    ];
  }

  List<DataRow> _createTableRows(List<Map<String, dynamic>> cars) {
    return cars.map((car) {
      final carId = car['id'] as int;
      final jurdData = _jurdDataCache[carId] ??
          {
            'totalLoads': 0.0,
            'totalDiscounts': 0.0,
              'totalReturns': 0.0,
            'totalPayments': 0.0,
          };
          final reminderAmount = _reminderCache[carId] ?? 0.0;

      final total = (jurdData['totalLoads'] ?? 0.0) -
          (jurdData['totalDiscounts'] ?? 0.0) -
           (jurdData['totalReturns'] ?? 0.0) -
          (jurdData['totalPayments'] ?? 0.0) + reminderAmount;

      return DataRow(
        cells: [
          DataCell(Text(car['name'] as String)),
          DataCell(Center(child: Text('${jurdData['totalLoads'] ?? 'N/A'}'))),
          DataCell(
              Center(child: Text('${jurdData['totalDiscounts'] ?? 'N/A'}'))),
         DataCell(Center(child: Text('${jurdData['totalReturns'] ?? 'N/A'}'))),
          DataCell(
              Center(child: Text('${jurdData['totalPayments'] ?? 'N/A'}'))),
           DataCell(Center(child: Text('$reminderAmount'))),
          DataCell(Center(child: Text('$total'))),
        ],
      );
    }).toList();
  }

Future<Map<String, double>> _calculateCarJurd(int carId) async {
  print('_calculateCarJurd started for carId: $carId');
  double totalLoads = 0.0;
  double totalDiscounts = 0.0;
  double totalReturns = 0.0;
  double totalPayments = 0.0;
  try {
    List<Map<String, dynamic>> loads = await widget.getLoadsForCar(carId);
    print("loads for carId $carId are $loads");
    List<Map<String, dynamic>> discounts = await widget.getDiscountsForCar(carId);
    List<Map<String, dynamic>> allReturns = await widget.getReturns();
    print("discounts for carId $carId are $discounts");
    List<Map<String, dynamic>> sales = await widget.getSalesForCar(carId);
    print("sales for carId $carId are $sales");
    double totalSalesAmount = sales.fold(
        0, (sum, sale) => sum + (sale['total_amount'] as double? ?? 0.0));
    
    // Filter returns by both product_id and car_id
    List<Map<String, dynamic>> returns = allReturns
        .where((item) =>
            loads.any((load) => load['product_id'] == item['product_id']) &&
            item['car_id'] == carId)
        .toList();
    print("returns for carId $carId are $returns");

    List<Map<String, dynamic>> products = await _productsFuture;

    // Fetch current and previous week's product quantities
    final currentProductsInCar = await widget.getProductsInCar(carId);
    final historyProducts = await widget.getHistoryProductsInCar(carId);
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime previousWeekEnd = startOfWeek.subtract(const Duration(days: 1));

    Map<int, int> previousWeekQuantities = {};
    for (var item in historyProducts) {
      if (item['end_of_week_date'] != null &&
          DateTime.parse(item['end_of_week_date']).isBefore(previousWeekEnd)) {
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

    totalLoads = loads.fold(0, (sum, load) {
      return sum + ((load['quantity'] as int) * (load['product_price'] as double));
    });
    for (var product in products) {
      int productId = product['id'];
      int previousWeekQuantity = previousWeekQuantities[productId] ?? 0;
      int currentWeekQuantity = currentWeekQuantities[productId] ?? 0;
      totalLoads += (previousWeekQuantity - currentWeekQuantity) * (product['price'] as double);
    }

    totalDiscounts = discounts.fold(
        0,
        (sum, discount) =>
            sum + (discount['discount_amount'] as double? ?? 0.0));
    totalReturns = returns.fold(0, (sum, re) {
      final product = products.firstWhere(
          (product) => product['id'] == re['product_id'],
          orElse: () => {});
      final productPrice = product['price'] as double? ?? 0.0;
      return sum + ((re['quantity'] as int) * productPrice);
    });

    List<Map<String, dynamic>> payments =
        await widget.databaseHelper.getWeeklyPaymentsForCar(carId);
    print("payments for carId $carId are $payments");
    double totalPaymentsAmount = payments.fold(
        0, (sum, pay) => sum + (pay['amount'] as double? ?? 0.0));
    totalPayments = totalPaymentsAmount + totalSalesAmount;

    print(
        '_calculateCarJurd finished for carId: $carId, with results: totalLoads=$totalLoads, totalDiscounts=$totalDiscounts,  totalReturns=$totalReturns,  totalPayments = $totalPayments');
    return {
      'totalLoads': totalLoads,
      'totalDiscounts': totalDiscounts,
      'totalReturns': totalReturns,
      'totalPayments': totalPayments
    };
  } catch (e) {
    print("error in _calculateCarJurd for $carId: $e");
    return {
      'totalLoads': 0.0,
      'totalDiscounts': 0.0,
      'totalReturns': 0.0,
      'totalPayments': 0.0
    };
  }
}
  
   Future<double> _getCarryOverAmount(int carId) async {
    print("_getCarryOverAmount for carId: $carId");
    try {
      final jurdData = _jurdDataCache[carId] ??
          {
            'totalLoads': 0.0,
            'totalDiscounts': 0.0,
             'totalReturns': 0.0,
            'totalPayments': 0.0,
          };
     final netAmount = jurdData['totalLoads']! -
          (jurdData['totalDiscounts'] ?? 0) -
           (jurdData['totalReturns'] ?? 0) -
          (jurdData['totalPayments'] ?? 0);


      print("_getCarryOverAmount for carId: $carId, netAmount= $netAmount");
      if (netAmount > 0) {
        return netAmount;
      } else {
        return 0;
      }
    } catch (e) {
      print("error in _getCarryOverAmount for $carId: $e");
      return 0;
    }
  }
    Future<void> _setReminderToTotal() async {
    await _calculateAllCarsJurd();
    setState(() {
      _isFirstTimeReminder = false;
    });
     ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة المبلغ بنجاح')),
     );
  }
}