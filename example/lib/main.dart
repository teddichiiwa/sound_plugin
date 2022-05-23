import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sound_plugin/sound_plugin.dart';
import 'package:sound_plugin_example/ui_rounded_button_v2.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initAudioSession();
  }

  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache cachePlayer = AudioCache();
  late AudioSession _session;

  late final Stream<AudioInterruptionEvent> _interruptionEvents;

  AudioInterruptionType _interruptionType = AudioInterruptionType.unknown;

  Future<void> initAudioSession() async {
    _session = await AudioSession.instance;
    await _session.configure(AudioSessionConfiguration.music());

    _session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // Another app started playing audio and we should duck.
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            // Another app started playing audio and we should pause.
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // The interruption ended and we should unduck.
            break;
          case AudioInterruptionType.pause:
          // The interruption ended and we should resume.
          case AudioInterruptionType.unknown:
            // The interruption ended but we should not resume.
            break;
        }
      }

      setState(() {
        _interruptionType = event.type;
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await SoundPlugin.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  AndroidAudioContentType contentType = AndroidAudioContentType.movie;

  int sessionId = -1;

  bool? isMusicActive;

  AndroidAudioFocusGainType _gainType = AndroidAudioFocusGainType.gain;

  String? _getGainType(AndroidAudioFocusGainType type) {
    switch (type) {
      case AndroidAudioFocusGainType.gain:
        return 'gain (will stop music)';
      case AndroidAudioFocusGainType.gainTransient:
        return 'gainTransient (will resume music)';
      case AndroidAudioFocusGainType.gainTransientExclusive:
        return 'gainTransientExclusive (will resume music)';
      case AndroidAudioFocusGainType.gainTransientMayDuck:
        return 'gainTransientMayDuck (play both sound at the same time)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: Text('Running on: $_platformVersion\n'),
            ),
            Spacer(),
            Center(
              child: Text(_interruptionType.toString()),
            ),
            Center(
              child: Text(contentType.toString()),
            ),
            Center(
              child: Text('Is music Active: ' +
                  (isMusicActive ?? false ? 'True' : 'False')),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text('Gain type: ${_getGainType(_gainType)}'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  UIRoundedButtonV2(
                    height: 40,
                    width: 200,
                    color: Colors.amber,
                    cornerRadius: 10,
                    onPressed: () async {
                      if (_gainType == AndroidAudioFocusGainType.gain) {
                        setState(() {
                          _gainType = AndroidAudioFocusGainType.gainTransient;
                        });
                      } else if (_gainType ==
                          AndroidAudioFocusGainType.gainTransient) {
                        setState(() {
                          _gainType =
                              AndroidAudioFocusGainType.gainTransientExclusive;
                        });
                      } else if (_gainType ==
                          AndroidAudioFocusGainType.gainTransientExclusive) {
                        setState(() {
                          _gainType =
                              AndroidAudioFocusGainType.gainTransientMayDuck;
                        });
                      } else if (_gainType ==
                          AndroidAudioFocusGainType.gainTransientMayDuck) {
                        setState(() {
                          _gainType = AndroidAudioFocusGainType.gain;
                        });
                      }
                    },
                    child: Text('Change focus type'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  UIRoundedButtonV2(
                    height: 40,
                    width: 200,
                    color: Colors.amber,
                    cornerRadius: 10,
                    onPressed: () async {
                      final id =
                          await AndroidAudioManager().generateAudioSessionId();
                      setState(() {
                        sessionId = id;
                      });
                    },
                    child: Text('Session id: $sessionId'),
                  ),
                  UIRoundedButtonV2(
                    height: 40,
                    width: 120,
                    color: Colors.amber,
                    cornerRadius: 10,
                    onPressed: () async {
                      final isActive =
                          await AndroidAudioManager().isMusicActive();
                      setState(() {
                        isMusicActive = isActive;
                      });
                    },
                    child: Text('Check active'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  UIRoundedButtonV2(
                    height: 40,
                    width: 80,
                    color: Colors.teal,
                    cornerRadius: 10,
                    onPressed: () async {
                      AndroidAudioManager()
                          .requestAudioFocus(
                        AndroidAudioFocusRequest(
                          audioAttributes: AndroidAudioAttributes(
                            usage:
                                AndroidAudioUsage.assistanceNavigationGuidance,
                            contentType: contentType,
                          ),
                          onAudioFocusChanged: (focus) {
                            print('focus changed: $focus');
                          },
                          gainType: _gainType,
                        ),
                      )
                          .then((value) async {
                        if (value) {
                          // cachePlayer.duckAudio = true;
                          final result = await cachePlayer.play(
                            'camera.mp3',
                          );
                          result.onPlayerStateChanged.listen((event) async {
                            if (event == PlayerState.COMPLETED) {
                              print('finish playing audio');
                              await AndroidAudioManager().abandonAudioFocus();
                              result.stop();
                              result.release();
                              result.dispose();
                            }
                          });
                        }
                      });
                    },
                    child: Text('Play'),
                  ),
                  UIRoundedButtonV2(
                    height: 40,
                    width: 80,
                    color: Colors.amber,
                    cornerRadius: 10,
                    onPressed: () {},
                    child: Text('Pause'),
                  ),
                  UIRoundedButtonV2(
                    height: 40,
                    width: 80,
                    color: Colors.red,
                    cornerRadius: 10,
                    onPressed: () {},
                    child: Text('Stop'),
                  ),
                  UIRoundedButtonV2(
                    height: 40,
                    width: 80,
                    color: Colors.red,
                    cornerRadius: 10,
                    onPressed: () {
                      if (contentType == AndroidAudioContentType.movie) {
                        setState(() {
                          contentType = AndroidAudioContentType.music;
                        });
                      } else if (contentType == AndroidAudioContentType.music) {
                        setState(() {
                          contentType = AndroidAudioContentType.sonification;
                        });
                      } else if (contentType ==
                          AndroidAudioContentType.sonification) {
                        setState(() {
                          contentType = AndroidAudioContentType.speech;
                        });
                      } else if (contentType ==
                          AndroidAudioContentType.speech) {
                        setState(() {
                          contentType = AndroidAudioContentType.unknown;
                        });
                      } else if (contentType ==
                          AndroidAudioContentType.unknown) {
                        setState(() {
                          contentType = AndroidAudioContentType.movie;
                        });
                      }
                    },
                    child: Text('Switch'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
