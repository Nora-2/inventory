import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';
import 'package:inventory/core/utilis/database/databasehelber.dart';
import 'package:inventory/core/utilis/sizedbox/sizedbox.dart';
import 'package:inventory/core/widgets/CustomButton.dart';

class AddNewProductScreen extends StatefulWidget {
  final Function() refreshProducts;
  const AddNewProductScreen({Key? key, required this.refreshProducts}) : super(key: key);

  @override
  _AddNewProductScreenState createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  int? _selectedCategoryId;
  late Future<List<Map<String, dynamic>>> categoriesFuture;
  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
     _databaseHelper = DatabaseHelper();
    _loadData();
  }

    Future<void> _loadData() async {
      categoriesFuture = _getCategories();
    }


    Future<List<Map<String, dynamic>>> _getCategories() async {
    return await _databaseHelper.getCategories();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productPriceController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
     if (_formKey.currentState!.validate()) {
        try {
          await _databaseHelper.addProduct(
            _productNameController.text,
             _selectedCategoryId!,
            double.parse(_productPriceController.text),
          );
           widget.refreshProducts();
          Navigator.pop(context);
        } catch (e) {
          print("Error adding product: $e");
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to add product. Check your input.")));
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج جديد'),
        backgroundColor: Appcolors.primarycolor,
      ),
      body: Form(
           key: _formKey,
          child:  Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextFormField(
                  controller: _productNameController,
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء ادخال اسم المنتج';
                  }
                  return null;
                },
                decoration:  InputDecoration(
            
            hintText: 'اسم المنتج',
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
              ),
                 sized.s20,
               FutureBuilder<List<Map<String, dynamic>>>(
                future: categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('لا يوجد أقسام'));
                  } else {
                    return DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      items: snapshot.data!.map((category) {
                        return DropdownMenuItem<int>(
                          value: category['id'] as int,
                          child: Text(category['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                     decoration:  InputDecoration(
            
            hintText: 'اختر النوع',
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
              TextFormField(
                  controller: _productPriceController,
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء ادخال السعر';
                  }
                  if (double.tryParse(value) == null) {
                    return 'ادخل سعر صحيح';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                 decoration:   InputDecoration(
            
            hintText: 'سعر المنتج',
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
              ),
                sized.s20,
                Custombutton(onPressed: _addProduct, text: 'إضافة'),
            ],
          ),
        )
      ),
    );
  }
}