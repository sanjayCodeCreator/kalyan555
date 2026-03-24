import 'dart:convert';

class SmePayStartResponse {
  final String status;
  final String message;
  final String? slug;
  final SmePayStartData? data;

  SmePayStartResponse({
    required this.status,
    required this.message,
    this.slug,
    this.data,
  });

  factory SmePayStartResponse.fromJson(Map<String, dynamic> json) {
    return SmePayStartResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      slug: json['slug']?.toString(),
      data: json['data'] != null ? SmePayStartData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'slug': slug,
      'data': data?.toJson(),
    };
  }
}

class SmePayStartData {
  final bool? status;
  final String? qrcode; // base64 string
  final String? refId;
  final SmePayStartLinks? link;
  final SmePayStartInnerData? data;

  SmePayStartData({
    this.status,
    this.qrcode,
    this.refId,
    this.link,
    this.data,
  });

  factory SmePayStartData.fromJson(Map<String, dynamic> json) {
    return SmePayStartData(
      status: json['status'] is bool ? json['status'] as bool : json['status'] == 'true',
      qrcode: json['qrcode']?.toString(),
      refId: (json['ref_id'] ?? json['refId'])?.toString(),
      link: json['link'] != null ? SmePayStartLinks.fromJson(json['link']) : null,
      data: json['data'] != null ? SmePayStartInnerData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'qrcode': qrcode,
      'ref_id': refId,
      'link': link?.toJson(),
      'data': data?.toJson(),
    };
  }

  /// Helper to decode base64 QR into bytes
  List<int>? decodeQrBytes() {
    try {
      if (qrcode == null || qrcode!.isEmpty) return null;
      return base64Decode(qrcode!);
    } catch (_) {
      return null;
    }
  }
}

class SmePayStartLinks {
  final String? bhim;
  final String? phonepe;
  final String? paytm;
  final String? gpay;

  SmePayStartLinks({
    this.bhim,
    this.phonepe,
    this.paytm,
    this.gpay,
  });

  factory SmePayStartLinks.fromJson(Map<String, dynamic> json) {
    return SmePayStartLinks(
      bhim: json['bhim']?.toString(),
      phonepe: json['phonepe']?.toString(),
      paytm: json['paytm']?.toString(),
      gpay: json['gpay']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bhim': bhim,
      'phonepe': phonepe,
      'paytm': paytm,
      'gpay': gpay,
    };
  }
}

class SmePayStartInnerData {
  final String? companyName;
  final num? amount;
  final String? type;
  final String? paymentStatus;

  SmePayStartInnerData({
    this.companyName,
    this.amount,
    this.type,
    this.paymentStatus,
  });

  factory SmePayStartInnerData.fromJson(Map<String, dynamic> json) {
    return SmePayStartInnerData(
      companyName: (json['company_name'] ?? json['companyName'])?.toString(),
      amount: json['amount'] is num ? json['amount'] : num.tryParse(json['amount']?.toString() ?? ''),
      type: json['type']?.toString(),
      paymentStatus: (json['payment_status'] ?? json['paymentStatus'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'amount': amount,
      'type': type,
      'payment_status': paymentStatus,
    };
  }
}