// Copyright (c) 2015, Michael Maier. All rights reserved. Use of this source code
// is governed by a MIT-style license that can be found in the LICENSE file.

library source_gen.build_file;

import 'package:cycle_core/cycle_core.dart';

import 'package:source_gen/source_gen.dart';


void main(List<String> args) {
  build(args, const [
    const CycleCoreGenerator()
  ], librarySearchPaths: ['example']).then((msg) {
    print(msg);
  });
}
