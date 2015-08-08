// Copyright (c) 2015, Michael Maier. All rights reserved. Use of this source code
// is governed by a MIT-style license that can be found in the LICENSE file.

library cycle_core.generator;

import 'dart:async';

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/element.dart';

import 'package:source_gen/source_gen.dart';
import 'package:source_gen/src/utils.dart';


class GenerateCycleCore {
  const GenerateCycleCore();
}

class CycleCoreGenerator
extends GeneratorForAnnotation<GenerateCycleCore> {
  const CycleCoreGenerator();

  @override
  Future<String> generateForAnnotatedElement(
      Element element, GenerateCycleCore annotation) async {
    if (element is! ClassElement) {
      var friendlyName = friendlyNameForElement(element);
      throw new InvalidGenerationSourceError(
          'Generator cannot target `$friendlyName`.',
          todo: 'Remove the GenerateDriverTypes annotation from `$friendlyName`.');
    }
    var classElement = element as ClassElement;

    List<_Field> sinkDriverFields = [];
    List<_Field> sourceDriverFields = [];
    for (var f in classElement.fields) {
      var fieldName = f.displayName;
      VariableDeclaration fieldDecl = f.computeNode();
      FunctionElementImpl driverFunc = (fieldDecl.initializer as SimpleIdentifier).staticElement;
      sinkDriverFields.add(new _Field(driverFunc.parameters.first.type.displayName, fieldName));
      sourceDriverFields.add(new _Field(driverFunc.returnType.displayName, fieldName));
    }

    var buffer = new StringBuffer();
    _writeClass(buffer, 'SinkDrivers', sinkDriverFields);
    buffer.writeln();
    _writeClass(buffer, 'SourceDrivers', sourceDriverFields);
    buffer.writeln();
    _writeAppTypedef(buffer);
    buffer.writeln();
    _writeRun(buffer, sourceDriverFields);
    return buffer.toString();
  }
}

void _writeClass(StringBuffer buffer, String className, List<_Field> fields) {
  buffer.writeln('class $className {');
  fields.forEach((field) {
    buffer.writeln('${field.type} ${field.name};');
  });
  _writeConstructor(buffer, className, fields);
  buffer.writeln('}');
}

void _writeConstructor(StringBuffer buffer, String className, List<_Field> fields) {
  buffer.write('$className(');
  buffer.writeAll(fields.map((field) => '{this.${field.name}}'), ', ');
  buffer.writeln(');');
}

void _writeAppTypedef(StringBuffer buffer) {
  buffer.writeln('typedef SinkDrivers App(SourceDrivers sourceDrivers);');
}

void _writeRun(StringBuffer buffer, List<_Field> fields) {
  buffer.writeln('run(App app, Drivers drivers) {');
  buffer.writeAll(fields.map((field) => 'var ${field.name}Proxy = new StreamController();'), '\n');
  buffer.writeln('var sourceDrivers = new SourceDrivers(');
  buffer.writeAll(fields.map((field) => '${field.name}: ${field.name}Proxy.stream.asBroadcastStream()'), '\n');
  buffer.writeln(');');
  buffer.writeln('var sinkDrivers = app(sourceDrivers);');
  buffer.writeAll(fields.map((field) => '${field.name}Proxy.addStream(drivers.${field.name}(sinkDrivers.${field.name}));'), '\n');
  buffer.writeln('}');
}

class _Field {
  final String type;
  final String name;

  const _Field(this.type, this.name);
}