import 'package:flutter/material.dart';

class ClientDropdown extends StatelessWidget {
  final String selectedClient;
  final Function(String) onChanged;

  ClientDropdown({required this.selectedClient, required this.onChanged});

  final List<String> clients = [
    '-- select --',
    'Vishnu Cars Driving School',
    'Sakthi Cars Driving School',
    'AIE Driving School',
    'Star Driving School',
    'Prime Driving School',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedClient,
      decoration: InputDecoration(
        labelText: 'Select Branch',
      ),
      items: clients.map((client) {
        return DropdownMenuItem(
          value: client,
          child: Text(client),
        );
      }).toList(),
      onChanged: (value) => onChanged(value!),
      validator: (value) {
        if (value == '-- select --') {
          return 'Please select a branch';
        }
        return null;
      },
    );
  }
}
