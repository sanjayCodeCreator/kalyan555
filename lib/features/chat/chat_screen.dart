import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sm_project/controller/apiservices/api_constant.dart';
import 'package:sm_project/features/chat/chat_conversation_model.dart';
import 'package:sm_project/features/chat/chat_message_model.dart';
import 'package:sm_project/features/chat/chat_service.dart';
import 'package:sm_project/utils/filecollection.dart' hide AudioPlayer;

final chatServiceProvider = Provider<ChatService>((ref) {
  // Returns the Singleton instance. MainScreen manages the dispose logic.
  return ChatService.instance;
});

final messagesProvider = StateProvider<List<ChatMessage>>((ref) => []);
final typingProvider = StateProvider<String>((ref) => '');
final connectionStatusProvider = StateProvider<bool>((ref) => false);
final conversationsProvider = StateProvider<List<ChatConversation>>((ref) => []);
final welcomeMessageSentProvider = StateProvider<bool>((ref) => false);

// Audio playback providers
final audioPlayersProvider = StateProvider<Map<String, AudioPlayer>>((ref) => {});
final playingAudioProvider = StateProvider<String?>((ref) => null);
final audioPositionProvider = StateProvider<Duration>((ref) => Duration.zero);
final audioDurationProvider = StateProvider<Duration>((ref) => Duration.zero);

// File upload providers
final isRecordingProvider = StateProvider<bool>((ref) => false);
final recordingDurationProvider = StateProvider<Duration>((ref) => Duration.zero);
final isUploadingProvider = StateProvider<bool>((ref) => false);
final uploadProgressProvider = StateProvider<double>((ref) => 0.0);

