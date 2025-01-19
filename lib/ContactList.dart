import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Contactlist extends StatefulWidget {
  const Contactlist({super.key});

  @override
  State<Contactlist> createState() => _ContactlistState();
}

class _ContactlistState extends State<Contactlist> {
  List<Map<String, String>> _contacts = [];
  List<Map<String, String>> _filteredContacts = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    try {
      final List<dynamic> result = await _getContactsFromNative();
      setState(() {
        // Convert result to Map<String, String>, sanitize, and remove duplicates
        _contacts = _removeDuplicates(
          result.map((dynamic contact) {
            // Convert to Map<String, String> and sanitize phone number
            final sanitizedContact = Map<String, String>.from(contact);
            String sanitizedPhone =
                (sanitizedContact['phone'] ?? '').replaceAll(' ', '');

            // Add +91 if it doesn't exist
            if (!sanitizedPhone.startsWith('+91') &&
                sanitizedPhone.isNotEmpty) {
              sanitizedPhone = '+91$sanitizedPhone';
            }

            sanitizedContact['phone'] = sanitizedPhone;
            return sanitizedContact;
          }).toList(),
        );
        _filteredContacts =
            _contacts; // Initialize filtered contacts with unique contacts
      });
    } on PlatformException catch (e) {
      print("Failed to get contacts: '${e.message}'.");
    }
  }

  List<Map<String, String>> _removeDuplicates(
      List<Map<String, String>> contacts) {
    final uniqueContacts = <Map<String, String>>[];
    for (var contact in contacts) {
      if (!uniqueContacts.any((existingContact) =>
          existingContact['name'] == contact['name'] &&
          existingContact['phone'] == contact['phone'])) {
        uniqueContacts.add(contact);
      }
    }
    return uniqueContacts;
  }

  Future<List<dynamic>> _getContactsFromNative() async {
    const platform = MethodChannel('com.example.dual_sim_info/contact_details');
    try {
      final List<dynamic> result = await platform.invokeMethod('getContacts');
      return result;
    } on PlatformException catch (e) {
      print("Failed to get contacts: '${e.message}'.");
      return [];
    }
  }

  void _filterContacts(String query) {
    List<Map<String, String>> filteredList = _contacts
        .where((contact) =>
            contact['name']!.toLowerCase().contains(query.toLowerCase()) ||
            contact['phone']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredContacts = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white, fontSize: 16),
                onChanged: (query) {
                  _filterContacts(query);
                },
              )
            : Text(
                'Contacts',
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                    fontSize: 18),
              ),
        backgroundColor: Colors.blueGrey,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear(); // Clear search text when closing
                  _filterContacts('');
                }
              });
            },
          ),
        ],
      ),
      body: ContactListWidget(contacts: _filteredContacts),
    );
  }
}

class ContactListWidget extends StatelessWidget {
  final List<Map<String, String>> contacts;

  ContactListWidget({required this.contacts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                contact['name'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                contact['phone'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              leading: CircleAvatar(
                child: Icon(Icons.person),
              ),
              onTap: () {
                // Handle tap on contact
              },
            ),
          ),
        );
      },
    );
  }
}
