import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:permission_handler/permission_handler.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _isOffline = false;
  List<File> _localImages = [];
  final String _imageFolderPath = 'sanatan_pariwar_images';

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _checkPermissions();
    _loadLocalImages();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isOffline = true;
      });
    } else {
      setState(() {
        _isOffline = false;
      });
    }
  }

  Future<void> _loadLocalImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> files = directory.listSync();
    setState(() {
      _localImages = files
          .whereType<File>()
          .where((file) => file.path.endsWith('.jpg') || file.path.endsWith('.png'))
          .toList();
    });
  }

  Future<void> _fetchAndDownloadImages() async {
    try {
      ListResult result = await _storage.ref(_imageFolderPath).listAll();
      List<String> urls = await Future.wait(result.items.map((ref) => ref.getDownloadURL()).toList());

      final directory = await getApplicationDocumentsDirectory();
      for (String url in urls) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final fileName = url.split('/').last.split('?').first;
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(response.bodyBytes);
        }
      }

      // Remove local files that are no longer present in Firebase Storage
      final localFiles = directory.listSync().whereType<File>().toList();
      for (var file in localFiles) {
        final fileName = file.uri.pathSegments.last;
        if (!urls.any((url) => url.contains(fileName))) {
          file.deleteSync();
        }
      }

      _loadLocalImages();
    } catch (e) {
      print('Error fetching and downloading images: $e');
    }
  }

  Future<void> _onRefresh() async {
    await _checkConnectivity();
    if (!_isOffline) {
      await _fetchAndDownloadImages();
    }
    setState(() {});
  }

  void _viewImage(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewer(
          imageFiles: _localImages,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.orange[100],
      body: _isOffline
          ? Center(child: Text('No internet connection'))
          : RefreshIndicator(
        onRefresh: _onRefresh,
        child: GridView.builder(
          padding: EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _localImages.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _viewImage(context, index),
              child: Image.file(_localImages[index], fit: BoxFit.cover),
            );
          },
        ),
      ),
    );
  }
}

class ImageViewer extends StatelessWidget {
  final List<File> imageFiles;
  final int initialIndex;

  ImageViewer({required this.imageFiles, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoViewGallery.builder(
        itemCount: imageFiles.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(imageFiles[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        pageController: PageController(initialPage: initialIndex),
        onPageChanged: (index) {},
      ),
    );
  }
}
