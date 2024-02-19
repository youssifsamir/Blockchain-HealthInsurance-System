//packages
import 'dart:async';
import 'package:http/http.dart';
import 'package:weatherapp/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/utils/constans.dart';
import 'package:weatherapp/services/provider.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';

// ignore: use_key_in_widget_constructors
class LandingScreen extends StatefulWidget {
  static const routeName = '/landing.dart';

  @override
  // ignore: library_private_types_in_public_api
  _LandingScreen createState() => _LandingScreen();
}

class _LandingScreen extends State<LandingScreen> {
  bool _visible = false;
  String privateKey = 'Enter Private Key';
  final shakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void initState() {
    //logoFading
    Timer(const Duration(milliseconds: 650), () {
      setState(() {
        _visible = true;
      });
    });
    //buttons
    Timer(
      const Duration(seconds: 3),
      () {
        showModalBottomSheet(
          enableDrag: false,
          isDismissible: false,
          barrierColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          context: context,
          builder: (ctx) {
            final provider = Provider.of<TransactionProvider>(ctx);
            return StatefulBuilder(
              builder: (context, setState) => Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
                color: Colors.transparent,
                height: 150,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            width: 280,
                            height: 40,
                            color: const Color.fromRGBO(0, 0, 0, 0.03),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 5),
                              child: TextField(
                                textInputAction: TextInputAction.next,
                                cursorWidth: 1.85,
                                cursorHeight: 17.5,
                                cursorColor: Theme.of(context).primaryColor,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.only(bottom: 7),
                                  icon: ShakeMe(
                                    key: shakeKey,
                                    shakeCount: 3,
                                    shakeOffset: 5,
                                    shakeDuration:
                                        const Duration(milliseconds: 350),
                                    child: Icon(
                                      Icons.lock_outline_rounded,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  hintText: privateKey,
                                  hintStyle: TextStyle(
                                    color: privateKey != 'Enter Private Key'
                                        ? Colors.black
                                        : Colors.black26,
                                    fontSize: 13.5,
                                    fontFamily: 'Open Sans',
                                  ),
                                ),
                                onChanged: (value) => setState(
                                  () => privateKey = value,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (privateKey.length == 64) {
                              owner_private_key = privateKey;
                              provider.setResult(
                                  '0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea',
                                  Web3Client(
                                    infura_url,
                                    Client(),
                                  ),
                                  0);
                              Navigator.pop(context);
                              Navigator.popAndPushNamed(
                                context,
                                HomeScreen.routeName,
                              );
                            } else {
                              setState(() {
                                HapticFeedback.heavyImpact();
                                shakeKey.currentState?.shake();
                              });
                            }
                          },
                          iconSize: 29,
                          color: Theme.of(context).primaryColor,
                          splashRadius: 0.01,
                          icon: const Icon(Icons.arrow_circle_right_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Center(
                      child: GestureDetector(
                        onTap: () => setState(
                          () => privateKey =
                              '206528d70a4602e559c234e76b1cda4270f3feb752c4c5fddaeb8a897edfd4e2',
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            width: 200,
                            height: 40,
                            color: Colors.indigo[300],
                            child: const Center(
                              child: Text(
                                'Use A Test Private Key',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var assetsImage2 = const AssetImage('./assets/images/txt.png');
    var assetsImage1 = const AssetImage('./assets/images/logo.png');

    var logo = Image(
      image: assetsImage1,
      width: 350,
    );
    var text = Image(
      image: assetsImage2,
      width: 250,
    );

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              top: 200,
              left: 22.5,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeIn,
                opacity: _visible ? 1 : 0,
                child: logo,
              ),
            ),
            Positioned(
              top: 450,
              left: 67.5,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeIn,
                opacity: _visible ? 1 : 0,
                child: text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
