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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MaterialApp(
      title: 'Guide App',
      home: MyApp(),
    ),
  );
  await FirebaseDynamicLinks.instance.getInitialLink().then((data) {
    if (data != null) {
      handleDynamicLink(data);
    }
  });

  FirebaseDynamicLinks.instance.onLink.listen((data) async {
    if (data != null) {
      handleDynamicLink(data);
    }
  });
}

void handleDynamicLink(PendingDynamicLinkData data) {
  final Uri? uri = data.link;
  if (uri != null && uri.pathSegments.contains('guide')) {
    // Extract link parameters
    final String? painting = uri.queryParameters['painting'];
    final String? audio = uri.queryParameters['audio'];

    // Construct paths to audio and picture files in Firebase Storage
    const String audioPath = '/audio/audio2.mp3';
    final String picturePath = 'paintings/$painting/pictures/1.jpg';

    runApp(const MaterialApp(
      home: GuideWidget(audioPath: audioPath),
    ));
  }
  if (uri != null && uri.pathSegments.contains('guide2')) {
    // Extract link parameters
    final String? painting = uri.queryParameters['painting'];
    final String? audio = uri.queryParameters['audio'];

    // Construct paths to audio and picture files in Firebase Storage
    const String audioPath = '/audio/audio1.mp3';
    final String picturePath = 'paintings/$painting/pictures/1.jpg';

    runApp(const MaterialApp(
      home: GuideWidget(audioPath: audioPath),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lime,
        brightness: Brightness.light, // Set the default brightness
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.lime,
        brightness: Brightness.dark, // Set the default brightness
      ),
      home: const MyHomePage(title: 'Museum Guide App'),
      onGenerateRoute: (RouteSettings settings) {
        // // Parse the deep link and extract the unique identifier
        // final uri = Uri.parse(settings.name!);
        // final routeId = uri.pathSegments.first;
        // print('onGenerateRoute called');
        // return MaterialPageRoute(builder: (context) => const GuideWidget());
        // // Use the routeId to navigate to the corresponding widget
        // final Widget widget = _routes[routeId]!;
        // return MaterialPageRoute(builder: (_) => widget);
      },
    );
  }
}

// Code for the Whole apps theme
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isDarkThemeEnabled = false;
  int _currentIndex = 0;

//List of all slides/pages
  final List<Widget> _children = [
    const GuideWidget(
      audioPath: '',
    ),
    const GeoWidget(),
    const GenerateQRCode(),
    const QRWidget(),
    const TTSWidget(),
  ];
  final Map<String, Widget> _routes = {
    'generateQRCode': const GenerateQRCode(),
    'geoWidget': const GeoWidget(),
    'guide': const GuideWidget(
      audioPath: '',
    ),
    'qrWidget': const QRWidget(),
    'ttsWidget': const TTSWidget(),
  };

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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lime,
        brightness: _isDarkThemeEnabled
            ? Brightness.dark // Set the brightness for dark mode
            : Brightness.light, // Set the brightness for light mode
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            //TODO: implement the settings page if needed
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
        body: _children[_currentIndex],
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
      onGenerateRoute: (RouteSettings settings) {
        // Parse the deep link and extract the unique identifier
        final uri = Uri.parse(settings.name!);
        final routeId = uri.pathSegments.first;
        print('onGenerateRoute called');

        // Use the routeId to navigate to the corresponding widget
        final Widget widget = _routes[GuideWidget]!;
        return MaterialPageRoute(builder: (_) => widget);
      },
    );
  }
}

//Guide example slide

class GuideWidget extends StatefulWidget {
  const GuideWidget({
    Key? key,
    required this.audioPath,
  }) : super(key: key);
  final String audioPath;
  @override
  GuideWidgetState createState() => GuideWidgetState();
}

class GuideWidgetState extends State<GuideWidget> {
  //init database
  final database = FirebaseDatabase.instance.ref();
  //Init storage
  final ref = FirebaseStorage.instance.ref();

  //database reads

