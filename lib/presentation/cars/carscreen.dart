import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';
import 'package:inventory/core/utilis/sizedbox/sizedbox.dart';
import 'package:inventory/core/widgets/CustomButton.dart';
import 'package:inventory/core/widgets/Textformfield.dart';

class CarsScreen extends StatefulWidget {
  final Function(String) onAddCar;
  final Function(int, String) onUpdateCar;
  final Function(int) onDeleteCar;
  final Future<List<Map<String, dynamic>>> Function() getCars;

  const CarsScreen(
      {super.key,
      required this.onAddCar,
      required this.onUpdateCar,
      required this.onDeleteCar,
      required this.getCars});
  @override
  _CarsScreenState createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController _nameController =
      TextEditingController(); // controller for the car name textfield
  final TextEditingController _searchController =
      TextEditingController(); //  controller for the search textfield
  List<Map<String, dynamic>> _allCars = []; // All the cars
  List<Map<String, dynamic>> _filteredCars = []; // Displayed cars
  late Future<List<Map<String, dynamic>>> carsFuture;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    _allCars = await widget.getCars();
    _filteredCars = List.from(_allCars);
    setState(() {});
  }

  void _filterCars(String query) {
    _filteredCars = _allCars
        .where((car) =>
            (car['name'] as String).toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Appcolors.primarycolor,
        title: const Text('إدارة السيارات'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                CustomFormField(
                  hint: 'بحث',
                  preicon: const Icon(Icons.search),
                  ispass: false,
                  controller: _searchController,
                  onChanged: (value) => _filterCars(value!),
                ),
                sized.s10,
                CustomFormField(
                  controller: _nameController,
                  ispass: false,
                 hint: 'اسم السيارة',
                  val: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم السيارة';
                    }
                    return null;
                  }, preicon:const Icon(Icons.car_rental),
                ),
                sized.s10,
                Custombutton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onAddCar(_nameController.text);
                      _nameController.clear();
                      _loadCars();
                    }
                  },
                  text:'إضافة سيارة',
                ),
                sized.s40,
                Expanded(
                    child: _filteredCars.isNotEmpty
                        ? ListView.builder(
                            itemCount: _filteredCars.length,
                            itemBuilder: (context, index) {
                              final car = _filteredCars[index];
                              return Card(
                                elevation: 2.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                child: ListTile(
                                    title: Text(car['name'] as String),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            _editCar(car['id'] as int,
                                                car['name'] as String);
                                          },
                                        ),
                                        IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              widget
                                                  .onDeleteCar(car['id'] as int);
                                              _loadCars();
                                            })
                                      ],
                                    )),
                              );
                            },
                          )
                        : const Center(child: Text('لا يوجد سيارات مطابقة')))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editCar(int id, String currentName) {
    _nameController.text = currentName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل اسم السيارة'),
          content: Form(
            key: _formKey,
            child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'اسم السيارة'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم السيارة';
                  }
                  return null;
                }),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onUpdateCar(id, _nameController.text);
                  _nameController.clear();
                  _loadCars();
                  Navigator.pop(context);
                }
              },
              child: const Text('تعديل'),
            ),
          ],
        );
      },
    );
  }
}
