import 'package:flutter/material.dart';
import '../utils/date_helpers.dart';
import '../services/firestore_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();

  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();
  final String userId = 'demoUser'; 

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    await _firestoreService.initializeDefaultCategories(userId);
    final userCategories = await _firestoreService.getUserCategories(userId);
    setState(() {
      _categories = userCategories;
    });
  }

  Future<void> _addNewCategory(String name) async {
    if (name.trim().isEmpty) return;
    await _firestoreService.addCategory(name, userId);
    _newCategoryController.clear();
    await _loadCategories();
    setState(() {
      _selectedCategory = name;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category added!')),
    );
  }

  Future<void> _submitExpense() async {
    if (_formKey.currentState!.validate()) {
      final description = _descriptionController.text.trim();
      final amount = double.parse(_amountController.text.trim());

      setState(() => _isLoading = true);

      try {
        await _firestoreService.addExpense({
          'description': description,
          'amount': amount,
          'category': _selectedCategory ?? 'Uncategorized',
          'month': DateHelpers.getCurrentMonthYear(),
        }, userId);

        _descriptionController.clear();
        _amountController.clear();
        setState(() => _selectedCategory = null);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
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
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter amount';
                  final numValue = double.tryParse(value);
                  if (numValue == null || numValue <= 0) return 'Enter valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newCategoryController,
                decoration: InputDecoration(
                  labelText: 'Add New Category',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addNewCategory(_newCategoryController.text),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitExpense,
                      child: const Text('Add Expense'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
