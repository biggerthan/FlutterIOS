import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TestPage extends StatefulWidget {
  TestPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int _counter = 33;

  //必须注册
  static const methodChannel = const MethodChannel("MethodChannelForFlutter");
  //必须注册
  static const eventChannel = const EventChannel('EventChannelForFlutter');

  @override
  void initState() {
    super.initState();
    eventChannel.receiveBroadcastStream('getInformation').listen(_onEvent, onError: _onError);
  }

  @override
  void dispose() {

    print('dispose');
    super.dispose();
  }

  _onEvent(Object event) {
    print("event: $event");
  }

  _onError(Object error) {}

  void _incrementCounter() {
    flutterPop();
    setState(() {
      _counter += 2;
    });
  }

  flutterPop() async {
    // 要想拿到返回结果, 需要async await
    var result =
        await methodChannel.invokeMethod("FlutterForNativeViewControllerDismissKey");
    print('result: $result');
  }

  @override
  Widget build(BuildContext context) {
    print("MediaQuery.of(context).padding: ");
    print(MediaQuery.of(context).padding);
    return Scaffold(
      appBar: null,
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        width: MediaQuery.of(context).size.width,
        color: Colors.red,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
