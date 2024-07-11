// // To parse this JSON data, do
// //
// //     final getMessages = getMessagesFromJson(jsonString);

// import 'dart:convert';

// List<GetMessages> getMessagesFromJson(String str) => List<GetMessages>.from(json.decode(str).map((x) => GetMessages.fromJson(x)));

// String getMessagesToJson(List<GetMessages> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class GetMessages {
//     int messageId;
//     int senderId;
//     int receiverId;
//     String messageText;
//     DateTime messageTimestamp;
//     bool isUserMessage;

//     GetMessages({
//         required this.messageId,
//         required this.senderId,
//         required this.receiverId,
//         required this.messageText,
//         required this.messageTimestamp,
//         required this.isUserMessage, required String text, required bool isUser,
//     });

//     factory GetMessages.fromJson(Map<String, dynamic> json) => GetMessages(
//         messageId: json["MessageId"],
//         senderId: json["SenderId"],
//         receiverId: json["ReceiverId"],
//         messageText: json["MessageText"],
//         messageTimestamp: DateTime.parse(json["MessageTimestamp"]),
//         isUserMessage: json["IsUserMessage"],
//     );

//     Map<String, dynamic> toJson() => {
//         "MessageId": messageId,
//         "SenderId": senderId,
//         "ReceiverId": receiverId,
//         "MessageText": messageText,
//         "MessageTimestamp": messageTimestamp.toIso8601String(),
//         "IsUserMessage": isUserMessage,
//     };
// }
