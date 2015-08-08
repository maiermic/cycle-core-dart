# cycle_core

[![Join the chat at https://gitter.im/maiermic/cycle-core-dart](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/maiermic/cycle-core-dart?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A fully reactive [Dart][dart-lang] framework for Human-Computer Interaction
(port of [Cycle.js][cycle-core-js]). See [cycle.js.org](http://cycle.js.org/)
for more information about the fundamental ideas of this library.

[dart-lang]: https://www.dartlang.org/
[cycle-core-js]: https://github.com/cyclejs/cycle-core 

## Usage

Usage of this library is explained by the included console example
(see *example/example.dart*). The entry point of your cycle-application looks
like this:
 
    main() {
      run(app, new Drivers());
    }

`run` starts your `app` function. All
[drivers](http://cycle.js.org/drivers.html)
used by `app` are declared as a class:

    @GenerateCycleCore()
    class Drivers {
      var console = consoleDriver;
    }

You must name this class `Drivers` and annotate it with `@GenerateCycleCore()`.
We use `consoleDriver` as only driver in our example. Its sink driver prints
messages to the console and its source driver reads input from the console.

**Note:** `consoleDriver` is the only available driver yet. An equivalent to
[cycle-dom][cycle-dom] is planned.

[cycle-dom]: https://github.com/cyclejs/cycle-dom

Before we continue writing our `app` function, we run this build file:

    void main(List<String> args) {
      build(args, const [
        const CycleCoreGenerator()
      ], librarySearchPaths: ['example']).then((msg) {
        print(msg);
      });
    }

It looks for a class in directory *example* that is annotated with
`@GenerateCycleCore()` and generates a file *example.g.dart*.
We include it as part of our application library with:

    part 'example.g.dart';

We run our build file every time we change the used drivers.
The generated file contains the cycle core function `run` and the classes
`SinkDrivers` and `SourceDrivers`, which are derived from the drivers that are
declared as fields in `Drivers`. It also contains a type definition of the
`app` function that is passed to `run`. As a result, we can benefit from type
information of drivers without writing classes `SinkDrivers` and
`SourceDrivers` per hand.

In this example we write a chat bot for the console.
The user can write a message/question and gets a response of the computer.
A chat protocol might look like this:

    Welcome to ChatBot
    user: Hi
    computer: Hello
    user: What's your name?
    computer: Bot
    ...

We represent computer response messages in a map with the user message as key.

    var messages = <String, String>{
      "Hi": "Hello",
      "What's your name?": "Bot"
    };

If the user writes an unknown message, the computer answers with a default
error message:

    var errorMessage = 'What?';

Our `app` function looks like this:
    
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

It takes source drivers as input and returns sink drivers as output.
In this example we map the user input of the console driver (`appInput.console`)
to the response message of the computer. Furthermore, we label messages with
`computer: ` and `user: ` to distinguish the author.
The result is a stream `output`. We [use][using-a-stream-controller] a
`StreamController` to start our output stream with a welcome message.
Finally, we pass this stream (`outController.stream`) to the console sink driver.

[using-a-stream-controller]:
https://www.dartlang.org/articles/creating-streams/#using-a-streamcontroller

We can run this example on command line (from the *example* directory) with:

    dart example.dart

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/maiermic/cycle-core-dart/issues
