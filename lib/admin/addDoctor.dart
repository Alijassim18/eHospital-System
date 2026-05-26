import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorSignUpPage extends StatefulWidget {
  const DoctorSignUpPage({super.key});

  @override
  State<DoctorSignUpPage> createState() => _DoctorSignUpPageState();
}

class _DoctorSignUpPageState extends State<DoctorSignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  List<String> hospitalNames = [];
  List<Map<String, dynamic>> hospitals = [];

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  Future<void> _fetchHospitals() async {
    final snapshot = await _firestore.collection('hospital').get();

    setState(() {
      hospitals =
          snapshot.docs
              .map((doc) => {'id': doc.id, 'name': doc['name']})
              .toList();
    });
  }

  Future<void> _chooseHospitalDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Choose Hospital"),
          children:
              hospitals.map((hospital) {
                return SimpleDialogOption(
                  child: Text(hospital['name']),
                  onPressed: () {
                    Navigator.pop(context, hospital['name']);
                  },
                );
              }).toList(),
        );
      },
    );

    if (result != null) {
      setState(() {
        if (!hospitalNames.contains(result)) {
          hospitalNames.add(result);
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      await _firestore.collection('user').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': 'doctor',
        'hospitalNames': hospitalNames,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _clearFields();
      _showMessage("Doctor account created successfully");
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Auth error");
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    hospitalNames.clear();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Create Doctor Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator:
                    (v) => v == null || v.isEmpty ? "Enter your name" : null,
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator:
                    (v) => v == null || v.isEmpty ? "Enter your email" : null,
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator:
                    (v) =>
                        v == null || v.isEmpty ? "Enter your password" : null,
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Selected Hospitals: ${hospitalNames.join(", ")}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: _chooseHospitalDialog,
                child: const Text("Choose Hospital"),
              ),

              const SizedBox(height: 20),

              ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (_, loading, __) {
                  return ElevatedButton(
                    onPressed: loading ? null : _signUp,
                    child:
                        loading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text("Create Doctor"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
