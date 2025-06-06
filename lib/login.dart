import 'package:flutter/material.dart';
import 'client_dropdown.dart';
import 'main.dart'; // Optional: only if MyHomePage is here

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedClient = '-- select --';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F2FD),
      body: Container(
        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)], // Light teal gradient
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //   ),
        // ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Login to Book Slot',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.teal[800],
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 30),

                      // Client Dropdown
                      ClientDropdown(
                        selectedClient: selectedClient,
                        onChanged: (value) {
                          setState(() {
                            selectedClient = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),

                      // Email
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: "Email"),
                        validator: (value) =>
                            value!.trim().isEmpty ? 'Email is required' : null,
                      ),
                      SizedBox(height: 20),

                      // Password
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: "Password"),
                        validator: (value) =>
                            value!.trim().isEmpty ? 'Password is required' : null,
                      ),
                      SizedBox(height: 30),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                selectedClient != '-- select --') {
                              // Success
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Login Successful")),
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MyHomePage(title: 'Welcome'),
                                ),
                              );
                            } else if (selectedClient == '-- select --') {
                              // Dropdown not selected
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please select a branch")),
                              );
                            }
                          },
                          child: Text("Login"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ),
        ),
      ),
    );
  }
}
