// ignore_for_file: avoid_print

import 'dart:async';
// import 'dart:html';
import 'package:http/http.dart' as http;
import 'dart:io' show File, Platform;
// import 'dart:typed_data';
import 'package:exapp/groupmain.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:exapp/generate_qr_code.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'firebase_options.dart';
import 'package:firebase_cached_image/firebase_cached_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseDynamicLinks.instance.getInitialLink().then((data) {
    if (data != null) {
      handleDynamicLink(data);
    } else {
      runApp(
        const MaterialApp(
          title: 'Guide App',
          home: MyHomePage(
            audioPath: '/audio/audio2.mp3',
            imagePath: [
              'gs://museum-guide-app.appspot.com/pictures/picture2.jpg',
              'gs://museum-guide-app.appspot.com/pictures/picture3.png',
              'gs://museum-guide-app.appspot.com/pictures/picture1.jpg',
              'gs://museum-guide-app.appspot.com/pictures/picture3.png',
            ],
            grouphost: true,
            roomId: "Default Room",
            svGuide:
                "Välkommen till Gamla Linköping, en unik historisk stadsdel som tar dig tillbaka i tiden!, Skanna QR koder eller använd dig av platstjänster för att starta en specifik guide, glöm inte att stänga av appen innan du skannar",
            enGuide:
                "Welcome to Gamla Linköping, a unique historic district that takes you back in time! Scan QR codes or use location services to start a specific guide. Remember to close the app before scanning.",
          ),
        ),
      );
    }
  });

  FirebaseDynamicLinks.instance.onLink.listen((data) async {
    if (data != null) {
      handleDynamicLink(data);
    }
  });
}

