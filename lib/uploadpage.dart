import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podcastplayer/addepisode.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _fileName;
  List<PlatformFile>? _paths;
  String? _directoryPath;
  String? _extension;
  bool _loadingPath = false;

  FileType _pickingType = FileType.any;

  @override
  void initState() {
    super.initState();
  }

  void _clearCachedFiles() {
    FilePicker.platform.clearTemporaryFiles().then((result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: result! ? Colors.green : Colors.red,
          content: Text((result
              ? 'Temporary files removed with success.'
              : 'Failed to clean temporary files')),
        ),
      );
    });
  }

  void _selectFolder() {
    FilePicker.platform.getDirectoryPath().then((value) {
      setState(() => _directoryPath = value);
    });
  }

  File? img;
  String imgurl = "";
  final picker = ImagePicker();

  bool uploaded = false;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController desccontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Upload Podcast',
          style: GoogleFonts.dmSans(
            textStyle: TextStyle(
              color: Colors.white,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'Source : BBC ',
              style: GoogleFonts.dmSans(
                textStyle: TextStyle(
                  color: Colors.white,
                  letterSpacing: 0,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Podcast Name : ',
              style: GoogleFonts.dmSans(
                textStyle: TextStyle(
                  color: Colors.white,
                  letterSpacing: 0,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              height: 50,
              child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade800, width: .5),
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                  controller: namecontroller),
              width: MediaQuery.of(context).size.width - 20,
              color: Colors.grey[900],
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Podcast Description : ',
              style: GoogleFonts.dmSans(
                textStyle: TextStyle(
                  color: Colors.white,
                  letterSpacing: 0,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              height: 50,
              child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade800, width: .5),
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                  controller: desccontroller),
              width: MediaQuery.of(context).size.width - 20,
              color: Colors.grey[900],
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Podcast Image : ',
              style: GoogleFonts.dmSans(
                textStyle: TextStyle(
                  color: Colors.white,
                  letterSpacing: 0,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: img == null
                  ? GestureDetector(
                      onTap: () async {
                        await ImagePicker()
                            .getImage(source: ImageSource.gallery)
                            .then((image) {
                          setState(() {
                            img = File(image!.path);
                            if (img != null) {
                              Reference storageref = FirebaseStorage.instance
                                  .ref()
                                  .child(DateTime.now().toString());
                              Future<TaskSnapshot> uploadTaskSnapshot =
                                  storageref
                                      .putFile(img!)
                                      .whenComplete(() async {
                                setState(() async {
                                  uploaded = true;
                                  setState(() {});
                                  imgurl = await storageref.getDownloadURL();
                                  print(imgurl);
                                  setState(() {});
                                });
                              });
                            } else {
                              print("Doesn't selected");
                            }
                          });
                        });
                      },
                      child: Container(
                        child: Center(
                          child: Text(
                            "Choose Image",
                            style: GoogleFonts.dmSans(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                  fontSize: 15,
                                  letterSpacing: 0),
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(0)),
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                          image: new DecorationImage(
                            image: new FileImage(img!),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(0)),
                      height: 150,
                      width: MediaQuery.of(context).size.width,
                    ),
            ),
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () async {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return AddEpisode(
                    name: namecontroller.text.toString(),
                  );
                }));
              },
              child: Container(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "ADD EPISODE",
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[300],
                                fontSize: 13,
                                letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(0)),
                  height: 50,
                  width: MediaQuery.of(context).size.width),
            ),
            SizedBox(
              height: 15,
            ),
            imgurl == ""
                ? SizedBox()
                : GestureDetector(
                    onTap: () async {
                      FirebaseFirestore.instance
                          .collection("podcastplayer")
                          .doc(namecontroller.text.toString())
                          .set({
                        "img": imgurl,
                        "source": "BBC",
                        "name": namecontroller.text.toString(),
                        "desc": desccontroller.text.toString()
                      });
                    },
                    child: Container(
                        child: Center(
                          child: Text(
                            "UPLOAD PODCAST",
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 13,
                                  letterSpacing: 0.5),
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(0)),
                        height: 50,
                        width: MediaQuery.of(context).size.width),
                  ),
          ],
        ),
      ),
    );
  }
}
