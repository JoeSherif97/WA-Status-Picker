import 'dart:io';
import 'status_model.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

///Status Controller is a class that requires Status Model and is responsible for toggling the theme, and refreshing the files, and the download mechanism.
class StatusController {
  final StatusModel model;

  StatusController(this.model);

  ///Turn the value of boolean isdarkmode from true to false and vise versa.
  void toggleTheme() {
    isDarkmode.value = !isDarkmode.value;
  }

  ///refresh is Future Void function that refresh the content of the app in case their was a new file added that wasn't displayed.
  Future<void> refresh(BuildContext context) async {
    //await model.loadStatusFiles();
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: Text("Refreshing"),
            content: Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox.square(
                dimension: 50,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: CircularProgressIndicator.adaptive(
                    //backgroundColor: Colors.teal,
                  ),
                ),
              ),
            ),
          ),
    );

    try {
      final results = await Future.wait([
        model.loadStatusFiles(),
        Future.delayed(const Duration(seconds: 1, milliseconds: 500)),
      ]);
      final error =
          results[0] as String?; //final error = await model.loadStatusFiles();

      if (context.mounted) {
        Navigator.of(context).pop();
        if (error != null) {
          showDialog(
            context: context,
            builder:
                (dialogContext) => AlertDialog(
                  title: Text(
                    error.contains("directory")
                        ? "Directory Not Found"
                        : "Permission Denied",
                  ),
                  content: Text(error),
                  actions: [
                    TextButton(
                      child: Text("OK"),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
          );
        } else {
          //print("Refresh Completed Successfully");
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        showDialog(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: const Text("Error"),
                content: Text("Refresh failed: $e"),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
        );
      } //print("Refresh error: $e");
    }
  }

  ///pickitup is a Future void function that saves the image/video the user selected and copy it from its whereabout to an album with the name of WA picker and show a snackbar for the user veryfing if the process was completed.
  Future<void> pickitup(BuildContext context, File file) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    const String foldername = "WA Status Picker";

    try {
      //Download Image
      bool? picked;
      final extentionpath = file.path.split('/').last.toLowerCase();
      final extention = extentionpath.split('.').last;
      if (['jpg', 'jpeg', 'png'].contains(extention)) {
        picked = await GallerySaver.saveImage(file.path, albumName: foldername);
      } else if (['mp4', '3gp', 'mkv'].contains(extention)) {
        picked = await GallerySaver.saveVideo(file.path, albumName: foldername);
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              "Your media was unpickable\nfile format unsupported:$extention",
            ),
          ),
        );
        return;
      }

      if (picked == true) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Your media was picked successfully")),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Your media was too heavy to get picked")),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
