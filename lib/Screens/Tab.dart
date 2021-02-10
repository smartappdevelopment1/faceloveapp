import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hookup4u/Screens/Profile/profile.dart';
import 'package:hookup4u/Screens/Splash.dart';
import 'package:hookup4u/Screens/blockUserByAdmin.dart';
import 'package:hookup4u/Screens/notifications.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/strings.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'Chat/home_screen.dart';
import 'Home.dart';
import 'package:hookup4u/util/color.dart';

import 'Calling/incomingCall.dart';

List likedByList = [];

class Tabbar extends StatefulWidget {
  final bool isPaymentSuccess;
  final String plan;
  Tabbar(this.plan, this.isPaymentSuccess);
  @override
  TabbarState createState() => TabbarState();
}

//_
class TabbarState extends State<Tabbar> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  CollectionReference docRef = Firestore.instance.collection('Users');
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User currentUser;
  List<User> matches = [];
  List<User> newmatches = [];


  List<User> users = [];

  /// Past purchases
  List<PurchaseDetails> purchases = [];
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;
  bool isPuchased = false;
  @override
  void initState() {
    super.initState();
    // Show payment success alert.
    if (widget.isPaymentSuccess != null && widget.isPaymentSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Alert(
          context: context,
          type: AlertType.success,
          title: "$confirmationText",
          desc: "${youHaveSuccessfullySubscribedText.replaceAll("_", widget.plan)}",

          buttons: [
            DialogButton(
              child: Text(
                "$okText",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              width: 120,
            )
          ],
        ).show();
      });
    }
    _getAccessItems();
    _getCurrentUser();
    _getMatches();
    _getpastPurchases();
  }

  Map items = {};
  _getAccessItems() async {
    Firestore.instance.collection("Item_access").snapshots().listen((doc) {
      if (doc.documents.length > 0) {
        items = doc.documents[0].data;
        print(doc.documents[0].data);
      }

      if (mounted) setState(() {});
    });
  }

  Future<void> _getpastPurchases() async {
    print('in past purchases');
    QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();
    print('response   ${response.pastPurchases}');
    for (PurchaseDetails purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        await _iap.completePurchase(purchase);
      }
    }
    setState(() {
      purchases = response.pastPurchases;
    });
    if (response.pastPurchases.length > 0) {
      purchases.forEach((purchase) async {
        print('   ${purchase.productID}');
        await _verifyPuchase(purchase.productID);
      });
    }
  }

  /// check if user has pruchased
  PurchaseDetails _hasPurchased(String productId) {
    return purchases.firstWhere((purchase) => purchase.productID == productId,
        orElse: () => null);
  }

  ///verifying pourchase of user
  Future<void> _verifyPuchase(String id) async {
    PurchaseDetails purchase = _hasPurchased(id);

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      print(purchase.productID);
      if (Platform.isIOS) {
        await _iap.completePurchase(purchase);
        print('Achats antérieurs........$purchase');
        isPuchased = true;
      }
      isPuchased = true;
    } else {
      isPuchased = false;
    }
  }

  int swipecount = 0;

  bool swipeScreen = true;

  _getSwipedcount() {
    Firestore.instance
        .collection('/Users/${currentUser.id}/CheckedUser')
        .where(
          'timestamp',
          isGreaterThan: Timestamp.now().toDate().subtract(Duration(days: 1)),
        )
        .snapshots()
        .listen((event) {
      print(event.documents.length);
      setState(() {
        swipecount = event.documents.length;
      });
      return event.documents.length;
    });
  }

  configurePushNotification(User user) {

    _firebaseMessaging.requestNotificationPermissions();

    _firebaseMessaging.getToken().then((token) {
      print(token);
      docRef.document(user.id).updateData({
        'pushToken': token,
      });
    });



    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) async {
        print('===============onLaunch$message');
        if (message['data']['type'] == 'Call') {
          bool iscallling =
              await _checkcallState(message['data']['channel_id']);
          if (iscallling) {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Incoming(message['data'])));
          }
        }
      },
      onMessage: (Map<String, dynamic> message) async {
        print(message);
        print('onMessage${message['notification']['title']}');
        if (message['data']['type'] == 'Call') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Incoming(message['data'])));
        } else{
          showSimpleNotification(
              Text("${message['notification']['title']}:${message['notification']['body']}"),
              background: Colors.green);
        }
          print("object");
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume$message');
        if (message['data']['type'] == 'Call') {
          bool iscallling =
              await _checkcallState(message['data']['channel_id']);
          if (iscallling) {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Incoming(message['data'])));
          } else {
            print("Timeout");
          }
        }
      },
    );
  }

  _checkcallState(channelId) async {
    bool iscalling = await Firestore.instance
        .collection("calls")
        .document(channelId)
        .get()
        .then((value) {
      return value.data["calling"] ?? false;
    });
    return iscalling;
  }

  _getMatches() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return Firestore.instance
        .collection('/Users/${user.uid}/Matches')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((ondata) {
      matches.clear();
      newmatches.clear();
      if (ondata.documents.length > 0) {
        ondata.documents.forEach((f) async {
          DocumentSnapshot doc = await docRef.document(f.data['Matches']).get();
          if (doc.exists) {
            User tempuser = User.fromDocument(doc);
            tempuser.distanceBW = calculateDistance(
                    currentUser.coordinates['latitude'],
                    currentUser.coordinates['longitude'],
                    tempuser.coordinates['latitude'],
                    tempuser.coordinates['longitude'])
                .round();

            matches.add(tempuser);
            newmatches.add(tempuser);
            if (mounted) setState(() {});
          }
        });
      }
    });
  }

  _getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return docRef.document("${user.uid}").snapshots().listen((data) async {
      currentUser = User.fromDocument(data);
      if (mounted) setState(() {});
      users.clear();
      userRemoved.clear();
      getUserList();
      getLikedByList();
      configurePushNotification(currentUser);
      if (!isPuchased) {
        _getSwipedcount();
      }
      return currentUser;
    });
  }

  query() {
    if (currentUser.showGender == 'everyone') {
      return docRef
          .where(
            'age',
            isGreaterThanOrEqualTo: int.parse(currentUser.ageRange['min']),
          )
          .where('age',
              isLessThanOrEqualTo: int.parse(currentUser.ageRange['max']))
          .orderBy('age', descending: false);
    } else {
      return docRef
          .where('editInfo.userGender', isEqualTo: currentUser.showGender)
          .where(
            'age',
            isGreaterThanOrEqualTo: int.parse(currentUser.ageRange['min']),
          )
          .where('age',
              isLessThanOrEqualTo: int.parse(currentUser.ageRange['max']))
          //FOR FETCH USER WHO MATCH WITH USER SEXUAL ORIENTAION
          // .where('sexualOrientation.orientation',
          //     arrayContainsAny: currentUser.sexualOrientation)
          .orderBy('age', descending: false);
    }
  }

  Future getUserList() async {
    List checkedUser = [];
    Firestore.instance
        .collection('/Users/${currentUser.id}/CheckedUser')
        .getDocuments()
        .then((data) {
      checkedUser.addAll(data.documents.map((f) => f['DislikedUser']));
      checkedUser.addAll(data.documents.map((f) => f['LikedUser']));
    }).then((_) {
      query().getDocuments().then((data) async {
        if (data.documents.length < 1) {
          print("no more data");
          return;
        }
        users.clear();
        userRemoved.clear();
        for (var doc in data.documents) {
          User temp = User.fromDocument(doc);
          var distance = calculateDistance(
              currentUser.coordinates['latitude'],
              currentUser.coordinates['longitude'],
              temp.coordinates['latitude'],
              temp.coordinates['longitude']);
          temp.distanceBW = distance.round();
          if (checkedUser.any(
            (value) => value == temp.id,
          )) {
          } else {
            if (distance <= currentUser.maxDistance &&
                temp.id != currentUser.id &&
                !temp.isBlocked) {
              users.add(temp);
            }
          }
        }
        if (mounted) setState(() {});
      });
    });
  }

  getLikedByList() {
    docRef
        .document(currentUser.id)
        .collection("LikedBy")
        .snapshots()
        .listen((data) async {
      likedByList.addAll(data.documents.map((f) => f['LikedBy']));
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
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
      child: Scaffold(
        body: currentUser == null
            ? Center(child: Splash())
            : currentUser.isBlocked
                ? BlockUser()
                : DefaultTabController(

                    length: 4,
                    initialIndex: widget.isPaymentSuccess != null
                        ? widget.isPaymentSuccess ? 0 : 1
                        : 1,
                    child: Scaffold(
                        appBar: AppBar(
                          elevation: 0,
                          backgroundColor: primaryColor,
                          automaticallyImplyLeading: false,
                          title: TabBar(
                            onTap: (i){
                              print(i);
                              if(i==1){
                                swipeScreen=true;

                              }else{
                                swipeScreen=false;
                              }
                              setState(() {

                              });
                            },
                              labelColor: Colors.white,
                              indicatorColor: Colors.white,
                              unselectedLabelColor: Colors.black,
                              isScrollable: false,


                              indicatorSize: TabBarIndicatorSize.label,
                              tabs: [
                                Tab(
                                  icon: Icon(
                                    Icons.person,
                                    size: 30,
                                  ),
                                ),
                                Tab(
                                  icon: Image.asset("asset/cardIcon.png",width: 30,height: 25,
                                      color: swipeScreen?Colors.white:Colors.black,),
                                ),

                                Tab(
                                  icon: Icon(
                                    Icons.notifications,
                                  ),
                                ),
                                Tab(
                                  icon: Icon(
                                    Icons.message,
                                  ),
                                )
                              ]),
                        ),
                        body: TabBarView(
                          children: [
                            Center(
                                child: Profile(
                                    currentUser, isPuchased, purchases, items)),
                            Center(
                                child: CardPictures(
                                    currentUser, users, swipecount, items)),
                            Center(child: Notifications(currentUser)),
                            Center(
                                child: HomeScreen(
                                    currentUser, matches, newmatches)),
                          ],
                          physics: NeverScrollableScrollPhysics(),
                        )),
                  ),
      ),
    );
  }
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}
