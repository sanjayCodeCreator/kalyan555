class ChatFileUploadIntent {
  final String fileName;
  final String uploadUrl;
  final String fileUrl;
  final String contentType;

  ChatFileUploadIntent({
    required this.fileName,
    required this.uploadUrl,
    required this.fileUrl,
    required this.contentType,
  });

  factory ChatFileUploadIntent.fromJson(Map<String, dynamic> json) {
    return ChatFileUploadIntent(
      fileName: json['fileName'] ?? '',
      uploadUrl: json['uploadUrl'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      contentType: json['contentType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'uploadUrl': uploadUrl,
      'fileUrl': fileUrl,
      'contentType': contentType,
    };
  }
}

class ChatFileUploadResponse {
  final bool success;
  final String message;
  final ChatFileUploadIntent? data;

  ChatFileUploadResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ChatFileUploadResponse.fromJson(Map<String, dynamic> json) {
    return ChatFileUploadResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ChatFileUploadIntent.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': success ? 'success' : 'failure',
      'message': message,
      'data': data?.toJson(),
    };
  }
}