//Dynamic linking
void handleDynamicLink(PendingDynamicLinkData data) {
  final Uri? uri = data.link;
  if (uri != null && uri.pathSegments.contains('guide')) {
    // Construct paths to audio and picture files in Firebase Storage
    const String audioPath = '/audio/audio2.mp3';

    const bool grouphost = true;

    final database = FirebaseDatabase.instance.ref();
    final roomId = database.child('rooms').push().key;

    // Create a new node for the room with the generated ID
    database.child('rooms/$roomId').set({});

    //ID of the newly created room

    const List<String> imagePath = [
      'gs://museum-guide-app.appspot.com/pictures/picture2.jpg',
      'gs://museum-guide-app.appspot.com/pictures/picture1.jpg',
    ];

    runApp(
      const MaterialApp(
        home: MyHomePage(
          audioPath: '/audio/audio2.mp3',
          imagePath: [
            'gs://museum-guide-app.appspot.com/pictures/picture4.jpg',
            'gs://museum-guide-app.appspot.com/pictures/picture3.png',
          ],
          grouphost: grouphost,
          roomId: "guide3",
          svGuide: "Thi",
          enGuide: "aah",
        ),
      ),
    );
  }
  // Guide för tåget.
  else if (uri != null && uri.pathSegments.contains('guide2')) {
// Extract link parameters

    // Construct paths to audio and picture files in Firebase Storage
    const String audioPath = '/audio/audio2.mp3';

    const bool grouphost = true;

    final database = FirebaseDatabase.instance.ref();

    const roomId = "guide3";
    // Create a new node for the room with the generated ID
    database.child('rooms/$roomId').set({
      'enPlay': 'false',
      'svPlay': 'false',
    });

    //ID of the newly created room

    const List<String> imagePath = [
      'gs://museum-guide-app.appspot.com/pictures/picture2.jpg',
      'gs://museum-guide-app.appspot.com/pictures/picture1.jpg',
    ];

    runApp(
      const MaterialApp(
        home: MyHomePage(
          audioPath: '/audio/audio2.mp3',
          imagePath: [
            'gs://museum-guide-app.appspot.com/pictures/Train/train.png',
            'gs://museum-guide-app.appspot.com/pictures/Train/trainhead.jpg',
            'gs://museum-guide-app.appspot.com/pictures/Train/trainmotor.jpg',
            'gs://museum-guide-app.appspot.com/pictures/Train/trainback.jpg',
          ],
          grouphost: grouphost,
          roomId: "guide3",
          svGuide:
              "Välkommen till Gamla Linköping, en unik historisk stadsdel som tar dig tillbaka i tiden! I denna guide kommer vi att använda bilder för att guida dig genom det röda tåget och dess olika delar. Helheten av det röda tåget, Första bilden ger en överblick av det röda tåget. Tåget är klätt i den klassiska röda färgen som ger det sin karaktär. Låt blicken svepa över hela tåget och beundra dess historiska charm och eleganta design. Utsikten från förarsätet, I den här bilden får du uppleva utsikten från förarsätet. Föreställ dig själv som föraren och ta del av den vy som mötte dem när de körde tåget. Följ rälsen med blicken och föreställ dig resan genom landskapet, precis som det gjordes under tågets aktiva tid. Låt fantasin ta dig tillbaka till en svunnen era av järnvägsresor. Motorhuven, Den tredje bilden är en närbild på tågets motorhuv. Låt blicken vandra över detaljerna och beundra den tekniska skicklighet som krävdes för att hålla tåget i gång. Tänk på de människor som ansvarade för underhållet och bevara historien om ånga och mekanik som en del av vardagen på järnvägen. Bagageutrymmet,Den fjärde bilden visar bagageutrymmet på tåget. Observera utformningen och tänk på de resenärer som använde detta utrymme för att förvara sina väskor och ägodelar under resan. Låt tankarna vandra till en tid då tåget var en populär och spännande transportmetod.",
          enGuide:
              "Welcome to Gamla Linköping, a unique historical district that takes you back in time! In this guide, we will use pictures to guide you through the red train and its various parts. The entirety of the red train. The first picture provides an overview of the red train. The train is adorned with the classic red color that gives it its character. Let your gaze sweep over the entire train and admire its historical charm and elegant design. The view from the driver's seat, In this picture, you will experience the view from the driver's seat. Imagine yourself as the train driver and take in the view that greeted them during the train's active days. Follow the tracks with your eyes and envision the journey through the landscape, just as it was done in the train's heyday. Let your imagination take you back to a bygone era of railway travel. The engine hood. The third picture is a close-up of the train's engine hood. Let your gaze wander over the details and admire the technical skill required to keep the train running. Think about the people who were responsible for its maintenance and preserving the history of steam and mechanics as part of everyday life on the railway. The luggage compartment, The fourth picture shows the train's luggage compartment. Take note of its design and think about the travelers who used this space to store their bags and belongings during the journey. Let your thoughts wander to a time when the train was a popular and exciting mode of transportation.",
        ),
      ),
    );
  } else if (uri != null && uri.pathSegments.contains('guide3')) {
    // Extract link parameters
    // Construct paths to audio and picture files in Firebase Storage
    const String audioPath = '/audio/audio2.mp3';

    const bool grouphost = false;

    final database = FirebaseDatabase.instance.ref();

    // final roomId = const Uuid().v4().replaceAll('-', '');

    // // Create a new node for the room with the generated ID
    // database.child('rooms/$roomId').set({
    //   'play': 'false',
    // });

    //ID of the newly created room

    const List<String> imagePath = [
      'gs://museum-guide-app.appspot.com/pictures/picture2.jpg',
      'gs://museum-guide-app.appspot.com/pictures/picture1.jpg',
    ];

    runApp(
      const MaterialApp(
        home: MyHomePage(
          audioPath: '/audio/audio2.mp3',
          imagePath: [
            'gs://museum-guide-app.appspot.com/pictures/picture4.jpg',
            'gs://museum-guide-app.appspot.com/pictures/picture3.png',
          ],
          grouphost: grouphost,
          roomId: "guide3",
          enGuide: "Hello",
          svGuide: "Hej",
        ),
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.lime,
//         brightness: Brightness.light, // Set the default brightness
//       ),
//       darkTheme: ThemeData(
//         primarySwatch: Colors.lime,
//         brightness: Brightness.dark, // Set the default brightness
//       ),
//       home: const MyHomePage(
//         audioPath: '/audio/audio1.mp3',
//         imagePath: [
//           'gs://museum-guide-app.appspot.com/pictures/picture1.jpg',
//           'gs://museum-guide-app.appspot.com/pictures/picture3.png'
//         ],
//         grouphost: true,
//         roomId: '',
//       ),
//     );
//   }
// }

// Code for the Whole apps theme
class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.audioPath,
    required this.imagePath,
    required this.grouphost,
    required this.roomId,
    required this.svGuide,
    required this.enGuide,
  }) : super(key: key);
  final String audioPath;
  final List<String> imagePath;
  final bool grouphost;
  final String? roomId;
  final String svGuide;
  final String enGuide;

  // final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isDarkThemeEnabled = false;
  int _currentIndex = 0;
  bool grouphost = false;
  String audio = 'audio track';
  String audioUrl = 'audiofile';
  String enGuide = "English guide";
  String svGuide = "Swedish guide";
  String? roomId = 'test5';
  List<String> image = [];
  List<String> imagePath = [];
  List<Image> images = [];
  List<Image> imageWidgets = [];
//Timings of the pictures, first value is second and other is index
  final List<MapEntry<Duration, int>> imageTimestamps = [
    const MapEntry(Duration(seconds: 0), 0), // show first image at start
    const MapEntry(Duration(seconds: 5), 1), // show second image at 5 seconds
    const MapEntry(Duration(seconds: 60), 2), // show third image at 60 seconds
  ];
  @override
  void initState() {
    super.initState();
    grouphost = widget.grouphost;
    audio = widget.audioPath;
    roomId = widget.roomId;
    svGuide = widget.svGuide;
    enGuide = widget.enGuide;
    imagePath = widget.imagePath;
    for (final url in widget.imagePath) {
      images.add(Image(
        image: FirebaseImageProvider(FirebaseUrl(url)),
      ));
    }
    downloadFile(audio).then((url) {
      setState(() {
        // audioUrl = url;
      });
    });

    for (var image in images) {
      imageWidgets.add(image);
    }
  }

  Future<void> downloadFile(String filePath) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(filePath);
    audioUrl = await ref.getDownloadURL();
    setState(() {});
  }

  //List of all slides/pages
  // final List<Widget> _children = [
  //   const GuideWidget(
  //     audioPath: audio,
  //     imagePath: [
  //       'gs://museum-guide-app.appspot.com/pictures/picture1.jpg',
  //       'gs://museum-guide-app.appspot.com/pictures/picture3.png'
  //     ],
  //     grouphost: true,
  //     roomId: '',
  //   ),
  //   const GeoWidget(),
  //   const GenerateQRCode(),
  //   const QRWidget(),
  //   const TTSWidget(),
  // ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkThemeEnabled = !_isDarkThemeEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      GuideWidget(
        audioPath: audio,
        imagePath: imagePath,
        grouphost: grouphost,
        roomId: roomId,
        enGuide: enGuide,
        svGuide: svGuide,
      ),
      const GeoWidget(),
      GenerateQRCode(
        roomId: roomId,
        //TODO: Fixa så att roomid skickas till generate och skapar en egen qr kod, ska även generera en dynamisk länk.
      ),
      const QRWidget(),
      const TTSWidget(),
    ];
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lime,
        brightness: _isDarkThemeEnabled
            ? Brightness.dark // Set the brightness for dark mode
            : Brightness.light, // Set the brightness for light mode
      ),
      home: Scaffold(
        body: children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.surround_sound),
              label: 'Guide',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.map), label: 'Geolocation'),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Invite Code',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              label: 'QR-Scan',
              // title: Text('Messages'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.volume_up),
              label: 'TTS',
              // title: Text('Profile'),
            )
          ],
        ),
        floatingActionButton: ThemeSwitchButton(
          isDarkThemeEnabled: _isDarkThemeEnabled,
          onThemeSwitch: _toggleTheme,
        ),
      ),
    );
  }
}

