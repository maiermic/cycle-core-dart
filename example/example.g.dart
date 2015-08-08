// GENERATED CODE - DO NOT MODIFY BY HAND
// 2015-08-08T15:39:37.017Z

part of cycle_core.example;

// **************************************************************************
// Generator: CycleCoreGenerator
// Target: class Drivers
// **************************************************************************

class SinkDrivers {
  Stream<String> console;
  SinkDrivers({this.console});
}

class SourceDrivers {
  Stream<String> console;
  SourceDrivers({this.console});
}

typedef SinkDrivers App(SourceDrivers sourceDrivers);

run(App app, Drivers drivers) {
  var consoleProxy = new StreamController();
  var sourceDrivers =
      new SourceDrivers(console: consoleProxy.stream.asBroadcastStream());
  var sinkDrivers = app(sourceDrivers);
  consoleProxy.addStream(drivers.console(sinkDrivers.console));
}