class ChatScreen extends HookConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatService = ref.watch(chatServiceProvider);
    final messages = ref.watch(messagesProvider);
    final typingText = ref.watch(typingProvider);
    final isConnected = ref.watch(connectionStatusProvider);
    final isRecording = ref.watch(isRecordingProvider);
    final recordingDuration = ref.watch(recordingDurationProvider);
    final isUploading = ref.watch(isUploadingProvider);
    final uploadProgress = ref.watch(uploadProgressProvider);
    final audioPlayers = ref.watch(audioPlayersProvider);
    final playingAudio = ref.watch(playingAudioProvider);

    useEffect(() {
      log('🎵 [AUDIO STATE] playingAudio changed: $playingAudio');
      return null;
    }, [playingAudio]);

    final messageController = useTextEditingController();
    final scrollController = useScrollController();
    final isTyping = useState(false);
    final showEmojiPicker = useState(false);

    useEffect(() {
      // Defer to after build frame — Riverpod forbids provider mutation during build
      Future.microtask(() {
        ref.read(connectionStatusProvider.notifier).state = chatService.isConnected;
        if (chatService.isConnected && chatService.currentConversationId != null) {
          chatService.loadConversationHistoryPublic(chatService.currentConversationId!);
        }
      });
      // Set up stream listeners
      final messageSubscription = chatService.messageStream.listen((message) {
        ref.read(messagesProvider.notifier).state = [
          ...ref.read(messagesProvider),
          message
        ];
        _scrollToBottom(scrollController);
      });

      final typingSubscription = chatService.typingStream.listen((typing) {
        ref.read(typingProvider.notifier).state = typing;
      });

      final connectionSubscription = chatService.connectionStatusStream.listen((connected) {
        ref.read(connectionStatusProvider.notifier).state = connected;
        // Check if welcome message needs to be sent
        if (connected && !ref.read(welcomeMessageSentProvider) && messages.isEmpty) {
          // Assuming _sendWelcomeMessage exists in your file
          // _sendWelcomeMessage(chatService, ref);
        }
      });

      final errorSubscription = chatService.errorStream.listen((error) {
        // toast(error);
        if (error.contains('Authentication') || error.contains('login')) {
          print('Authentication required: $error');
        }
      });

      final conversationsSubscription = chatService.conversationsStream.listen((convs) {
        ref.read(conversationsProvider.notifier).state = convs;
      });

      // REMOVED: chatService.connect(role: 'user'); -> This is now handled in MainScreen

      return () {
        messageSubscription.cancel();
        typingSubscription.cancel();
        connectionSubscription.cancel();
        errorSubscription.cancel();
        conversationsSubscription.cancel();

        for (var player in audioPlayers.values) {
          player.dispose();
        }
      };
    }, []);

    useEffect(() {
      if (messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(scrollController);
        });
      }
      return null;
    }, [messages.length]);

    const primaryGreen = Color(0xFF4CAF50);
    const lightGreen = Color(0xFF81C784);
    const backgroundColor = Color(0xFFFAFAFA);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: primaryGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // leading: IconButton(onPressed:() {
        //   context.pop();
        // }, icon: const Icon(Icons.arrow_back)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isConnected ? Colors.white : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Chat Support',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => chatService.connect(role: 'user'),
            icon: Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Container(
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryGreen, lightGreen],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 0),
                  decoration: const BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildConnectionStatus(isConnected, ref),

                      if (typingText.isNotEmpty)
                        _buildTypingIndicator(typingText),

                      Expanded(
                        child: _buildMessagesList(messages, scrollController, ref, audioPlayers, playingAudio),
                      ),

                      if (isUploading)
                        _buildUploadProgressBar(uploadProgress),

                      _buildMessageInput(
                        context,
                        messageController,
                        isTyping,
                        showEmojiPicker,
                        chatService,
                        ref,
                        isRecording,
                        recordingDuration,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMessageAudioId(ChatMessage message) {
    return message.id ?? message.fileUrl ?? '';
  }

  Widget _buildConnectionStatus(bool isConnected, WidgetRef ref) {
    final chatService = ref.watch(chatServiceProvider);
    final isAuthenticated = chatService.isAuthenticated;

    Color backgroundColor;
    Color textColor;
    String statusText;
    IconData iconData;

    if (!isAuthenticated) {
      backgroundColor = Colors.orange.shade50;
      textColor = Colors.orange;
      statusText = 'Authentication Required';
      iconData = Icons.lock;
    } else if (isConnected) {
      backgroundColor = const Color(0xFF4CAF50).withOpacity(0.1);
      textColor = const Color(0xFF4CAF50);
      statusText = 'Connected';
      iconData = Icons.wifi;
    } else {
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red;
      statusText = 'Disconnected';
      iconData = Icons.wifi_off;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(String typingText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            typingText,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            height: 12,
            child: Row(
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 2),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF4CAF50),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgressBar(double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uploading file...',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF4CAF50),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(
      List<ChatMessage> messages,
      ScrollController scrollController,
      WidgetRef ref,
      Map<String, AudioPlayer> audioPlayers,
      String? playingAudio,
      ) {
    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(
          context,
          message,
          index,
          messages,
          ref,
          audioPlayers,
          playingAudio,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with our support team',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      BuildContext context,
      ChatMessage message,
      int index,
      List<ChatMessage> messageList,
      WidgetRef ref,
      Map<String, AudioPlayer> audioPlayers,
      String? playingAudio,
      ) {
    final isOwnMessage = message.isOwn;
    final showAvatar =
    !_shouldGroupWithPrevious(messageList, index, isOwnMessage);

    return Container(
      margin: EdgeInsets.only(
        left: isOwnMessage ? 64 : 0,
        right: isOwnMessage ? 0 : 64,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment:
        isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwnMessage && showAvatar) ...[
            CircleAvatar(
              backgroundColor: const Color(0xFF4CAF50).withOpacity(0.2),
              child: Text(
                'A',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF4CAF50),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (!isOwnMessage && !showAvatar) const SizedBox(width: 40),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isOwnMessage
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isImage) _buildImageMessage(context, message),
                  if (message.isFile && !_isAudioFile(message))
                    _buildFileMessage(message),
                  if (_isAudioFile(message))
                    _buildAudioMessage(
                      context,
                      message,
                      ref,
                      audioPlayers,
                      playingAudio,
                      isOwnMessage,
                    ),
                  if (message.messageType == MessageType.text)
                    _buildTextMessage(message),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMessageTime(message.createdAt),
                        style: GoogleFonts.poppins(
                          color: isOwnMessage
                              ? Colors.white70
                              : Colors.grey.shade500,
                          fontSize: 10,
                        ),
                      ),
                      if (isOwnMessage) ...[
                        const SizedBox(width: 4),
                        Icon(
                          _getMessageStatusIcon(message.status),
                          size: 12,
                          color: message.statusColor,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextMessage(ChatMessage message) {
    return Text(
      message.text,
      style: GoogleFonts.poppins(
        color: message.isOwn ? Colors.white : Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildImageMessage(BuildContext context, ChatMessage message) {
    log('Image URL: ${message.fileUrl}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.fileUrl != null)
          GestureDetector(
            onTap: () => _showFullScreenImage(
                context, _getFullImageUrl(message.fileUrl!)),
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 200,
                maxHeight: 150,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _getFullImageUrl(message.fileUrl!),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      width: 200,
                      height: 150,
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stack) {
                    print('Image load error: $error');
                    print('Image URL: ${_getFullImageUrl(message.fileUrl!)}');
                    return Container(
                      width: 200,
                      height: 150,
                      color: Colors.grey.shade200,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(height: 4),
                          Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFileMessage(ChatMessage message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isOwn ? Colors.white24 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insert_drive_file,
                color: message.isOwn ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.displayText,
                  style: GoogleFonts.poppins(
                    color: message.isOwn ? Colors.white : Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioMessage(
      BuildContext context,
      ChatMessage message,
      WidgetRef ref,
      Map<String, AudioPlayer> audioPlayers,
      String? playingAudio,
      bool isOwnMessage,
      ) {
    final messageId = _getMessageAudioId(message);
    final isPlaying = playingAudio == messageId;

    log('🎵 [AUDIO WIDGET] messageId=$messageId, playingAudio=$playingAudio, isPlaying=$isPlaying');

    return GestureDetector(
      onTap: () {
        log('🎵 [AUDIO TAP] Tapped message: $messageId');
        _toggleAudioPlayback(
          message,
          ref,
          audioPlayers,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isOwnMessage ? Colors.white24 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOwnMessage
                    ? Colors.white.withOpacity(0.3)
                    : const Color(0xFF4CAF50).withOpacity(0.2),
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: isOwnMessage ? Colors.white : const Color(0xFF4CAF50),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🎙️ Audio Message',
                  style: GoogleFonts.poppins(
                    color: isOwnMessage ? Colors.white : Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatAudioDuration(message),
                  style: GoogleFonts.poppins(
                    color: isOwnMessage ? Colors.white70 : Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isAudioFile(ChatMessage message) {
    if (message.mimeType == null) return false;
    return message.mimeType!.startsWith('audio/');
  }

  Future<void> _toggleAudioPlayback(
      ChatMessage message,
      WidgetRef ref,
      Map<String, AudioPlayer> audioPlayers,
      ) async {
    try {
      final messageId = _getMessageAudioId(message);
      log('🎵 [AUDIO TAP] Tapped message: $messageId');

      final currentPlaying = ref.read(playingAudioProvider);
      if (currentPlaying != null && currentPlaying != messageId) {
        if (audioPlayers.containsKey(currentPlaying)) {
          await audioPlayers[currentPlaying]!.stop();
          ref.read(playingAudioProvider.notifier).state = null;
        }
      }

      AudioPlayer? player = audioPlayers[messageId];

      if (player == null) {
        player = AudioPlayer();
        audioPlayers[messageId] = player;

        // FIXED: Simplified listener
        player.playerStateStream.listen((state) {
          log('🎵 [PLAYER STATE] processingState: ${state.processingState}, playing: ${player?.playing}');

          // Simply check if completed
          if (state.processingState == ProcessingState.completed) {
            log('🎵 [AUDIO COMPLETED] Resetting playingAudioProvider');
            ref.read(playingAudioProvider.notifier).state = null;
          }
        });

        player.positionStream.listen((position) {
          log('🎵 [POSITION] ${position.inSeconds}s / ${player?.duration?.inSeconds ?? 0}s');
        });

        player.durationStream.listen((duration) {
          if (duration != null) {
            ref.read(audioDurationProvider.notifier).state = duration;
            log('🎵 [DURATION] ${duration.inSeconds}s');
          }
        });
      }

      if (player.playing) {
        await player.pause();
        ref.read(playingAudioProvider.notifier).state = null;
        log('🎵 [PAUSED] playingAudioProvider set to null');
      } else {
        ref.read(playingAudioProvider.notifier).state = messageId;
        log('🎵 [PLAYING] Loading and playing: ${message.fileUrl}');
        await player.setUrl(message.fileUrl ?? '');
        await player.play();
        // ref.read(playingAudioProvider.notifier).state = messageId;
        log('🎵 [PLAYING SUCCESS] playingAudioProvider set to: $messageId');
      }
    } catch (e) {
      log('❌ Error toggling audio playback: $e');
      toast('Failed to play audio');
      ref.read(playingAudioProvider.notifier).state = null;
    }
  }

  String _formatAudioDuration(ChatMessage message) {
    if (message.fileSize != null) {
      final estimatedSeconds = (message.fileSize! / 16000).toInt();
      final minutes = estimatedSeconds ~/ 60;
      final seconds = estimatedSeconds % 60;
      return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '--:--';
  }

  bool _shouldGroupWithPrevious(
      List<ChatMessage> messageList, int currentIndex, bool isOwnMessage) {
    if (currentIndex == 0) return false;
    final currentMessage = messageList[currentIndex];
    final previousMessage = messageList[currentIndex - 1];

    return previousMessage.senderType == currentMessage.senderType &&
        previousMessage.createdAt != null &&
        currentMessage.createdAt != null &&
        currentMessage.createdAt!
            .difference(previousMessage.createdAt!)
            .inMinutes <
            5;
  }

  IconData _getMessageStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
    }
  }

  String _formatMessageTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  Widget _buildMessageInput(
      BuildContext context,
      TextEditingController controller,
      ValueNotifier<bool> isTyping,
      ValueNotifier<bool> showEmojiPicker,
      ChatService chatService,
      WidgetRef ref,
      bool isRecording,
      Duration recordingDuration,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: isRecording
          ? _buildRecordingUI(context, recordingDuration, chatService, ref)
          : Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () =>
                  _showAttachmentOptions(context, chatService, ref),
              icon: Icon(
                Icons.attach_file,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: controller,
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _pickImage(chatService, ref),
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            _startAudioRecording(chatService, ref),
                        icon: Icon(
                          Icons.mic,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  if (text.isNotEmpty && !isTyping.value) {
                    isTyping.value = true;
                    chatService.sendTypingStatus(true);
                  } else if (text.isEmpty && isTyping.value) {
                    isTyping.value = false;
                    chatService.sendTypingStatus(false);
                  }
                },
                onSubmitted: (text) {
                  _sendMessage(text, controller, chatService, isTyping);
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => _sendMessage(
                  controller.text, controller, chatService, isTyping),
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingUI(
      BuildContext context,
      Duration recordingDuration,
      ChatService chatService,
      WidgetRef ref,
      ) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              ref.read(isRecordingProvider.notifier).state = false;
            },
            icon: Icon(
              Icons.close,
              color: Colors.red.shade700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Recording audio...',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDuration(recordingDuration),
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () =>
                _stopAudioRecording(chatService, ref, context),
            icon: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _sendMessage(String text, TextEditingController controller,
      ChatService chatService, ValueNotifier<bool> isTyping) {
    if (text.trim().isEmpty) return;

    chatService.sendTextMessage(text.trim());
    controller.clear();
    isTyping.value = false;
    chatService.sendTypingStatus(false);
  }

  void _sendWelcomeMessage(ChatService chatService, WidgetRef ref) {
    ref.read(welcomeMessageSentProvider.notifier).state = true;

    final welcomeMessage = ChatMessage(
      conversationId: 'welcome',
      messageType: MessageType.text,
      senderType: SenderType.admin,
      text: 'Welcome to Customer Support',
      createdAt: DateTime.now(),
    );

    ref.read(messagesProvider.notifier).state = [
      welcomeMessage,
      ...ref.read(messagesProvider),
    ];
  }

  void _showAttachmentOptions(
      BuildContext context, ChatService chatService, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.image, color: Color(0xFF4CAF50)),
            title: Text(
              'Photos',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _pickImage(chatService, ref);
            },
          ),
          ListTile(
            leading:
            const Icon(Icons.insert_drive_file, color: Color(0xFF4CAF50)),
            title: Text(
              'Documents',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _pickFile(chatService, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.mic, color: Color(0xFF4CAF50)),
            title: Text(
              'Audio Recording',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _startAudioRecording(chatService, ref);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ChatService chatService, WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        ref.read(isUploadingProvider.notifier).state = true;
        final success = await chatService.sendFileMessage(file);
        ref.read(isUploadingProvider.notifier).state = false;
        if (!success) {
          toast('Failed to send image');
        }
      }
    } catch (e) {
      ref.read(isUploadingProvider.notifier).state = false;
      toast('Failed to pick image: $e');
    }
  }

  Future<void> _pickFile(ChatService chatService, WidgetRef ref) async {
    try {
      toast(
          'File picker requires additional dependency. Please add file_picker to pubspec.yaml');
    } catch (e) {
      ref.read(isUploadingProvider.notifier).state = false;
      toast('Failed to pick file: $e');
    }
  }

  void _startAudioRecording(ChatService chatService, WidgetRef ref) async {
    try {
      final audioService = chatService.audioRecorderService;
      await audioService.startRecording();
      ref.read(isRecordingProvider.notifier).state = true;

      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (ref.read(isRecordingProvider)) {
          final duration = ref.read(recordingDurationProvider);
          ref.read(recordingDurationProvider.notifier).state =
              duration + const Duration(milliseconds: 100);
        } else {
          timer.cancel();
        }
      });
    } catch (e) {
      toast('Failed to start recording: $e');
      log('Error starting audio recording: $e');
    }
  }

  Future<void> _stopAudioRecording(
      ChatService chatService,
      WidgetRef ref,
      BuildContext context,
      ) async {
    try {
      final audioService = chatService.audioRecorderService;
      final recordedFile = await audioService.stopRecording();

      ref.read(isRecordingProvider.notifier).state = false;
      ref.read(recordingDurationProvider.notifier).state = Duration.zero;

      if (recordedFile != null) {
        ref.read(isUploadingProvider.notifier).state = true;
        final success = await chatService.sendFileMessage(recordedFile);
        ref.read(isUploadingProvider.notifier).state = false;

        if (success) {
          toast('Audio message sent successfully');
        } else {
          toast('Failed to send audio message');
        }
      } else {
        toast('No audio recording found');
      }
    } catch (e) {
      ref.read(isRecordingProvider.notifier).state = false;
      ref.read(isUploadingProvider.notifier).state = false;
      toast('Failed to stop recording: $e');
      log('Error stopping audio recording: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Container(
                  color: Colors.black,
                  child: InteractiveViewer(
                    panEnabled: true,
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Center(
                      child: Image.network(
                        _getFullImageUrl(imageUrl),
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stack) {
                          print('Full screen image load error: $error');
                          print('Full screen image URL: ${_getFullImageUrl(imageUrl)}');
                          return const Center(
                            child: Icon(
                              Icons.error,
                              color: Colors.white,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFullImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }
    return '${APIConstants.baseUrl}$imageUrl';
  }

  void _scrollToBottom(ScrollController controller) {
    if (!controller.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasClients) return;
      controller.jumpTo(controller.position.maxScrollExtent);
    });
  }
}