import 'dart:async';
// import 'dart:html';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:exapp/tts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TextToSpeech.initTTs();
  runApp(const MyApp());
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
    );
  }
}

// Code for the homepage
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isDarkThemeEnabled = false;
  int _currentIndex = 0;

  final List<Widget> _children = [
    const HomeWidget(),
    GuideWidget(),
    const QRWidget(),
    const TTSWidget(),
  ];

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
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => SettingsPage(_isDarkThemeEnabled),
                //   ),
                // );
              },
            ),
          ],
        ),
        // body: const Center(
        //   child: Text('This is the main page.'),
        // ),
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.surround_sound),
              label: 'Guide',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              label: 'QR-Scanner',
              // title: Text('Messages'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.volume_up),
              label: 'Text-To-Speech',
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

//First default slide
class HomeWidget extends StatelessWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('First Page'),
          ElevatedButton(
            onPressed: () async {
              try {
                // await requestAudioPermission();
                // _requestPermission();
                // TextToSpeech.speak();
              } catch (e) {
                print(e.toString());
              }
            },
            child: const Text('Speak'),
          ),
        ],
      ),
    );
  }
}

//Guide example slide

class GuideWidget extends StatefulWidget {
  const GuideWidget({Key? key}) : super(key: key);

  @override
  _GuideWidgetState createState() => _GuideWidgetState();
}

class _GuideWidgetState extends State<GuideWidget> {
  // GuideWidget({Key? key}) : super(key: key);
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  @override
  void initState() {
    super.initState();
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
      });
    });
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
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'https://scontent.farn1-2.fna.fbcdn.net/v/t39.30808-6/290550921_6028899657126287_8235422534649890651_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=G_NWDv-wKUAAX-oEmzd&_nc_ht=scontent.farn1-2.fna&oh=00_AfDFVrbAvXvCOn30HCkmCw0JwyOnBRz-WFCdBzeAoMi7_g&oe=64335988',
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Epic song',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Mull',
                style: TextStyle(fontSize: 20),
              ),
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
                      String url =
                          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
                      await audioPlayer.play(url);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
}

//QR scanner slide
class QRWidget extends StatelessWidget {
  const QRWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Scanner')),
      body: MobileScanner(
        // fit: BoxFit.contain,
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
          torchEnabled: true,
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          final Uint8List? image = capture.image;
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
  _TTSWidgetState createState() => _TTSWidgetState();
}

class _TTSWidgetState extends State<TTSWidget> {
  final FlutterTts flutterTts = FlutterTts();
  TextEditingController textController = TextEditingController();
  double volume = 1.0;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  String? language;
  String? _newVoiceText;
  int end = 0;
  int currentPosition = 0;
  bool isCurrentLanguageInstalled = false;

  TtsState ttsState = TtsState.stopped;

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.5);
    flutterTts.setVolume(volume);
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Text to speech"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: textController,
          ),
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
            child: Icon(Icons.pause),
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
          // ttsState == TtsState.playing ? _progressBar(end) : Text(""),
          // _progressBar(end),
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
          return Text('Error loading languages...');
        } else
          return Text('Loading Languages...');
      });

  Widget _languageDropDownSection(dynamic languages) => Container(
      padding: EdgeInsets.only(top: 10.0),
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
