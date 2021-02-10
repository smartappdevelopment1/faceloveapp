import 'package:flutter/material.dart';
import 'package:hookup4u/util/color.dart';
import 'package:hookup4u/util/strings.dart';

class BlockUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondryColor.withOpacity(.5),
      body: AlertDialog(
        actionsPadding: EdgeInsets.only(right: 10),
        backgroundColor: Colors.white,
        actions: [
          Text("$forMoreInfoVisitText"),
        ],
        title: Column(
          children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
                  child: Container(
                      height: 50,
                      width: 100,
                      child: Image.asset(
                        "asset/logocolor.png",
                        fit: BoxFit.contain,
                      )),
                )),
            Text(
              "$sorryYouCantAccessTheApplicationText",
              style: TextStyle(color: primaryColor),
            ),
          ],
        ),
        content: Text(
            "$youAreBlockedByTheAdminAndYOurProfileText"),
      ),
    );
  }
}
