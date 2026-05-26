import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddHospitalPage extends StatefulWidget {
  const AddHospitalPage({super.key});

  @override
  State<AddHospitalPage> createState() => _AddHospitalPageState();
}

class _AddHospitalPageState extends State<AddHospitalPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  Future<bool> _isNameExists(String name) async {
    final result =
        await _firestore
            .collection('hospital')
            .where('name', isEqualTo: name)
            .get();

    return result.docs.isNotEmpty;
  }

  Future<int> _getNextId() async {
    final query =
        await _firestore
            .collection('hospital')
            .orderBy('id', descending: true)
            .limit(1)
            .get();

    if (query.docs.isEmpty) return 1;

    return query.docs.first['id'] + 1;
  }

  Future<void> _addHospital() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();

    try {
      final exists = await _isNameExists(name);

      if (exists) {
        _showSnackBar("Name already exists, you must change it");
        setState(() => _isLoading = false);
        return;
      }

      final newId = await _getNextId();

      await _firestore.collection('hospital').add({'id': newId, 'name': name});

      _formKey.currentState!.reset();
      _nameController.clear();

      _showSnackBar("Hospital added successfully");

      setState(() {});
    } catch (e) {
      _showSnackBar("Error: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Hospital")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Hospital Name",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Enter hospital name"
                            : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _addHospital,
                    child: const Text("Add Hospital"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
