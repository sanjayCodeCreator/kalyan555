class NoticeModel {
  String? sId;
  bool? allUser;
  List<String>? userIds;
  String? title;
  String? message;
  bool? status;
  String? createdAt;
  String? updatedAt;
  int? iV;

  NoticeModel(
      {this.sId,
      this.allUser,
      this.userIds,
      this.title,
      this.message,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.iV});

  NoticeModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    allUser = json['all_user'];
    if (json['user_ids'] != null) {
      userIds = <String>[];
      json['user_ids'].forEach((v) {
        userIds!.add(v.toString());
      });
    }
    title = json['title'];
    message = json['message'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['all_user'] = allUser;
    if (userIds != null) {
      data['user_ids'] = userIds!.map((v) => v.toString()).toList();
    }
    data['title'] = title;
    data['message'] = message;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class NoticeListModel {
  String? status;
  String? message;
  List<NoticeModel>? data;

  NoticeListModel({this.status, this.message, this.data});

  NoticeListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <NoticeModel>[];
      json['data'].forEach((v) {
        data!.add(NoticeModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