//Guide example slide
enum TtsState { playing, stopped, paused, continued }

class GuideWidget extends StatefulWidget {
  const GuideWidget({
    Key? key,
    required this.audioPath,
    required this.imagePath,
    required this.grouphost,
    required this.roomId,
    required this.svGuide,
    required this.enGuide,
  }) : super(key: key);
  final String audioPath;
  final List<String> imagePath;
  final bool grouphost;
  final String? roomId;
  final String svGuide;
  final String enGuide;
  @override
  GuideWidgetState createState() => GuideWidgetState();
}

class GuideWidgetState extends State<GuideWidget> {
  //init database
  final database = FirebaseDatabase.instance.ref();
  //Init storage
  final ref = FirebaseStorage.instance.ref();

  //database reads
  bool isPlaying = false;
  String audio = 'audio track';
  String audioUrl = 'audiofile';

  String? roomId = 'test6';

  final audioPlayer = AudioPlayer();
  bool grouphost = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  List<String> image = [];

  //TTS variables
  final FlutterTts flutterTts = FlutterTts();
  double volume = 1.0;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  String? language;
  // String? _newVoiceText;
  int end = 0;
  int currentPosition = 0;
  bool isCurrentLanguageInstalled = false;
  double progress = 0.0;
  String enGuide = "english guide";
  String svGuide = "svensk guide";

