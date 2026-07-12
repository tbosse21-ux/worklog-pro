class WorkReportDay {
  final int? id;
  final int reportId;
  final int weekday;
  final String startTime;
  final String endTime;
  final int breakMinutes;
  final String activity;

  WorkReportDay({
    this.id,
    required this.reportId,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.breakMinutes,
    required this.activity,
  });

  double get hours {
    if (startTime.isEmpty || endTime.isEmpty) {
      return 0;
    }

    final start = startTime.split(":");
    final end = endTime.split(":");

    final startMinutes =
        int.parse(start[0]) * 60 + int.parse(start[1]);

    final endMinutes =
        int.parse(end[0]) * 60 + int.parse(end[1]);

    return (endMinutes - startMinutes - breakMinutes) / 60;
  }

  bool get isFilled =>
      startTime.isNotEmpty ||
      endTime.isNotEmpty ||
      activity.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reportId': reportId,
      'weekday': weekday,
      'startTime': startTime,
      'endTime': endTime,
      'breakMinutes': breakMinutes,
      'activity': activity,
    };
  }

  factory WorkReportDay.fromMap(Map<String, dynamic> map) {
    return WorkReportDay(
      id: map['id'],
      reportId: map['reportId'],
      weekday: map['weekday'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      breakMinutes: map['breakMinutes'],
      activity: map['activity'],
    );
  }
}