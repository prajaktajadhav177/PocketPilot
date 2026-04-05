import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget{

  final bool isDark;
  final Function(bool) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDark,
    required this.onThemeChanged

  });

  @override
  _SettingsScreenState createState()=> _SettingsScreenState();
}



class _SettingsScreenState extends State<SettingsScreen>{

late bool isDarkMode;
String username = "User";

@override
void initState(){
  super.initState();
  isDarkMode=widget.isDark;
  loadUser();
}


void loadUser() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    username = prefs.getString('username') ?? "User";
  });
}

void _showEditNameDialog() {
  final controller = TextEditingController(text: username);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Edit Name"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: "Enter your name",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
  final newName = controller.text.trim();

  if (newName.isEmpty) return;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', newName);

  setState(() {
    username = newName;
  });

  Navigator.pop(context); 

  Navigator.pop(context, newName); 
},
          child: const Text("Save"),
        ),
      ],
    ),
  );
}

void toggleTheme(bool value) async{
  setState(() {
    isDarkMode=value;
  });
  final prefs=await SharedPreferences.getInstance();
  await prefs.setBool('isDarkMode', value);
  widget.onThemeChanged(value);
   }

  void _showResetDialog() {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Reset Data"),
      content: const Text(
        "This will delete all your transactions. This action cannot be undone.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
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
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

 @override
Widget build(BuildContext context) {

  BoxDecoration _cardDecoration(BuildContext context) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    color: Theme.of(context).cardColor,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 3),
      )
    ],
  );
}
  return Scaffold(
    appBar: AppBar(
      title: Text(
  "Settings",
  style: GoogleFonts.orbitron(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  ),
),
      centerTitle: true,
      elevation: 0,
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [

        _buildSectionTitle("Profile"),

       GestureDetector(
  onTap: _showEditNameDialog,
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(context),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 22,
          child: Icon(Icons.person),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: GoogleFonts.poppins(
  fontWeight: FontWeight.w600,
  fontSize: 15,
    color: Theme.of(context).textTheme.bodyLarge?.color,
),
              ),
              const SizedBox(height: 2),
              const Text(
                "Tap to edit",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),

        const Icon(Icons.edit),
      ],
    ),
  ),
),

        

        const SizedBox(height: 20),

        _buildSectionTitle("Appearance"),

        Container(
          decoration: _cardDecoration(context),
          child: ListTile(
            title: const Text("Dark Mode"),
            trailing: Switch(
              value: isDarkMode,
              onChanged: toggleTheme,
            ),
          ),
        ),

        const SizedBox(height: 20),

        _buildSectionTitle("Preferences"),

        Container(
          decoration: _cardDecoration(context),
          child: Column(
            children: [

              ListTile(
                title: const Text("Currency"),
                subtitle: const Text("INR (₹)"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),

              Divider(height: 1),

              ListTile(
                title: const Text("Notifications"),
                trailing: Switch(
                  value: true,
                  onChanged: (_) {},
                ),
              ),

              Divider(height: 1),

              ListTile(
                title: const Text("Reset Data"),
                trailing: const Icon(Icons.delete, color: Colors.red),
                onTap: () {
                  _showResetDialog();
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: GoogleFonts.orbitron(
  fontSize: 12,
  letterSpacing: 1,
  fontWeight: FontWeight.w700,
  color: Theme.of(context)
      .textTheme
      .bodySmall
      ?.color
      ?.withOpacity(0.6),
),
    ),
  );
}
}