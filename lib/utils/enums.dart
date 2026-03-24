enum SocketEventType {
  chatMessage,
  chatReady,
  chatError,
  userConnected,
  userDisconnected,
  userStatusChanged,
  adminStatusChanged,
  adminOffline,
  chatTyping,
  chatRead,
  chatDelivered,
  messageRead,
  ping,
  pong,
}

enum SocketConnectionState {
  disconnected,
  connecting,
  connected,
  error,
  reconnecting,
}

enum UserRole { user, admin }