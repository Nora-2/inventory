// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';
import 'package:inventory/core/utilis/database/databasehelber.dart';
import 'package:inventory/core/utilis/sizedbox/sizedbox.dart';
import 'package:inventory/core/widgets/CustomButton.dart';
import 'package:inventory/core/widgets/Textformfield.dart';

class WeeklyPaymentScreen extends StatefulWidget {
    final Future<List<Map<String, dynamic>>> Function() getCars;
   final  DatabaseHelper  databaseHelper;
  const WeeklyPaymentScreen({super.key, required this.getCars, required this.databaseHelper});
  @override
  _WeeklyPaymentScreenState createState() => _WeeklyPaymentScreenState();
}

class _WeeklyPaymentScreenState extends State<WeeklyPaymentScreen> {
  int? _selectedCarId;
  final TextEditingController _paymentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
    late Future<List<Map<String,dynamic>>> carsFuture;

   @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    carsFuture = widget.getCars();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل نقديات أسبوعية'),
        backgroundColor: Appcolors.primarycolor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                FutureBuilder<List<Map<String, dynamic>>>(
                   future: carsFuture,
                    builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('لا يوجد سيارات'));
                        } else {
                          return  DropdownButtonFormField<int>(
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
                            focusColor: Appcolors.primarycolor,
                            
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
                          );
                        }
                    },
                ),
                sized.s20,
                CustomFormField(
                  controller: _paymentController,
                  text: TextInputType.number,
                  ispass: false,
                  preicon: const Icon(Icons.credit_card),
                  hint: 'المبلغ',
                  val: (value) {
                     if (value == null || value.isEmpty) {
                       return 'الرجاء إدخال المبلغ';
                     }
                      if(double.tryParse(value) == null){
                        return 'ادخل مبلغ صحيح';
                      }
                     return null;
                  }
                ),
                sized.s20,
                Custombutton(
                  onPressed: () async {
                     if(_formKey.currentState!.validate() && _selectedCarId != null){
                        await widget.databaseHelper.addWeeklyPayment(_selectedCarId!, double.parse(_paymentController.text));
                         _paymentController.clear();
                          Navigator.of(context).pop();
                        } else {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء ادخال البيانات المطلوبة')));
                        }
      
                  },
                 text:'تسجيل الدفع'
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}