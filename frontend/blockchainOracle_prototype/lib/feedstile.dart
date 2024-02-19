// ignore_for_file: use_key_in_widget_constructors, must_be_immutable

//packages
import 'package:weatherapp/home.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/feedbox.dart';
import 'package:weatherapp/services/provider.dart';

class FeedsList extends StatelessWidget {
  int selected;
  List<FeedObject> feeds;
  Web3Client ethClient;

  FeedsList({
    required this.feeds,
    required this.selected,
    required this.ethClient,
  });
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemBuilder: (ctx, index) {
        return FeedBox(
          name: feeds[index].name,
          shortName: feeds[index].abbr,
          img: feeds[index].img,
          selected: provider.selected == index,
          addr: feeds[index].addr,
          ethClient: ethClient,
          index: index,
          valid: provider.valid,
        );
      },
      itemCount: feeds.length,
    );
  }
}
