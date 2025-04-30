import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/date_helpers.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String _selectedMonth = DateHelpers.getCurrentMonthYear();
  bool _isLoading = false;

  Future<void> _submitIncome() async {
    if (_formKey.currentState!.validate()) {
      final description = _descriptionController.text.trim();
      final amount = double.tryParse(_amountController.text.trim());

      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }

      setState(() => _isLoading = true);
      FocusScope.of(context).unfocus();

      try {
        await FirebaseFirestore.instance.collection('income').add({
          'description': description,
          'amount': amount,
          'timestamp': FieldValue.serverTimestamp(),
          'month': _selectedMonth,
        });

        _descriptionController.clear();
        _amountController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Income added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add income. Please try again.')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> months = DateHelpers.getRecentMonthYears(12);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Income')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter amount';
                  final numValue = double.tryParse(value);
                  if (numValue == null || numValue <= 0) return 'Enter valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMonth,
                decoration: const InputDecoration(
                  labelText: 'Select Month',
                  border: OutlineInputBorder(),
                ),
                items: months.map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMonth = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitIncome,
                      child: const Text('Add Income'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
