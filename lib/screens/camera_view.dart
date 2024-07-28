import 'dart:io';
import 'package:chat_bot_gemini/view/home_page.dart';
import 'package:flutter/material.dart';

class CameraViewPage extends StatefulWidget {
  const CameraViewPage(
      {super.key, required this.path, required this.onImageSend});

  final String path;
  final Function onImageSend;

  @override
  State<CameraViewPage> createState() => _CameraViewPageState();
}

class _CameraViewPageState extends State<CameraViewPage> {
  TextEditingController controller = TextEditingController();
  bool isTextFieldEmpty = true;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        isTextFieldEmpty = controller.text.isEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.crop_rotate,
              size: 27,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.emoji_emotions_outlined,
              size: 27,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.title,
              size: 27,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.edit,
              size: 27,
            ),
          ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            if (widget.path.isNotEmpty) // Check if path is not empty
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 150,
                child: Image.file(
                  File(widget.path),
                  fit: BoxFit.cover,
                ),
              )
            else
              Center(child: Text('No image to display')),
            Positioned(
              bottom: 0,
              child: Container(
                color: Colors.black38,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: TextFormField(
                  controller: controller,
                  maxLines: 6,
                  minLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask something',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 17,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: isTextFieldEmpty?  Colors.grey : const Color(0xFF0474ea),
                        child: InkWell(
                          onTap: isTextFieldEmpty
                              ? null
                              : () {
                            if (widget.onImageSend != null) {
                              if (widget.path.isEmpty) {
                                widget.onImageSend(controller.text, widget.path);
                              } else {
                                widget.onImageSend(widget.path, controller.text);
                              }
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (builder) => IndividualPage(
                                  userAddedImagePath: widget.path,
                                  userMessage: controller.text,
                                ),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.check,
                            size: 18,
                            color: isTextFieldEmpty ? Colors.grey : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.add_photo_alternate,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
