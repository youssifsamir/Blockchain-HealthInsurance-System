// ignore_for_file: camel_case_types

//packages
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:weatherapp/services/functions.dart';

class TransactionProvider with ChangeNotifier {
  var result = '';
  int catIndex = 0, selected = 0;
  bool flag = false, status = true, valid = true;

  FutureOr<Null> connection(bool con) async {
    status = con;
    valid = con ? true : false;
    notifyListeners();
  }

  void setResult(String feedAddr, Web3Client ethClient, int selc) {
    getLatestData(feedAddr, ethClient).then(
      (value) {
        result = (int.parse(value[0].toString()) / 100000000).toString();
        flag = true;
        status = true;
        selected = selc;
        valid = true;
        notifyListeners();
      },
    ).onError(
      (error, stackTrace) {
        print('stackTrace = $stackTrace');
        print('error = $error');
        connection(false);
      },
    );
    notifyListeners();
  }

  void setCatIndex(int x) {
    catIndex = x;
    notifyListeners();
  }
}
