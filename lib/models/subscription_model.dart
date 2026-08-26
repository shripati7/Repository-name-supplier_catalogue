class SubscriptionModel {
  final String supplierId;
  final String planName;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;

  SubscriptionModel({
    required this.supplierId,
    required this.planName,
    required this.status,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'supplierId': supplierId,
      'planName': planName,
      'status': status,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
