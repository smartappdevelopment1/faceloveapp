import 'dart:io';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hookup4u/Screens/Tab.dart';
import 'package:hookup4u/Screens/Welcome.dart';
import 'package:hookup4u/Screens/auth/otp.dart';
import 'package:hookup4u/models/custom_web_view.dart';
import 'package:hookup4u/util/color.dart';
import 'package:hookup4u/util/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatelessWidget {
  static const your_client_id = '838962953505440';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const your_redirect_url =
      'https://facelove-f2510.firebaseapp.com/__/auth/handler';

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              color: Colors.white),
          child: ListView(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipPath(
                    clipper: WaveClipper2(),
                    child: Container(
                      child: Column(),
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                        darkPrimaryColor,
                        primaryColor.withOpacity(.15)
                      ])),
                    ),
                  ),
                  ClipPath(
                    clipper: WaveClipper3(),
                    child: Container(
                      child: Column(),
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                        darkPrimaryColor,
                        primaryColor.withOpacity(.2)
                      ])),
                    ),
                  ),
                  ClipPath(
                    clipper: WaveClipper1(),
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 15,
                          ),
                          Image.asset(
                            "asset/logowhite.png",
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [primaryColor, primaryColor])),
                    ),
                  ),
                ],
              ),
              Column(children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * .1,
                ),
                Container(
                  child: Text(
                    byTappingLoginText,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Material(
                    elevation: 2.0,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
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
                            width: MediaQuery.of(context).size.width * .8,
                            child: Center(
                                child: Text(
                             loginInWithFacebookText,
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold),
                            ))),
                        onTap: () async {
                          showDialog(
                              context: context,
                              child: Container(
                                  height: 30,
                                  width: 30,
                                  child: Center(
                                      child: CupertinoActivityIndicator(
                                    key: UniqueKey(),
                                    radius: 20,
                                    animating: true,
                                  ))));
                          await handleFacebookLogin(context).then((user) {
                            navigationCheck(user, context);
                          }).then((_) {
                            Navigator.pop(context);
                          }).catchError((e) {
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Platform.isIOS
                    ? Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10.0, left: 30, right: 30),
                        child: AppleSignInButton(

                          cornerRadius: 50,
                          type: ButtonType.defaultButton,
                          onPressed: () async {
                            final FirebaseUser currentUser =
                                await handleAppleLogin().catchError((onError) {
                              SnackBar snackBar =
                                  SnackBar(content: Text(onError));
                              _scaffoldKey.currentState.showSnackBar(snackBar);
                            });
                            if (currentUser != null) {
                              print(
                                  'usernaem ${currentUser.displayName} \n photourl ${currentUser.photoUrl}');
                              await _setDataUser(currentUser);
                              navigationCheck(currentUser, context);
                            }
                          },
                        ),
                      )
                    : Container(),
                OutlineButton(
                  child: Container(
                    height: MediaQuery.of(context).size.height * .065,
                    width: MediaQuery.of(context).size.width * .75,
                    child: Center(
                        child: Text(loginInWithPhoneNumberText,
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold))),
                  ),
                  borderSide: BorderSide(
                      width: 1, style: BorderStyle.solid, color: primaryColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  onPressed: () {
                    bool updateNumber = false;
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => OTP(updateNumber)));
                  },
                ),
              ]),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                     troubleLoggingInText,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    child: Text(
                     privacyPolicyText,
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () => launch(
                        "www.google.com"), //TODO: add privacy policy
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    height: 4,
                    width: 4,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.blue),
                  ),
                  GestureDetector(
                    child: Text(
                      termsConditionsText,
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () => launch(
                        "www.facebook.com"), //TODO: add Terms and conditions
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      onWillPop: () {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(exitText),
              content: Text(doYouWantToExitTheAppText),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(noText),
                ),
                FlatButton(
                  onPressed: () => SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop'),
                  child: Text(yesText),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<FirebaseUser> handleFacebookLogin(context) async {
    FirebaseUser user;
    String result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CustomWebView(
                selectedUrl:
                    'https://www.facebook.com/dialog/oauth?client_id=$your_client_id&redirect_uri=$your_redirect_url&response_type=token&scope=email,public_profile,',
              ),
          maintainState: true),
    );
    if (result != null) {
      try {
        final facebookAuthCred =
            FacebookAuthProvider.getCredential(accessToken: result);
        user =
            (await FirebaseAuth.instance.signInWithCredential(facebookAuthCred))
                .user;

        print('user $user');
      } catch (e) {
        print('Error $e');
      }
    }
    return user;
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future navigationCheck(FirebaseUser currentUser, context) async {
    await Firestore.instance
        .collection('Users')
        .where('userId', isEqualTo: currentUser.uid)
        .getDocuments()
        .then((QuerySnapshot snapshot) async {
      if (snapshot.documents.length > 0) {
        if (snapshot.documents[0].data['location'] != null) {
          Navigator.push(context,
              CupertinoPageRoute(builder: (context) => Tabbar(null, null)));
        } else {
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => Welcome()));
        }
      } else {
        await _setDataUser(currentUser);
        Navigator.push(
            context, CupertinoPageRoute(builder: (context) => Welcome()));
      }
    });
  }

  Future<FirebaseUser> handleAppleLogin() async {
    FirebaseUser user;
    if (await AppleSignIn.isAvailable()) {
      try {
        final AuthorizationResult result = await AppleSignIn.performRequests([
          AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
        ]).catchError((onError) {
          print("inside $onError");
        });

        switch (result.status) {
          case AuthorizationStatus.authorized:
            try {
              print("successfull sign in");
              final AppleIdCredential appleIdCredential = result.credential;

              OAuthProvider oAuthProvider =
                  new OAuthProvider(providerId: "apple.com");
              final AuthCredential credential = oAuthProvider.getCredential(
                idToken: String.fromCharCodes(appleIdCredential.identityToken),
                accessToken:
                    String.fromCharCodes(appleIdCredential.authorizationCode),
              );

              user = (await _auth.signInWithCredential(credential)).user;
              print("signed in as " + user.toString());
            } catch (error) {
              print("Error $error");
            }
            break;
          case AuthorizationStatus.error:
            // do something

            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('$anErrorOccuredText'),
              duration: Duration(seconds: 8),
            ));

            break;

          case AuthorizationStatus.cancelled:
            print('User cancelled');
            break;
        }
      } catch (error) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('$error.'),
          duration: Duration(seconds: 8),
        ));
        print("error with apple sign in");
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('$appleSignInText'),
        duration: Duration(seconds: 8),
      ));
    }
    return user;
  }
}

class WaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * 0.6, size.height - 29 - 50);
    var firstControlPoint = Offset(size.width * .25, size.height - 60 - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 60);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper3 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * 0.6, size.height - 15 - 50);
    var firstControlPoint = Offset(size.width * .25, size.height - 60 - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 40);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * .7, size.height - 40);
    var firstControlPoint = Offset(size.width * .25, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 45);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

Future _setDataUser(FirebaseUser user) async {
  await Firestore.instance.collection("Users").document(user.uid).setData(
    {
      'userId': user.uid,
      'UserName': user.displayName,
      'Pictures': FieldValue.arrayUnion([user.photoUrl]),
      'phoneNumber': user.phoneNumber,
      'timestamp': FieldValue.serverTimestamp()
    },
    merge: true,
  );
}
