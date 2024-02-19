//packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'PharmacyApp',
      home: MyHomePage(title: 'Insurance A'),
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
  bool _isFade = false, _visible = true;
  String _progressText = 'Waiting for requests...', _response = '';
  final Map<String, String> _prescription = {
    'id': '',
    'disease': '',
    'medicine': '',
    'zone': '',
  };

  // Future<void> _trigger() async {
  //   print("working");
  //   setState(() {
  //     _visible = true;
  //     _progressText = 'Request';
  //   });
  //   final response = await http.post(
  //     Uri.parse('http://localhost:5080/issuePrescription'),
  //     body: jsonEncode(_prescription),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'secretKey'
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       _progressText = 'Issue Prescription';
  //       _response = response.body;
  //       _visible = false;
  //       _isFade = true;
  //       Timer(const Duration(milliseconds: 1500), () {
  //         setState(() => _isFade = !_isFade);
  //       });
  //     });
  //   } else {
  //     throw Exception("Response: ${response.body}");
  //   }
  // }

  double opacityLevel = 0.0;
  final MethodChannel _methodChannel =
      const MethodChannel('communicationChannel');

  @override
  void initState() {
    super.initState();

    _methodChannel.setMethodCallHandler((call) async {
      if (call.method == 'triggerFunction') {
        print("working");
        // _trigger();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        // elevation: 10,
        // shadowColor: Colors.black,
        // backgroundColor: const Color.fromARGB(255, 146, 198, 148),
        backgroundColor: Color.fromARGB(255, 237, 105, 96),
      ),
      body: Center(
        child: Visibility(
          visible: _visible,
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
                  style: TextStyle(
                    fontSize: 12,
                    color: _response == "Prescription Issued."
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              );
            },
          ),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 275),
              Text(
                _progressText,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                // color: Color.fromARGB(255, 146, 198, 148),
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
