class WithdrawalDepositLeaderboardModel {
  String? status;
  int? total;
  List<LeaderboardData>? data;

  WithdrawalDepositLeaderboardModel({
    this.status,
    this.total,
    this.data,
  });

  WithdrawalDepositLeaderboardModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    total = json['total'];
    if (json['data'] != null) {
      data = <LeaderboardData>[];
      json['data'].forEach((v) {
        data!.add(LeaderboardData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['total'] = total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LeaderboardData {
  String? id;
  String? userName;
  String? type;
  int? amount;

  LeaderboardData({
    this.id,
    this.userName,
    this.type,
    this.amount,
  });

  LeaderboardData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    userName = json['user_name'];
    type = json['type'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['user_name'] = userName;
    data['type'] = type;
    data['amount'] = amount;
    return data;
  }
}

