@JS("bridge")
library bridge;

import 'package:js/js.dart';
import 'dart:async';

@JS("load")
external Future<dynamic> load(dynamic buffer);

@JS("call")
external Future<dynamic> call(dynamic buffer, List<Object?> lengths);
