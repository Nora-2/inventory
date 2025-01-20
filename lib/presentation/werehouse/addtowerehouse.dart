import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';
import 'package:inventory/core/utilis/database/databasehelber.dart';
import 'package:inventory/core/utilis/sizedbox/sizedbox.dart';
import 'package:inventory/core/widgets/CustomButton.dart';

class AddToWarehouseScreen extends StatefulWidget {
  final Function() refreshWarehouse;
  const AddToWarehouseScreen({Key? key, required this.refreshWarehouse}) : super(key: key);

  @override
  _AddToWarehouseScreenState createState() => _AddToWarehouseScreenState();
}

class _AddToWarehouseScreenState extends State<AddToWarehouseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  int? _selectedProductId;
    late Future<List<Map<String, dynamic>>> productsFuture;
    late DatabaseHelper _databaseHelper;
    @override
  void initState() {
      super.initState();
      _databaseHelper = DatabaseHelper();
       _loadData();
  }
  Future<void> _loadData() async {
    productsFuture = _getProducts();
  }
     Future<List<Map<String, dynamic>>> _getProducts() async {
    return await _databaseHelper.getProducts();
  }
  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
  Future<void> _addProductToWarehouse() async {
    if (_formKey.currentState!.validate()) {
       try {
           await _databaseHelper.updateWarehouseQuantity(
             _selectedProductId!,
            int.parse(_quantityController.text),
          );
          widget.refreshWarehouse();
          Navigator.pop(context);
        } catch (e) {
          print("Error adding product: $e");
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to add product to warehouse. Check your input.")));

        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج إلى المخزن'),
           backgroundColor: Appcolors.primarycolor,
      ),
      body: Form(
        key: _formKey,
        child:  Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
             children: [
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
                          child: Text("${product['name'] as String} ${product['price']}"),
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
                    );
                  }
                },
              ),
                  sized.s20,
                TextFormField(
                controller: _quantityController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء ادخال الكمية';
                    }
                    if (int.tryParse(value) == null) {
                      return 'ادخل كمية صحيحة';
                    }
                    return null;
                  },
                 keyboardType: TextInputType.number,
                  decoration: InputDecoration(
            
            hintText: 'الكمية',
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
              Custombutton(
                onPressed: _addProductToWarehouse,
                 text: 'إضافة',
               ),
             ],
          ),
      ),
      ),
    );
  }
}