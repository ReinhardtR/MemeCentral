import 'package:flutter/material.dart';
import 'package:memecentral/variables.dart';

class ContentPage extends StatefulWidget {
  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  buildProfile() {
    return Container(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Positioned(
            left: (60 / 2) - (50 / 2),
            child: Container(
              width: 50,
              height: 50,
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    'https://pbs.twimg.com/media/Ec30a19WsAEot7U.jpg',
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: (60 / 2) - (20 / 2),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // meme
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              color: Colors.black,
            ),
          ),
          Column(
            children: [
              // Top Section
              Container(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Following",
                      style: fontStyle(17, Colors.white, FontWeight.bold),
                    ),
                    SizedBox(width: 7.5),
                    Text(
                      "|",
                      style: fontStyle(17, Colors.white, FontWeight.bold),
                    ),
                    SizedBox(width: 7.5),
                    Text(
                      "Recommended",
                      style: fontStyle(17, Colors.white, FontWeight.bold),
                    ),
                    SizedBox(width: 7.5),
                    Text(
                      "|",
                      style: fontStyle(17, Colors.white, FontWeight.bold),
                    ),
                    SizedBox(width: 7.5),
                    Text(
                      "Trending",
                      style: fontStyle(17, Colors.white, FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Bottom Section
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Left Side
                    Expanded(
                      child: Container(
                        height: 70,
                        padding: EdgeInsets.only(left: 20),
                        margin: EdgeInsets.only(bottom: 5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "@Reinhardt",
                              style: fontStyle(16, Colors.white, FontWeight.bold),
                            ),
                            Text(
                              "Look at the top of his head",
                              style: fontStyle(16, Colors.white, FontWeight.normal),
                            ),
                            Row(
                              children: [
                                Text(
                                  "#123  -  #abc  -  #wasd",
                                  style: fontStyle(14, Colors.white, FontWeight.normal, FontStyle.italic),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right Side
                    Container(
                      width: 100,
                      margin: EdgeInsets.only(top: 150),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildProfile(),
                          // Likes
                          Column(
                            children: [
                              Icon(Icons.favorite, size: 30, color: Colors.white),
                              SizedBox(height: 7),
                              Text(
                                "10",
                                style: fontStyle(14, Colors.white),
                              ),
                            ],
                          ),
                          // Comments
                          Column(
                            children: [
                              Icon(Icons.comment, size: 30, color: Colors.white),
                              SizedBox(height: 7),
                              Text(
                                "5",
                                style: fontStyle(14, Colors.white),
                              ),
                            ],
                          ),
                          // Share
                          Column(
                            children: [
                              Icon(Icons.reply, size: 30, color: Colors.white),
                              SizedBox(height: 7),
                              Text(
                                "3",
                                style: fontStyle(14, Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
