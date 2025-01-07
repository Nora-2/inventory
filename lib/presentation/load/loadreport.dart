import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';
import 'package:inventory/core/utilis/sizedbox/sizedbox.dart';
import 'package:inventory/core/widgets/CustomButton.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DailyLoadReportScreen extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() getCars;
  final Future<List<Map<String, dynamic>>> Function(int) getLoadsForCar;
  final Future<List<Map<String, dynamic>>> Function() getProducts;

  const DailyLoadReportScreen({
    required this.getCars,
    required this.getLoadsForCar,
    required this.getProducts,
  });

  @override
  _DailyLoadReportScreenState createState() => _DailyLoadReportScreenState();
}

class _DailyLoadReportScreenState extends State<DailyLoadReportScreen> {
  DateTime? _selectedDate;
  int? _selectedCarId;
  late Future<List<Map<String, dynamic>>> _carsFuture;
  pw.Font? arabicFont;
  bool _fontLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadFont();
    _carsFuture = widget.getCars();
  }

  Future<void> _loadFont() async {
    final fontData =
        await rootBundle.load('assets/fonts/Cairo-VariableFont_slnt,wght.ttf');
    arabicFont = pw.Font.ttf(fontData);
    setState(() {
      _fontLoaded = true;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _printDailyLoads() async {
    if (!_fontLoaded) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('الخط العربي غير متوفر')));
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('الرجاء اختيار التاريخ')));
      return;
    }
    if (_selectedCarId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('الرجاء اختيار السيارة')));
      return;
    }

    final pdf = pw.Document();
    final products = await widget.getProducts();
    final loads = await widget.getLoadsForCar(_selectedCarId!);

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
                  'تقرير حمولة يومية',
                  textDirection: pw.TextDirection.rtl,
                  style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      font: arabicFont),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                textDirection: pw.TextDirection.rtl,
                'تاريخ التقرير: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                style: pw.TextStyle(fontSize: 16, font: arabicFont),
              ),
              pw.SizedBox(height: 20),
              if (loads.isEmpty)
                pw.Center(
                    child: pw.Text('لا توجد حمولات في هذا اليوم.',
                        style: pw.TextStyle(font: arabicFont)))
              else
                _buildLoadsTable(
                    loads.where((load) {
                      DateTime loadDate = DateTime.parse(load['load_date']);
                      return loadDate.year == _selectedDate!.year &&
                          loadDate.month == _selectedDate!.month &&
                          loadDate.day == _selectedDate!.day;
                    }).toList(),
                    products),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildLoadsTable(
      List<Map<String, dynamic>> loads, List<Map<String, dynamic>> products) {
    double totalAmount = 0.0;
    final tableRows = loads.map((load) {
      final product = products.firstWhere(
        (product) => product['id'] == load['product_id'],
        orElse: () => {},
      );
      final price = product['price'] as double? ?? 0.0;
      final quantity = load['quantity'] as int;
      final rowTotal = price * quantity;
      totalAmount += rowTotal;
      return pw.TableRow(
        children: [
          pw.Center(
              child: pw.Text(
                  textDirection: pw.TextDirection.rtl,
                  product['name'] as String? ?? 'N/A',
                  style: pw.TextStyle(font: arabicFont))),
          pw.Center(
              child: pw.Text(
            textDirection: pw.TextDirection.rtl,
            '$quantity',
            style: pw.TextStyle(font: arabicFont),
          )),
          pw.Center(
            child: pw.Text(
              textDirection: pw.TextDirection.rtl,
              '$price',
              style: pw.TextStyle(font: arabicFont),
            ),
          ),
        ],
      );
    }).toList();

    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Table(
            border: pw.TableBorder.all(),
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              pw.TableRow(
                children: [
                  pw.Center(
                      child: pw.Text('اسم المنتج',
                          textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              font: arabicFont))),
                  pw.Center(
                      child: pw.Text('الكمية',
                          textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              font: arabicFont))),
                  pw.Center(
                      child: pw.Text('السعر',
                          textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              font: arabicFont))),
                ],
              ),
              ...tableRows
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'الإجمالي : ${totalAmount.toStringAsFixed(2)}',
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(
                    font: arabicFont, fontWeight: pw.FontWeight.bold),
              ))
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طباعة الحمولات اليومية'),
        backgroundColor: Appcolors.primarycolor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Appcolors.secondarycolor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'اختر التاريخ'
                            : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        style:
                            TextStyle(fontSize: 16, color: Appcolors.seccolor),
                      ),
                    ),
                  ),
                ),
                sized.w10,
                FutureBuilder<List<Map<String, dynamic>>>(
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
                      return Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedCarId,
                          items: snapshot.data!.map((car) {
                            return DropdownMenuItem<int>(
                              value: car['id'] as int,
                              child: Text(car['name'] as String),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCarId = value;
                            });
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
              ],
            ),
            sized.s20,
            Custombutton(
              onPressed: _printDailyLoads,
              text: 'طباعة',
            ),
          ],
        ),
      ),
    );
  }
}
