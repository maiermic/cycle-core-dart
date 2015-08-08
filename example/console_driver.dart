// Copyright (c) 2015, Michael Maier. All rights reserved. Use of this source code
// is governed by a MIT-style license that can be found in the LICENSE file.

library cycle_core.example.console_driver;

import 'dart:io';
import 'dart:async';

Stream<String> consoleDriver(Stream<String> output) {
  return output.map((message) {
    stdout.write(message);
    return stdin.readLineSync();
  });
}