import 'package:flutter/material.dart';

class AddTransaction extends StatefulWidget {
  final Function addTransaction;

  AddTransaction(this.addTransaction);

  @override
  _AddTransactionState createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String _selectedType = 'income';

  void submitData() {
    final enteredTitle = titleController.text;
    final enteredAmount = double.tryParse(amountController.text);

    if (enteredTitle.isEmpty || enteredAmount == null || enteredAmount <= 0) {
      return;
    }

    widget.addTransaction(
      enteredTitle,
      enteredAmount,
      _selectedType,
    );

    Navigator.of(context).pop(); // Close the modal
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
                onSubmitted: (_) => submitData(),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSubmitted: (_) => submitData(),
              ),
              DropdownButton<String>(
                value: _selectedType,
                items: <String>['income', 'expense']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.capitalize()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              ElevatedButton(
                onPressed: submitData,
                child: Text('Add Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringCapitalization on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1);
  }
}
