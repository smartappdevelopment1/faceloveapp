import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hookup4u/util/color.dart';
import 'package:hookup4u/util/snackbar.dart';
import 'package:hookup4u/util/strings.dart';
import 'package:mapbox_search_flutter/mapbox_search_flutter.dart';
import 'AllowLocation.dart';

class SearchLocation extends StatefulWidget {
  final Map<String, dynamic> userData;
  SearchLocation(this.userData);

  @override
  _SearchLocationState createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  MapBoxPlace _mapBoxPlace;
  TextEditingController _city = TextEditingController();
  //Add here your mapbox token
  String _mapboxApi = "pk.eyJ1IjoiZmFjZWxvdmUiLCJhIjoiY2trZWNhM3c0MGliMzJ3cGcwcnBvaTQzOSJ9.1kBalL87Tp1WswAcFWuOtw";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
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
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: <Widget>[
                Padding(
                  child: Text(
                    "$selectYouCityText",
                    style: TextStyle(fontSize: 40),
                  ),
                  padding: EdgeInsets.only(left: 50, top: 120),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextField(
                        autofocus: false,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "Enter your city name",
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor)),
                          helperText: "This is how it will appear in App.",
                          helperStyle:
                              TextStyle(color: secondryColor, fontSize: 15),
                        ),
                        controller: _city,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Material(
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 80),
                                            child: MapBoxPlaceSearchWidget(
                                              language: 'en',
                                              popOnSelect: true,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .5,
                                              apiKey: _mapboxApi,
                                              limit: 10,
                                              searchHint:
                                                  'Enter your city name',
                                              onSelected: (place) {
                                                setState(() {
                                                  _mapBoxPlace = place;
                                                  _city.text =
                                                      _mapBoxPlace.placeName;
                                                });
                                              },
                                              context: context,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))),
                      ),
                    ),
                  ],
                ),
                _city.text.length > 0
                    ? Padding(
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
                                height:
                                    MediaQuery.of(context).size.height * .065,
                                width: MediaQuery.of(context).size.width * .75,
                                child: Center(
                                    child: Text(
                                      continueText,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: textColor,
                                      fontWeight: FontWeight.bold),
                                ))),
                            onTap: () async {
                              widget.userData.addAll(
                                {
                                  'location': {
                                    'latitude':
                                        _mapBoxPlace.geometry.coordinates[1],
                                    'longitude':
                                        _mapBoxPlace.geometry.coordinates[0],
                                    'address': "${_mapBoxPlace.placeName}"
                                  },
                                  'maximum_distance': 20,
                                  'age_range': {
                                    'min': "20",
                                    'max': "50",
                                  },
                                },
                              );

                              showWelcomDialog(context);
                              setUserData(widget.userData);
                            },
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: InkWell(
                            child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                height:
                                    MediaQuery.of(context).size.height * .065,
                                width: MediaQuery.of(context).size.width * .75,
                                child: Center(
                                    child: Text(
                                      continueText,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: secondryColor,
                                      fontWeight: FontWeight.bold),
                                ))),
                            onTap: () {
                              CustomSnackbar.snackbar(
                                  "$selectALocationText", _scaffoldKey);
                            },
                          ),
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
