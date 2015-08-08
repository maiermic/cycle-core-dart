// Copyright (c) 2015, Michael Maier. All rights reserved. Use of this source code
// is governed by a MIT-style license that can be found in the LICENSE file.

library cycle_core.example;

import 'dart:async';

import 'package:cycle_core/cycle_core.dart';

import './console_driver.dart';

// include generated cycle library
part 'example.g.dart';


main() {
  run(app, new Drivers());
}

@GenerateCycleCore()
class Drivers {
  var console = consoleDriver;
}

var messages = <String, String>{
  "Hi": "Hello",
  "What's your name?": "Bot"
};

var errorMessage = 'What?';

SinkDrivers app(SourceDrivers appInput) {
  var userInput = appInput.console;
  var output = userInput
    .map((m) => messages.containsKey(m) ? messages[m] : errorMessage)
    .map((m) => 'computer: $m\nuser: ');
  var outController = new StreamController<String>(sync: true);
  outController.add('Welcome to ChatBot\nuser: ');
  outController.addStream(output);
  return new SinkDrivers(
      console: outController.stream
  );
}