class WorkReportMaterial {
  final int? id;
  final int reportId;
  final int materialId;
  final double quantity;
  final String remark;

  const WorkReportMaterial({
    this.id,
    required this.reportId,
    required this.materialId,
    required this.quantity,
    required this.remark,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reportId': reportId,
      'materialId': materialId,
      'quantity': quantity,
      'remark': remark,
    };
  }

  factory WorkReportMaterial.fromMap(Map<String, dynamic> map) {
    return WorkReportMaterial(
      id: map['id'] as int?,
      reportId: map['reportId'] as int,
      materialId: map['materialId'] as int,
      quantity: (map['quantity'] as num).toDouble(),
      remark: (map['remark'] ?? '') as String,
    );
  }

  WorkReportMaterial copyWith({
    int? id,
    int? reportId,
    int? materialId,
    double? quantity,
    String? remark,
  }) {
    return WorkReportMaterial(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      materialId: materialId ?? this.materialId,
      quantity: quantity ?? this.quantity,
      remark: remark ?? this.remark,
    );
  }
}
