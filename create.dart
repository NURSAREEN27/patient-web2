import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class Create extends StatefulWidget {
  const Create({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CreateState();
}

class CreateState extends State {
  List<String> dataList = [];
  bool isHoveredMap = false;

  get id => null; // กำหนดตัวแปร isHovered ให้เป็นตัวแปรส่วนของ CreateState

  Future<void> fetchData() async {
    var url = Uri.parse('http://10.4.71.114/PHP_script.php');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        dataList = List<String>.from(
                json.decode(response.body).map((item) => item.values.join(',')))
            .toList();
      });
    } else {
      print('Failed to load data');
    }
  }

  Future<void> createData(String name, String lastName, String position) async {
    if (name.isNotEmpty && lastName.isNotEmpty && position.isNotEmpty) {
      var url = Uri.parse('http://10.4.71.114/PHP_script.php');
      var response = await http.post(url, body: {
        'name': name,
        'lastName': lastName,
        'position': position,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Data created successfully'),
          duration: Duration(seconds: 2),
        ));
        fetchData();
      } else {
        print('Failed to create data');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in all fields'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> deleteData(int id) async {
    try {
      var response = await http.post(
        Uri.parse("http://10.4.71.114/PHP_script.php"),
        body: {
          '_method': 'DELETE',
          'id': id.toString(),
        },
      );

      if (response.statusCode == 200) {
        fetchData();
      } else {
        print('Failed to delete data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting data: $e');
    }
  }

  Future<void> confirmDelete(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteData(id);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> editData(
      String id, String name, String lastName, String position) async {
    try {
      var url = Uri.parse('http://10.4.71.114/PHP_script.php');
      var response = await http.post(
        url,
        body: {
          '_method':
              'UPDATE', // เพิ่มพารามิเตอร์ _method เพื่อระบุว่าเป็นการอัปเดต
          'id': id,
          'name': name,
          'lastname': lastName,
          'position': position,
        },
      );

      if (response.statusCode == 200) {
        fetchData(); // เมื่ออัปเดตข้อมูลเรียบร้อยแล้ว ให้ดึงข้อมูลใหม่
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data updated successfully'),
          ),
        );
      } else {
        print('Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  Future<void> addDataDialog(BuildContext context) async {
    String name = '';
    String lastName = '';
    String position = '';

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Data"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    name = value;
                  },
                  decoration: InputDecoration(hintText: "Name"),
                ),
                TextField(
                  onChanged: (value) {
                    lastName = value;
                  },
                  decoration: InputDecoration(hintText: "Lastname"),
                ),
                TextField(
                  onChanged: (value) {
                    position = value;
                  },
                  decoration: InputDecoration(hintText: "Position"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty &&
                    lastName.isNotEmpty &&
                    position.isNotEmpty) {
                  Navigator.pop(context);
                  createData(name, lastName, position);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please fill in all fields'),
                    duration: Duration(seconds: 2),
                  ));
                }
              },
              child: Text("Create"),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateDataDialog(BuildContext context, String id, String name,
      String lastName, String position) async {
    String newName = name;
    String newLastName = lastName;
    String newPosition = position;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update Data"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "ID",
                    hintTextDirection: null,
                  ),
                  initialValue: id,
                ),
                TextField(
                  onChanged: (value) {
                    newName = value;
                  },
                  decoration: InputDecoration(
                      hintText: "Name", hintTextDirection: null),
                  controller: TextEditingController()..text = name,
                ),
                TextField(
                  onChanged: (value) {
                    newLastName = value;
                  },
                  decoration: InputDecoration(hintText: "Lastname"),
                  controller: TextEditingController()..text = lastName,
                ),
                TextField(
                  onChanged: (value) {
                    newPosition = value;
                  },
                  decoration: InputDecoration(hintText: "Position"),
                  controller: TextEditingController()..text = position,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // ตรวจสอบว่ามีการเปลี่ยนแปลงข้อมูลหรือไม่
                if (newName != name ||
                    newLastName != lastName ||
                    newPosition != position) {
                  Navigator.pop(context);
                  editData(
                      id, newName, newLastName, newPosition); // ส่ง ID ไปด้วย
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('No changes made'),
                    duration: Duration(seconds: 2),
                  ));
                }
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 105, 186, 132),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ID',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Name',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Lastname',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Position',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child:
                          SizedBox(), // Add an extra expanded to align the buttons
                    ),
                  ],
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: dataList.length,
              itemBuilder: (BuildContext context, int index) {
                return buildListTile(dataList[index]);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addDataDialog(context);
        },
        child: Icon(Icons.post_add),
      ),
    );
  }

  Widget buildListTile(String data) {
    List<String> rowData = data.split(',');

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHoveredMap =
              true; // เมื่อโฮเวอร์โดน ให้เปลี่ยนค่า isHovered เป็น true
        });
      },
      onExit: (_) {
        setState(() {
          isHoveredMap =
              false; // เมื่อโฮเวอร์ออก ให้เปลี่ยนค่า isHovered เป็น false
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.0),
        margin: EdgeInsets.symmetric(horizontal: 9.0, vertical: 9.0),
        decoration: BoxDecoration(
          color: isHoveredMap
              ? Color.fromARGB(255, 208, 219, 192) // สีพื้นหลังเมื่อโฮเวอร์โดน
              : Color.fromARGB(255, 187, 193, 188), // สีพื้นหลังปกติ
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          // ส่วนของลิสต์ไทล์ของคุณอยู่ตรงนี้
          title: Row(
            children: [
              Expanded(
                child: Text(
                  rowData[0], // ID
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  rowData[1], // name
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  rowData[2], // lastname
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  rowData[3], // position
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.edit_square),
                  onPressed: () {
                    updateDataDialog(
                      context,
                      rowData[0], // ID
                      rowData[1], // Name
                      rowData[2], // Lastname
                      rowData[3], // Position
                    );
                  },
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete_outlined),
            onPressed: () {
              confirmDelete(int.parse(rowData[0]));
            },
          ),
        ),
      ),
    );
  }
}
