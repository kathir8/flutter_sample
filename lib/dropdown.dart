import 'package:flutter/material.dart';

class ClientDropdown extends StatefulWidget {
  final Function(String) onChanged; 

  ClientDropdown({required this.onChanged});

  @override
  _ClientDropdownState createState() => _ClientDropdownState();
}

class _ClientDropdownState extends State<ClientDropdown> {
  String selectedClient = '-- select --';
  final List<String> clients = [
    '-- select --',
    'Vishnu cars',
    'Sakthi cars',
    'AIE cars',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedClient,
      decoration: InputDecoration(
        labelText: 'Client',
        border: OutlineInputBorder(),
      ),
      items: clients.map((String client) {
        return DropdownMenuItem<String>(
          value: client,
          child: Text(client),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedClient = newValue!;
        });
        widget.onChanged(selectedClient); // Notify parent widget
      },
    );
  }
}
