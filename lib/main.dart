import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  StreamSubscription? _sub;

  double _level = 0.0;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) return;

    await _recorder.openRecorder();
    // update progres untuk dapat "dbLevel"
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));

    await _recorder.startRecorder(
      toFile: 'temp.aac', // kita tidak butuh file ini, tapi wajib diisi
      codec: Codec.aacADTS,
    );

    _sub = _recorder.onProgress?.listen((e) {
      // e.decibels bisa null di beberapa device, jadi amanin
      final db = e.decibels ?? -60.0;
      setState(() {
        _ready = true;
        _level = db;
      });
    });

    setState(() => _ready = true);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _recorder.stopRecorder();
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Music Tuner - Mic Test')),
        body: Center(
          child: Text(
            _ready ? 'Mic dB: ${_level.toStringAsFixed(1)}' : 'Menyiapkan mic...',
            style: const TextStyle(fontSize: 26),
          ),
        ),
      ),
    );
  }
}