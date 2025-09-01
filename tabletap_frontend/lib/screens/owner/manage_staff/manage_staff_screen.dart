import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:tabletap_frontend/screens/owner/manage_staff/edit_staff_screen.dart';
import 'dart:convert';
import 'add_staff_screen.dart';

class ManageStaffScreen extends StatefulWidget {
  const ManageStaffScreen({super.key});

  @override
  State<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends State<ManageStaffScreen> {
  List<dynamic> staffList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStaff();
  }

  Future<void> fetchStaff() async {
    final url = Uri.parse('http://192.168.0.244:5000/staff');
    final response = await http.get(url);

  if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  setState(() {
    staffList = data['staff'] ?? [];
    isLoading = false;
  });
}
 else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to load staff list')),
      );
    }
  }

  void _deleteStaff(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content:
            const Text("Are you sure you want to delete this staff member?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final url = Uri.parse('http://192.168.0.244:5000/staff/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      setState(() => staffList.removeWhere((s) => s['id'] == id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Staff deleted')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to delete staff')),
      );
    }
  }

  void _goToEditStaff(Map<String, dynamic> staff) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStaffScreen(staff: staff),
      ),
    );

    if (result == true) {
      fetchStaff(); // 🔁 Re-fetch updated list from server
    }
  }

  void _goToAddStaff() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddStaffScreen()),
    );

    if (result == true) {
      fetchStaff(); // Refresh after successful add
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Staff", style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddStaff,
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : staffList.isEmpty
              ? const Center(child: Text("No staff found"))
              : ListView.builder(
                  itemCount: staffList.length,
                  itemBuilder: (context, index) {
                    final staff = staffList[index];
                    return Card(
                      margin: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          staff['name'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          "${staff['email']} • ${staff['role']}",
                          style: GoogleFonts.poppins(),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _goToEditStaff(staff),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteStaff(staff['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
