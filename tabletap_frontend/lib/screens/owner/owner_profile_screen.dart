import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController = TextEditingController(text: prefs.getString('owner_name') ?? '');
      _emailController = TextEditingController(text: prefs.getString('owner_email') ?? '');
      _phoneController = TextEditingController(text: prefs.getString('owner_phone') ?? '');
      _passwordController = TextEditingController();
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('owner_name', _nameController.text.trim());
    await prefs.setString('owner_email', _emailController.text.trim());
    await prefs.setString('owner_phone', _phoneController.text.trim());
    

    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  Widget _buildProfileField(
      {required IconData icon,
      required String label,
      required TextEditingController controller,
      bool obscureText = false}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: _isEditing
            ? TextField(
                controller: controller,
                obscureText: obscureText,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter $label',
                ),
              )
            : Text(
                controller.text.isEmpty ? 'Not set' : controller.text,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text("Owner Profile"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),

            _buildProfileField(icon: Icons.person, label: 'Name', controller: _nameController),
            const SizedBox(height: 16),
            _buildProfileField(icon: Icons.email, label: 'Email', controller: _emailController),
            const SizedBox(height: 16),
            _buildProfileField(icon: Icons.phone, label: 'Phone', controller: _phoneController),
            const SizedBox(height: 16),
            
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.badge, color: Colors.deepPurple),
                title: Text('Role', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
                subtitle: const Text('Owner'),
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                if (_isEditing) {
                  _saveProfile();
                } else {
                  setState(() => _isEditing = true);
                }
              },
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              label: Text(_isEditing ? "Save Profile" : "Edit Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
