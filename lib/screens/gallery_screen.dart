import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';

class GalleryScreen extends StatelessWidget {
  final List<String> imageUrls = [
    'https://picsum.photos/1080/720.jpg',
    'https://picsum.photos/800/800.jpg',
    'https://picsum.photos/1200/800.jpg',
    'https://picsum.photos/1080/512.jpg',
    'https://picsum.photos/1200/990.jpg',
    'https://picsum.photos/800/600.jpg',
    'https://picsum.photos/700/900.jpg',
    'https://picsum.photos/700/900.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.orange[100], // Set the background color here
      body: GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return _buildImageTile(context, imageUrls[index]);
        },
      ),
    );
  }

  Widget _buildImageTile(BuildContext context, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _buildPhotoView(context, imageUrl),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: SpinKitFadingCircle(
              color: Colors.blue,
              size: 48.0,
            ),
          ),
          errorWidget: (context, url, error) {
            if (error is PlatformException && error.message!.contains('SocketException')) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'You are offline. Please check your internet connection.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            }
            return Icon(Icons.error);
          },
        ),
      ),
    );
  }

  Widget _buildPhotoView(BuildContext context, String imageUrl) {
    final currentIndex = imageUrls.indexOf(imageUrl);
    return Scaffold(
      body: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(imageUrls[index]),
            ),
          );
        },
        onPageChanged: (index) {
          if (index < currentIndex) {
            // Swiped to the left
            // Navigator.pop(context);
          } else if (index > currentIndex) {
            // Swiped to the right
            // Handle action for swiping to the next image
          }
        },
        controller: PageController(initialPage: currentIndex),
      ),
    );
  }
}