  TtsState ttsState = TtsState.stopped;

//Pictures for the guide
  List<Image> images = [];

  List<Image> imageWidgets = [];
//Timings of the pictures, first value is second and other is index
  final List<MapEntry<double, int>> imageProgress = [
    const MapEntry(0.0, 0), // show first image at start (progress 0.0)
    const MapEntry(0.2, 1), // show second image at 20% progress (0.2)
    const MapEntry(0.6, 2), // show third image at 60% progress (0.6)
    const MapEntry(1.0, 3), // show fourth image at 100% progress (1.0)
  ];

  int currentImageIndex = 0;
  @override
  void initState() {
    super.initState();
    initTts();
    roomId = widget.roomId;
    enGuide = widget.enGuide;
    svGuide = widget.svGuide;
    _activateListeners();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.4);
    flutterTts.setVolume(volume);
    grouphost = widget.grouphost;
    audio = widget.audioPath;

    // image = widget.imagePath;
    for (final url in widget.imagePath) {
      images.add(Image(
        image: FirebaseImageProvider(FirebaseUrl(url)),
      ));
    }
    downloadFile(audio).then((url) {
      setState(() {
        // audioUrl = url;
      });
    });

    for (var image in images) {
      imageWidgets.add(image);
    }

    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.PLAYING;
        });
      }
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onAudioPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
        // Check if the current position is within a range of a timestamp
        // for (int i = 0; i < imageTimestamps.length; i++) {
        //   final timestamp = imageTimestamps[i].key;
        //   final imageIndex = imageTimestamps[i].value;
        //   final nextTimestamp = i + 1 < imageTimestamps.length
        //       ? imageTimestamps[i + 1].key
        //       : duration;

        //   if (position >= timestamp && position < nextTimestamp) {
        //     currentImageIndex = imageIndex;
        //     break;
        //   }
        // }
      });
    });
  }

  void _activateListeners() {
    database.child("rooms/$roomId").onValue.listen((event) {
      final guide1 = database.child('/rooms/$roomId');
      final Object? play = event.snapshot.value;
      if (play != null) {
        print(play.toString());
        if (play.toString() == "{enPlay: true, svPlay: false}") {
          setState(() {
            isPlaying = true;
          });
          // audioPlayer.play(audioUrl);
          _speak(enGuide);
          // guide1.update({'play': 'false'});
        } else if (play.toString() == "{enPlay: false, svPlay: true}") {
          setState(() {
            isPlaying = true;
          });
          // audioPlayer.play(audioUrl);
          _speak(svGuide);
        } else {
          setState(() {
            isPlaying = false;
          });
          audioPlayer.pause();
          pause();
          // guide1.update({'play': 'false'});
        }
      }
    });
  }

//Download audio from firebase storage
  Future<void> downloadFile(String filePath) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(filePath);
    audioUrl = await ref.getDownloadURL();
    setState(() {});
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }

