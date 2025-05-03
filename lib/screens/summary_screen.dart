import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import '../services/firestore_service.dart';
import '../utils/date_helpers.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String userId = 'demoUser';
  String _selectedMonth = DateHelpers.getCurrentMonthYear();
  late Future<Map<String, dynamic>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _firestoreService.getMonthlySummary(_selectedMonth, userId);
  }

  void _onMonthChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedMonth = newValue;
        _summaryFuture = _firestoreService.getMonthlySummary(_selectedMonth, userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> months = DateHelpers.getRecentMonthYears(12);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Summary')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: DropdownButtonFormField<String>(
              value: _selectedMonth,
              decoration: InputDecoration(
                labelText: "Select Month",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _onMonthChanged,
              items: months
                  .map((month) => DropdownMenuItem<String>(
                        value: month,
                        child: Text(month),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _summaryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text("No data available."));
                }

                final data = snapshot.data!;
                final double income = data['incomeTotal'];
                final double expense = data['expenseTotal'];
                final double netBalance = income - expense;
                final breakdown = Map<String, double>.from(data['categoryBreakdown']);
                final sortedBreakdown = breakdown.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: theme.cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text("Total Income", style: theme.textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Text("₹${income.toStringAsFixed(2)}",
                                style: theme.textTheme.headlineSmall?.copyWith(color: Colors.greenAccent)),
                            const SizedBox(height: 16),
                            Text("Total Expense", style: theme.textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Text("₹${expense.toStringAsFixed(2)}",
                                style: theme.textTheme.headlineSmall?.copyWith(color: Colors.redAccent)),
                            const SizedBox(height: 16),
                            Text("Net Balance", style: theme.textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Text("₹${netBalance.toStringAsFixed(2)}",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: netBalance >= 0 ? Colors.blue : Colors.red,
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (breakdown.isNotEmpty) ...[
                      Text("Category Pie Chart", style: theme.textTheme.titleLarge),
                      const SizedBox(height: 10),
                      PieChart(
                        dataMap: breakdown,
                        chartRadius: MediaQuery.of(context).size.width * 0.6,
                        chartType: ChartType.disc,
                        legendOptions: const LegendOptions(
                          showLegendsInRow: false,
                          legendPosition: LegendPosition.right,
                        ),
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValuesInPercentage: true,
                          showChartValues: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text("Category Breakdown", style: theme.textTheme.titleLarge),
                    const SizedBox(height: 10),
                    if (sortedBreakdown.isEmpty)
                      const Center(child: Text("No expenses yet."))
                    else
                      ...sortedBreakdown.map(
                        (entry) => ListTile(
                          leading: const Icon(Icons.category, color: Colors.grey),
                          title: Text(entry.key),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("₹${entry.value.toStringAsFixed(2)}"),
                              Text(
                                "${(entry.value / expense * 100).toStringAsFixed(1)}%",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
