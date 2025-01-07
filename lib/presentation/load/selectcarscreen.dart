// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';
import 'package:inventory/core/utilis/database/databasehelber.dart';
import 'package:inventory/core/utilis/sizedbox/sizedbox.dart';
import 'package:inventory/core/widgets/CustomButton.dart';
import 'package:inventory/presentation/load/loadreport.dart';

class SelectCarScreen extends StatefulWidget {
  final Function(int, int, int) onAddLoad;
  final Future<List<Map<String, dynamic>>> Function() getProducts;
  final Future<List<Map<String, dynamic>>> Function() getCars;
  final Future<List<Map<String, dynamic>>> Function() getCategories;

  const SelectCarScreen(
      {super.key, required this.onAddLoad,
      required this.getProducts,
      required this.getCars,
      required this.getCategories});

  @override
  _SelectCarScreenState createState() => _SelectCarScreenState();
}

class _SelectCarScreenState extends State<SelectCarScreen> {
  int? _selectedCarId;
  late Future<List<Map<String, dynamic>>> carsFuture;
  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _initDatabase();
        carsFuture = _getCars(); // Initialize carsFuture here
  }

  Future<void> _initDatabase() async {
    await _databaseHelper.database;
    await _databaseHelper.insertInitialCategories();
    await _databaseHelper.insertInitialProducts();
  }

  Future<List<Map<String, dynamic>>> _getCars() async {
    return await _databaseHelper.getCars();
  }


  Future<List<Map<String, dynamic>>> _getProducts() async {
    return await _databaseHelper.getProducts();
  }

  Future<void> addReturn(int productId, int quantity, int carid) async {
    await _databaseHelper.addReturn(productId, quantity, carid);
  }

  Future<List<Map<String, dynamic>>> _getLoadsForCar(int carId) async {
    return await _databaseHelper.getLoadsForCar(carId);

  }
   void _refreshProducts() {
      setState(() {
        // This will force the ProductListScreen to rebuild
      });
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
                      hintStyle:
                          TextStyle(color: Appcolors.seccolor, fontSize: 16),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Appcolors.secondarycolor)),
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
                               Custombutton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DailyLoadReportScreen(
                                  getCars: _getCars,
                                  getLoadsForCar: _getLoadsForCar,
                                  getProducts: _getProducts,
                                )),
                      );
                    },
                    text:'طباعة الحمولة'),
                    
            if (_selectedCarId != null)
              Expanded(
                  child: SingleChildScrollView( // Wrap with SingleChildScrollView
                    child: ProductListScreen(
                  carId: _selectedCarId!,
                  onAddLoad: widget.onAddLoad,
                  getProducts: widget.getProducts,
                  getCategories: widget.getCategories,
                ),
                  ))
          ],
        ),
      ),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  final int carId;
  final Function(int, int, int) onAddLoad;
  final Future<List<Map<String, dynamic>>> Function() getProducts;
  final Future<List<Map<String, dynamic>>> Function() getCategories;

 const ProductListScreen(
      {super.key, required this.carId,
      required this.onAddLoad,
      required this.getProducts,
      required this.getCategories});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  int? _selectedProductId;
  int? _selectedCategoryId;
  final TextEditingController _quantityController = TextEditingController();
  late Future<List<Map<String, dynamic>>> productsFuture;
  late Future<List<Map<String, dynamic>>> categoriesFuture;
  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    categoriesFuture = widget.getCategories();
    productsFuture = widget.getProducts();
  }

  void _filterProducts(int? categoryId) async {
    setState(() {
      _selectedCategoryId = categoryId;
      if (categoryId == null) {
        _filteredProducts = [];
        return;
      }
    });
    final allProducts = await widget.getProducts();
    setState(() {
      _filteredProducts = allProducts
          .where((product) => product['category_id'] == categoryId)
          .toList();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
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
                    _filterProducts(value);
                  },
                   decoration: InputDecoration(
        
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
            }),
        sized.s20,
        if (_selectedCategoryId != null)
          FutureBuilder<List<Map<String, dynamic>>>(
            future:
                Future.value(_filteredProducts), // Use the filtered list here
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('لا يوجد منتجات في هذا القسم'));
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
                );
              }
            },
          ),
          sized.s20,
        TextFormField(
            controller: _quantityController,
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء ادخال الكمية';
              }
              if (int.tryParse(value) == null) {
                return 'ادخل كمية صحيحة';
              }
              return null;
            }),
        sized.s20,
        Custombutton(
          onPressed: () {
            if (_selectedProductId != null &&
                _quantityController.text.isNotEmpty) {
              widget.onAddLoad(widget.carId, _selectedProductId!,
                  int.parse(_quantityController.text));
                  
              _quantityController.clear();
              _selectedProductId = null;
              setState(() {});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("الرجاء إدخال البيانات المطلوبة")));
            }
          },
        text: 'إضافة إلى الحمولة',
        ),
      ],
    );
  }
}