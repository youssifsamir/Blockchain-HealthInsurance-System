//packages
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhysicianApp',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const MyHomePage(title: 'Physician'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isFade = false, _progress = false;
  String _progressText = 'Issue Prescription', _response = '';
  final Map<String, String> _prescription = {
    'id': '',
    'disease': '',
    'medicine': '',
    'quantity': '',
    'zone': '',
  };

  Future<void> _trigger() async {
    setState(() {
      _progress = true;
      _progressText = 'Issuing...';
    });
    final response = await http.post(
      Uri.parse('http://localhost:5080/issuePrescription'),
      body: jsonEncode(_prescription),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'secretKey'
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        _progressText = 'Issue Prescription';
        _response = response.body;
        _progress = false;
        _isFade = true;
        Timer(const Duration(milliseconds: 1500), () {
          setState(() => _isFade = !_isFade);
        });
      });
    } else {
      throw Exception("Response: ${response.body}");
    }
  }

  final TextEditingController _controller0 = TextEditingController(),
      _controller2 = TextEditingController(),
      _controller3 = TextEditingController(),
      _controller4 = TextEditingController(),
      _controller5 = TextEditingController();

  double opacityLevel = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(118, 63, 81, 181),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_progressText),
            const SizedBox(height: 20),
            Visibility(
              visible: _progress,
              replacement: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1250),
                tween: _isFade
                    ? Tween<double>(begin: 0.0, end: 1.0)
                    : Tween<double>(begin: 1, end: 0),
                builder: (context, value, child) {
                  opacityLevel = value;
                  return Opacity(
                    opacity: opacityLevel,
                    child: Text(
                      _response,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        // color: _response == "Token Claimed"
                        // ? Colors.green
                        // : Colors.red,
                      ),
                    ),
                  );
                },
              ),
              child: const CircularProgressIndicator(
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _controller0,
                onChanged: (text) => _prescription['id'] = text,
                decoration: const InputDecoration(
                    hintText: 'Patient ID', hintStyle: TextStyle(fontSize: 10)),
              ),
            ),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _controller2,
                onChanged: (text) => _prescription['disease'] = text,
                decoration: const InputDecoration(
                    hintText: 'Disease', hintStyle: TextStyle(fontSize: 10)),
              ),
            ),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _controller3,
                onChanged: (text) => _prescription['medicine'] = text,
                decoration: const InputDecoration(
                  hintText: 'Medicine',
                  hintStyle: TextStyle(fontSize: 10),
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _controller4,
                onChanged: (text) => _prescription['quantity'] = text,
                decoration: const InputDecoration(
                  hintText: 'Quantity',
                  hintStyle: TextStyle(fontSize: 10),
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _controller5,
                onChanged: (text) => _prescription['zone'] = text,
                decoration: const InputDecoration(
                  hintText: 'Zone',
                  hintStyle: TextStyle(fontSize: 10),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          try {
            _controller0.clear();
            _controller2.clear();
            _controller3.clear();
            _controller4.clear();
            _controller5.clear();
            _trigger();
          } catch (e) {}
        },
        tooltip: 'Increment',
        child: const Icon(Icons.send),
      ),
    );
  }
}
