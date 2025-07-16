import "dart:io";
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

///imagesFiles and videoFiles are ValueNotifier list of files that are suppose to store the images and videos files while isDarkmode is a ValueNotifier boolean that determines if the theme mode is light or dark mode.
final ValueNotifier<List<File>> imageFiles = ValueNotifier<List<File>>([]);
final ValueNotifier<List<File>> videoFiles = ValueNotifier<List<File>>([]);
ValueNotifier<bool> isDarkmode = ValueNotifier(true);

///Status Model is a class that have the main mechanisms of the app in it like loading the files and generating the thumbnails.
class StatusModel {
  /// loadStatusFiles is a Future String function that access the memory to get the images and videos from their folders.
  Future<String?> loadStatusFiles() async {
    //print(await Permission.photos.status); //print(await Permission.videos.status);
    if (await Permission.manageExternalStorage.request().isGranted) {
      Directory sdir = Directory(
        "/storage/emulated/0/Anime/",
        //"/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses/",
      );
      if (!await sdir.exists()) {
        sdir = Directory(
          "/storage/emulated/0/WhatsApp/Media/.Statuses",
        ); // Fallback
      }
      if (await sdir.exists()) {
        List<FileSystemEntity> files = sdir.listSync(followLinks: true);
        final newImages = <File>[];
        final newVideos = <File>[];
        //print("Scanning Directory: ${sdir.path}");
        //print("Found ${files.length} files");

        for (var file in files) {
          if (file is File) {
            final path = file.path.toLowerCase();
            //print("Checking File: ${file.path}");

            if (path.endsWith('.jpg') ||
                path.endsWith('.jpeg') ||
                path.endsWith('.png') ||
                path.endsWith('.gif')) {
              newImages.add(file);
              //imageFiles.add(file);
            } else if (path.endsWith('.mp4') ||
                path.endsWith('.3gp') ||
                path.endsWith('.mkv')) {
              newVideos.add(file);
              //videoFiles.add(file);
            }
          }
        }

        imageFiles.value =
            newImages; //print('Images found: ${newImages.length}');
        videoFiles.value =
            newVideos; //print('Videos found: ${newVideos.length}');
        return null;
      } else {
        return "Whatsapp Status Directory not found";
      }
    } else {
      return "Storage Permission Denied";
    }
  }

  ///generateAndCleanThumbnail is a Future String function that generates the thumbnails for the videos and then clean it from the device after displaying it to the user.
  Future<String?> generateAndCleanThumbnail(String videoPath) async {
    try {
      String? thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        //maxHeight: 100,//maxWidth: 100,//quality: 100,
      );
      //print("Thumbnail created: $thumbnailPath");
      return thumbnailPath;
    } catch (e) {
      //print("Thumbnail generation failed: $e");
      rethrow;
    } finally {
      // Delay deletion slightly to ensure the UI renders the thumbnail
      Future.delayed(const Duration(milliseconds: 500), () async {
        Directory tempDir = await getTemporaryDirectory();
        List<FileSystemEntity> files = tempDir.listSync();
        for (var file in files) {
          if (file.path.endsWith('.jpeg') && file.path.contains('thumbnail')) {
            try {
              await file.delete();
              //print("Deleted thumbnail: ${file.path}");
            } catch (e) {
              //print("Error deleting thumbnail: $e");
            }
          }
        }
      });
    }
  }
}
