import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickalert/quickalert.dart';
import 'package:utang_monitoring_system/controller/my_debts_controller.dart';
import 'package:utang_monitoring_system/layouts/main_layout.dart';
import 'package:utang_monitoring_system/views/my_debts/capture_proof_photo.dart';
import 'package:utang_monitoring_system/widgets/input_widget.dart';
import 'package:intl/intl.dart';

class MyDebtsPage extends StatefulWidget {
  const MyDebtsPage({super.key});

  @override
  State<MyDebtsPage> createState() => _MyDebtsPageState();
}

class _MyDebtsPageState extends State<MyDebtsPage> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _middlenameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _partialAmountController =
      TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  List<Map<String, dynamic>> debts = [];
  final _formKey = GlobalKey<FormState>();
  final _updateStatusFormKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? selectedFilterStatus;
  final DateFormat formatter = DateFormat('MMM. dd, yyyy \'at\' h:mm a');

  final List<String> statuses = [
    'All',
    'Pending',
    'Partially Paid',
    'Paid',
    'Cancelled',
  ];

  Future<void> getMyDebts(filterStatus) async {
    setState(() {
      isLoading = true;
    });

    final _data = await MyDebtsController.getMyDebts(filterStatus);

    setState(() {
      debts = _data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getMyDebts('');
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
      await MyDebtsController.addDebt(
        _firstnameController.text,
        _middlenameController.text,
        _lastnameController.text,
        int.parse(_amountController.text),
        _remarksController.text,
      );
      _clearForm();
      Navigator.of(context).pop();
      getMyDebts('');
    }
  }

  void _viewDebtDetails(
    BuildContext viewDetailsContext,
    Map<String, dynamic> debt,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final photoPath = debt['proof_completed_photo'];

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Debt to: ${debt['lastname']}, ${debt['firstname']} ${debt['middlename']}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildInfoRow('Amount', '₱${debt['amount']}'),
                  _buildInfoRow('Status', debt['status']),
                  _buildInfoRow('Remarks', debt['remarks']),
                  _buildInfoRow(
                    'Created At',
                    formatter.format(DateTime.parse(debt['created_at'])),
                  ),
                  _buildInfoRow(
                    'Updated At',
                    formatter.format(DateTime.parse(debt['updated_at'])),
                  ),
                  if (photoPath != null && photoPath.toString().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Proof Photo:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(photoPath),
                        height: 500,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.confirm,
                  title: 'Delete Payable',
                  text: 'Are you sure you want to delete this payable?',
                  confirmBtnText: 'Delete',
                  cancelBtnText: 'Cancel',
                  onConfirmBtnTap: () async {
                    Navigator.of(context).pop();
                    final response = await MyDebtsController.deleteDebt(
                      debt['id'],
                    );
                    if (response == 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payable deleted successfully'),
                        ),
                      );
                      Navigator.of(viewDetailsContext).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to delete payable'),
                        ),
                      );
                    }
                    getMyDebts('');
                  },
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add Payable'),
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
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setModalState,
          ) {
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
                    Form(
                      key: _updateStatusFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: selectedStatus,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            items:
                                statuses.where((value) => value != 'All').map((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setModalState(() {
                                selectedStatus = newValue;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          if (selectedStatus == 'Partially Paid')
                            InputWidget(
                              hintText: 'Partial Amount',
                              controller: _partialAmountController,
                              isRequired: true,
                              isText: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a partial amount';
                                }
                                final amount = int.tryParse(value);
                                if (amount == null ||
                                    amount <= 0 ||
                                    amount >=
                                        int.parse(debt['amount'].toString())) {
                                  return 'Please enter a valid amount';
                                }
                                return null;
                              },
                            ),
                        ],
                      ),
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
                    if (_updateStatusFormKey.currentState!.validate()) {
                      if (selectedStatus != null) {
                        if (selectedStatus == 'Paid' ||
                            selectedStatus == 'Partially Paid') {
                          Get.to(
                            () => CaptureProofPhoto(
                              debt: debt,
                              selectedStatus: selectedStatus,
                              partialAmount:
                                  _partialAmountController.text.isNotEmpty
                                      ? int.parse(_partialAmountController.text)
                                      : 0,
                            ),
                          );
                        } else {
                          final response = await MyDebtsController.updateDebt(
                            debt['id'],
                            selectedStatus!,
                          );

                          if (response == 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Status updated successfully'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to update status'),
                              ),
                            );
                          }
                          Navigator.of(context).pop();
                        }
                        getMyDebts('');
                      }
                    }
                  },
                ),
              ],
            );
          },
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
                'Payables',
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
                            statuses.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value == 'All' ? '' : value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedFilterStatus = newValue;

                            getMyDebts(selectedFilterStatus);
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
                                '${debts[index]['lastname']}, ${debts[index]['firstname']} ${debts[index]['middlename']}';
                            return Card(
                              child: ListTile(
                                isThreeLine: true, // Allows more vertical space
                                title: Text(
                                  fullName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
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
                                        if (debts[index]['status'] ==
                                            'Pending') {
                                          _showUpdateStatusDialog(debts[index]);
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Cannot update status of this payable',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        debts[index]['status'] == 'Pending'
                                            ? 'Update Status'
                                            : debts[index]['status'],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style:
                                          debts[index]['status'] == 'Pending'
                                              ? TextButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              )
                                              : debts[index]['status'] == 'Paid'
                                              ? TextButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              )
                                              : TextButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
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
