import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:github/contact.dart';
import 'package:github/gallery.dart';
import 'package:github/map/Maps.dart';
import 'package:github/screens/ChooseQuizScreen.dart';
import 'package:github/screens/login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerNavigationOne extends StatefulWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;
  final GoogleSignInAccount? googleUser;
  final String? email;

  const DrawerNavigationOne({
    required this.onItemSelected,
    required this.selectedIndex,
    required this.googleUser,
    required this.email,
  });

  @override
  _DrawerNavigationOneState createState() => _DrawerNavigationOneState();
}

class _DrawerNavigationOneState extends State<DrawerNavigationOne> {
  Uint8List? _image;
  File? selectedImage;
  final String imageKey = 'selected_image';

  @override
  void initState() {
    super.initState();
    loadPersistedData();
  }

  Future<void> loadPersistedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imageString = prefs.getString(imageKey);

    if (imageString != null) {
      setState(() {
        selectedImage = File(imageString);
        _image = selectedImage?.readAsBytesSync();
      });
    }
  }

  Future<void> persistSelectedImage() async {
    if (selectedImage != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(imageKey, selectedImage!.path);
    }
  }

  void logout() {
    // Add your logout logic here
    // For example, you can clear user session data, perform any cleanup, etc.

    // After logout, navigate to the login screen
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    String? userName = widget.googleUser?.displayName;
    String? userEmail = widget.email ?? widget.googleUser?.email;

    return Drawer(
      width: 300.0,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(userName ?? ''),
            accountEmail: Text(userEmail ?? ''),
            currentAccountPicture: imageProfile(),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
            ),
          ),
          _buildListTile('Home', Icons.home, 0),
          _buildListTile('Calc', Icons.calculate, 1),
          _buildListTile('Contact us', Icons.info, 2),
          _buildListTile('phone', Icons.call, 3),
          _buildListTile('Images', Icons.photo, 4),
          _buildListTile('Attempt Quiz', Icons.quiz, 5),
          _buildListTile('Location', Icons.map_outlined, 6),
          _buildListTile('Signout', Icons.logout, 7),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, int index) {
    bool isSelected = widget.selectedIndex == index;
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: () {
        if (title == 'Contact') {
          Navigator.pop(context); // Close the drawer
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Contacts()),
          );
        }
        else if (title == 'Images') {
          Navigator.pop(context); // Close the drawer
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GalleryPage()),
          );
        } else if (title == 'Attempt Quiz') {
          Navigator.pop(context); // Close the drawer
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChooseQuizScreen()),
          );
        }
        else if (title == 'Location') {
          Navigator.pop(context); // Close the drawer
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapPage()),
          );
        }
        else if (title == 'Signout') {
          Navigator.pop(context); // Close the drawer
          logout(); // Call the logout method
        }
        else {
          widget.onItemSelected(index);
          Navigator.pop(context); // Close the drawer
        }
      },
      selected: isSelected,
      tileColor: isSelected ? const Color.fromARGB(255, 76, 175, 158).withOpacity(0.2) : null,
      selectedTileColor: const Color.fromARGB(255, 76, 175, 173).withOpacity(0.2),
    );
  }

  Widget imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
          selectedImage != null
              ? CircleAvatar(
                  radius: 100.0,
                  backgroundImage: FileImage(selectedImage!),
                )
              : CircleAvatar(
                  radius: 100.0,
                  backgroundImage: AssetImage('assets/1.jpeg'),
                ),
          Positioned(
            bottom: -5.0,
            right: -5.0,
            child: IconButton(
              onPressed: () {
                showImagePickerOption(context);
              },
              icon: const Icon(
                Icons.add_a_photo,
                color: Colors.teal,
                size: 30.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.teal,
      context: context,
      builder: (builder) {
        return Padding(
          padding: const EdgeInsets.all(18.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4.5,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _pickImageFromGallery();
                    },
                    child: const SizedBox(
                      child: Column(
                        children: [
                          Icon(
                            Icons.image,
                            size: 70,
                          ),
                          Text("Gallery")
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _pickImageFromCamera();
                    },
                    child: const SizedBox(
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 70,
                          ),
                          Text("Camera")
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Gallery
  Future<void> _pickImageFromGallery() async {
    final returnImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnImage == null) {
      // Handle the case where the user cancels the image picking operation
      return;
    }

    try {
      final imageFile = File(returnImage.path);
      if (imageFile.existsSync()) {
        setState(() {
          selectedImage = imageFile;
          _image = imageFile.readAsBytesSync();
        });
        persistSelectedImage(); // Persist the selected image
      }
    } catch (e) {
      // Handle potential exceptions when reading the image file
      print('Error reading image file: $e');
    }

    Navigator.of(context).pop();
  }

  // Camera
  Future<void> _pickImageFromCamera() async {
    final returnImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnImage == null) {
      // Handle the case where the user cancels the image picking operation
      return;
    }

    try {
      final imageFile = File(returnImage.path);
      if (imageFile.existsSync()) {
        setState(() {
          selectedImage = imageFile;
          _image = imageFile.readAsBytesSync();
        });
        persistSelectedImage(); // Persist the selected image
      }
    } catch (e) {
      // Handle potential exceptions when reading the image file
      print('Error reading image file: $e');
    }

    Navigator.of(context).pop();
  }
}
