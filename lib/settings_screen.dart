import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
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
  String selectedCurrency = "INR";

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDark;
    loadUser();
    loadCurrency();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      username = prefs.getString('username') ?? "User";

    
    });
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

  void loadCurrency() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    selectedCurrency = prefs.getString('currency') ?? "INR";
  });
}

String getSymbol(String code) {
  switch (code) {
    case "USD":
      return "\$";
    case "EUR":
      return "€";
    default:
      return "₹";
  }
}

 BoxDecoration cardDecoration(BuildContext context) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    gradient: LinearGradient(
      colors: [
        Theme.of(context).cardColor,
        Theme.of(context).cardColor.withOpacity(0.95),
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
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

          Container(
            padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
    
    borderRadius: BorderRadius.circular(24),
    gradient: const LinearGradient(
  colors: [
    Color(0xFF1E293B), 
    Color(0xFF0F172A),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
),
    boxShadow: [
  BoxShadow(
    color: Color(0xFFF59E0B).withOpacity(0.15),
    blurRadius: 30,
    spreadRadius: 2,
  )
],
  ),
            child: Row(
              children: [
               Stack(
  children: [
    Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF59E0B),
            Color(0xFFFFC107),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.transparent,
        child: Text(
          username.isNotEmpty
              ? username[0].toUpperCase()
              : "U",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),


  ],
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
                              fontSize: 17,
                              letterSpacing: 1.4,
                              color: Colors.white,
                            )),
                        const SizedBox(height: 2),
                        const Text("Tap to edit ",
                            style: TextStyle(
                                fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(height: 20),

          _section("Appearance"),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
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
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: cardDecoration(context),
            child: Column(
              children: [
                
                ListTile(
  title: const Text("Currency"),
  subtitle: Text("$selectedCurrency (${getSymbol(selectedCurrency)})"),
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () async {
    final result = await showModalBottomSheet(
              backgroundColor:Theme.of(context).cardColor,

      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final currencies = [
          {"code": "INR", "symbol": "₹"},
          {"code": "USD", "symbol": "\$"},
          {"code": "EUR", "symbol": "€"},
        ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((c) {
            return ListTile(
              title: Text("${c["code"]} (${c["symbol"]})",
                  style: TextStyle(fontWeight: FontWeight.w600),),
              onTap: () {
                Navigator.pop(context, c["code"]);
              },
            );
          }).toList(),
        );
      },
    );

    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency', result);

      setState(() {
        selectedCurrency = result;
      });

      Navigator.pop(context); 
    }
  },
),

                divider(),

                SwitchListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  title: const Text("Notifications"),
                  value: true,
                  onChanged: (_) {},
                ),

                divider(),

                _tile("Language", "English"),

                divider(),

                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  title: const Text("Help Centre"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Help Centre"),
                        content: const Text(
                            "Contact: prajaktajadhav177@gmail.com"),
                      ),
                    );
                  },
                ),

                divider(),

                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  title: const Text("Reset Data"),
                  trailing:
                      const Icon(Icons.delete, color: Color.fromARGB(255, 254, 109, 99)),
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
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 8),
      child: Text(
        title,
        style: GoogleFonts.orbitron(
          fontSize: 12,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
          color: Theme.of(context)
              .textTheme
              .bodySmall
              ?.color
              ?.withOpacity(0.8),
        ),
      ),
    );
  }
}