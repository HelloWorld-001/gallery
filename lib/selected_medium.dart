// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

class SelectedMedium extends StatelessWidget {
  final List<Medium> selected;
  const SelectedMedium({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: IconButton(
          onPressed: () {/* Show bottom modal sheet */},
          icon: Icon(Icons.music_note),
        ),
      ),
      body: Container(
        height: media.height/2, width: double.maxFinite,
        alignment: Alignment.center,
        child: (selected.length == 1)
        ? Card(
          color: Colors.grey[300],
          margin: EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FadeInImage(
              fit: BoxFit.fill,
              placeholder: MemoryImage(kTransparentImage),
              image: ThumbnailProvider(
                mediumId: selected.first.id,
                mediumType: selected.first.mediumType,
                highQuality: true,
              ),
            ),
          ),
        )
        : ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: selected.length,
          itemBuilder: (context, index) {
            var medium = selected[index];
            return Card(
              color: Colors.grey[300],
              margin: EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FadeInImage(
                  fit: BoxFit.fill,
                  placeholder: MemoryImage(kTransparentImage),
                  image: ThumbnailProvider(
                    mediumId: medium.id,
                    mediumType: medium.mediumType,
                    highQuality: true,
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}