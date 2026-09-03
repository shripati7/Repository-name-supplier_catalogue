class SubscriptionModel {
  final String supplierId;

  final String planName;
  final String status;

  final DateTime? startDate;
  final DateTime? endDate;

  final int retailerLimit;
  final int connectedRetailers;

  final int freeTrialDays;

  SubscriptionModel({
    required this.supplierId,
    required this.planName,
    required this.status,
    this.startDate,
    this.endDate,
    required this.retailerLimit,
    required this.connectedRetailers,
    required this.freeTrialDays,
  });

  Map<String, dynamic> toMap() {
    return {
      'supplierId': supplierId,
      'planName': planName,
      'status': status,
      'startDate': startDate,
      'endDate': endDate,
      'retailerLimit': retailerLimit,
      'connectedRetailers': connectedRetailers,
      'freeTrialDays': freeTrialDays,
    };
  }

  static const String freeTrial = 'Free Trial';
  static const String basic = 'Basic';
  static const String silver = 'Silver';
  static const String gold = 'Gold';
}
