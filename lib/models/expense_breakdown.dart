/// One category row in the expense breakdown (GET /api/expense_breakdown).
class ExpenseCategoryBreakdown {
  final String name;
  final int amount;
  final double percent;

  const ExpenseCategoryBreakdown({
    required this.name,
    required this.amount,
    required this.percent,
  });
}

/// Response from GET /api/expense_breakdown: current (unsettled) expenses
/// grouped by main category, with percent of grand total.
class ExpenseBreakdown {
  final bool success;
  final int total;
  final List<ExpenseCategoryBreakdown> categories;

  const ExpenseBreakdown({
    required this.success,
    required this.total,
    required this.categories,
  });

  static int _numInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.round();
    final d = double.tryParse(v.toString().trim());
    return d?.round() ?? 0;
  }

  static double _numDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().trim()) ?? 0;
  }

  factory ExpenseBreakdown.fromJson(Map<String, dynamic> json) {
    final raw = json['categories'] as List<dynamic>? ?? [];
    final categories = raw.map((e) {
      final m = e as Map<String, dynamic>;
      return ExpenseCategoryBreakdown(
        name: (m['name'] ?? '').toString(),
        amount: _numInt(m['amount']),
        percent: _numDouble(m['percent']),
      );
    }).toList();

    return ExpenseBreakdown(
      success: json['success'] as bool? ?? false,
      total: _numInt(json['total']),
      categories: categories,
    );
  }

  /// Empty placeholder for loading/error states.
  const ExpenseBreakdown.empty()
      : this(success: false, total: 0, categories: const []);
}
