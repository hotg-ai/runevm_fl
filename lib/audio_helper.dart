@JS("audio")
library audio;

import 'package:js/js.dart';
import 'dart:async';

@JS("decode")
external Future<dynamic> decode(int milliseconds);

@JS("initMic")
external Future<dynamic> initMic();
