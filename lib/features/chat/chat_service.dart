import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sm_project/controller/apiservices/api_constant.dart';
import 'package:sm_project/controller/apiservices/dio_client.dart';
import 'package:sm_project/controller/local/pref.dart';
import 'package:sm_project/controller/local/pref_names.dart';
import 'package:sm_project/features/chat/chat_conversation_model.dart';
import 'package:sm_project/features/chat/chat_file_upload_model.dart';
import 'package:sm_project/features/chat/chat_message_model.dart';
import 'package:socket_io_client_new/socket_io_client_new.dart' as io;
import 'package:record/record.dart';


class ChatService {
  // --- SINGLETON SETUP ---
  ChatService._internal();
  static final ChatService _instance = ChatService._internal();
  static ChatService get instance => _instance;
  factory ChatService() {
    return _instance;
  }
  // -----------------------

  // Extract base domain from APIConstants.baseUrl (remove /api/v1/)
  static String get _baseUrl {
    const baseUrl = APIConstants.baseUrl;
    // Remove trailing /api/v1/ to get just the domain
    if (baseUrl.endsWith('/api/v1/')) {
      return baseUrl.substring(0, baseUrl.length - 8);
    }
    return baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }

  static const String _socketNamespace = '/api/v1/chat';

  io.Socket? _socket;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  // Stream controllers for real-time updates
  final StreamController<ChatMessage> _messageController =
  StreamController<ChatMessage>.broadcast();
  final StreamController<String> _typingController =
  StreamController<String>.broadcast();
  final StreamController<bool> _connectionStatusController =
  StreamController<bool>.broadcast();
  final StreamController<String> _errorController =
  StreamController<String>.broadcast();
  final StreamController<List<ChatConversation>> _conversationsController =
  StreamController<List<ChatConversation>>.broadcast();

  // Getters for streams
  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<String> get typingStream => _typingController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<List<ChatConversation>> get conversationsStream =>
      _conversationsController.stream;

  // Current conversation and user info
  String? _currentConversationId;
  String? _currentUserRole;
  late AudioRecorderService _audioRecorderService;

  bool get isConnected => _socket?.connected ?? false;

  // Public getter so ChatScreen can read the current conversation ID on mount
  String? get currentConversationId => _currentConversationId;

  // Public wrapper so ChatScreen can reload history after mount if already connected
  Future<void> loadConversationHistoryPublic(String conversationId) async {
    await _loadConversationHistory(conversationId);
  }

  bool get isAuthenticated {
    final token = Prefs.getString(PrefNames.accessToken);
    return token != null && token.isNotEmpty;
  }

  Future<void> initialize() async {
    _audioRecorderService = AudioRecorderService();
    await _loadUserData();
  }


  AudioRecorderService get audioRecorderService => _audioRecorderService;

  Future<void> _loadUserData() async {
    // This would typically get user data from your app's state management
    // For now, we'll assume user data is available through Prefs
  }

  Future<bool> connect({String? conversationId, String? role}) async {
    if (_socket?.connected ?? false) {
      return true;
    }

    if (!isAuthenticated) {
      _errorController.add('Authentication required. Please login first.');
      return false;
    }

    try {
      final token = Prefs.getString(PrefNames.accessToken)!;

      _currentConversationId = conversationId;
      _currentUserRole = role ?? 'user';
      final socketUrl = '$_baseUrl$_socketNamespace';

      _socket = io.io(
        socketUrl,
        io.OptionBuilder()
            .setPath('/api/v1/socket.io')
            .setTransports(['polling', 'websocket'])
            .enableAutoConnect()
            .enableForceNew()
            .setAuth({'token': token,'role': _currentUserRole})
            .build(),
      );
      _setupSocketEventHandlers();

      return true;
    } catch (e) {
      _errorController.add('Connection failed: $e');
      log("chattt, $e");
      return false;
    }
  }

