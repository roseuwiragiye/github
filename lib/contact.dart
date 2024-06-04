import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

class Contacts extends StatefulWidget {
  @override
  _MyContactsState createState() => _MyContactsState();
}

class _MyContactsState extends State<Contacts> {
  List<Contact>? contacts;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    getContact();
  }

  void getContact() async {
    if (await FlutterContacts.requestPermission()) {
      contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
      setState(() {});
    }
  }

  List<Contact>? _filteredContacts() {
    if (_searchQuery.isEmpty) {
      return contacts;
    } else {
      return contacts
          ?.where((contact) => contact.displayName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "  MY CONTACTS  ",
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _buildContactList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactList() {
    return (contacts == null)
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _filteredContacts()?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              Contact contact = _filteredContacts()![index];
              Uint8List? image = contact.photo;
              String num = (contact.phones.isNotEmpty)
                  ? (contact.phones.first.number)
                  : "--";
              return ListTile(
                leading: (contact.photo == null)
                    ? const CircleAvatar(child: Icon(Icons.person))
                    : CircleAvatar(backgroundImage: MemoryImage(image!)),
                title: Text("${contact.name.first} ${contact.name.last}"),
                subtitle: Text(num),
                onTap: () {
                  // Show options for call or send SMS
                  _showOptions(contact);
                },
              );
            },
          );
  }

  void _showOptions(Contact contact) {
    String phoneNumber =
        (contact.phones.isNotEmpty) ? contact.phones.first.number : "--";

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Call $phoneNumber'),
              onTap: () {
                Navigator.pop(context);
                _makeCall(phoneNumber);
              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Send SMS to $phoneNumber'),
              onTap: () {
                Navigator.pop(context);
                _sendMessage(phoneNumber);
              },
            ),
          ],
        );
      },
    );
  }

  void _sendMessage(String number) {
    launch('sms:$number');
  }

  void _makeCall(String number) {
    launch('tel:$number');
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Contacts(),
  ));
}