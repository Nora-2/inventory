import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';
import 'package:inventory/core/utilis/sizedbox/sizedbox.dart';
import 'package:inventory/core/widgets/CustomButton.dart';

import '../../core/widgets/Textformfield.dart';

class SelectCarForDiscountScreen extends StatefulWidget {
  final Function(int, double) onAddDiscount;
  final Future<List<Map<String, dynamic>>> Function() getCars;

  SelectCarForDiscountScreen({required this.onAddDiscount, required this.getCars});

  @override
  _SelectCarForDiscountScreenState createState() => _SelectCarForDiscountScreenState();
}

class _SelectCarForDiscountScreenState extends State<SelectCarForDiscountScreen> {
  int? _selectedCarId;
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
        title: const Text('اختر السيارة'),
        backgroundColor: Appcolors.primarycolor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
              if (_selectedCarId != null)
                Expanded(child: DiscountInputScreen(
                  carId: _selectedCarId!,
                  onAddDiscount: widget.onAddDiscount,
                ))
          ],
        ),
      ),
    );
  }
}

class DiscountInputScreen extends StatefulWidget {
  final int carId;
  final Function(int, double) onAddDiscount;

  DiscountInputScreen({required this.carId, required this.onAddDiscount});

  @override
  _DiscountInputScreenState createState() => _DiscountInputScreenState();
}

class _DiscountInputScreenState extends State<DiscountInputScreen> {
  TextEditingController _amountController = TextEditingController();
   final _formKey = GlobalKey<FormState>(); // Add a form key
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key:_formKey,
        child:Column(
          children: <Widget>[
            sized.s20,
          CustomFormField(
            ispass: false,
            preicon: const Icon(Icons.credit_card),
            controller: _amountController,
text:const TextInputType.numberWithOptions(),
           hint:' المبلغ',
            val: (value) {
               if (value == null || value.isEmpty) {
                 return 'الرجاء ادخال المبلغ';
               }
                if(double.tryParse(value) == null){
                  return 'ادخل مبلغ صحيح';
                }
               return null;
            }
          ),
          sized.s20,
            Custombutton(
              onPressed: () {
                 if(_formKey.currentState!.validate()){
                  widget.onAddDiscount(
                      widget.carId,
                      double.parse(_amountController.text));
                  _amountController.clear();
                 }
              },
            text:'تسجيل الخصم',
            ),
          ],
        ),
      )
    );
  }
}