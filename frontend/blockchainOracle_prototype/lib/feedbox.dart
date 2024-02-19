// ignore_for_file: use_key_in_widget_constructors, must_be_immutable

//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:weatherapp/services/provider.dart';

class FeedBox extends StatelessWidget {
  int index;
  bool selected, valid;
  Web3Client ethClient;
  String addr, name, shortName, img;

  FeedBox({
    required this.img,
    required this.name,
    required this.addr,
    required this.index,
    required this.valid,
    required this.selected,
    required this.shortName,
    required this.ethClient,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    return GestureDetector(
      onTap: () => provider.setResult(
        addr,
        ethClient,
        index,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const SizedBox(width: 25),
              CircleAvatar(
                backgroundImage: AssetImage(img),
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 5),
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      shortName,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 120),
              CircleAvatar(
                radius: 15.5,
                backgroundColor: Colors.black26,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white,
                  child: Icon(
                    valid ? Icons.done : Icons.close,
                    color: selected && valid
                        ? Colors.green
                        : selected && !valid
                            ? Colors.red
                            : Colors.white,
                    size: 18,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 45),
        ],
      ),
    );
  }
}
