import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'camera_view.dart';

late List<CameraDescription> cameras;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.onImageSend});

  final Function onImageSend;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> _cameraValue;
  bool _isTakingPicture = false;
  bool flash = false;
  bool isCameraFront = true;
  double transform = 0;
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameraController = CameraController(cameras[0], ResolutionPreset.high);
      _cameraValue = _cameraController.initialize();
      if (mounted) {
        setState(() {}); // Trigger rebuild after camera is initialized
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_cameraController);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            flash = !flash;
                          });
                          _cameraController.setFlashMode(
                              flash ? FlashMode.torch : FlashMode.off);
                        },
                        icon: flash
                            ? const Icon(Icons.flash_on,
                            color: Colors.white, size: 28)
                            : const Icon(Icons.flash_off,
                            color: Colors.white, size: 28),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (!_isTakingPicture) {
                            takePhoto(context);
                          }
                        },
                        child: const Icon(
                          Icons.panorama_fish_eye,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          setState(() {
                            isCameraFront = !isCameraFront;
                            transform += pi;
                          });
                          int cameraPos = isCameraFront ? 0 : 1;
                          _cameraController = CameraController(
                              cameras[cameraPos], ResolutionPreset.high);
                          _cameraValue = _cameraController.initialize();
                          if (mounted) {
                            setState(() {}); // Trigger rebuild after switching camera
                          }
                        },
                        icon: Transform.rotate(
                          angle: transform,
                          child: const Icon(Icons.flip_camera_ios,
                              color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tap for photo",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void takePhoto(BuildContext context) async {
  //   if (_isTakingPicture) return;
  //   setState(() {
  //     _isTakingPicture = true;
  //   });
  //
  //   try {
  //     final XFile picture = await _cameraController.takePicture();
  //     print("Picture taken: ${picture.path}");
  //
  //     // Check if onImageSend is not null before calling it
  //     if (widget.onImageSend != null) {
  //       // In your main.dart or wherever you navigate to CameraScreen
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => CameraScreen(
  //             onImageSend: (String imagePath, String? message) {
  //               print("Image path: $imagePath");
  //               print("Message: $message");
  //               // Handle the image and message sending here
  //             },
  //           ),
  //         ),
  //       );
  //
  //     } else {
  //       print("onImageSend is null");
  //     }
  //   } catch (e) {
  //     // Handle any errors here
  //     print("Error taking picture: $e");
  //   } finally {
  //     setState(() {
  //       _isTakingPicture = false;
  //     });
  //   }
  // }


  Future<void> takePhoto(BuildContext context) async {
    if (_isTakingPicture) return; // Prevent taking multiple pictures simultaneously

    setState(() {
      _isTakingPicture = true; // Indicate that a picture is being taken
    });

    try {
      // Capture the picture using image_picker
      final XFile? picture = await _picker.pickImage(source: ImageSource.camera);

      if (picture == null) {
        print("No picture taken");
        return;
      }

      // Get the app's document directory
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpeg';

      // Save the picture to the temporary directory
      final File imageFile = File(picture.path);
      await imageFile.copy(path);

      // Check if the path is valid
      if (path.isNotEmpty) {
        setState(() {
          _imagePath = path; // Store the image path
          print("Picture taken, path: $_imagePath"); // Debug information
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (builder) => CameraViewPage(
              path: picture.path,
              onImageSend: widget.onImageSend,
            ),
          ),
        );
      } else {
        print("Error: Picture path is empty"); // Debug information
      }

    } catch (e) {
      // Handle any errors during picture capture
      print("Error taking picture: $e");
    } finally {
      setState(() {
        _isTakingPicture = false; // Reset the flag
      });
    }
  }

}
