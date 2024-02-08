import 'package:flutter/material.dart';
import 'package:gallery/video_provider.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

class MediumViewerPage extends StatelessWidget {
  final Medium medium;

  const MediumViewerPage({super.key, required this.medium});

  @override
  Widget build(BuildContext context) {
    DateTime? date = medium.creationDate ?? medium.modifiedDate;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: date != null ? Text(date.toLocal().toString()) : null,
      ),
      body: Container(
        alignment: Alignment.center,
        child: medium.mediumType == MediumType.image
            ? GestureDetector(
                onTap: () async {
                  PhotoGallery.deleteMedium(mediumId: medium.id);
                },
                child: FadeInImage(
                  fit: BoxFit.cover,
                  placeholder: MemoryImage(kTransparentImage),
                  image: PhotoProvider(mediumId: medium.id),
                ),
              )
            : VideoProvider(
                mediumId: medium.id,
              ),
      ),
    );
  }
}
