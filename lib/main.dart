//Status_view
import 'dart:io';
import 'package:flutter/material.dart';
import 'status_model.dart';
import 'status_controller.dart';
import 'package:video_player/video_player.dart';


///Main function where we initialize the flutter binding, and the model of our code while awaiting the files using the loadStatusFiles function and running our app while referecing our model to the main class.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final model = StatusModel();
  await model.loadStatusFiles();
  runApp(StatusPickerApp(model: model));
}

///StatusPickerApp class is an stateless widget that takes the model (StatusModel) and using widget build, it builds the main screen with all what is shown to the user.
class StatusPickerApp extends StatelessWidget {
  final StatusModel model;
  const StatusPickerApp({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final controller = StatusController(model);

    ///assigning the controller of the model we have.
    return ValueListenableBuilder<bool>(
      ///Building the widget tree using the ValueListenableBuilder boolean type, which uses the ValueNotifier boolean type to be the valueListenable
      valueListenable: isDarkmode,
      builder: (context, darkMode, child) {
        return MaterialApp(
          ///using Material app with theme attributes to have the essential function of the dark mode.
          debugShowCheckedModeBanner: false,
          theme: wasptheme(),
          darkTheme: wasptheme(),
          themeMode: ThemeMode.system,
          themeAnimationDuration: Durations.short1,
          home: DefaultTabController(
            ///And using here the DefaultTabController to make two seperate tabs one for pictures and the second for videos.
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                bottom: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.photo_library)),
                    Tab(icon: Icon(Icons.video_collection)),
                  ],
                ),
                title: Text(
                  "WA Status Picker",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                actions: [
                  IconButton(
                    icon: dlicon(),
                    onPressed: () => controller.toggleTheme(),
                  ),
                  Builder(
                    builder:
                        (context) => IconButton(
                          icon: Icon(Icons.refresh_rounded),
                          onPressed: () => controller.refresh(context),
                        ),
                  ),
                ],
              ),
              body: TabBarView(
                ///Making the actual tabs child by putting PictureSP and VideoSP passing to them ValueNotifier depending on the type of the media, and passing the model and controller.
                children: [
                  PictureSP(imageFiles: imageFiles, controller: controller),
                  VideoSP(
                    videoFiles: videoFiles,
                    model: model,
                    controller: controller,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

///PictureSp is a stateful widget class that we pass to it a ValueNotifier of Type List of Files, and the controller of the App, and then creating the state of it.
class PictureSP extends StatefulWidget {
  final ValueNotifier<List<File>> imageFiles;
  final StatusController controller;

  const PictureSP({
    super.key,
    required this.imageFiles,
    required this.controller,
  });

  @override
  State<PictureSP> createState() => PictureSPState();
}

///PictureSPState is the class of the State of PictureSP while using AutomaticKeepAliveClientMixin to keep the user place in the scroll in that Tab.
class PictureSPState extends State<PictureSP>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder<List<File>>(
      valueListenable: widget.imageFiles,
      builder: (context, images, child) {
        if (images.isEmpty) {
          ///Safety fallback if there was no pictures to show
          return Center(child: Text("No Pictures Found"));
        }
        return GridView.builder(
          ///Using GridView builder to display the pictures using the card widget and using as a grid delegate the SliverGridDelegateWithFixedCrossAxisCount, while setting the items count by how many picture we have.
          padding: EdgeInsets.all(2),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: images.length,
          //itemCount: imageFiles.length,
          itemBuilder: (context, index) {
            /// returning in each grid index an card with a stack as its child which we have in it the image itself as an image file that we get from the images List with a Boxfit fill and a GestureDetector that on tap it open a dialog that show the image in more detail, and in the right bottom an icon button that triger the download mechanism.
            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(
                  children: [
                    GestureDetector(
                      child: Center(
                        child: Image.file(
                          images[index], //imageFiles[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => dispPic(images, index),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(Icons.downloading_rounded),
                        onPressed: () async {
                          await widget.controller.pickitup(
                            context,
                            images[index],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  ///dispPic is an Alert Dialog that we use to display the picture in a bigger frame for the user to view more details of the picture he tapped on, while keeping the download button for easier access for the user to download the picture.
  AlertDialog dispPic(images, index) {
    //print('you tried to open a pic');
    return AlertDialog(
      //alignment: Alignment.center,
      titlePadding: EdgeInsets.only(left: 5, right: 5, bottom: 0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Do you want to pick it up?", style: TextStyle(fontSize: 22)),
          IconButton(
            icon: Icon(Icons.downloading_rounded),
            onPressed: () async {
              await widget.controller.pickitup(context, images[index]);
            },
          ),
        ],
      ),
      elevation: 2,
      content: Padding(
        padding: EdgeInsets.only(right: 5, left: 5, bottom: 5, top: 0),
        child: Image.file(images[index], fit: BoxFit.contain),
      ),
    );
  }
}

///VideoSP is a stateful widget class that requires ValueNotifier of List of Files type, the model of StatusModel, and its controller and ends by creating a state for it.
class VideoSP extends StatefulWidget {
  final ValueNotifier<List<File>> videoFiles;
  final StatusModel model;
  final StatusController controller;

  const VideoSP({
    super.key,
    required this.videoFiles,
    required this.model,
    required this.controller,
  });

  @override
  State<VideoSP> createState() => VideoSPState();
}

///VideoSPState is the state of VideoSP while using AutomaticKeepAliveClientMixin to keep the user place in the scroll in that Tab.
class VideoSPState extends State<VideoSP> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder<List<File>>(
      valueListenable: widget.videoFiles,
      builder: (context, videos, child) {
        return GridView.builder(
          ///Using GridView builder to display the videos using the card widget and using as a grid delegate the SliverGridDelegateWithFixedCrossAxisCount, while setting the items count by how many videos we have.
          padding: EdgeInsets.all(2),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: videos.length, //itemCount: videoFiles.length,
          itemBuilder: (context, index) {
            /// returning in each grid index an card with a stack as its child which we have in it the image itself as an image file that we get from the images List with a Boxfit fill and a GestureDetector that on tap it open a dialog that show the image in more detail, and in the right bottom an icon button that triger the download mechanism.
            return Card(
              ///returning Card widget with its child being a FutureBuilder that return the generateAndCleanThumbnail function depending on the video index.
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: FutureBuilder<String?>(
                  future: widget.model.generateAndCleanThumbnail(
                    videos[index].path,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      // Safety Fallback if thumbnail failed to load
                      //print("Thumbnail error: ${snapshot.error}");
                      return //const Center(child: Text("Error loading thumbnail"));
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.video_file,
                            //size: 50,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            videos[index].path.split('/').last,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    }
                    if (snapshot.hasData) {
                      ///if the videos list had data, it return the card with a child of a stack that composite of the video thumbnail, a download button, and a Gesture Detector that when tapped on, enlarge the video for the user to see.
                      return Stack(
                        children: [
                          Center(
                            child: Image.file(
                              File(snapshot.data!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Center(
                            child: GestureDetector(
                              child: Icon(
                                Icons.play_circle,
                                color: Colors.white,
                              ),
                              onTap:
                                  () => showDialog(
                                    context: context,
                                    builder:
                                        (dialogContext) => DispVid(
                                          vidfile: videos[index],
                                          controller: widget.controller,
                                        ),
                                  ),
                            ),
                            //Icon(Icons.play_circle, color: Colors.white),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(Icons.downloading_rounded),
                              onPressed: () async {
                                await widget.controller.pickitup(
                                  context,
                                  videos[index],
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

///DispVid is a Stateful widget that requires video file and controller and create a State.
class DispVid extends StatefulWidget {
  final File vidfile;
  final StatusController controller;

  const DispVid({super.key, required this.vidfile, required this.controller});

  @override
  State<DispVid> createState() => VideoDialog();
}

///VideoDialog is a State of DispVid that use VideoPlayerController and an boolean to make the video player in which the video tapped on by the user will be playing.
class VideoDialog extends State<DispVid> {
  late VideoPlayerController vid;
  bool awake = false;

  @override
  ///initState initialise the video player by the video file selected by the user.
  void initState() {
    super.initState();
    vid = VideoPlayerController.file(widget.vidfile)
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                awake = true;
              });
              vid.setLooping(true);
            }
          })
          .catchError((error) {
            //print("video awakening error: $error");
          });
  }

  @override
  ///Disposes of the video player.
  void dispose() {
    vid.dispose();
    super.dispose();
  }

  @override
  ///Here we return an Alert Dialog with the video player, and the download button for easy user access.
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.only(left: 5, right: 5, bottom: 0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Do you want to pick it up?",
            style: TextStyle(fontSize: 22),
          ),
          IconButton(
            icon: const Icon(Icons.downloading_rounded),
            onPressed: () async {
              await widget.controller.pickitup(context, widget.vidfile);
            },
          ),
        ],
      ),
      elevation: 2,
      content: Padding(
        padding: const EdgeInsets.only(right: 5, left: 5, bottom: 5, top: 0),
        child:
            awake
                ? AspectRatio(
                  aspectRatio: vid.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(vid),
                      IconButton(
                        icon: Icon(
                          vid.value.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          color: Colors.white,
                          size: 50,
                        ),
                        onPressed: () {
                          setState(() {
                            if (vid.value.isPlaying) {
                              vid.pause();
                            } else {
                              vid.play();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                )
                : const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
      ),
      actions: [
        TextButton(
          child: const Text("Close"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

///dlicon is a widget function that return a sun icon if the mode is dark and a moon icon if the mode was light.
Widget dlicon() {
  if (isDarkmode.value) {
    return Icon(Icons.light_mode_rounded);
  } else {
    return Icon(Icons.dark_mode_rounded);
  }
}

///darky is a Thememode function that return dark thememode if the dark mode is on and return light thememode otherwise.
ThemeMode darky() {
  if (isDarkmode.value) {
    return ThemeMode.dark;
  } else {
    return ThemeMode.light;
  }
}

///wasptheme is responsible for returning themedata for the thememode depending on the active mode.
ThemeData wasptheme() {
  if (isDarkmode.value) {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blueGrey,
      scaffoldBackgroundColor: const Color.fromARGB(255, 10, 15, 10),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.teal[900],
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(color: Colors.grey[850], elevation: 2),
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      iconTheme: const IconThemeData(color: Colors.greenAccent),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.tealAccent,
        indicatorColor: Colors.tealAccent,
      ),
    );
  } else {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.teal,
      scaffoldBackgroundColor: const Color.fromARGB(255, 240, 255, 225),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      cardTheme: const CardTheme(color: Colors.white, elevation: 2),
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
      iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 60, 15)),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.greenAccent,
        indicatorColor: Colors.greenAccent,
      ),
    );
  }
}
