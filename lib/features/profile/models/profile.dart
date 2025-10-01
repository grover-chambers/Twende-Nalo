import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController(text: "John Doe");
  final TextEditingController _emailController = TextEditingController(text: "john.doe@example.com");
  final TextEditingController _aboutController = TextEditingController(text: "Flutter developer and tech enthusiast.");
  
  bool _isEditing = false;
  final String _profileImageUrl = 'https://i.pravatar.cc/150?img=3'; // Placeholder profile image

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    // Here you would typically save the updated profile info to backend or local storage
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(_profileImageUrl),
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              onTap: () {
                // Implement image picker here to update profile picture
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Change profile picture tapped')),
                );
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue,
                child: Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: _isEditing ? const OutlineInputBorder() : InputBorder.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileImage(),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Name',
              controller: _nameController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              label: 'Email',
              controller: _emailController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              label: 'About',
              controller: _aboutController,
              maxLines: 4,
              enabled: _isEditing,
            ),
          ],
        ),
      ),
    );
  }
}
