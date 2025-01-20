import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';
import 'package:inventory/core/utilis/sizedbox/sizedbox.dart';
import 'package:inventory/core/widgets/CustomButton.dart';
import 'package:inventory/presentation/report/dailyreport.dart';
import 'package:inventory/presentation/report/logic/reportcontroller.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportScreen extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() getCars;
  final Future<List<Map<String, dynamic>>> Function(int) getSalesForCar;
  final Future<List<Map<String, dynamic>>> Function(int) getLoadsForCar;
  final Future<List<Map<String, dynamic>>> Function(int) getDiscountsForCar;
  final Future<List<Map<String, dynamic>>> Function(int) getReturnsForCar;
  final Future<List<Map<String, dynamic>>> Function() getProducts;
  final Future<List<Map<String, dynamic>>> Function(int) getProductsInCar;
  final Future<List<Map<String, dynamic>>> Function(int)
      getPreviousWeekProductsInCar;

  ReportScreen({
    required this.getCars,
    required this.getSalesForCar,
    required this.getLoadsForCar,
    required this.getDiscountsForCar,
    required this.getReturnsForCar,
    required this.getProducts,
    required this.getProductsInCar,
    required this.getPreviousWeekProductsInCar,
  });

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  pw.Font? arabicFont;
  bool _fontLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadFont();
  }

  Future<void> _loadFont() async {
    final fontData = await rootBundle
        .load('assets/fonts/Cairo-VariableFont_slnt,wght.ttf');
    arabicFont = pw.Font.ttf(fontData);
    setState(() {
      _fontLoaded = true;
    });
  }