//TTS inits

  void initTts() {
    flutterTts.setCompletionHandler(() {
      setState(() {
        final guide1 = database.child('/rooms/$roomId');
        progress = 0.0; // Reset progress when TTS completes playing
        guide1.update({'enPlay': 'false', 'svPlay': 'false'});
      });
    });

    flutterTts.setProgressHandler(
        (String? text, int startOffset, int endOffset, String? word) {
      setState(() {
        progress =
            endOffset / text!.length; // Calculate progress as a percentage
      });
    });
  }

  startTts(String lang) async {
    // Start your TTS sound here
    final guide1 = database.child('/rooms/$roomId');
    if (lang == "sv") {
      flutterTts.setLanguage("sv-SE");
      guide1.update({'enPlay': 'false', 'svPlay': 'true'});
    } else if (lang == "en") {
      flutterTts.setLanguage("en-US");
      guide1.update({'enPlay': 'true', 'svPlay': 'false'});
    }
    // await flutterTts
    //     .speak('Your text to be spoken xd ha ha ha ha void void lord');
  }

  int getCurrentImageIndex(double progress) {
    // Iterate through the imageProgress list
    for (int i = 0; i < imageProgress.length - 1; i++) {
      final currentEntry = imageProgress[i];
      final nextEntry = imageProgress[i + 1];

      if (progress >= currentEntry.key && progress < nextEntry.key) {
        return currentEntry.value;
      }
    }

    // If progress exceeds the last timestamp, show the last image
    return imageProgress.last.value;
  }

  @override
  Widget build(BuildContext context) {
    final guide1 = database.child('/rooms/$roomId');
    int currentImageIndex = getCurrentImageIndex(progress);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //images

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: imageWidgets[currentImageIndex],
            ),
            const SizedBox(height: 32),
            const Text(
              'Guide Example',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("Room ID: $roomId"),
            LinearProgressIndicator(value: progress),

            // Button to start TTS
            if (grouphost)
              ElevatedButton(
                onPressed: () => startTts("en"),
                child: const Text('Start English guide'),
              ),
            if (grouphost)
              ElevatedButton(
                onPressed: () => startTts("sv"),
                child: const Text('Start Swedish guide'),
              ),
            if (grouphost)
              ElevatedButton(
                onPressed: () {
                  pause();
                  guide1.update({'enPlay': 'false', 'svPlay': 'false'});
                },
                child: const Icon(Icons.pause),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Volume: "),
                SizedBox(
                  width: 200,
                  child: Slider(
                    value: volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      setState(() {
                        volume = value;
                        flutterTts.setVolume(volume);
                      });
                    },
                  ),
                ),
              ],
            ),

            //  Slider(
            //    min: 0,
            //    max: duration.inSeconds.toDouble(),
            //  value: position.inSeconds.toDouble(),
            //    onChanged: (value) async {
            //      final position = Duration(seconds: value.toInt());
            //      await audioPlayer.seek(position);
            //      // await audioPlayer.pause();
            //    },
            //  ),
            //  //Playback time
            //  Padding(
            //    padding: const EdgeInsets.symmetric(horizontal: 16),
            //    child: Row(
            //      mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //     Text(formatTime(position)),
            //        Text(formatTime(duration - position)),
            //      ],
            //    ),
            //  ),
            // if (grouphost)
            //   ElevatedButton(
            //     onPressed: () {
            //       // _speak("Text from the application");
            //       guide1.update({'play': 'true'});
            //     },
            //     child: const Icon(Icons.play_arrow),
            //   ),

            // CircleAvatar(
            //   radius: 35,
            //   child: IconButton(
            //     icon: Icon(
            //       isPlaying ? Icons.pause : Icons.play_arrow,
            //     ),
            //     iconSize: 50,
            //     onPressed: () async {
            //       if (isPlaying) {
            //         // await audioPlayer.pause();
            //         await guide1.update({'play': 'false'});
            //         pause();
            //       } else {
            //         // downloadFile(audio);
            //         await guide1.update({'play': 'true'});
            //         // await audioPlayer.play(audioUrl);
            //         _speak(
            //             "This is an example guide text for the default room, scan the QR code for specific guides");
            //       }
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language!);
      if (isAndroid) {
        flutterTts
            .isLanguageInstalled(language!)
            .then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.setVolume(volume);
    await flutterTts.speak(text);
  }

  Future<void> pause() async {
    await flutterTts.pause();
  }
}

//Geolocation slide

class GeoWidget extends StatefulWidget {
  const GeoWidget({Key? key}) : super(key: key);

  @override
  GeoWidgetState createState() => GeoWidgetState();
}

class GeoWidgetState extends State<GeoWidget> {
  Position? _currentPosition;

  void _getCurrentLocation() async {
    final permissionStatus = await Permission.locationWhenInUse.request();
    if (permissionStatus.isGranted) {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
      _checkZone();
    } else {
      print('Permission denied');
    }
  }

