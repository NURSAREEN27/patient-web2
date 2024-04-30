import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NextPage extends StatefulWidget {
  const NextPage({Key? key}) : super(key: key);

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State {
  Future<List<String>> fetchData() async {
    var url = Uri.parse('http://10.4.71.114/PHP_script.php');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return List<String>.from(
              json.decode(response.body).map((item) => item.values.join(',')))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create'),
      ),
      body: FutureBuilder<List<String>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 105, 186, 132),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(6.0),
                    margin: EdgeInsets.all(1),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                'ID',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Name',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Lastname',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Position',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return buildListTile(snapshot.data![index]);
                    },
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget buildListTile(String data) {
    List<String> rowData = data.split(',');
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: 5.0, horizontal: 1.0), // ปรับ margin เพื่อลดระยะห่างรอบขอบ
      padding: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 127, 164, 124)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                rowData[0], // ID
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                rowData[1], // name
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                rowData[2], // lastname
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                rowData[3], // position
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
