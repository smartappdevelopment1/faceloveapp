import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hookup4u/Screens/Tab.dart';
import 'package:hookup4u/Screens/seach_location.dart';
import 'package:hookup4u/util/color.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hookup4u/util/strings.dart';

class AllowLocation extends StatelessWidget {
  final Map<String, dynamic> userData;
  AllowLocation(this.userData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(milliseconds: 50),
              child: FloatingActionButton(
                heroTag: UniqueKey(),
                elevation: 10,
                child: IconButton(
                  color: secondryColor,
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                backgroundColor: Colors.white38,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            /*Padding(
              padding: const EdgeInsets.only(top:10, right: 25),
              child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(milliseconds: 5000),
                  child: Container(
                    height: 42,
                    child: FloatingActionButton.extended(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 10,
                      heroTag: UniqueKey(),
                      backgroundColor: Colors.white,
                      onPressed: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => SearchLocation(userData))),
                      label: Text(
                        "Skip..",
                        style: TextStyle(color: primaryColor),
                      ),
                      icon: Icon(
                        Icons.navigate_next,
                        color: primaryColor,
                      ),
                    ),
                  )),
            ),*/
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor: secondryColor.withOpacity(.2),
                      radius: 110,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 90,
                      ),
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: RichText(
                      text: TextSpan(
                        text: "$enableLocationText",
                        style: TextStyle(color: Colors.black, fontSize: 40),
                        children: [
                          TextSpan(
                              text: """\n$youLlNeedToProvideALocationText
                              """,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: secondryColor,
                                  textBaseline: TextBaseline.alphabetic,
                                  fontSize: 18)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    )),
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  // child: FlatButton.icon(
                  //     onPressed: null,
                  //     icon: Icon(Icons.arrow_drop_down),
                  //     label: Text("Show more")),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                primaryColor.withOpacity(.5),
                                primaryColor.withOpacity(.8),
                                primaryColor,
                                primaryColor
                              ])),
                      height: MediaQuery.of(context).size.height * .065,
                      width: MediaQuery.of(context).size.width * .75,
                      child: Center(
                          child: Text(
                        "$allowLocationText",
                        style: TextStyle(
                            fontSize: 15,
                            color: textColor,
                            fontWeight: FontWeight.bold),
                      ))),
                  onTap: () async {
                    var currentLocation = await Geolocator().getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.best);
                    List<Placemark> pm = await Geolocator()
                        .placemarkFromCoordinates(currentLocation.latitude,
                            currentLocation.longitude);
                    userData.addAll(
                      {
                        'location': {
                          'latitude': currentLocation.latitude,
                          'longitude': currentLocation.longitude,
                          'address':
                              "${pm[0].locality} ${pm[0].subLocality} ${pm[0].subAdministrativeArea}\n ${pm[0].country} ,${pm[0].postalCode}"
                        },
                        'maximum_distance': 20,
                        'age_range': {
                          'min': "20",
                          'max': "50",
                        },
                      },
                    );
                    showWelcomDialog(context);
                    setUserData(userData);
                  },
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

Future setUserData(Map<String, dynamic> userData) async {
  await FirebaseAuth.instance.currentUser().then((FirebaseUser user) async {
    await Firestore.instance
        .collection("Users")
        .document(user.uid)
        .setData(userData, merge: true);
  });
}

Future showWelcomDialog(context) async {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pop(context);
          Navigator.push(context,
              CupertinoPageRoute(builder: (context) => Tabbar(null, null)));
        });
        return Center(
            child: Container(
                width: 150.0,
                height: 100.0,
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      "asset/auth/verified.jpg",
                      height: 60,
                      color: primaryColor,
                      colorBlendMode: BlendMode.color,
                    ),
                    Text(
                      "$welcomeText",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontSize: 20),
                    )
                  ],
                )));
      });
}
