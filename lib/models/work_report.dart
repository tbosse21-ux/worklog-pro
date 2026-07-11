class WorkReport {
  final int? id;
  final DateTime date;
  final int customerId;
  final String constructionSite;
  final String startTime;
  final String endTime;
  final int breakMinutes;
  final String activity;

  const WorkReport({
    this.id,
    required this.date,
    required this.customerId,
    required this.constructionSite,
    required this.startTime,
    required this.endTime,
    required this.breakMinutes,
    required this.activity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'customerId': customerId,
      'constructionSite': constructionSite,
      'startTime': startTime,
      'endTime': endTime,
      'breakMinutes': breakMinutes,
      'activity': activity,
    };
  }

  factory WorkReport.fromMap(Map<String, dynamic> map) {
    return WorkReport(
      id: map['id'] as int?,
      date: DateTime.parse(map['date']),
      customerId: map['customerId'] as int,
      constructionSite: map['constructionSite'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      breakMinutes: map['breakMinutes'] as int,
      activity: map['activity'] as String,
    );
  }

  WorkReport copyWith({
    int? id,
    DateTime? date,
    int? customerId,
    String? constructionSite,
    String? startTime,
    String? endTime,
    int? breakMinutes,
    String? activity,
  }) {
    return WorkReport(
      id: id ?? this.id,
      date: date ?? this.date,
      customerId: customerId ?? this.customerId,
      constructionSite: constructionSite ?? this.constructionSite,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      activity: activity ?? this.activity,
    );
  }
}