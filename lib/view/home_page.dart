import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:chat_bot_gemini/constants/static_values.dart';
import 'package:chat_bot_gemini/custom_ui/own_message_card.dart';
import 'package:chat_bot_gemini/custom_ui/reply_message_card.dart';
import 'package:chat_bot_gemini/model/model_message.dart';
import 'package:chat_bot_gemini/screens/camera_screen.dart';
import 'package:chat_bot_gemini/screens/camera_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as google_generative_ai;

class IndividualPage extends StatefulWidget {

  const IndividualPage({super.key, this.userAddedImagePath, this.userMessage});

  final String? userAddedImagePath;
  final String? userMessage;


  @override
  State<IndividualPage> createState() => _IndividualPageState();
}

class _IndividualPageState extends State<IndividualPage> {
  TextEditingController textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  List<String> messages = [];
  bool _isTakingPicture = false; // Flag to track if a picture is being taken
  final ImagePicker _picker = ImagePicker();
  static final apiKey = StaticValues.geminiApiKey;
  final model = GenerativeModel(model: "gemini-1.5-flash", apiKey: apiKey);

  DateFormat dateFormat = DateFormat('yyyy-MM-dd'); // Adjust format as per timestamp

  final List<ModelMessage> prompt = [];
  String? _imagePath;
  String geminiResponse = "waiting";

  @override
  void initState() {
    super.initState();
    if (widget.userAddedImagePath != null && widget.userMessage != null) {
      onImageSend(widget.userAddedImagePath!, widget.userMessage!);
    }
    _scrollToBottom();
  }


