import 'package:flutter/material.dart';

class CRUDPage extends StatefulWidget {
  const CRUDPage({super.key});

  @override
  State<CRUDPage> createState() => _CRUDPageState();
}

class _CRUDPageState extends State<CRUDPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('CRUD Page',
              style: TextStyle(color: Colors.white, fontSize: 27)),
          backgroundColor: const Color.fromARGB(255, 33, 243, 68),
        ),
        body: const Column(
          children: [
            Text("CRUD Page",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
          ],
        ));
  }
}
