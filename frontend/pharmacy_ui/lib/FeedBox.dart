//packages
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FeedBox extends StatelessWidget {
  String id;
  FeedBox({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            const SizedBox(width: 25),
            const CircleAvatar(
              backgroundImage: AssetImage('./assets/images/tkn.png'),
              backgroundColor: Colors.black,
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 170,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 5),
                  Text(
                    id,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('yyyy-MM-dd - HH:mm:ss').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 120),
            // CircleAvatar(
            //   radius: 15.5,
            //   backgroundColor: Colors.black26,
            //   child: CircleAvatar(
            //     radius: 15,
            //     backgroundColor: Colors.white,
            //     child: Icon(
            //       valid ? Icons.done : Icons.close,
            //       color: selected && valid
            //           ? Colors.green
            //           : selected && !valid
            //               ? Colors.red
            //               : Colors.white,
            //       size: 18,
            //     ),
            //   ),
            // )
          ],
        ),
        const SizedBox(height: 20),
        const Divider(
          thickness: 0.5,
        )
      ],
    );
  }
}
