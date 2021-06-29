// ignore: import_of_legacy_library_into_null_safe
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:mic_stream/mic_stream.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:runevm_fl/runevm_fl.dart';

class Audio {
  final int bufferLength;
  final int stepSize;
  int stepCounter = 0;
  Function onStep = (String? buffer) {};
  Stream<List<int>>? stream;
  List _streamSubscriptions = [];
  int? bits;
  List<int> _buffer = [];
  double amplitude = 0;
  bool freeze = false;
  int sampleRate = 16000;
  List<int> getBuffer() {
    return _buffer.toList();
  }

  setAmplitude() {
    List<int> buf = getBuffer();
    amplitude = buf
            .sublist((buf.length / 4).round(), (buf.length * 3 / 4).round())
            .reduce((a, b) => (a.abs() + b.abs())) /
        getBuffer().length /
        5;
  }

  Audio({this.bufferLength = 16000, this.stepSize = 32000}) {
    initRune();
  }

  ByteData? bytes;

  initRune() async {
    try {
      bytes = await rootBundle.load('assets/microspeech.rune');
      bool loaded = await RunevmFl.load(bytes!.buffer.asUint8List()) ?? false;
      if (loaded) {
        String manifest = (await RunevmFl.manifest).toString();
        print("Manifest loaded: $manifest");
      }
    } on Exception {
      print('Failed to init rune');
    }
  }

  initRecording() async {
    stream = await MicStream.microphone(
        sampleRate: 16000,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: AudioFormat.ENCODING_PCM_16BIT);
  }

  /*getStepBuffer() {
    while (_stepBuffer.length < this.stepSize) {
      _stepBuffer.add(0);
    }
    return _stepBuffer;
  }*/

  Uint8List getStepBuffer() {
    while (_buffer.length < this.bufferLength) {
      _buffer.add(0);
    }
    return Int16List.fromList(_buffer).buffer.asUint8List();
  }

  List<int> to16bit(List<int> input) {
    List<int> out = [];
    out = Uint8List.fromList(input).buffer.asInt16List().toList();
    return out;
  }

  int bitcount = 0;
  int millisecondStarted = 0;
  bool runningModel = false;
  int counter = 0;
  startRecording() async {
    if (stream == null) {
      await initRecording();
    }

    if (await Permission.microphone.request().isGranted) {
      bits = await MicStream.bitDepth;
      print("Start recording");
      for (StreamSubscription<List<int>> streamSub in _streamSubscriptions) {
        await streamSub.cancel();
      }
      if (stream != null) {
        _streamSubscriptions.add(stream?.listen((List<int> samples) async {
          if (millisecondStarted == 0) {
            millisecondStarted = DateTime.now().millisecondsSinceEpoch;
          }
          List<int> stream = to16bit(samples);
          bitcount += stream.length;

          double sampleRateCalc = bitcount /
              (DateTime.now().millisecondsSinceEpoch - millisecondStarted) *
              1000;
          double maxDifference = 100000;
          if ((sampleRateCalc - 16000).abs() < maxDifference) {
            maxDifference = (sampleRateCalc - 16000).abs();
            sampleRate = 16000;
          }
          if ((sampleRateCalc - 32000).abs() < maxDifference) {
            maxDifference = (sampleRateCalc - 32000).abs();
            sampleRate = 32000;
          }
          if ((sampleRateCalc - 48000).abs() < maxDifference) {
            maxDifference = (sampleRateCalc - 48000).abs();
            sampleRate = 48000;
          }
          if (sampleRate == 48000) {
            for (int i = 2; i < stream.length; i += 3) {
              _buffer.add(
                  ((stream[i - 2] + stream[i - 1] + stream[i]) / 3).round());
            }
          }
          if (sampleRate == 32000) {
            for (int i = 1; i < stream.length; i += 2) {
              _buffer.add(((stream[i - 1] + stream[i]) / 2).round());
            }
          }
          if (sampleRate == 16000) {
            _buffer.addAll(stream);
          }

          /*for (int i = 1; i < stream.length; i += 2) {
            _buffer.add(((stream[i - 1] + stream[i]) / 2).round());
          }*/

          if (_buffer.length > this.bufferLength) {
            _buffer = _buffer.sublist(_buffer.length - this.bufferLength);
          }
          if (_buffer.length == this.bufferLength) {
            onStep(null);
          }
          //print(
          //    "${_stepBuffer.length} ${this.stepSize} ${_buffer.length} ${this.bufferLength}");
          /*
          if (_stepBuffer.length == this.stepSize) {
            counter++;
            if (!runningModel) {
              await run(_stepBuffer);
            }
          } else {
            if (_buffer.length == this.bufferLength) {
              onStep(null);
            }
          }*/
        }));
      }
    } else {
      print("No recording permission");
    }
    runLoop();
  }

  runLoop() async {
    await run(getStepBuffer());

    runLoop();
  }

  run(List<int> stepBuffer) async {
    try {
      runningModel = true;
      setAmplitude();
      if (amplitude > 80) {
        String? output = await RunevmFl.runRune(Uint8List.fromList(stepBuffer));
        onStep(output);
        freeze = true;
        await Future.delayed(const Duration(milliseconds: 1000), () {});
        freeze = false;
      } else {
        onStep(
            '{"type_name":"&str","channel":0,"elements":[""],"dimensions":[1]}');
        await Future.delayed(const Duration(milliseconds: 100), () {});
      }

      runningModel = false;
    } catch (e) {
      print("Error running rune: $e");
    }
  }

  stopRecording() {
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    onStep = (List buffer) {
      //empty function
    };
  }

  List<Color> gradientColorsX = [
    Colors.red[200]!,
    Colors.red[600]!,
  ];
  List<Color> gradientColorsY = [
    Colors.lightGreen[200]!,
    Colors.lightGreen[600]!,
  ];
  List<Color> gradientColorsZ = [
    Colors.yellow[200]!,
    Colors.yellow[600]!,
  ];
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  LineChartData audioData(List<int> x) {
    final List<double> minMax = [-32768 * 0.1, 32768 * 0.1];
    List<FlSpot> spotsX = [];

    for (int i = 0; i < x.length; i++) {
      double value = x[i] > minMax[1]
          ? minMax[1]
          : (x[i] * 1.0 < minMax[0] ? minMax[0] : x[i] * 1.0);
      spotsX.add(FlSpot(i * 1.0, value * 1.0));
    }
    if (spotsX.length == 0) {
      spotsX.add(FlSpot(0, 0));
    }
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: false,
        bottomTitles: SideTitles(
          showTitles: false,
          reservedSize: 10,
          getTextStyles: (value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 12),
          getTitles: (value) {
            switch (value) {
            }
            return (value.round() % 12 == 0) ? value.toString() : "";
          },
          margin: 2,
        ),
        leftTitles: SideTitles(
          showTitles: false,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          getTitles: (value) {
            switch (value) {
            }
            return value.round().toString();
          },
          reservedSize: 21,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: false,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: x.length * 1.0,
      minY: minMax[0],
      maxY: minMax[1],
      lineBarsData: [
        LineChartBarData(
          spots: spotsX,
          isCurved: false,
          colors: freeze ? gradientColorsY : gradientColorsX,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.1)).toList(),
          ),
        ),
      ],
    );
  }
}
