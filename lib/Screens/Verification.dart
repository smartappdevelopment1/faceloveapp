import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hookup4u/Screens/University.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/color.dart';
import 'package:hookup4u/util/snackbar.dart';
import 'package:hookup4u/util/strings.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'AllowLocation.dart';

class VerificationImage extends StatefulWidget {
  final Map<String, dynamic> userData;
  VerificationImage(this.userData);


  @override
  _VerificationImageState createState() => _VerificationImageState();
}

class _VerificationImageState extends State<VerificationImage> {
  String university = '';
  String uploadedImage;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String code="";
  FirebaseUser user;
  bool loading=false;

  verificationCode() async {

    var _random = new Random();
    code = ( _random.nextInt(4) +1 ).toString();

    await FirebaseAuth.instance.currentUser().then((value) {
      user=value;
    });

    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    verificationCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      floatingActionButton: AnimatedOpacity(
        opacity: 1.0,
        duration: Duration(milliseconds: 50),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: FloatingActionButton(
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(
                  "$humanVerificationText",
                  style: TextStyle(fontSize: 40),
                ),
                padding: EdgeInsets.only(left: 50, top: 120),
              ),

            loading?Expanded(child: Center(child: SizedBox(width: 50,height: 50,child: CircularProgressIndicator()))): Expanded(
               child: Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text("$takeASelifeWithFingerText $code ${code=="1"? "$fingerText":"$fingersText"} "),

                     SizedBox(height: 30,),
                     GestureDetector(
                       onTap: (){
                         getImage();
                       },
                       child: Container(
                         width: MediaQuery.of(context).size.width*.6,
                         height: MediaQuery.of(context).size.width*.6,
                         decoration: BoxDecoration(color: primaryColor,
                         borderRadius: BorderRadius.circular(10),
                           boxShadow: [
                             BoxShadow(color: Colors.grey.withOpacity(0.3),blurRadius: 5,spreadRadius: 5),
                           ],
                           image: DecorationImage(
                             image: uploadedImage!=null? CachedNetworkImageProvider(uploadedImage):
                                 AssetImage("asset/selfie.png",),
                             fit: BoxFit.cover

                           ),
                         ),
                       ),
                     ),
                     SizedBox(height: 10,),
                     Text("$clickOnImageToTakeSelifeText"),

                   ],
                 ),
               ),
             ),

            uploadedImage!=null?
            Padding(
                padding: const EdgeInsets.only(bottom: 40),
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
                              "$continueText",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: textColor,
                                  fontWeight: FontWeight.bold),
                            ))),
                    onTap: () {


                      print(widget.userData);
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) =>
                                  University(widget.userData)));
                    },
                  ),
                ),
              ):
            Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        height: MediaQuery.of(context).size.height * .065,
                        width: MediaQuery.of(context).size.width * .75,
                        child: Center(
                            child: Text(
                              "$continueText",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: secondryColor,
                                  fontWeight: FontWeight.bold),
                            ))),
                    onTap: () {
                      CustomSnackbar.snackbar(
                          "$pleaseUploadImageText", _scaffoldKey);
                    },
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera,imageQuality: 70,maxHeight: 400);
    if (image != null) {
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Crop',
              toolbarColor: primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      if (croppedFile != null) {
        print("Uploading Image");
        loading = true;
        setState(() {

        });
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child('users/${user==null?"dummy":user.uid}/verification.jpg');
        StorageUploadTask uploadTask = storageReference.putFile(image);
        if (uploadTask.isInProgress == true) {}
        if (await uploadTask.onComplete != null) {
          print("Image Uploaded ");
          storageReference.getDownloadURL().then((fileURL) async {
            print("Image Uploaded $fileURL ");

            uploadedImage=fileURL;
          widget.userData.addAll({
            "verificationCode":code,
            "verificationImage":fileURL,
            "verified":true,
            "rejected":false
          });
            loading = false;
            setState(() {

            });
          });
        }
      }
    }

 //   Navigator.pop(context);
  }



}
