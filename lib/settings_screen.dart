import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDark;
  final Function(bool) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool isDarkMode;
  String username = "User";
  File? profileImage;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDark;
    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      username = prefs.getString('username') ?? "User";

      final path = prefs.getString('profile_image');
      if (path != null) profileImage = File(path);
    });
  }

  Future<void> pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', picked.path);

      setState(() => profileImage = File(picked.path));
    }
  }

  void toggleTheme(bool value) async {
    setState(() => isDarkMode = value);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);

    widget.onThemeChanged(value);
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: username);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('username', newName);

              setState(() => username = newName);

              Navigator.pop(context);
              Navigator.pop(context, newName);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset Data"),
        content: const Text(
            "This will delete all your transactions. This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final box = Hive.box('transactions');
              await box.clear();

              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('goal');

              if (!mounted) return;

              Navigator.pop(context);
              Navigator.pop(context, "reset");
            },
            child:
                const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ✅ MATCH YOUR EXISTING CARD STYLE
  BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      color: Theme.of(context).cardColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings",
            style: GoogleFonts.orbitron(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section("Profile"),

          // 👤 PROFILE CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: cardDecoration(context),
            child: Row(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor:
                            const Color(0xFFF59E0B).withOpacity(0.15),
                        backgroundImage: profileImage != null
                            ? FileImage(profileImage!)
                            : null,
                        child: profileImage == null
                            ? const Icon(Icons.person,
                                color: Color(0xFFF59E0B))
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFF59E0B),
                          ),
                          child: const Icon(Icons.edit,
                              size: 12, color: Colors.black),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: GestureDetector(
                    onTap: _showEditNameDialog,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(username,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: textColor,
                            )),
                        const SizedBox(height: 2),
                        const Text("Tap to edit",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),

                Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _section("Appearance"),

          Container(
            decoration: cardDecoration(context),
            child: SwitchListTile(
              title: const Text("Dark Mode"),
              value: isDarkMode,
              onChanged: toggleTheme,
            ),
          ),

          const SizedBox(height: 20),

          _section("Preferences"),

          Container(
            decoration: cardDecoration(context),
            child: Column(
              children: [
                _tile("Currency", "INR (₹)"),

                divider(),

                SwitchListTile(
                  title: const Text("Notifications"),
                  value: true,
                  onChanged: (_) {},
                ),

                divider(),

                _tile("Language", "English"),

                divider(),

                ListTile(
                  title: const Text("Help Centre"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Help Centre"),
                        content: const Text(
                            "Contact: support@pocketpilot.com"),
                      ),
                    );
                  },
                ),

                divider(),

                ListTile(
                  title: const Text("Reset Data"),
                  trailing:
                      const Icon(Icons.delete, color: Colors.red),
                  onTap: _showResetDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget divider() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Divider(height: 1),
      );

  Widget _tile(String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.orbitron(
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
          color: Theme.of(context)
              .textTheme
              .bodySmall
              ?.color
              ?.withOpacity(0.5),
        ),
      ),
    );
  }
}