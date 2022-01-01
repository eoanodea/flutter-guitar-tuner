import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:pitchdetector/pitchdetector.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitchupdart/instrument_type.dart';
import 'package:pitchupdart/pitch_handler.dart';

import 'constants.dart';
import 'resuable_card.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Pitchdetector detector = Pitchdetector(sampleRate: 44100, sampleSize: 4096);
  final pitchupDart = PitchHandler(InstrumentType.guitar);
  final pitchDetectorDart = PitchDetector(44100, 2000);

  AudioPlayer audioPlayer = AudioPlayer();

  bool isRecording = false;
  double pitch = 0.0;
  double value = 0.0;
  String note = "";
  String status = "Awful";

  @override
  void initState() {
    super.initState();
    isRecording = isRecording;
    detector.onRecorderStateChanged.listen((event) {
      double castedPitch = event["pitch"] as double;

      if (castedPitch != -1) {
        //Uses the pitchupDart library to check a given pitch for a Guitar
        final handledPitchResult = pitchupDart.handlePitch(castedPitch);

        String tuningStatus = handledPitchResult.tuningStatus.toString();

        String formattedStatus = displayStatusMessage(tuningStatus);

        //Updates the state with the result
        setState(() {
          note = handledPitchResult.note;
          status = formattedStatus;
          value = calculateStatusValue(tuningStatus);
          pitch = castedPitch;
        });

        if (tuningStatus != 'TuningStatus.undefined') {
          playLocalAsset(tuningStatus == 'TuningStatus.tuned');
        }
      }
    });
  }

  String displayStatusMessage(String status) {
    switch (status) {
      case 'TuningStatus.waytoolow':
        return "Waaay too low";
      case 'TuningStatus.toolow':
        return "Too low";
      case 'TuningStatus.tuned':
        return "You're in tune for once!";
      case 'TuningStatus.toohigh':
        return "Too high";
      case 'TuningStatus.waytoohigh':
        return "Waaay too high";

      default:
        return "Awful";
    }
  }

  double calculateStatusValue(String status) {
    switch (status) {
      case 'TuningStatus.waytoolow':
        return 10.0;
      case 'TuningStatus.toolow':
        return 25.0;
      case 'TuningStatus.tuned':
        return 50.0;
      case 'TuningStatus.toohigh':
        return 75.0;
      case 'TuningStatus.waytoohigh':
        return 90.0;

      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kScaffoldBackgroundColor,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: kScaffoldBackgroundColor,
          title: const Text('Are you bad at singing?',
              style: kLargeButtonTextStyle),
        ),
        bottomNavigationBar: bottomBar(),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              note,
              style: kTitleTextStyle,
            ),
            // Expanded(
            ReuseableCard(
              onPress: () => {},
              colour: kActiveCardColour,
              cardChild: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(status, style: kLargeButtonTextStyle),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        activeTrackColor: kInactiveCardColour,
                        inactiveTrackColor: kInactiveCardColour,
                        thumbColor: value == 50.0
                            ? kTunedColour
                            : kBottomContainerColour,
                        overlayColor: kSliderOverlayColour,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 15.0),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 30.0)),
                    child: Slider(
                      value: value,
                      min: 0,
                      max: 100,
                      onChanged: (double value) => {},
                    ),
                  ),
                ],
              ),
            ),

            Text(
              "Pitch Freq in hz: ${pitch.toStringAsFixed(2)}",
              style: kLabelTextStyle,
            )
          ],
        )),
      ),
    );
  }

  Widget bottomBar() {
    const double borderRadius = 40;
    return GestureDetector(
      onTap: () {
        isRecording ? stopRecording() : startRecording();
      },
      child: Container(
        alignment: Alignment.center,
        height: 80,
        decoration: const BoxDecoration(
            color: kBottomContainerColour,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(borderRadius),
              topRight: Radius.circular(borderRadius),
            ),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, -5),
                blurRadius: 10,
                color: Colors.black26,
              ),
            ]),
        child:
            // isRecording ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
            Text(!isRecording ? "RECORD" : "STOP RECORDING",
                style: kLargeButtonTextStyle),
      ),
    );
  }

  Future<AudioPlayer> playLocalAsset(bool playGood) async {
    AudioCache cache = AudioCache();

    return await cache.play(!playGood ? "awful-final.mp3" : "good-final.wav");
  }

  void startRecording() async {
    await detector.startRecording();
    if (detector.isRecording) {
      setState(() {
        isRecording = true;
        note = "";
      });
    }
  }

  void stopRecording() async {
    detector.stopRecording();
    setState(() {
      isRecording = false;
      pitch = 0.0;
    });
  }
}
