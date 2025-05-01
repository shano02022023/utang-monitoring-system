import 'package:flutter/material.dart';
import 'package:utang_monitoring_system/controller/debts_controller.dart';
import 'package:utang_monitoring_system/layouts/main_layout.dart';
import 'package:utang_monitoring_system/widgets/input_widget.dart';
import 'package:intl/intl.dart';

class DebtsPage extends StatefulWidget {
  const DebtsPage({super.key});

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _middlenameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  List<Map<String, dynamic>> debts = [];
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? selectedFilterStatus;

  Future<void> getDebts(filterStatus) async {
    setState(() {
      isLoading = true;
    });
    final _data = await DebtsController.getDebts(filterStatus);

    setState(() {
      debts = _data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getDebts('');
  }

  void _clearForm() {
    _firstnameController.clear();
    _middlenameController.clear();
    _lastnameController.clear();
    _amountController.clear();
    _remarksController.clear();
  }

  Future<void> _addDebt(BuildContext context) async {
    if (_firstnameController.text.isNotEmpty &&
        _lastnameController.text.isNotEmpty &&
        int.parse(_amountController.text) != 0 &&
        (_middlenameController.text.length < 2 ||
            _middlenameController.text.isNotEmpty)) {
      await DebtsController.addDebt(
        _firstnameController.text,
        _middlenameController.text,
        _lastnameController.text,
        int.parse(_amountController.text),
        _remarksController.text,
      );
      _clearForm();
      Navigator.of(context).pop();
      getDebts('');
    }
  }

  void _viewDebtDetails(BuildContext context, Map<String, dynamic> debt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${debt['firstname']} ${debt['lastname']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Amount: ₱${debt['amount']}'),
              Text('Status: ${debt['status']}'),
              Text('Remarks: ${debt['remarks']}'),
              Text('Created At: ${debt['created_at']}'),
              Text('Updated At: ${debt['updated_at']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add Debt'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Container(
                    child: Column(
                      children: [
                        InputWidget(
                          hintText: "Enter First Name",
                          controller: _firstnameController,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Last Name';
                            }
                            return null;
                          },
                        ),
                        InputWidget(
                          hintText: 'Enter Middle Name',
                          controller: _middlenameController,
                          isRequired: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return null;
                            } else {
                              if (value.length < 2) {
                                return 'Please enter a valid middle name';
                              }
                            }
                            return null;
                          },
                        ),
                        InputWidget(
                          hintText: 'Enter Last Name',
                          controller: _lastnameController,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Last Name';
                            }
                            return null;
                          },
                        ),
                        InputWidget(
                          hintText: 'Enter Amount',
                          controller: _amountController,
                          isRequired: true,
                          isText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            final amount = int.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                        ),
                        TextField(
                          controller: _remarksController,
                          decoration: const InputDecoration(
                            hintText: 'Enter remarks',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5, // You can increase this as needed
                          minLines: 3, // Optional, gives a default height
                          keyboardType: TextInputType.multiline,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _clearForm();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                // Add your add logic here
                if (_formKey.currentState!.validate()) {
                  await _addDebt(dialogContext);
                } else {
                  // Show a snackbar or some error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields correctly'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateStatusDialog(Map<String, dynamic> debt) async {
    String? selectedStatus = debt['status'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Update Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${debt['firstname']} ${debt['lastname']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Amount: ₱${debt['amount']}'),
                Text('Status: ${debt['status']}'),
                Text('Remarks: ${debt['remarks'] ?? 'None'}'),
                const Divider(height: 24, thickness: 1),
                const Text(
                  'Select New Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  items:
                      <String>['Pending', 'Paid', 'Cancelled'].map((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedStatus = newValue;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton.icon(
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (selectedStatus != null) {
                  final response = await DebtsController.updateDebt(
                    debt['id'],
                    selectedStatus!,
                  );

                  if (response == 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Status updated successfully'),
                      ),
                    );
                    getDebts('');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update status')),
                    );
                  }

                  Navigator.of(context).pop();
                  getDebts('');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Text(
                'Debts Page',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedFilterStatus,
                        hint: const Text('Filter by status'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items:
                            <String>['All', 'Pending', 'Paid', 'Cancelled'].map((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value == 'All' ? '' : value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedFilterStatus = newValue;

                            getDebts(selectedFilterStatus);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<Object>(
                  stream: null,
                  builder: (context, snapshot) {
                    if (debts.isEmpty) {
                      return Center(
                        child: Text(
                          'No debts found',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    } else {
                      if (isLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else if (debts.isEmpty) {
                        return Center(
                          child: Text(
                            'No debts found',
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: debts.length,
                          itemBuilder: (context, index) {
                            final DateFormat formatter = DateFormat(
                              'MMM. dd, yyyy \'at\' h:mm a',
                            );
                            DateTime createdAt = DateTime.parse(
                              debts[index]['created_at'],
                            );
                            DateTime updatedAt = DateTime.parse(
                              debts[index]['updated_at'],
                            );

                            String formattedCreatedAt = formatter.format(
                              createdAt,
                            );
                            String formattedUpdatedAt = formatter.format(
                              updatedAt,
                            );
                            final fullName =
                                '${debts[index]['firstname']} ${debts[index]['middlename']} ${debts[index]['lastname']}';
                            return Card(
                              child: ListTile(
                                isThreeLine: true, // Allows more vertical space
                                title: Text(fullName),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '₱${debts[index]['amount'].toString()}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text('Status: ${debts[index]['status']}'),
                                      Text('Created: ${formattedCreatedAt}'),
                                      Text('Updated: ${formattedUpdatedAt}'),
                                    ],
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisSize:
                                      MainAxisSize.min, // Prevent overflow
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const SizedBox(height: 4),
                                    TextButton(
                                      onPressed: () {
                                        _showUpdateStatusDialog(debts[index]);
                                      },
                                      child: Text(
                                        'Update Status',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                                onLongPress: () {
                                  _viewDebtDetails(context, debts[index]);
                                },
                              ),
                            );
                          },
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddDialog(context);
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
