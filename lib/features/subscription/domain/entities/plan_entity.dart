class PlanEntity {
  final String id;
  final String name;
  final String description;
  final double monthlyPrice;
  final double sixMonthsPrice;
  final double yearlyPrice;
  final double? originalSixMonthsPrice;
  final double? originalYearlyPrice;
  final int? sixMonthsDiscountPercent;
  final int? yearlyDiscountPercent;
  final List<String> features;
  final bool isPopular;
  final bool isBestValue;
  final String? badge;

  const PlanEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.sixMonthsPrice,
    required this.yearlyPrice,
    this.originalSixMonthsPrice,
    this.originalYearlyPrice,
    this.sixMonthsDiscountPercent,
    this.yearlyDiscountPercent,
    required this.features,
    this.isPopular = false,
    this.isBestValue = false,
    this.badge,
  });
}
