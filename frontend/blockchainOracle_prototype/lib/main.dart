//packages;
import 'home.dart';
import 'landing.dart';
import '/services/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//providers
import 'package:provider/provider.dart';

//main
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(MyApp()));
  runApp(MyApp());
}

//mainWidget
// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => TransactionProvider(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.indigo,
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color.fromARGB(255, 28, 145, 141),
            contentTextStyle: TextStyle(
              fontSize: 20,
              fontFamily: 'Open Sans',
              color: Colors.white,
            ),
          ),
        ),
        home: LandingScreen(),
        routes: {
          HomeScreen.routeName: (ctx) => HomeScreen(),
          LandingScreen.routeName: (ctx) => LandingScreen(),
        },
      ),
    );
  }
}