  void _setupSocketEventHandlers() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      log('Connected to chat server');
      _connectionStatusController.add(true);
      _startHeartbeat();
      _reconnectAttempts = 0;
    });

    _socket!.onDisconnect((_) {
      log('Disconnected from chat server');
      _connectionStatusController.add(false);
      _stopHeartbeat();
    });

    _socket!.onConnectError((error) {
      log('Connection error: $error');
      _errorController.add('Connection failed: $error');
      _connectionStatusController.add(false);
      _scheduleReconnect();
    });

    _socket!.on('chat:ready', (data) {
      log('Chat ready: $data');
      if (data is Map && data.containsKey('conversationId')) {
        _currentConversationId = data['conversationId'];
        _loadConversationHistory(_currentConversationId!);
      }
    });

    _socket!.on('chat:new_message', (data) {
      if (data is Map<String, dynamic>) {
        final message = ChatMessage.fromJson(data);
        if (message.isImage) {
          log('Received image message:');
          log('  fileUrl: ${message.fileUrl}');
          log('  fileName: ${message.fileName}');
          log('  mimeType: ${message.mimeType}');
        }
        _messageController.add(message);
      }
    });

    _socket!.on('chat:typing', (data) {
      if (data is Map &&
          data.containsKey('isTyping') &&
          data.containsKey('actorType')) {
        final isTyping = data['isTyping'] as bool;
        final actorType = data['actorType'] as String;
        _typingController.add(isTyping ? '$actorType is typing...' : '');
      }
    });

    _socket!.on('chat:read', (data) {
      // Handle read receipts - update message status in UI
      log('Message marked as read: $data');
    });

    _socket!.on('chat:delivered', (data) {
      // Handle delivery receipts
      log('Message delivered: $data');
    });

    _socket!.on('chat:error', (error) {
      log('Chat error: $error');
      _errorController.add('Chat error: ${error['message']}');
    });

    // Admin-specific events
    if (_currentUserRole == 'admin') {
      _socket!.on('user:connected', (data) {
        log('User connected: $data');
        _loadConversations(); // Refresh conversations list
      });

      _socket!.on('user:disconnected', (data) {
        log('User disconnected: $data');
        _loadConversations(); // Refresh conversations list
      });
    }

    // Presence events
    _socket!.on('admin:online', (_) {
      log('Admin is online');
    });

    _socket!.on('admin:offline', (_) {
      log('Admin is offline');
    });
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_socket?.connected ?? false) {
        _socket!.emit('ping');
      } else {
        _stopHeartbeat();
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _errorController.add('Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: 2 * _reconnectAttempts), () {
      connect(conversationId: _currentConversationId, role: _currentUserRole);
    });
  }

  Future<void> _loadConversationHistory(String conversationId) async {
    try {
      final token = Prefs.getString(PrefNames.accessToken);
      if (token == null || token.isEmpty) {
        log('No authentication token available');
        _errorController.add('Authentication required. Please login again.');
        return;
      }

      final endpoint = _currentUserRole == 'admin'
          ? '${APIConstants.baseUrl}admin/chat/messages/$conversationId?page=1&limit=100'
          : '${APIConstants.baseUrl}app/chat/messages/$conversationId?page=1&limit=100';

      final response = await dio.get(
        endpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data['data'];
        if (data is List) {
          // Emit each message to the stream for UI updates
          for (var messageData in data) {
            if (messageData is Map<String, dynamic>) {
              final message =
              ChatMessage.fromJson(messageData.cast<String, dynamic>());
              _messageController.add(message);
            }
          }
        }
      } else if (response.statusCode == 401) {
        log('Authentication token expired or invalid');
        _errorController.add('Authentication expired. Please login again.');
      } else {
        log('Failed to load conversation history: ${response.statusCode}');
        _errorController.add('Failed to load conversation history');
      }
    } catch (e) {
      log('Failed to load conversation history: $e');
      if (e is DioException && e.response?.statusCode == 401) {
        _errorController.add('Authentication required. Please login again.');
      } else {
        _errorController.add('Failed to load conversation history');
      }
    }
  }

  Future<List<ChatConversation>> _loadConversations() async {
    try {
      final token = Prefs.getString(PrefNames.accessToken);
      if (token == null || token.isEmpty) {
        log('No authentication token available');
        _errorController.add('Authentication required. Please login again.');
        return [];
      }

      final response = await dio.get(
        '${APIConstants.baseUrl}admin/chat/conversations?page=1&limit=50',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data['data'];
        if (data is List) {
          final conversations =
          data.map((json) => ChatConversation.fromJson(json)).toList();
          _conversationsController.add(conversations);
          return conversations;
        }
      } else if (response.statusCode == 401) {
        log('Authentication token expired or invalid');
        _errorController.add('Authentication expired. Please login again.');
      } else {
        log('Failed to load conversations: ${response.statusCode}');
        _errorController.add('Failed to load conversations');
      }
      return [];
    } catch (e) {
      log('Failed to load conversations: $e');
      if (e is DioException && e.response?.statusCode == 401) {
        _errorController.add('Authentication required. Please login again.');
      } else {
        _errorController.add('Failed to load conversations');
      }
      return [];
    }
  }

  Future<bool> sendTextMessage(String text, {String? conversationId}) async {
    print("chala ${conversationId}");
    if (!isConnected || text.trim().isEmpty) {
      return false;
    }
    print("chala2");


    final targetConversationId = conversationId ?? _currentConversationId;
    if (targetConversationId == null) {
      _errorController.add('No conversation selected');
      print("chala3");
      return false;
    }

    try {
      print("chala4");
      _socket!.emit('chat:send_text', {
        'conversationId': targetConversationId,
        'text': text.trim(),
      });
      return true;
    } catch (e) {
      _errorController.add('Failed to send message: $e');
      return false;
    }
  }

  Future<bool> sendFileMessage(File file, {String? conversationId, String? mimeType}) async {
    if (!isConnected || !file.existsSync()) return false;

    final targetConversationId = conversationId ?? _currentConversationId;
    if (targetConversationId == null) {
      _errorController.add('No conversation selected');
      return false;
    }

    try {
      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last;
      final fileMimeType = mimeType ?? _getMimeTypeFromExtension(extension);

      final uploadIntent = await _requestFileUploadIntent(fileName, extension, mimeType: fileMimeType);

      if (uploadIntent == null) {
        _errorController.add('Failed to get upload intent');
        return false;
      }

      final uploadSuccess = await _uploadFileToPresignedUrl(file, uploadIntent.uploadUrl, uploadIntent.contentType);
      if (!uploadSuccess) {
        _errorController.add('Failed to upload file');
        return false;
      }

      final notifySuccess = await _notifyFileUpload(uploadIntent.fileName, uploadIntent.contentType, file.lengthSync());
      if (!notifySuccess) {
        _errorController.add('Failed to notify file upload');
        return false;
      }

      _socket!.emit('chat:send_file', {
        'conversationId': targetConversationId,
        'fileUrl': uploadIntent.fileUrl,
        'fileName': uploadIntent.fileName,
        'fileSize': file.lengthSync(),
        'mimeType': uploadIntent.contentType,
        'messageType': _getMessageTypeFromMimeType(uploadIntent.contentType),
      });

      return true;
    } catch (e) {
      _errorController.add('Failed to send file: $e');
      return false;
    }
  }
  Future<bool> sendAudioMessage(File audioFile, {String? conversationId}) async {
    if (!audioFile.existsSync()) return false;

    final mimeType = 'audio/mpeg'; // assuming AAC/MP3; adjust if needed
    return sendFileMessage(audioFile, conversationId: conversationId, mimeType: mimeType);
  }
  Future<ChatFileUploadIntent?> _requestFileUploadIntent(
      String fileName, String extension, {String? mimeType}) async {
    try {
      // Get auth token
      final token = Prefs.getString(PrefNames.accessToken);
      if (token == null || token.isEmpty) {
        log('No authentication token available');
        _errorController.add('Authentication required. Please login again.');
        return null;
      }

      // Use provided mimeType or derive from extension
      final fileMimeType = mimeType ?? _getMimeTypeFromExtension(extension);

      // Determine endpoint based on role
      final endpoint = _currentUserRole == 'admin'
          ? '${APIConstants.baseUrl}admin/chat/files/upload-intent'
          : '${APIConstants.baseUrl}app/chat/files/upload-intent';

      log('Requesting upload intent for file: $fileName, mimeType: $fileMimeType');
      log('Endpoint: $endpoint');

      // Request upload intent from server
      final response = await dio.post(
        endpoint,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
        data: {
          'filename': fileName,
          'contentType': fileMimeType,
        },
      );

      log('Upload intent response: ${response.statusCode}');
      log('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data['data'];
        if (data != null) {
          return ChatFileUploadIntent.fromJson(data);
        } else {
          log('No data in response');
          _errorController.add('Failed to get upload intent data');
        }
      } else if (response.statusCode == 401) {
        log('Authentication token expired or invalid');
        _errorController.add('Authentication expired. Please login again.');
      } else {
        log('Upload intent request failed with status: ${response.statusCode}');
        _errorController.add('Upload intent request failed');
      }
    } catch (e) {
      log('Failed to request upload intent: $e');
      if (e is DioException && e.response?.statusCode == 401) {
        _errorController.add('Authentication required. Please login again.');
      } else {
        _errorController.add('Failed to request upload intent: $e');
      }
    }

    return null;
  }
  // Future<ChatFileUploadIntent?> _requestFileUploadIntent(
  //     String fileName, String extension) async {
  //   try {
  //     final token = Prefs.getString(PrefNames.accessToken);
  //     if (token == null || token.isEmpty) {
  //       log('No authentication token available');
  //       _errorController.add('Authentication required. Please login again.');
  //       return null;
  //     }
  //
  //     final mimeType = _getMimeTypeFromExtension(extension);
  //
  //     final endpoint = _currentUserRole == 'admin'
  //         ? '${APIConstants.baseUrl}admin/chat/files/upload-intent'
  //         : '${APIConstants.baseUrl}app/chat/files/upload-intent';
  //
  //     log('Requesting upload intent for file: $fileName, mimeType: $mimeType');
  //     log('Endpoint: $endpoint');
  //
  //     final response = await dio.post(
  //       endpoint,
  //       options: Options(headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json'
  //       }),
  //       data: {'filename': fileName, 'contentType': mimeType},
  //     );
  //
  //     log('Upload intent response: ${response.statusCode}');
  //     log('Response data: ${response.data}');
  //
  //     if (response.statusCode == 200 && response.data is Map) {
  //       final data = response.data['data'];
  //       if (data != null) {
  //         return ChatFileUploadIntent.fromJson(data);
  //       } else {
  //         log('No data in response');
  //         _errorController.add('Failed to get upload intent data');
  //       }
  //     } else if (response.statusCode == 401) {
  //       log('Authentication token expired or invalid');
  //       _errorController.add('Authentication expired. Please login again.');
  //     } else {
  //       log('Upload intent request failed with status: ${response.statusCode}');
  //       _errorController.add('Upload intent request failed');
  //     }
  //   } catch (e) {
  //     log('Failed to request upload intent: $e');
  //     if (e is DioException && e.response?.statusCode == 401) {
  //       _errorController.add('Authentication required. Please login again.');
  //     } else {
  //       _errorController.add('Failed to request upload intent: $e');
  //     }
  //   }
  //   return null;
  // }
  Future<bool> _uploadFileToPresignedUrl(
      File file, String uploadUrl, String contentType) async {
    try {
      log('Uploading file to presigned URL: $uploadUrl');
      log('Content-Type: $contentType');
      log('File size: ${file.lengthSync()} bytes');

      final bytes = await file.readAsBytes();

      final response = await dio.put(
        uploadUrl,
        data: bytes,
        options: Options(
          headers: {'Content-Type': contentType},
          contentType: contentType,
        ),
      );

      log('Upload response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      log('Failed to upload file: $e');
      return false;
    }
  }

  Future<bool> _notifyFileUpload(
      String fileName, String contentType, int size) async {
    try {
      final token = Prefs.getString(PrefNames.accessToken);
      if (token == null || token.isEmpty) {
        log('No authentication token available');
        _errorController.add('Authentication required. Please login again.');
        return false;
      }

      final endpoint = _currentUserRole == 'admin'
          ? '${APIConstants.baseUrl}admin/chat/files/notify'
          : '${APIConstants.baseUrl}app/chat/files/notify';

      log('Notifying file upload: $fileName, size: $size');
      log('Endpoint: $endpoint');

      final response = await dio.post(
        endpoint,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        }),
        data: {
          'fileName': fileName,
          'contentType': contentType,
          'size': size,
        },
      );

      log('Notify response status: ${response.statusCode}');
      log('Notify response data: ${response.data}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        log('Authentication token expired or invalid');
        _errorController.add('Authentication expired. Please login again.');
      } else {
        log('Notify request failed with status: ${response.statusCode}');
        _errorController.add('Notify request failed');
      }
      return false;
    } catch (e) {
      log('Failed to notify file upload: $e');
      if (e is DioException && e.response?.statusCode == 401) {
        _errorController.add('Authentication required. Please login again.');
      } else {
        _errorController.add('Failed to notify file upload: $e');
      }
      return false;
    }
  }

  void sendTypingStatus(bool isTyping, {String? conversationId}) {
    if (!isConnected) return;

    final targetConversationId = conversationId ?? _currentConversationId;
    if (targetConversationId == null) return;

    _socket!.emit('chat:typing', {
      'conversationId': targetConversationId,
      'isTyping': isTyping,
    });
  }

  void markMessagesAsRead({String? conversationId}) {
    if (!isConnected) return;

    final targetConversationId = conversationId ?? _currentConversationId;
    if (targetConversationId == null) return;

    _socket!.emit('chat:mark_read', {
      'conversationId': targetConversationId,
    });
  }

  Future<ChatConversation?> findConversationByPhone(String phone) async {
    try {
      final token = Prefs.getString(PrefNames.accessToken);
      if (token == null || token.isEmpty) {
        log('No authentication token available');
        _errorController.add('Authentication required. Please login again.');
        return null;
      }

      int page = 1;
      const limit = 50;

      while (true) {
        final response = await dio.get(
          '${APIConstants.baseUrl}admin/chat/conversations?page=$page&limit=$limit',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        if (response.statusCode == 200 && response.data is Map) {
          final data = response.data['data'];
          if (data is List) {
            for (var conversation in data) {
              if (conversation is Map<String, dynamic> &&
                  conversation['user_id']?['mobile'] == phone) {
                return ChatConversation.fromJson(conversation);
              }
            }

            if (data.length < limit) break;
            page++;
          }
        } else if (response.statusCode == 401) {
          log('Authentication token expired or invalid');
          _errorController.add('Authentication expired. Please login again.');
          return null;
        }
      }
    } catch (e) {
      log('Failed to find conversation by phone: $e');
      if (e is DioException && e.response?.statusCode == 401) {
        _errorController.add('Authentication required. Please login again.');
      }
    }
    return null;
  }

  void disconnect() {
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _socket?.disconnect();
    _socket = null;
  }

  void dispose() {
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    log('ChatService disposed and socket disconnected');
  }

  String _getMimeTypeFromExtension(String extension) {
    switch (extension.toLowerCase()) {
    // Image types
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';

    // Audio types (NEW - Support for audio recordings)
      case 'm4a':
        return 'audio/mp4a-latm';  // Your recording format
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'aac':
        return 'audio/aac';
      case 'flac':
        return 'audio/flac';
      case 'ogg':
        return 'audio/ogg';

    // Document types
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';

    // Default fallback
      default:
        return 'application/octet-stream';
    }
  }

  String _getMessageTypeFromMimeType(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return 'image';
    }
    return 'file';
  }
}


