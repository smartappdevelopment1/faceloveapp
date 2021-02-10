import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class User {
  final String id;
  final String name;
  final bool isBlocked;
  String address;
  final Map coordinates;
  final List sexualOrientation;
  final String gender;
  final String showGender;
  final int age;
  final String phoneNumber;
  String verificationCode;
  String verificationImage;
  int maxDistance;
  Timestamp lastmsg;
  final Map ageRange;
  final Map editInfo;
  List imageUrl = [];
  var distanceBW;
  bool verified;
  bool rejected;

  User({
    @required this.id,
    @required this.age,
    @required this.address,
    this.isBlocked,
    this.coordinates,
    @required this.name,
    @required this.imageUrl,
    this.phoneNumber,
     this.lastmsg,
    this.gender,
    this.showGender,
    this.ageRange,
    this.maxDistance,
    this.editInfo,
    this.distanceBW,
    this.sexualOrientation,
    this.verificationCode,
    this.verificationImage,
    this.verified,
    this.rejected
  });
  factory User.fromDocument(DocumentSnapshot doc) {
    // DateTime date = DateTime.parse(doc["user_DOB"]);
    return User(
        id: doc['userId'],
        isBlocked: doc['isBlocked'] != null ? doc['isBlocked'] : false,
        phoneNumber: doc['phoneNumber'],
        name: doc['UserName'],
        editInfo: doc['editInfo'],
        ageRange: doc['age_range'],
        showGender: doc['showGender'],
        maxDistance: doc['maximum_distance'],
        sexualOrientation: doc['sexualOrientation']['orientation'] ?? "",
        age: ((DateTime.now()
                    .difference(DateTime.parse(doc["user_DOB"]))
                    .inDays) /
                365.2425)
            .truncate(),
        address: doc['location']['address'],
        coordinates: doc['location'],
        verificationCode: doc['verificationCode'],
        verificationImage: doc['verificationImage'],
        verified: doc['verified'],
        rejected: doc['rejected'],
        // university: doc['editInfo']['university'],
        imageUrl: doc['Pictures'] != null
            ? List.generate(doc['Pictures'].length, (index) {
                return doc['Pictures'][index];
              })
            : null);
  }
}