  Future<void> onImageSend(String imagePath, String message) async {
    if (imagePath.isEmpty) {
      _showErrorDialog(context, "Failed to capture image. Please try again.");
      return;
    }

    final bytes = File(imagePath).readAsBytesSync();
    final mimeType = 'image/jpeg';

    final List<google_generative_ai.Content> content = [
      google_generative_ai.Content.text(message),
      google_generative_ai.Content.data(mimeType, Uint8List.fromList(bytes)),
    ];

    try {
      final response = await model.generateContent(content);
      if (response.text != null) {
        // Add the user message immediately
        setState(() {
          prompt.add(
            ModelMessage(
              message: message,
              time: DateTime.now(),
              imagePath: imagePath,
              type: MessageType.user,
            ),
          );
          _scrollToBottom(); // Ensure the chat scrolls to the bottom
        });

        // Delay before adding the model response
        await Future.delayed(const Duration(seconds: 2)); // Adjust the delay as needed

        setState(() {
          prompt.add(
            ModelMessage(
              message: response.text!,
              time: DateTime.now(),
              type: MessageType.model,
            ),
          );
          _scrollToBottom(); // Ensure the chat scrolls to the bottom
        });
      } else {
        _showErrorDialog(context, "Received empty response from the model.");
      }
    } catch (e) {
      print("Error sending image to model: $e");
      _showErrorDialog(context, "Failed to send message. Please try again.");
    }

    // Optionally, delete the image file if needed
    // try {
    //   final file = File(imagePath);
    //   if (await file.exists()) {
    //     await file.delete();
    //   }
    // } catch (e) {
    //   print("Error deleting image file: $e");
    // }
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/pexels-hngstrm-1939485.jpg",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leadingWidth: 70,
            titleSpacing: 0,
            backgroundColor: Theme.of(context).primaryColor,
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blueGrey,
                    child: ClipOval(
                      child: Image.asset(
                        "assets/icon.jpg",
                        height: 40,
                        width: 40,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            title: InkWell(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.all(5),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Gemini",
                      style: const TextStyle(
                          fontSize: 18.5,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Talk to me",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: prompt.length,
                      itemBuilder: (context, index) {
                        final message = prompt[index];
                        if (message.type == MessageType.user) {
                          return OwnMessageCard(
                            message: message.message,
                            time: dateFormat.format(DateTime.parse(message.time.toString())),
                            imagePath: message.imagePath,
                          );
                        } else {
                          return ReplyMessageCard(
                            message: message.message,
                            time: dateFormat.format(DateTime.parse(message.time.toString())),
                          );
                        }
                      },
                      shrinkWrap: true,
                    ),
                    // child: ListView(
                    //   children: [
                    //     OwnFileCard(),
                    //     ReplyFileCard(),
                    //   ],
                    // ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 70,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width - 60,
                                child: Card(
                                  margin: const EdgeInsets.only(
                                    left: 2,
                                    right: 2,
                                    bottom: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: TextFormField(
                                    onChanged: (value) {},
                                    controller: textEditingController,
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 6,
                                    minLines: 1,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Type a message",
                                      contentPadding: const EdgeInsets.all(8),
                                      // prefixIcon: IconButton(
                                      //   onPressed: () {},
                                      //   icon: Icon(
                                      //     Icons.emoji_emotions,
                                      //     color: Theme.of(context).primaryColor,
                                      //   ),
                                      // ),
                                      suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // IconButton(
                                          //   onPressed: () async{
                                          //     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                                          //     if (pickedFile != null) {
                                          //       Navigator.push(
                                          //         context,
                                          //         MaterialPageRoute(
                                          //           builder: (builder) => CameraViewPage(
                                          //             path: pickedFile.path,
                                          //             onImageSend: onImageSend,
                                          //           ),
                                          //         ),
                                          //       );
                                          //     } else {
                                          //       // Handle the case where no image was selected
                                          //       print("No image selected.");
                                          //     }
                                          //   },
                                          //   icon: Icon(
                                          //     Icons.attach_file,
                                          //     color: Theme.of(context)
                                          //         .primaryColor,
                                          //   ),
                                          // ),
                                          IconButton(
                                            onPressed: (){
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (builder) =>
                                                      CameraScreen(
                                                        onImageSend: onImageSend,
                                                      ),
                                                ),
                                              );
                                            },
                                            icon: Icon(
                                              Icons.camera_alt,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8.0, right: 5, left: 2),
                                child: CircleAvatar(
                                  backgroundColor:
                                  Theme.of(context).primaryColor,
                                  radius: 25,
                                  child: IconButton(
                                    onPressed: () {
                                      sendMessageToGemini();
                                    },
                                    icon: const Icon(
                                     Icons.send,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> takePhoto() async {
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

  Future<void> sendMessageAndImageToGemini(String pathOfTheClickedImage, [String message = "Describe the image"]) async {
  //  await takePhoto(); // Take a photo before sending the message

    final imagePath = pathOfTheClickedImage; // Get the image path

    print("Image Path in sendMessage: $imagePath"); // Debug information

    if (imagePath == null) {
      _showErrorDialog(context, "Failed to capture image. Please try again.");
      return;
    }

    final bytes = File(imagePath!).readAsBytesSync();
    final mimeType = 'image/jpeg'; // Adjust MIME type if necessary

    final List<google_generative_ai.Content> content = [
      google_generative_ai.Content.text(message),
     google_generative_ai.Content.data(mimeType, Uint8List.fromList(bytes)), // Send the base64 image as data
    ];

    final response = await model.generateContent(content);
    setState(() {
      prompt.add(
        ModelMessage(
          message: response.text ?? "",
          time: DateTime.now(),
          imagePath: imagePath!,
          type: MessageType.model, // Set type to model
        ),
      );
    });
    _imagePath = null; // Clear the image path after sending

    // Delete the image file after sending
    try {
      final file = File(imagePath!);
      if (await file.exists()) {
        await file.delete();
        textEditingController.clear();
        print("Image file deleted: $imagePath");
      }
    } catch (e) {
      print("Error deleting image file: $e");
    }
  }

  Future<void> sendMessageToGemini() async {
    final message = textEditingController.text;

    if (message.isEmpty) {
      _showErrorDialog(context, "Message cannot be empty. Please enter a message.");
      return;
    }

    // Add the user message to the prompt list
    setState(() {
      prompt.add(
        ModelMessage(
          message: message,
          time: DateTime.now(),
          type: MessageType.user, // Set type to user
        ),
      );
      _scrollToBottom();
    });

    // Send the message to the model
    final List<google_generative_ai.Content> content = [
      google_generative_ai.Content.text(message),
    ];

    try {
      final response = await model.generateContent(content);
      setState(() {
        prompt.add(
          ModelMessage(
            message: response.text ?? "No response from model",
            time: DateTime.now(),
            type: MessageType.model, // Set type to model
          ),
        );
      });

      textEditingController.clear();
    } catch (e) {
      print("Error sending message to Gemini: $e");
      _showErrorDialog(context, "Failed to send message. Please try again.");
    }
  }


  void _showErrorDialog(BuildContext context, String message) {
    print(message);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

}