import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';
import 'package:inventory/core/utilis/sizedbox/sizedbox.dart';
import 'package:inventory/core/widgets/CustomButton.dart';
import 'package:inventory/core/widgets/Textformfield.dart';

class ReturnScreen extends StatefulWidget {
  final Function(int, int, int) onAddReturn; // Updated callback
  final Future<List<Map<String, dynamic>>> Function() getProducts;
  final Future<List<Map<String, dynamic>>> Function() getCars; // Added cars fetch

  ReturnScreen({
    required this.onAddReturn,
    required this.getProducts,
    required this.getCars,
  });

  @override
  _ReturnScreenState createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  int? _selectedProductId;
  int? _selectedCarId; // Added selected car ID
  final TextEditingController _quantityController = TextEditingController();
  late Future<List<Map<String, dynamic>>> productsFuture;
  late Future<List<Map<String, dynamic>>> carsFuture; // Added cars future
  final _formKey = GlobalKey<FormState>(); // Add a form key

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    productsFuture = widget.getProducts();
    carsFuture = widget.getCars(); // Load cars
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مرتجعات'),
        backgroundColor: Appcolors.primarycolor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              FutureBuilder<List<Map<String, dynamic>>>(
                future: carsFuture,
                builder: (context, snapshot) {
                   if(snapshot.connectionState == ConnectionState.waiting){
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError){
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('لا يوجد سيارات'));
                      } else {
                    return DropdownButtonFormField<int>(
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
                      validator: (value) => value == null ? 'الرجاء اختيار سيارة' : null,
                    );
                  }
                },
              ),
              sized.s20,
              FutureBuilder<List<Map<String, dynamic>>>(
                future: productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('لا يوجد منتجات'));
                  } else {
                    return DropdownButtonFormField<int>(
                      value: _selectedProductId,
                      items: snapshot.data!.map((product) {
                        return DropdownMenuItem<int>(
                          value: product['id'] as int,
                          child: Text(product['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProductId = value;
                        });
                      },
                      decoration: InputDecoration(
          
          hintText: 'اختر المنتج',
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
                      validator: (value) => value == null ? 'الرجاء اختيار منتج' : null,
                    );
                  }
                },
              ),sized.s20,
              CustomFormField(
                controller: _quantityController,
                text: const TextInputType.numberWithOptions(),
                hint: 'الكمية',
                preicon:const Icon( Icons.add,),
                ispass: false,
                val: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء ادخال الكمية';
                  }
                  if (int.tryParse(value) == null) {
                    return 'ادخل كمية صحيحة';
                  }
                  return null;
                },
              ),
              sized.s20,
              Custombutton(
                onPressed: () {
                   if(_formKey.currentState!.validate()){
                    if (_selectedProductId != null &&
                        _quantityController.text.isNotEmpty &&
                        _selectedCarId !=null) {
                      widget.onAddReturn(
                          _selectedProductId!,
                          int.parse(_quantityController.text),
                           _selectedCarId! // Pass carId
                          );
                          _quantityController.clear();
                         _selectedProductId = null;
                         _selectedCarId = null;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("الرجاء إدخال البيانات المطلوبة")));
                    }
                   }
                },
                text:'إضافة إلى المرتجع',
              ),
            ],
          ),
        ),
      ),
    );
  }
}