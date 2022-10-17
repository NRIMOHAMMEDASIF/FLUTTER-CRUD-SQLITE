import 'package:flutter/material.dart';
import 'package:salessms/database_helper.dart';
// ignore: unused_import
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //variable declaration
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  var myData = [];
  //form submision key
  final formKey = GlobalKey<FormState>();

//validating text field
  String? validateMyTextField(String? value) {
    if (value!.isEmpty) return 'Field is Required';
    return null;
  }

  _refreshData() async {
    final data = await DatabaseHelper.getItems();
    setState(() {
      myData = data;
    });
  }

//Add Items from button
  Future<void> addItem() async {
    await DatabaseHelper.createItem(
        _titleController.text, _descriptionController.text);
    _refreshData();
  }

//update item from the button
  Future<void> updateItem(int id) async {
    await DatabaseHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshData();
  }

  //delete item from the button

  void deleteItem(int id) async {
    await DatabaseHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Successfully Deleted Data"),
      backgroundColor: Colors.green,
    ));
    _refreshData();
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sqlite Example")),
      body: myData.isEmpty
          ? const Center(child: Text("No data available!!"))
          : ListView.builder(
              shrinkWrap: true,
              itemCount: myData.length,
              itemBuilder: (ctx, index) {
                return Card(
                  color: index % 2 == 0 ? Colors.green : Colors.green[200],
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    title: Text(myData[index]['title']),
                    subtitle: Text(myData[index]['description']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () => showMyForm(myData[index]['id']),
                            icon: const Icon(Icons.edit)),
                        IconButton(
                            onPressed: () => deleteItem(myData[index]['id']),
                            icon: const Icon(Icons.delete)),
                      ],
                    ),
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showMyForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void showMyForm(int? id) async {
    if (id != null) {
      final existingData = myData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descriptionController.text = existingData['description'];
    } else {
      _titleController.text = "";
      _descriptionController.text = "";
    }
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isDismissible: false,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          right: 15,
          left: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  validator: validateMyTextField,
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: "Title")),
              TextFormField(
                  validator: validateMyTextField,
                  controller: _descriptionController,
                  decoration: const InputDecoration(hintText: "Description")),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Exit"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        if (id != null) {
                          await updateItem(id);
                        } else {
                          await addItem();
                        }

                        Navigator.pop(context);
                      }
                      setState(() {
                        _titleController.text = "";
                        _descriptionController.text = "";
                      });
                    },
                    child: Text(id == null ? "Create Item" : "update"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
