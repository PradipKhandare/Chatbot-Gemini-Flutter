class ModelMessage
{
  final String message;
  final DateTime time;
  final String? imagePath;
  final MessageType type; // Add this property

  ModelMessage({ required this.message, required this.time, this.imagePath, required this.type,});
}

enum MessageType {
  user,
  model,
}