  void _checkZone() {
    print("In the ZONE3");
    // Define the zones and their coordinates
    //Torget
    final zone1 = <LatLng>[
      const LatLng(58.406544, 15.590581),
      const LatLng(58.406198, 15.588713),
      const LatLng(58.405389, 15.589336),
      const LatLng(58.405626, 15.590986),
    ];
    //Ryttartorp
    final zone2 = <LatLng>[
      const LatLng(58.403553, 15.586971),
      const LatLng(58.403801, 15.589500),
      const LatLng(58.402533, 15.589992),
      const LatLng(58.402223, 15.587089),
    ];
    //Gamla linköping tåg
    final zone3 = <LatLng>[
      const LatLng(58.405038, 15.587285),
      const LatLng(58.405715, 15.589811),
      const LatLng(58.404394, 15.591222),
      const LatLng(58.403976, 15.588211),
    ];

    //cloetta
    final zone4 = <LatLng>[
      const LatLng(58.406494, 15.586535),
      const LatLng(58.407059, 15.588241),
      const LatLng(58.406336, 15.589264),
      const LatLng(58.405592, 15.587458),
    ];

    // Check if the user is inside a zone and launch the guide if they are
    if (_currentPosition != null) {
      final isInZone1 = _isInPolygon(
          _currentPosition!.latitude, _currentPosition!.longitude, zone1);
      final isInZone2 = _isInPolygon(
          _currentPosition!.latitude, _currentPosition!.longitude, zone2);
      final isInZone3 = _isInPolygon(
          _currentPosition!.latitude, _currentPosition!.longitude, zone3);
      final isInZone4 = _isInPolygon(
          _currentPosition!.latitude, _currentPosition!.longitude, zone4);
      print("zone 1: $zone1, zone 2: $zone2");
      if (isInZone1) {
        print("In the ZONE");
        _runGuide(1);
      } else if (isInZone2) {
        print("In the ZONE2");
        _runGuide(2);
      } else if (isInZone3) {
        print('IN THE ZONE 3');
        _runGuide(3);
      } else if (isInZone4) {
        print('IN THE ZONE 4');
        _runGuide(4);
      }
    }
  }

