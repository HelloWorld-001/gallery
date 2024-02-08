// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery/media_viewer_age.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Album>? _albums;
  bool loading = false;
  late Album selectedAlbum;

  bool isSelectable = false;
  Set<int> selectedItems = {};
  late List<Medium>? media;

  @override
  void initState() {
    super.initState();
    loading = true;
    initAsync();
  }

  Future<void> initAsync() async {
    if (await _promptPermissionSetting()) {
      List<Album> albums = await PhotoGallery.listAlbums();
      MediaPage mediaPage = await albums.first.listMedia();
      setState(() {
        selectedAlbum = albums.first;
        _albums = albums;
        media = mediaPage.items;
        loading = false;
      });
    }
    setState(() {
      loading = false;
    });
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS) {
      if (await Permission.photos.request().isGranted || await Permission.storage.request().isGranted) {
        return true;
      }
    }
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted ||
          await Permission.photos.request().isGranted &&
              await Permission.videos.request().isGranted) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isSelectable,
      onPopInvoked: (didPop) {
        setState(() {
          isSelectable = false;
          selectedItems.clear();
        });
      },
      child: Scaffold(
        body: loading
        ? Center(
          child: CircularProgressIndicator(),
        )
        : CustomScrollView(
          slivers: [
            SliverAppBar(
              title: PopupMenuButton(// * Albums
                itemBuilder: (context) {
                  return <PopupMenuItem>[
                    ...?_albums?.map(
                      (album) {
                        if (album.name == null) {
                          return PopupMenuItem(
                            height: 0,
                            child: SizedBox()
                          );
                        }
                        return PopupMenuItem(
                          onTap: () async {
                            var newMedia = await album.listMedia();
                            setState(() {
                              selectedAlbum = album;
                              media = newMedia.items;
                              selectedItems.clear();
                            });
                          },
                          child: Text(album.name.toString()),
                        );
                      },
                    )
                  ];
                },
                child: Row(
                  children: [
                    Text(selectedAlbum.name!, style: TextStyle(color: Colors.black)),
                    Icon(Icons.keyboard_arrow_down, color: Colors.black,)
                  ],
                ),
              ),
              actions: [
                if(isSelectable)
                TextButton(
                  onPressed: () {},
                  child: Text("Next", style: TextStyle(color: Colors.blue, fontSize: 20)),
                )
              ],
            ),
            SliverGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 1.0,
              crossAxisSpacing: 1.0,
              children: <Widget>[
                ...?media?.asMap().entries.map(
                  (entry) {
                    int index = entry.key;
                    Medium medium = entry.value;
                    return GestureDetector(
                      onTap: () {
                        if (isSelectable) {
                          setState(() {
                            if (selectedItems.contains(index)) {
                              selectedItems.remove(index);
                              if(selectedItems.isEmpty) {
                                isSelectable = false;
                              }
                            } else {
                              selectedItems.add(index);
                            }
                          });
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MediumViewerPage(medium: medium)),
                          );
                        }
                      },
                      onLongPress: () {
                        setState(() {
                          isSelectable = true;
                          selectedItems.add(index);
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center, fit: StackFit.expand,
                        children: [
                          Container(
                            color: Colors.grey[300],
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
                          if (isSelectable && selectedItems.contains(index))
                            Container(
                              height: double.maxFinite, width: double.maxFinite,
                              color: Colors.black.withOpacity(0.45),
                              child: Icon(Icons.done_rounded, size: 40, color: Colors.white.withOpacity(0.9),),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}