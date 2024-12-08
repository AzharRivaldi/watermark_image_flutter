import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../tools/widgets_to_image.dart';
import '../tools/widgetstoimagecontroller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WidgetsToImageController controller = WidgetsToImageController();
  final imagePicker = ImagePicker();
  late String strMessage;
  Uint8List? bytes;
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Watermark Image",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          WidgetsToImage(
            controller: controller,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (BuildContext context) {
                          return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 40, left: 20, right: 20
                              ),
                              child: Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(30))
                                  ),
                                  height: 150,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Flexible(
                                              child: GestureDetector(
                                                onTap: () {
                                                  getFromGallery();
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(20),
                                                  decoration: const BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(200)),
                                                      gradient: LinearGradient(
                                                        begin: Alignment.topCenter,
                                                        end: Alignment.center,
                                                        colors: [
                                                          Colors.red,
                                                          Colors.redAccent
                                                        ],
                                                      )
                                                  ),
                                                  child: const Icon(
                                                    Icons.image_search_outlined,
                                                    color: Colors.white,
                                                    size: 35,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Text(
                                              'Galeri',
                                            ),
                                          ]
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Flexible(
                                            child: GestureDetector(
                                              onTap: () {
                                                getFromCamera();
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(20),
                                                decoration: const BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(200)),
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.center,
                                                      colors: [
                                                        Colors.blue,
                                                        Colors.blueAccent
                                                      ],
                                                    )
                                                ),
                                                child: const Icon(
                                                  Icons.camera_alt_outlined,
                                                  color: Colors.white,
                                                  size: 35,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Text(
                                            'Kamera',
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                              )
                          );
                        });
                  },
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.50,
                    width: MediaQuery.of(context).size.width,
                    child: imageFile != null
                        ? Image.file(File(imageFile!.path), fit: BoxFit.cover)
                        : const Icon(Icons.image_search, size: 300, color: Color(0xFF5A5A5A)
                    )
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 170,
                  right: 0,
                  bottom: 10,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: imageFile != null
                        ? Text(GetDateToday.getDateToday(), style: TextStyle(fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.75)), textAlign: TextAlign.center)
                        : const SizedBox()
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (imageFile != null) {
            final bytes = await controller.capture();
            setState(() {
              this.bytes = bytes;
            });

            saveImage(bytes!);
          }
          else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text('Ups, image not found!', style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Chirp'))
                ],
              ),
              backgroundColor: Colors.red,
              shape: StadiumBorder(),
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        label: const Text('Save Image', style: TextStyle(fontWeight: FontWeight.bold),),
        icon: const Icon(Icons.create),
      ),
    );
  }

  // get from gallery
  getFromGallery() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  // get from camera
  getFromCamera() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future saveImage(Uint8List bytes) async {
    try {
      final strDirectory = await getTemporaryDirectory();
      var random = Random();
      var filename = '${strDirectory.path}/Images${random.nextInt(100)}.png';
      final file = File(filename);
      await file.writeAsBytes(bytes);

      final params = SaveFileDialogParams(sourceFilePath: file.path);
      final finalPath = await FlutterFileDialog.saveFile(params: params);

      if (finalPath != null) {
        strMessage = 'Image saved to disk';
      }
    } catch (e) {
      strMessage = e.toString();
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(
          strMessage,
          style: const TextStyle(
              fontSize: 14),
        ),
      ));
    }
  }
}

class GetDateToday {
  static String getDateToday() {
    var currentDate = DateFormat('EEEE, dd MMM yyyy HH:mm').format(DateTime.now());
    return currentDate;
  }
}
