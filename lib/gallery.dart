import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<ImageFile> images = [];

  @override
  void initState() {
    super.initState();
    loadAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              // Handle selection
              List<ImageFile> selectedImages =
                  images.where((image) => image.isSelected).toList();
              Navigator.pop(context, selectedImages);
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // View image in full-screen mode
              _onAssetTap(images[index]);
            },
            onLongPress: () {
              // Handle long press to toggle selection
              setState(() {
                // Toggle selection state
                images[index].isSelected = !images[index].isSelected;
              });
            },
            child: Stack(
              children: [
                Image.file(
                  File(images[index].path),
                  fit: BoxFit.cover,
                ),
                if (images[index].isSelected)
                  Positioned(
                    top: 4.0,
                    right: 4.0,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> loadAssets() async {
    try {
      final List<XFile>? result = await ImagePicker().pickMultiImage();
      if (result != null) {
        setState(() {
          // Initialize images list and set isSelected property to true for each image
          images = result
              .map((file) => ImageFile(path: file.path, isSelected: true))
              .toList();
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _onAssetTap(ImageFile asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenView(asset: asset),
      ),
    );
  }
}

class ImageFile {
  final String path;
  bool isSelected;

  ImageFile({required this.path, required this.isSelected});
}

class FullScreenView extends StatelessWidget {
  final ImageFile asset;

  const FullScreenView({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Screen View'),
      ),
      body: Center(
        child: Hero(
          tag: 'asset_${asset.path}', // Use a unique tag for each asset
          child: Image.file(
            File(asset.path),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}