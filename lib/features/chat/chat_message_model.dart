import 'package:flutter/material.dart';

enum MessageType { text, image, file }

enum SenderType { user, admin }

enum MessageStatus { sent, delivered, read }

class ChatMessage {
  final String? id;
  final String conversationId;
  final MessageType messageType;
  final SenderType senderType;
  final String text;
  final String? fileUrl;
  final String? fileName;
  final String? mimeType;
  final int? fileSize;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredToAdminAt;
  final DateTime? deliveredToUserAt;
  final List<String>? readBy;
  final MessageStatus status;

  ChatMessage({
    this.id,
    required this.conversationId,
    required this.messageType,
    required this.senderType,
    required this.text,
    this.fileUrl,
    this.fileName,
    this.mimeType,
    this.fileSize,
    this.createdAt,
    this.updatedAt,
    this.deliveredToAdminAt,
    this.deliveredToUserAt,
    this.readBy,
    this.status = MessageStatus.sent,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? json['id'],
      conversationId: json['conversationId'] ?? json['conversation_id'] ?? '',
      messageType: _parseMessageType(json['message_type']),
      senderType: _parseSenderType(json['sender_type']),
      text: json['text'] ?? '',
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      mimeType: json['mime_type'],
      fileSize: json['file_size']?.toInt(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deliveredToAdminAt: json['delivered_to_admin_at'] != null
          ? DateTime.parse(json['delivered_to_admin_at'])
          : null,
      deliveredToUserAt: json['delivered_to_user_at'] != null
          ? DateTime.parse(json['delivered_to_user_at'])
          : null,
      // readBy:
      //     json['read_by'] != null ? List<String>.from(json['read_by']) : null,
      status: _calculateMessageStatus(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'conversationId': conversationId,
      'conversation_id': conversationId,
      'message_type': messageType.name,
      'sender_type': senderType.name,
      'text': text,
      'file_url': fileUrl,
      'file_name': fileName,
      'mime_type': mimeType,
      'file_size': fileSize,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'delivered_to_admin_at': deliveredToAdminAt?.toIso8601String(),
      'delivered_to_user_at': deliveredToUserAt?.toIso8601String(),
      'read_by': readBy,
    };
  }

  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'text':
        return MessageType.text;
      default:
        return MessageType.text;
    }
  }

  static SenderType _parseSenderType(String? type) {
    switch (type) {
      case 'admin':
        return SenderType.admin;
      case 'user':
        return SenderType.user;
      default:
        return SenderType.user;
    }
  }

  static MessageStatus _calculateMessageStatus(Map<String, dynamic> json) {
    final readBy = json['read_by'];
    if (readBy != null && readBy is List && readBy.isNotEmpty) {
      return MessageStatus.read;
    }

    final deliveredToAdminAt = json['delivered_to_admin_at'];
    final deliveredToUserAt = json['delivered_to_user_at'];

    if (deliveredToAdminAt != null || deliveredToUserAt != null) {
      return MessageStatus.delivered;
    }

    return MessageStatus.sent;
  }

  bool get isOwn => senderType == SenderType.user;
  bool get isImage => messageType == MessageType.image;
  bool get isFile => messageType == MessageType.file;
  bool get isRead => status == MessageStatus.read;
  bool get isDelivered => status == MessageStatus.delivered;

  String get displayText {
    switch (messageType) {
      case MessageType.image:
        return fileName ?? 'Image';
      case MessageType.file:
        return fileName ?? 'File';
      case MessageType.text:
      default:
        return text;
    }
  }

  Color get statusColor {
    switch (status) {
      case MessageStatus.read:
        return Colors.blue;
      case MessageStatus.delivered:
        return Colors.grey;
      case MessageStatus.sent:
        return Colors.grey.shade400;
    }
  }
}
