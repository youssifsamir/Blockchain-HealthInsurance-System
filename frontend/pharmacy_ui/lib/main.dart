//packages
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharmacy_ui/FeedBox.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'PharmacyApp',
      home: MyHomePage(title: 'Pharmacy'),
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
  bool _visible = true;
  String _progressText = 'Waiting for requests...';
  List<String> tokens = [];

  final shakeKey = GlobalKey<ShakeWidgetState>();
  Completer<void> completer = Completer<void>();

  Future<void> _trigger() async {
    setState(
      () {
        _visible = false;
        _progressText = 'Incoming Request';
        shakeKey.currentState?.shake();
      },
    );
  }

  double opacityLevel = 0.0;
  String _requestResponse = "";
  // final Map<String, String> _prescription = {
  //   'medicine': '',
  //   'quantity': '',
  // };

  Future<void> handleApiRequest(HttpRequest request) async {
    await _trigger();
    Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (_requestResponse != "") {
          completer.complete();
          timer.cancel();
        }
      },
    );

    completer.future.then((_) async {
      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'message': _requestResponse}))
        ..close();
      setState(() {
        tokens.add("TX07219CD");
        _requestResponse = "";
        _visible = true;
        _progressText = 'Waiting for requests...';
      });
    });
  }

  Future<void> startServer() async {
    final server = await HttpServer.bind('localhost', 3000);
    print('Listening on localhost: ${server.port}');

    await for (var request in server) {
      if (request.method == 'GET' && request.uri.path == '/api/message') {
        handleApiRequest(request);
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Not Found')
          ..close();
      }
    }
  }

  @override
  void initState() {
    startServer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 10,
        shadowColor: Colors.black,
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Visibility(
              visible: _visible,
              replacement: Column(
                children: <Widget>[
                  const SizedBox(height: 200),
                  ShakeMe(
                    key: shakeKey,
                    shakeCount: 3,
                    shakeOffset: 5,
                    shakeDuration: const Duration(milliseconds: 350),
                    child: Text(
                      _progressText,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _requestResponse = "Accepted.";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 104, 175, 106),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Accept",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _requestResponse = "Declined.";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 245, 111, 101),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Decline",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 200),
                  ShakeMe(
                    key: shakeKey,
                    shakeCount: 3,
                    shakeOffset: 5,
                    shakeDuration: const Duration(milliseconds: 350),
                    child: Text(
                      _progressText,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const CircularProgressIndicator(
                    color: Colors.blueGrey,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Container(
              width: double.infinity,
              height: 345,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(50, 0, 0, 0),
                    blurRadius: 7,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(right: 245),
                    child: Text(
                      'Alive Tokens',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Divider(
                    thickness: 0.5,
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemBuilder: (ctx, index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: FeedBox(
                            id: tokens[index],
                          ),
                        );
                      },
                      itemCount: tokens.length,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
