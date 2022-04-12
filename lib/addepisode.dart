import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:google_fonts/google_fonts.dart';

class AddEpisode extends StatefulWidget {
  final String name;
  const AddEpisode({Key? key, required this.name}) : super(key: key);

  @override
  State<AddEpisode> createState() => _AddEpisodeState();
}

class _AddEpisodeState extends State<AddEpisode> {
  bool _loadingPath = false;
  String? _fileName;
  String? _extension;
  String? _directoryPath;

  String audiourl = "";
  File? file;
  List<PlatformFile>? _paths;
  List<UploadTask> _tasks = <UploadTask>[];
  FileType _pickingType = FileType.any;

  bool uploaded = false;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController desccontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 55,
            ),
            Text(
              "Add Episode",
              style: GoogleFonts.dmSans(
                textStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 0),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Episode Name : ',
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
              'Episode Description : ',
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
            Row(
              children: [
                Text(
                  'Attach Music : ',
                  style: GoogleFonts.dmSans(
                    textStyle: TextStyle(
                      color: Colors.white,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                Text(
                  _fileName.toString(),
                  style: GoogleFonts.dmSans(
                    textStyle: TextStyle(
                      color: Colors.white,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            IconButton(
                onPressed: () {
                  selectFile();
                },
                icon: Icon(
                  Icons.attach_file,
                  color: Colors.white,
                )),
            audiourl != ""
                ? GestureDetector(
                    onTap: () {
                      //               String selTime =
                      //     DateTime.now().hour.toString() + ':' + DateTime.now().minute.toString() + ':00';
                      // print(DateFormat.jm().format(DateFormat("hh:mm:ss").parse(selTime)));
                      //               print(DateTime.now().hour.toString() +
                      //                   " - " +
                      //                   DateTime.now().minute.toString() +
                      //                   DateTime.now().timeZoneName);
                      var now = new DateTime.now();
                      var formatter = new DateFormat('yyyy-MM-dd');
                      String formattedDate = formatter.format(now);
                      print(formattedDate); // 2016-01-25
                      FirebaseFirestore.instance
                          .collection("podcastplayer")
                          .doc(widget.name)
                          .collection("episodes")
                          .doc(namecontroller.text.toString())
                          .set({
                        "episode name": namecontroller.text.toString(),
                        "desc": desccontroller.text.toString(),
                        "date": formattedDate,
                        "min": "0",
                        "url": audiourl
                      });
                    },
                    child: Container(
                        child: Center(
                          child: Text(
                            "UPLOAD",
                            style: GoogleFonts.dmSans(
                              textStyle: TextStyle(
                                color: Colors.white,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.red[900],
                            borderRadius: BorderRadius.circular(1)),
                        height: 50,
                        width: MediaQuery.of(context).size.width - 20),
                  )
                : SizedBox()
          ],
        ),
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
      ),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() => file = File(path));
    uploadFile();
  }

  Future uploadFile() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    if (file == null) return;

    final fileName = basename(file!.path);
    final destination = 'files/$fileName';
    setState(() {
      _fileName = fileName;
    });

    TaskSnapshot task = await storage.ref(fileName).putFile(
          file!,
          // SettableMetadata(customMetadata: {
          //   'uploaded_by': 'A bad guy',
          //   'description': 'Some description...'
          // }
        );

    // task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task.ref.getDownloadURL();
    setState(() {});
    setState(() {
      audiourl = snapshot;
    });
    setState(() {});

    // final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download-Link: $snapshot');
  }

  void _openFileExplorer() async {
    //   Future selectFile() async {
    //   final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    //   if (result == null) return;
    //   final path = result.files.single.path!;

    //   setState(() => file = File(path));
    // }
    //   setState(() => _loadingPath = true);
    //   try {
    //     _directoryPath = null;
    //   FilePickerResult?  _paths = await FilePicker.platform.pickFiles();

    //     // FilePicker.platform.pickFiles(
    //     //   type: _pickingType,
    //     //   allowedExtensions: (_extension?.isNotEmpty ?? false)
    //     //       ? _extension?.replaceAll(' ', '').split(',')
    //     //       : null,

    //     // ?.files;
    //     String fileName = _directoryPath!.split('/').last;
    //     String filePath = _directoryPath!;
    //     // upload("jd", filePath);
    //     Reference storageref =
    //         FirebaseStorage.instance.ref().child(DateTime.now().toString());
    //     Future<TaskSnapshot> uploadTaskSnapshot =
    //         storageref.putFile(_paths.first.).whenComplete(() async {
    //       setState(() async {
    //         uploaded = true;
    //         String imgurl = await storageref.getDownloadURL();
    //         print(imgurl);
    //       });
    //     });
    //   } on PlatformException catch (e) {
    //     print("Unsupported operation" + e.toString());
    //   } catch (ex) {
    //     print(ex);
    //   }
    //   // if (!mounted) return;
    //   setState(() {
    //     _loadingPath = false;
    //     print(_paths!.first.extension);
    //     _fileName =
    //         _paths != null ? _paths!.map((e) => e.name).toString() : '...';
    //   });
    // }

    // void upload(String fileName, String filePath) {
    //   _extension = fileName.toString().split('.').last;
    //   Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
    //   final UploadTask uploadTask = storageRef.putFile(
    //     File(filePath),
    //     // StorageMetadata(
    //     //   contentType: '$_pickType/$_extension',
    //     // ),
    //   );
    //   setState(() {
    //     _tasks.add(uploadTask);
    //   });
    // }
  }
}
