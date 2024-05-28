import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  List<File> _localImages = [];
  final String _imageFolderPath = 'sanatan_pariwar_images';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadLocalImages();
    _fetchAndDownloadImages();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
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
    setState(() {
    });

    try {
      ListResult result = await _storage.ref(_imageFolderPath).listAll();
      List<Reference> refs = result.items;

      final directory = await getApplicationDocumentsDirectory();
      List<Future<void>> downloadFutures = [];
      List<String> fileNames = [];

      for (var ref in refs) {
        fileNames.add(ref.name);
        final localFile = File('${directory.path}/${ref.name}');
        if (!localFile.existsSync()) {
          downloadFutures.add(_downloadFile(ref, localFile));
        }
      }

      // Remove local files that are no longer present in Firebase Storage
      final localFiles = directory.listSync().whereType<File>().toList();
      for (var file in localFiles) {
        final fileName = file.uri.pathSegments.last;
        if (!fileNames.contains(fileName)) {
          file.deleteSync();
        }
      }

      await Future.wait(downloadFutures);
      await _loadLocalImages();
    } catch (e) {
      print('Error fetching and downloading images: $e');
    } finally {
      setState(() {
      });
    }
  }

  Future<void> _downloadFile(Reference ref, File localFile) async {
    final downloadUrl = await ref.getDownloadURL();
    final response = await http.get(Uri.parse(downloadUrl));
    if (response.statusCode == 200) {
      await localFile.writeAsBytes(response.bodyBytes);
    }
  }

  Future<void> _onRefresh() async {
    await _fetchAndDownloadImages();
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
        backgroundColor: Colors.orange[100],
        elevation: 0,
      ),
      backgroundColor: Colors.orange[100],
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.file(_localImages[index], fit: BoxFit.cover),
                ),
              );
            },
          ),
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