class AudioRecorderService {
  final _recorder = AudioRecorder();
  String? _currentRecordingPath;  // Track current recording

  /// Start recording audio to a temporary file
  Future<void> startRecording() async {
    if (!await _recorder.hasPermission()) {
      throw Exception('Microphone permission not granted');
    }

    try {
      // Generate unique file path in app's temporary directory
      final appTempDir = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${appTempDir.path}/audio_recording_$timestamp.m4a';

      log('🎤 Starting audio recording');
      log('📁 Recording path: $_currentRecordingPath');

      // Start recording with proper configuration
      await _recorder.start(
        const RecordConfig(
        ),
        path: _currentRecordingPath!,
      );

      log('✓ Audio recording started successfully');
    } catch (e) {
      log('❌ Error starting recording: $e');
      throw Exception('Failed to start recording: $e');
    }
  }

  /// Stop recording and return the recorded file
  Future<File?> stopRecording() async {
    try {
      log('⏹️  Stopping audio recording...');

      // Stop the recorder
      final recordingPath = await _recorder.stop();

      if (recordingPath == null) {
        log('❌ _recorder.stop() returned null');
        return null;
      }

      log('📝 Recorder returned path: $recordingPath');
      log('💾 Stored path: $_currentRecordingPath');

      // Use either the returned path or the stored path
      final finalPath = recordingPath.isNotEmpty ? recordingPath : _currentRecordingPath;

      if (finalPath == null || finalPath.isEmpty) {
        log('❌ No valid recording path');
        return null;
      }

      final recordedFile = File(finalPath);

      // Verify file exists
      if (await recordedFile.exists()) {
        final fileSize = await recordedFile.length();
        log('✓ Audio file found');
        log('📊 File size: $fileSize bytes');
        log('✓ Recording successfully saved: $finalPath');

        // Reset for next recording
        _currentRecordingPath = null;

        return recordedFile;
      } else {
        log('❌ Recording file does not exist at: $finalPath');
        log('❌ This usually means startRecording() failed');
        return null;
      }
    } catch (e) {
      log('❌ Error stopping recording: $e');
      return null;
    }
  }

  /// Cancel recording and delete the file
  Future<void> cancelRecording() async {
    try {
      log('🛑 Cancelling recording...');

      final recordingPath = await _recorder.stop();

      if (recordingPath != null) {
        final file = File(recordingPath);
        if (await file.exists()) {
          await file.delete();
          log('✓ Recording cancelled and file deleted');
        }
      }

      _currentRecordingPath = null;
    } catch (e) {
      log('Error cancelling recording: $e');
    }
  }
}