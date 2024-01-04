class SubscriptionPlan {
  final String id;
  final String name;
  final int price;
  final String time_period;
  final bool is_active;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'time_period': time_period,
      'is_active': is_active
    };
  }

  SubscriptionPlan(
      {required this.id,
      required this.name,
      required this.price,
      required this.time_period,
      required this.is_active});

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? '',
      time_period: json['time_period'] ?? '',
      is_active: json['is_active'] ?? '',
    );
  }
}
