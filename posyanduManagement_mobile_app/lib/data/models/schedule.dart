import 'package:posyandumanagement_mobile_app/data/models/user.dart';

class Schedule {
  final int? id;
  final int? userId;
  final String? title;
  final String? address;
  final String? note;
  final String? status;
  final String? reason;
  final int? revision;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? submitDate;
  final DateTime? rejectedDate;
  final DateTime? approvedDate;
  final String? attachment;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User? user;

  Schedule({
    this.id,
    this.userId,
    this.title,
    this.address,
    this.note,
    this.status,
    this.reason,
    this.revision,
    this.startDate,
    this.endDate,
    this.submitDate,
    this.rejectedDate,
    this.approvedDate,
    this.attachment,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    print("JSON: $json");
    return Schedule(
      id: json["id"],
      userId: json["userId"],
      title: json["title"],
      address: json["address"],
      note: json["note"],
      status: json["status"],
      reason: json["reason"],
      revision: json["revision"],
      startDate:
          json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
      endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
      submitDate: json["submitDate"] == null || json["submitDate"] == ''
          ? null
          : DateTime.parse(json["submitDate"]),
      rejectedDate: json["rejectedDate"] == null || json["rejectedDate"] == ''
          ? null
          : DateTime.parse(json["rejectedDate"]),
      approvedDate: json["approvedDate"] == null || json["approvedDate"] == ''
          ? null
          : DateTime.parse(json["approvedDate"]),
      attachment: json["attachment"],
      createdAt:
          json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
      updatedAt:
          json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      user: json["user"] == null ? null : User.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "title": title,
        "address": address,
        "note": note,
        "status": status,
        "reason": reason,
        "revision": revision,
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "submitDate": submitDate?.toIso8601String(),
        "rejectedDate": rejectedDate?.toIso8601String(),
        "approvedDate": approvedDate?.toIso8601String(),
        "attachment": attachment,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "user": user?.toJson(),
      };
}
