import 'package:flutter/material.dart';
import 'package:inventory/core/utilis/appcolors/app_colors.dart';
import 'package:inventory/presentation/load/addnewproduct.dart';

class ProductsScreen extends StatefulWidget {
  final Function(int, double) onUpdateProductPrice;
   final Future<List<Map<String, dynamic>>> Function() getProducts;
  const ProductsScreen({super.key, required this.onUpdateProductPrice,required this.getProducts});
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {

    late Future<List<Map<String,dynamic>>> productsFuture;
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    productsFuture = widget.getProducts();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة أسعار المنتجات'),
        backgroundColor: Appcolors.primarycolor,
        actions: [
          IconButton(
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh),
          ),
            IconButton(
            onPressed:     () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddNewProductScreen(refreshProducts:_loadProducts,)),
                    );
                  },
                  
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body:  Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: productsFuture,
            builder: (context,snapshot){
             if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError){
                  return Center(child: Text('Error: ${snapshot.error}'));
               } else if (!snapshot.hasData || snapshot.data!.isEmpty){
                   return const Center(child: Text('لا يوجد منتجات'));
               } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final product = snapshot.data![index];
                    return Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: ListTile(
                        title: Text(product['name'] as String),
                        trailing: SizedBox(
                          width: 100.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("${product['price']}"),
                              IconButton(
                                  onPressed: (){
                                    _editProductPrice(product['id'] as int, product['price'] as double);
                                  },
                                  icon: const Icon(Icons.edit)
                              )
                            ],
                          ),
                        )
                      ),
                    );
                    },
                  );
                }
            },
          )
      )
    );
  }
   void _editProductPrice(int id,double currentPrice) {
      TextEditingController priceController = TextEditingController(text: currentPrice.toString());
       final formKey = GlobalKey<FormState>();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('تعديل سعر المنتج'),
            content: Form(
              key: formKey,
             child:  TextFormField(

                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: 'سعر المنتج'),
               validator: (value){
                 if (value == null || value.isEmpty){
                   return 'الرجاء ادخال السعر';
                 }
                  if(double.tryParse(value) == null){
                    return 'ادخل سعر صحيح';
                  }
                 return null;
                },
              ) ,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                  onPressed: (){
                   if(formKey.currentState!.validate()){
                      widget.onUpdateProductPrice(id,double.parse(priceController.text));
                      priceController.clear();
                      _loadProducts();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('تعديل')
              )
            ],
          );
        },
      );
   }
}