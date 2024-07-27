import 'dart:io';

import 'package:flutter/material.dart';

class OwnMessageCard extends StatelessWidget {
  const OwnMessageCard({super.key, this.message, this.time, this.imagePath});
  final String? message;
  final String? time;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          color: const Color(0xFFec8630),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imagePath != null)
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height / 2.3,
                    width: MediaQuery.of(context).size.width / 1.8,
                  ),
                ),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    message!,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 60, top: 5, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (time != null)
                      Text(
                        time!,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.done_all,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
