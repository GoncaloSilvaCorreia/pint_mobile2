class Report {
  final int id;
  final int commentId;
  final String workerNumber;
  final DateTime reportDate;
  final String reason;
  final bool status; // false=Pendente, true=Resolvido

  Report({
    required this.id,
    required this.commentId,
    required this.workerNumber,
    required this.reportDate,
    required this.reason,
    required this.status,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int? ?? 0,
      commentId: json['commentId'] as int? ?? 0,
      workerNumber: json['workerNumber'] as String? ?? '',
      reportDate: DateTime.parse(json['reportDate'] as String? ?? DateTime.now().toIso8601String()),
      reason: json['reason'] as String? ?? '',
      status: json['status'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'commentId': commentId,
        'workerNumber': workerNumber,
        'reportDate': reportDate.toIso8601String(),
        'reason': reason,
        'status': status,
      };
}