Future<void> _printWeeklyReport(
    List<Map<String, dynamic>> weeklyReport) async {
    if (!_fontLoaded) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('الخط العربي غير متوفر')));
      return;
    }
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData(defaultTextStyle: pw.TextStyle(font: arabicFont)),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'التقرير الأسبوعي',
                  textDirection: pw.TextDirection.rtl,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    font: arabicFont,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                  border: pw.TableBorder.all(),
                  defaultVerticalAlignment:
                      pw.TableCellVerticalAlignment.middle,
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Center(
                            child: pw.Text('التاريخ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    font: arabicFont),
                                textDirection: pw.TextDirection.rtl)),
                        pw.Center(
                            child: pw.Text('اجمالي المبيعات',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    font: arabicFont),
                                textDirection: pw.TextDirection.rtl)),
                        pw.Center(
                            child: pw.Text('اجمالي الخصومات',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    font: arabicFont),
                                textDirection: pw.TextDirection.rtl)),
                        pw.Center(
                            child: pw.Text('اجمالي الحمولة',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    font: arabicFont),
                                textDirection: pw.TextDirection.rtl)),
                         pw.Center(
                            child: pw.Text('جرد المنتجات',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    font: arabicFont),
                                textDirection: pw.TextDirection.rtl)),
                        pw.Center(
                            child: pw.Text('الإجمالي',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    font: arabicFont),
                                textDirection: pw.TextDirection.rtl)),
                      ],
                    ),
                    ...weeklyReport.map((report) {
                          double productDifference = report['productDifference'] as double;
                          double total = (report['loads'] as double) -
                          (report['discount'] as double) -
                          (report['sales'] as double) +
                          productDifference;
                      return pw.TableRow(
                        children: [
                          pw.Center(
                              child: pw.Text(
                                  report['date'].toString().substring(0, 10),
                                  textDirection: pw.TextDirection.rtl)),
                          pw.Center(
                              child: pw.Text('${report['sales']}',
                                  textDirection: pw.TextDirection.rtl)),
                          pw.Center(
                              child: pw.Text('${report['discount']}',
                                  textDirection: pw.TextDirection.rtl)),
                          pw.Center(
                              child: pw.Text('${report['loads']}',
                                  textDirection: pw.TextDirection.rtl)),
                        pw.Center(
                              child: pw.Text('$productDifference',
                                  textDirection: pw.TextDirection.rtl)),
                          pw.Center(
                              child: pw.Text('$total',
                                  textDirection: pw.TextDirection.rtl)),
                        ],
                      );
                    }).toList()
                  ]),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                        textDirection: pw.TextDirection.rtl,
                        'اجمالي المبيعات الأسبوعية :   ${weeklyReport.fold(0.0, (sum, item) => sum + (item['sales'] as double))}',
                        style: pw.TextStyle(font: arabicFont)),
                    pw.Text(
                        textDirection: pw.TextDirection.rtl,
                        'اجمالي الخصومات الأسبوعية:   ${weeklyReport.fold(0.0, (sum, item) => sum + (item['discount'] as double))}',
                        style: pw.TextStyle(font: arabicFont)),
                    pw.Text(
                        textDirection: pw.TextDirection.rtl,
                        'اجمالي الحمولة الأسبوعية:   ${weeklyReport.fold(0.0, (sum, item) => sum + (item['loads'] as double))}',
                        style: pw.TextStyle(font: arabicFont)),
                    pw.Text(
                        textDirection: pw.TextDirection.rtl,
                         'اجمالي جرد المنتجات الأسبوعي:  ${weeklyReport.fold(0.0, (sum, item) => sum + (item['productDifference'] as double))}',
                        style: pw.TextStyle(font: arabicFont)),
                    pw.Text(
                        textDirection: pw.TextDirection.rtl,
                        'الإجمالي الأسبوعي:   ${weeklyReport.fold(0.0, (sum, item) => sum + ((item['loads'] as double) - (item['discount'] as double) - (item['sales'] as double) + (item['productDifference'] as double)))}',
                        style: pw.TextStyle(font: arabicFont)),
                  ],
                ),
              ),
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
    return GetBuilder<ReportController>(
      init: ReportController(
        getCars: widget.getCars,
        getSalesForCar: widget.getSalesForCar,
        getLoadsForCar: widget.getLoadsForCar,
        getDiscountsForCar: widget.getDiscountsForCar,
        getReturnsForCar: widget.getReturnsForCar,
        getProducts: widget.getProducts,
        getProductsInCar: widget.getProductsInCar,
        getHistoryProductsInCar: widget.getPreviousWeekProductsInCar,
      ),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('التقارير الأسبوعية'),
            backgroundColor: Appcolors.primarycolor,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: controller.carsFuture.value,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('لا يوجد سيارات'));
                    } else {
                      return Obx(
                        () => DropdownButtonFormField<int>(
                          value: controller.selectedCarId.value == -1
                              ? null
                              : controller.selectedCarId.value,
                          items: snapshot.data!.map((car) {
                            return DropdownMenuItem<int>(
                              value: car['id'] as int,
                              child: Text(car['name'] as String),
                            );
                          }).toList(),
                          onChanged: (value) {
                            controller.updateSelectedCarId(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'اختر السيارة',
                            prefixIconColor: Appcolors.secondarycolor,
                            hintStyle: TextStyle(
                                color: Appcolors.seccolor, fontSize: 16),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Appcolors.secondarycolor)),
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
                      );
                    }
                  },
                ),
                sized.s20,
                Custombutton(
                  onPressed: () {
                    if (controller.selectedCarId.value != -1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarWeeklyReportScreen(
                            getCars: widget.getCars,
                            getProducts: widget.getProducts,
                            getSalesForCar: widget.getSalesForCar,
                            getProductsInCar: widget.getProductsInCar,
                            getLoadsForCar: widget.getLoadsForCar,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('الرجاء اختيار سيارة'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      text: 'جرد المنتجات',
                    ),
                    sized.s20,
                    Custombutton(
                      onPressed: () {
                        if (controller.weeklyReport.isNotEmpty) {
                          _printWeeklyReport(controller.weeklyReport);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('لا يوجد بيانات لطباعة التقرير'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      text: 'طباعة التقرير الأسبوعي',
                    ),
                    sized.s20,
                    Expanded(
                        child: Obx(() => controller.weeklyReport.isNotEmpty
                            ? SingleChildScrollView(
                               scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: _createTableColumns(),
                                    rows:
                                        _createTableRows(controller.weeklyReport),
                                  ),
                                ),
                            )
                            : const Center(
                                child: Text('لا يوجد بيانات'),
                              ))),
                    Obx(
                      () => controller.weeklyReport.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                right: 4,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      'اجمالي المبيعات الأسبوعية :   ${controller.weeklyReport.fold(0.0, (sum, item) => sum + (item['sales'] as double))}'),
                                  Text(
                                      'اجمالي الخصومات الأسبوعية:   ${controller.weeklyReport.fold(0.0, (sum, item) => sum + (item['discount'] as double))}'),
                                  Text(
                                      'اجمالي الحمولة الأسبوعية:   ${controller.weeklyReport.fold(0.0, (sum, item) => sum + (item['loads'] as double))}'),

                                  Text(
                                      'الإجمالي الأسبوعي:   ${controller.weeklyReport.fold(0.0, (sum, item) => sum + ((item['loads'] as double) - (item['discount'] as double) - (item['sales'] as double) -(item['currentWeek'] as double)+ (item['previousWeek'] as double)))}'),
                                ],
                              ))
                          : const SizedBox.shrink(),
                    )
                  ],
                ),
              ),
            );
          },
        );
      }
    
    
    
      List<DataColumn> _createTableColumns() {
        return [
          const DataColumn(
              label: Text('التاريخ',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          const DataColumn(
              label: Text('اجمالي المبيعات',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          const DataColumn(
              label: Text('اجمالي الخصومات',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          const DataColumn(
              label: Text('اجمالي الحمولة',
                  style: TextStyle(fontWeight: FontWeight.bold))),
   
          const DataColumn(
              label: Text('الإجمالي',
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ];
      }
    
     List<DataRow> _createTableRows(List<Map<String, dynamic>> weeklyReport) {
      return weeklyReport.map((report) {
       double total = (report['loads'] as double) -
          (report['discount'] as double) -
          (report['sales'] as double)-  (report['currentWeek'] as double) + (report['previousWeek'] as double);
      return DataRow(
        cells: [
           DataCell(Text(report['date'].toString().substring(0, 10))),
              DataCell(Center(child: Text('${report['sales']}'))),
              DataCell(Center(child: Text('${report['discount']}'))),
              DataCell(Center(child: Text('${report['loads']}'))),
        
              DataCell(Center(child: Text('$total'))),
        ],
      );
    }).toList();
    }
    }
    

   