  String audio = 'audio track';
  String audioUrl = 'audiofile';

  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
//Pictures for the guide
  List<Image> images = [
    Image(
      image: FirebaseImageProvider(
        FirebaseUrl('gs://museum-guide-app.appspot.com/pictures/picture1.jpg'),
      ),
    ),
    Image(
      image: FirebaseImageProvider(
        FirebaseUrl('gs://museum-guide-app.appspot.com/pictures/picture2.jpg'),
      ),
    ),
  ];

  List<Image> imageWidgets = [];
//Timings of the pictures, first value is second and other is index
  final List<MapEntry<Duration, int>> imageTimestamps = [
    const MapEntry(Duration(seconds: 0), 0), // show first image at start
    const MapEntry(Duration(seconds: 5), 1), // show second image at 5 seconds
    const MapEntry(Duration(seconds: 60), 2), // show third image at 60 seconds
  ];

  int currentImageIndex = 0;
  @override
  void initState() {
    super.initState();
    audio = widget.audioPath;
    downloadFile(audio).then((url) {
      setState(() {
        // audioUrl = url;
      });
    });

    for (var image in images) {
      imageWidgets.add(image);
    }

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.PLAYING;
      });
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
        for (int i = 0; i < imageTimestamps.length; i++) {
          final timestamp = imageTimestamps[i].key;
          final imageIndex = imageTimestamps[i].value;
          final nextTimestamp = i + 1 < imageTimestamps.length
              ? imageTimestamps[i + 1].key
              : duration;

          if (position >= timestamp && position < nextTimestamp) {
            currentImageIndex = imageIndex;
            break;
          }
        }
      });
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

  @override
  Widget build(BuildContext context) => Scaffold(
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
              const SizedBox(height: 4),
              const Text(
                'Guide Author',
                style: TextStyle(fontSize: 20),
              ),
              //Audio progressbar playback time
              Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await audioPlayer.seek(position);
                  await audioPlayer.resume();
                },
              ),
              //Playback time
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatTime(position)),
                    Text(formatTime(duration - position)),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 35,
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  iconSize: 50,
                  onPressed: () async {
                    if (isPlaying) {
                      await audioPlayer.pause();
                    } else {
                      downloadFile(audio);
                      await audioPlayer.play(audioUrl);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
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
    } else {
      print('Permission denied');
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const CircularProgressIndicator();
    } else {
      return Text(
          "Latitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}");
    }
  }
}

//Generate invite slide

class GenerateQRCode extends StatefulWidget {
  const GenerateQRCode({Key? key}) : super(key: key);

  @override
  GenerateQRCodeState createState() => GenerateQRCodeState();
}

class GenerateQRCodeState extends State<GenerateQRCode> {
  final database = FirebaseDatabase.instance.ref();
  String? roomId;

  Future<String?> createRoom() async {
    // Generate a new ID for the room
    final roomId = database.child('rooms').push().key;

    // Create a new node for the room with the generated ID
    await database.child('rooms/$roomId').set({
      'createdAt': DateTime.now().toUtc().toString(),
      'audio': 'your_audio_file_url_here',
      'pictures': ['your_picture_file_url_here'],
    });

    // Return the ID of the newly created room
    return roomId;
  }

  Future<Uri> createDynamicLink(String roomId) async {
    // Create a new DynamicLinkParameters object
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("https://groupguideapp.page.link/guide"),
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

  @override
  void initState() {
    super.initState();
    createRoom().then((roomId) {
      setState(() {
        this.roomId = roomId;
      });
    });
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
                  QrImage(
                    data: 'https://groupguideapp.page.link/guide',
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () async {
                      final dynamicLink = await createDynamicLink(roomId!);
                      await _launchURL(dynamicLink);
                    },
                    child: const Text('Join Room'),
                  ),
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
enum TtsState { playing, stopped, paused, continued }

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
    // _activateListeners();
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
    await database.child('rooms/$roomId').set({
      'createdAt': DateTime.now().toUtc().toString(),
    });

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