  bool _isInPolygon(double lat, double lng, List<LatLng> polygon) {
    bool c = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; i++) {
      if ((polygon[i].longitude > lng) != (polygon[j].longitude > lng) &&
          (lat <
              (polygon[j].latitude - polygon[i].latitude) *
                      (lng - polygon[i].longitude) /
                      (polygon[j].longitude - polygon[i].longitude) +
                  polygon[i].latitude)) {
        c = !c;
      }
      j = i;
    }
    return c;
  }

  void _runGuide(int zone) {
    // Construct paths to audio and picture files in Firebase Storage
    print('Inside zone 3');
    //Torp
    if (zone == 1) {
      const String audioPath = '/audio/audio2.mp3';
      const List<String> imagePath = [
        'gs://museum-guide-app.appspot.com/pictures/torg.jpg',
        'gs://museum-guide-app.appspot.com/pictures/torp.jpg',
      ];
      const bool grouphost = true;

      runApp(const MaterialApp(
        home: GuideWidget(
          audioPath: audioPath,
          imagePath: imagePath,
          grouphost: grouphost,
          roomId: '',
          enGuide: "Sample text that will function as the text for TTS",
          svGuide: "Exempeltext som skall användas till TTS",
        ),
      ));
    } else if (zone == 2) {
      const String audioPath = '/audio/audio2.mp3';
      const List<String> imagePath = [
        'gs://museum-guide-app.appspot.com/pictures/picture2.png',
        'gs://museum-guide-app.appspot.com/pictures/torp.jpg',
      ];
      const bool grouphost = true;

      runApp(const MaterialApp(
        home: GuideWidget(
          audioPath: audioPath,
          imagePath: imagePath,
          grouphost: grouphost,
          roomId: '',
          enGuide: "Sample text that will function as the text for TTS",
          svGuide: "Exempeltext som skall användas till TTS",
        ),
      ));
    } else if (zone == 3) {
      const String audioPath = '/audio/audio2.mp3';
      const List<String> imagePath = [
        'gs://museum-guide-app.appspot.com/pictures/picture3.png',
        'gs://museum-guide-app.appspot.com/pictures/picture3.png',
      ];
      const bool grouphost = true;

      runApp(const MaterialApp(
        home: GuideWidget(
          audioPath: audioPath,
          imagePath: imagePath,
          grouphost: grouphost,
          roomId: '',
          enGuide: "Sample text that will function as the text for TTS",
          svGuide: "Exempeltext som skall användas till TTS",
        ),
      ));
    } else if (zone == 4) {
      const String audioPath = '/audio/audio2.mp3';
      const List<String> imagePath = [
        'gs://museum-guide-app.appspot.com/pictures/picture4.jpg',
        'gs://museum-guide-app.appspot.com/pictures/picture4.jpg',
      ];
      const bool grouphost = true;

      runApp(const MaterialApp(
        home: GuideWidget(
          audioPath: audioPath,
          imagePath: imagePath,
          grouphost: grouphost,
          roomId: '',
          enGuide: "Sample text that will function as the text for TTS",
          svGuide: "Exempeltext som skall användas till TTS",
        ),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _checkZone();
    //Geolocation call

    // _runGuide();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const CircularProgressIndicator();
    } else {
      _checkZone();
      return Text(
          "Latitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}");
    }
  }
}

//Generate invite slide

class GenerateQRCode extends StatefulWidget {
  const GenerateQRCode({
    Key? key,
    required this.roomId,
  }) : super(key: key);
  final String? roomId;

  @override
  GenerateQRCodeState createState() => GenerateQRCodeState();
}

class GenerateQRCodeState extends State<GenerateQRCode> {
  final database = FirebaseDatabase.instance.ref();
  String? roomId = '';
  bool invite = false;

  Future<String?> createRoom() async {
    // Generate a new ID for the room
    final roomId = database.child('rooms').push().key;

    // Create a new node for the room with the generated ID
    await database.child('rooms/$roomId').set({
      'play': 'false',
    });

    // Return the ID of the newly created room
    return roomId;
  }

  Future<Uri> createDynamicLink(String roomId) async {
    // Create a new DynamicLinkParameters object
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(
          "https://groupguideapp.page.link/guide2/room?roomId=$roomId"),
      uriPrefix: "https://groupguideapp.page.link",
      androidParameters:
          const AndroidParameters(packageName: "com.example.app.android"),
      iosParameters: const IOSParameters(bundleId: "com.example.app.ios"),
    );
    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParams);
    return dynamicLink;
  }

  Future<void> _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void enableQRCode() {
    setState(() {
      invite = true;
    });
  }

  @override
  void initState() {
    super.initState();
    // createRoom().then((roomId) {
    //   setState(() {
    roomId = widget.roomId;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR Code'),
      ),
      body: Center(
        child: roomId == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20.0),
                  if (invite == false)
                    ElevatedButton(
                      onPressed: () async {
                        enableQRCode();
                        // createRoom();
                        // final dynamicLink = await createDynamicLink(roomId!);
                        // await _launchURL(dynamicLink);
                      },
                      child: const Text('Create invite code'),
                    ),
                  if (invite)
                    QrImage(
                      data: 'https://groupguideapp.page.link/$roomId',
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  if (invite) const Text('Invite QR code created!'),
                ],
              ),
      ),
    );
  }
}
//QR scanner slide

class QRWidget extends StatefulWidget {
  const QRWidget({Key? key}) : super(key: key);

  @override
  QRWidgetState createState() => QRWidgetState();
}

class QRWidgetState extends State<QRWidget> {
  bool isTorchOn = false;
  late MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  void _toggleTorch(bool value) {
    setState(() {
      isTorchOn = value;
    });
    _scannerController.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Scanner'),
        actions: [
          Row(
            children: [
              //Flashlight option
              Switch(
                value: isTorchOn,
                onChanged: _toggleTorch,
                activeColor: Colors
                    .white, // set the color of the switch when it is turned on
              ),
              Align(
                alignment: Alignment
                    .centerLeft, // adjust the position of the flashlight icon
                child: Icon(
                  Icons.flashlight_on, // use the flashlight icon
                  color: isTorchOn
                      ? Colors.white
                      : Colors
                          .grey, // set the color of the icon based on the value of isTorchOn
                ),
              ),
            ],
          ),
        ],
      ),
      body: MobileScanner(
        controller: _scannerController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          //Returned QR-code
          for (final barcode in barcodes) {
            debugPrint('Barcode found! ${barcode.rawValue}');
          }
        },
      ),
    );
  }
}

