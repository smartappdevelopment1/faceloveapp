import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hookup4u/Screens/Chat/chatPage.dart';
import 'package:hookup4u/Screens/Payment/subscriptions.dart';
import 'package:hookup4u/models/user_model.dart';
import 'package:hookup4u/util/color.dart';
import 'package:hookup4u/util/strings.dart';
import 'dart:ui';

class Matches extends StatelessWidget {
  final User currentUser;
  final List<User> matches;
  final Map items;

  Matches(this.currentUser, this.matches,this.items);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '$newMatchText',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_horiz,
                ),
                iconSize: 30.0,
                color: Colors.white,
                onPressed: () {},
              ),
            ],
          ),
        ),
        Container(
            height: 75.0,
            child: matches.length > 0
                ? Row(

                  children: [

                    Padding(
                      padding: EdgeInsets.fromLTRB(10.0,0,10,0),
                      child: Column(
                        children: <Widget>[

                          BlurredImage(currentUser:currentUser,items: items,),
                         SizedBox(height: 3.0),
                                          Text(
                                           "New",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 10.0,

                                            ),
                                          ),

                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ListView.builder(


                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: matches.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (_) => ChatPage(
                                          sender: currentUser,
                                          chatId: chatId(currentUser, matches[index]),
                                          second: matches[index],
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(5.0,0,5,0),
                                      child: Column(
                                        children: <Widget>[
                                          CircleAvatar(
                                            backgroundColor: secondryColor,
                                            radius: 25.0,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(90),
                                              child: Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(100),
                                                    image: DecorationImage(
                                                        image: CachedNetworkImageProvider(
                                                            matches[index].imageUrl[0]
                                                        ),
                                                        fit: BoxFit.cover
                                                    )
                                                ),
                                              )
                                            ),
                                          ),
                                          SizedBox(height: 3.0),
                                          Text(
                                            matches[index].name,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                : Center(
                    child: Text(
                    "$noMatchFoundText",
                    style: TextStyle(color: secondryColor, fontSize: 16),
                  ))),
      ],
    );
  }
}

var groupChatId;
chatId(currentUser, sender) {
  if (currentUser.id.hashCode <= sender.id.hashCode) {
    return groupChatId = '${currentUser.id}-${sender.id}';
  } else {
    return groupChatId = '${sender.id}-${currentUser.id}';
  }
}


class BlurredImage extends StatefulWidget {
  final Map items;
  final User currentUser;

  BlurredImage({this.items,this.currentUser});

  @override
  _BlurredImageState createState() => _BlurredImageState();
}

class _BlurredImageState extends State<BlurredImage> {
  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Subscription(widget.currentUser, null, widget.items)));
      }
      ,
      child: Stack(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(
                    image: CachedNetworkImageProvider(
                        "https://images.pexels.com/photos/2065725/pexels-photo-2065725.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"
                    ),
                    fit: BoxFit.cover
                )
            ),

          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1,sigmaY: 1),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.transparent.withOpacity(0.1)
                ),

              ),
            ),
          )
        ],
      ),
    );
  }
}

