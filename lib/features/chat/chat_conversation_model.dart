import 'package:sm_project/features/chat/chat_message_model.dart';

class ChatConversation {
  final String id;
  final String? userId;
  final String? adminId;
  final String? userMobile;
  final String? userName;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadForAdmin;
  final int unreadForUser;
  final bool? userOnline;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ChatMessage>? messages;

  ChatConversation({
    required this.id,
    this.userId,
    this.adminId,
    this.userMobile,
    this.userName,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadForAdmin = 0,
    this.unreadForUser = 0,
    this.userOnline,
    this.createdAt,
    this.updatedAt,
    this.messages,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user_id']?['_id'] ?? json['user_id'],
      adminId: json['admin_id'],
      userMobile: json['user_id']?['mobile'],
      userName: json['user_id']?['name'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      unreadForAdmin: json['unread_for_admin']?.toInt() ?? 0,
      unreadForUser: json['unread_for_user']?.toInt() ?? 0,
      userOnline: json['user_id']?['online'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'user_id': userId != null
          ? {
              '_id': userId,
              'mobile': userMobile,
              'name': userName,
              'online': userOnline
            }
          : null,
      'admin_id': adminId,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'unread_for_admin': unreadForAdmin,
      'unread_for_user': unreadForUser,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get hasUnreadMessages => unreadForAdmin > 0 || unreadForUser > 0;
  int get totalUnreadCount => unreadForAdmin + unreadForUser;

  String get displayName => userName ?? userMobile ?? 'Unknown User';
  String get displayLastMessage => lastMessage ?? 'No messages yet';

  @override
  String toString() {
    return 'ChatConversation(id: $id, userMobile: $userMobile, lastMessage: $lastMessage)';
  }
}

