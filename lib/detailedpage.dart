import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class detailedpage extends StatefulWidget {
  final QueryDocumentSnapshot querySnapshot;
  const detailedpage({Key? key, required this.querySnapshot}) : super(key: key);

  @override
  State<detailedpage> createState() => _detailedpageState();
}

class _detailedpageState extends State<detailedpage> {
  late AudioPlayer audioPlayer = new AudioPlayer(mode: PlayerMode.LOW_LATENCY);
  String audiourl = "";

  @override
  void initState() {
    // TODO: implement initState
    audioPlayer = AudioPlayer();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [Icon(Icons.menu)],
        backgroundColor: Colors.black,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        // ignore: avoid_unnecessary_containers
        child: Column(children: [
          Row(
            children: [
              Container(
                  height: 120,
                  width: 120,
                  child: Image.network(widget.querySnapshot['img'])),
              SizedBox(
                width: 30,
              ),
              Column(
                children: [
                  Text(
                    widget.querySnapshot['name'],
                    style: GoogleFonts.dmSans(
                      textStyle: TextStyle(
                          color: Colors.white,
                          letterSpacing: 1.5,
                          fontSize: 15),
                    ),
                  ),
                  Text(
                    widget.querySnapshot['source'],
                    style: GoogleFonts.dmSans(
                      textStyle: TextStyle(
                        color: Colors.grey,
                        letterSpacing: 0,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Container(
                child: Center(
                  child: Text(
                    'Subscribe',
                    style: GoogleFonts.dmSans(
                      textStyle: TextStyle(
                        color: Colors.white,
                        letterSpacing: 0.5,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                height: 35,
                width: 120,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[900]),
              ),
              SizedBox(width: 20),
              Icon(
                Icons.share,
                color: Colors.white,
              )
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            height: 60,
            alignment: Alignment.topLeft,
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 20),
            child: Text(
              widget.querySnapshot['desc'],
              textAlign: TextAlign.left,
              style: GoogleFonts.dmSans(
                textStyle: TextStyle(
                  color: Colors.white,
                  letterSpacing: 0,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              SizedBox(width: 12),
              Text(
                '2 Episodes',
                style: GoogleFonts.dmSans(
                  textStyle: TextStyle(
                    color: Colors.white,
                    letterSpacing: 0,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 13,
          ),
          Container(
            height: 1,
            width: MediaQuery.of(context).size.width - 20,
            color: Colors.white,
          ),
          SizedBox(
            height: 13,
          ),
          Expanded(
            child: Container(
              height: 200,
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("podcastplayer")
                      .doc(widget.querySnapshot['name'])
                      .collection("episodes")
                      .snapshots(),
                  builder: (context, snapshots) {
                    if (!snapshots.hasData) {
                      return LinearProgressIndicator(
                        color: Colors.grey[900],
                        backgroundColor: Colors.black,
                      );
                    }
                    return ListView.builder(
                        itemCount: snapshots.data!.docs.length,
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.grey.shade900,
                            height: 150,
                            width: MediaQuery.of(context).size.width - 20,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        snapshots.data!.docs[index]['date'],
                                        style: GoogleFonts.dmSans(
                                          textStyle: TextStyle(
                                            color: Colors.white,
                                            letterSpacing: 0,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        snapshots.data!.docs[index]
                                            ['episode name'],
                                        style: GoogleFonts.dmSans(
                                          textStyle: TextStyle(
                                            color: Colors.white,
                                            letterSpacing: 0,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                20,
                                            maxHeight: 40),
                                        child: Text(
                                          snapshots.data!.docs[index]['desc'],
                                          maxLines: 3,
                                          style: GoogleFonts.dmSans(
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              letterSpacing: 0,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Container(
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                  onTap: () async {
                                                    setState(() {
                                                      audiourl = snapshots.data!
                                                          .docs[index]['url'];
                                                    });

                                                    // await audioPlayer.setUrl(
                                                    //     "https://firebasestorage.googleapis.com/v0/b/podcast-player-9bd14.appspot.com/o/2022-04-12%2016%3A05%3A55.681894?alt=media&token=ea0ac4a0-69ef-4ff3-9a63-12ef21078f61");
                                                    // int result =
                                                    //     await audioPlayer.play(
                                                    //         "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3");

                                                    // print(result);
                                                  },
                                                  child:
                                                      Icon(Icons.play_arrow)),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                snapshots.data!.docs[index]
                                                    ['min'],
                                                style: GoogleFonts.dmSans(
                                                  textStyle: TextStyle(
                                                    color: Colors.black,
                                                    letterSpacing: 0,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        height: 30,
                                        width: 100,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      SizedBox(
                                        width: 30,
                                      ),
                                      Icon(
                                        Icons.save,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 30,
                                      ),
                                      Icon(
                                        Icons.download,
                                        color: Colors.white,
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.menu,
                                        color: Colors.white,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  }),
            ),
          ),
          Container(
            height: 80,
            width: MediaQuery.of(context).size.width,
            color: Colors.grey[900],
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    await audioPlayer.play(audiourl);
                  },
                  child: Icon(
                    Icons.play_arrow_outlined,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    await audioPlayer.stop();
                  },
                  child: Icon(
                    Icons.pause_circle_outline,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
