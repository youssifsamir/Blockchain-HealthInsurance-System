// ignore_for_file: use_key_in_widget_constructors, curly_braces_in_flow_control_structures, avoid_print, prefer_void_to_null
//packages
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:weatherapp/landing.dart';
import 'package:weatherapp/feedstile.dart';
import 'package:weatherapp/utils/constans.dart';
import 'package:weatherapp/services/provider.dart';
import 'package:animated_digit/animated_digit.dart';

class FeedObject {
  String addr, name, abbr, img;
  FeedObject({
    required this.addr,
    required this.name,
    required this.abbr,
    required this.img,
  });
}

class HomeScreen extends StatefulWidget {
  static const routeName = '/home.dart';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Client? httpClient;
  Web3Client? ethClient;

  double temp = 0;
  String string = '';
  int index = 0, catIndex = 0;

  final List<FeedObject> foriegnExchange = [
    FeedObject(
      addr: '0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea',
      name: 'Gold',
      abbr: 'XAU/USD',
      img: './assets/images/gr.png',
    ),
    FeedObject(
      addr: '0xC32f0A9D70A34B9E7377C10FDAd88512596f61EA',
      name: 'Czech Koruna',
      abbr: 'CZK/USD',
      img: './assets/images/cr.png',
    ),
    FeedObject(
      addr: '0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910',
      name: 'Euro',
      abbr: 'EUR/USD',
      img: './assets/images/er.png',
    ),
    FeedObject(
      addr: '0x91FAB41F5f3bE955963a986366edAcff1aaeaa83',
      name: 'Pound Sterling',
      abbr: 'GBP/USD',
      img: './assets/images/ur.png',
    ),
    FeedObject(
      addr: '0x8A6af2B75F23831ADc973ce6288e5329F63D86c6',
      name: 'Japanese Yen',
      abbr: 'JPY/USD',
      img: './assets/images/jr.png',
    ),
  ];

  final List<String> forigenExchangeImages = [
    './assets/images/gold.gif',
    './assets/images/czech.gif',
    './assets/images/euro.gif',
    './assets/images/uk.gif',
    './assets/images/japan.gif',
  ];

  final List miniText = [
    '1 Ounce of Gold to USD',
    '1 Czech Koruna to USD',
    '1 Euro to USD',
    '1 Pound Sterling to USD',
    '1 Japanese Yen to USD',
  ];

  @override
  void initState() {
    httpClient = Client();
    ethClient = Web3Client(infura_url, httpClient!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 25,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Row(
          children: <Widget>[
            const SizedBox(width: 15),
            Text(
              provider.status ? 'Live' : 'Offline',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Open Sans',
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 6.5),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: CircleAvatar(
                radius: 5,
                backgroundColor:
                    provider.status ? Colors.greenAccent : Colors.red,
              ),
            ),
            SizedBox(width: provider.status ? 245 : 227),
            IconButton(
              onPressed: () {
                owner_private_key = '';
                Navigator.popAndPushNamed(context, LandingScreen.routeName);
              },
              icon: const Icon(Icons.logout),
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 25),
          SizedBox(
            height: 256,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: provider.status ? 148 : 200,
                  child: Image.asset(
                    provider.status
                        ? forigenExchangeImages[provider.selected]
                        : 'assets/images/noWifi.gif',
                    width: provider.status ? 150 : 400,
                  ),
                ),
                provider.flag
                    ? Column(
                        children: <Widget>[
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '\$',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 42,
                                  fontFamily: 'Open Sans',
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 20),
                              AnimatedDigitWidget(
                                value: num.parse(provider.result),
                                fractionDigits: 4,
                                textStyle: TextStyle(
                                  fontSize: 42,
                                  fontFamily: 'Open Sans',
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          SizedBox(height: provider.status ? 20 : 2),
                          CircularProgressIndicator(
                            color: provider.status
                                ? Theme.of(context).primaryColor
                                : Colors.red,
                            strokeWidth: 5,
                          ),
                          SizedBox(height: provider.status ? 20 : 0),
                        ],
                      ),
                SizedBox(height: provider.status ? 10 : 0),
                Text(
                  provider.status ? miniText[provider.selected] : '',
                  style: TextStyle(
                    color: Colors.indigo[300],
                    fontFamily: 'Open Sans',
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
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
            height: 466,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(right: 245),
                  child: Text(
                    'DATA FEEDS',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: FeedsList(
                    selected: 1,
                    feeds: foriegnExchange,
                    ethClient: ethClient!,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