//Text to speech slide
// enum TtsState { playing, stopped, paused, continued }

class TTSWidget extends StatefulWidget {
  const TTSWidget({Key? key}) : super(key: key);

  @override
  TTSWidgetState createState() => TTSWidgetState();
}

class TTSWidgetState extends State<TTSWidget> {
  //init database
  final database = FirebaseDatabase.instance.ref();
  //database reads
  String displayText = 'Results go here';

  final FlutterTts flutterTts = FlutterTts();
  TextEditingController textController = TextEditingController();
  double volume = 1.0;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  String? language;
  // String? _newVoiceText;
  int end = 0;
  int currentPosition = 0;
  bool isCurrentLanguageInstalled = false;

  TtsState ttsState = TtsState.stopped;

  @override
  void initState() {
    super.initState();
    _activateListeners();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.5);
    flutterTts.setVolume(volume);
  }

  void _activateListeners() {
    database.child('test/description').onValue.listen((event) {
      final Object? description = event.snapshot.value;
      setState(() {
        displayText = 'Today\'s special: $description';
      });
    });
  }

  // Define a function to create a new "room" node with a randomly generated ID
  Future<String?> createRoom() async {
    // Generate a new ID for the room
    final roomId = database.child('rooms').push().key;

    // Create a new node for the room with the generated ID
    await database.child('rooms/$roomId').set({});

    // Return the ID of the newly created room
    return roomId;
  }

  initTts() {
    flutterTts.setCompletionHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setProgressHandler(
        (String text, int startOffset, int endOffset, String word) {
      setState(() {
        currentPosition = endOffset;
      });
    });
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;
  @override
  Widget build(BuildContext context) {
    final dailySpecialRef = database.child('/test');
    final guideset = database.child('/testguide');
    final audiofile = database.child('/audioTracks');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Text to speech"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Writes to database
          ElevatedButton(
            onPressed: () async {
              try {
                await dailySpecialRef.set({
                  'description': 'Latte',
                  'price': 4.99,
                });
                print("Special written");
              } catch (e) {
                print("Error!! $e");
              }
            },
            child: const Text('Simple set'),
          ),

          //Read from database
          Text(displayText),
          //Field to write in
          TextField(
            controller: textController,
          ),
          //Button to speak the inputed content
          ElevatedButton(
            onPressed: () {
              _speak(textController.text);
            },
            child: const Text("Speak"),
          ),
          ElevatedButton(
            onPressed: () {
              pause();
            },
            child: const Icon(Icons.pause),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Volume: "),
              SizedBox(
                width: 200,
                child: Slider(
                  value: volume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    setState(() {
                      volume = value;
                      flutterTts.setVolume(volume);
                    });
                  },
                ),
              ),
            ],
          ),
          _languageslider(),
        ],
      ),
    );
  }

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language!);
      if (isAndroid) {
        flutterTts
            .isLanguageInstalled(language!)
            .then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  Widget _languageslider() => FutureBuilder<dynamic>(
      future: _getLanguages(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _languageDropDownSection(snapshot.data);
        } else if (snapshot.hasError) {
          return const Text('Error loading languages...');
        } else {
          return const Text('Loading Languages...');
        }
      });

  Widget _languageDropDownSection(dynamic languages) => Container(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton(
          value: language,
          items: getLanguageDropDownMenuItems(languages),
          onChanged: changedLanguageDropDownItem,
        ),
        Visibility(
          visible: isAndroid,
          child: Text("Is installed: $isCurrentLanguageInstalled"),
        ),
      ]));

  Future<void> _speak(String text) async {
    await flutterTts.setVolume(volume);
    await flutterTts.speak(text);
  }

  Future<void> pause() async {
    await flutterTts.pause();
  }
}

// Theme switch button
class ThemeSwitchButton extends StatelessWidget {
  const ThemeSwitchButton({
    Key? key,
    required this.isDarkThemeEnabled,
    required this.onThemeSwitch,
  }) : super(key: key);

  final bool isDarkThemeEnabled;
  final VoidCallback onThemeSwitch;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onThemeSwitch,
      tooltip: 'Switch Theme',
      child: Icon(
        isDarkThemeEnabled ? Icons.brightness_7 : Icons.brightness_4,
      ),
    );
  }
}
