import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:number_slide_animation/number_slide_animation.dart';
import 'package:infodengue_app/splashscreen.dart';
import 'package:infodengue_app/idapi.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infodengue Mobile',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Splash(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  static final showCard = true; // Set to false to show Stack
  Future<List<Stats>> futureStats;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    var munimap = read_municipios();
    // debugPrint("$munimap");
    // var geoc = munimap['Rio de Janeiro'];
    // debugPrint("$geoc");
    futureStats = fetchStats('3304557', 'dengue');
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData localTheme = Theme.of(context);
    
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(child: showCard ? _buildCard() : _buildStack())
          ],
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          right: false,
          child: Center(
            child: Column(
              children: [
                Text("Rio de Janeiro",style: localTheme.textTheme.headline4,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() =>
      SizedBox(
        // This widget represents the stats cards.
        // Reads data from infodengue API.
        height: 210,
        child: Card(
          child: Column(
            children: [
              ListTile(
                title: Text('Alerta Rio de Janeiro',
                    style: Theme.of(context).textTheme.headline6),
                subtitle: Text('Estatísticas:', style: Theme.of(context).textTheme.bodyText1),
                leading: Icon(
                  Icons.location_city,
                  color: Colors.blue[500],
                  size: 50,
                ),
              ),
              Padding(padding: const EdgeInsets.all(16),
                      child: FutureBuilder <List<Stats>>(
                        future: futureStats,
                        builder: (context, snapshot) {
                          final Map<int, Color> alertColors= {
                            1:Colors.green,
                            2:Colors.yellow,
                            3: Colors.orange,
                            4: Colors.red};
                          var se = snapshot.data[2].SE.toString();
                          var ew = se.substring(se.length-2);
                          if (snapshot.hasData) {
                            return Container(
                                color: alertColors.values.toList()[snapshot.data[2].nivel],
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text('Semana Epidemiológica: ${ew} de ${se.substring(0,4)}',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                                      Text('Casos notificados: ${snapshot.data[2].casos}'),
                                      Text('Casos estimados: ${snapshot.data[2].casos_est}'),
                                      Text('Tweets: ${snapshot.data[2].tweet}'),
                                      Text('Rt: ${snapshot.data[2].Rt}'),
                                    ],
                                )

                            );

                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }

                          // By default, show a loading spinner.
                          return
                            CircularProgressIndicator
                              (
                            );
                        },
                      ),
              )

            ],
          ),
        ),
      );

  Widget _buildStack() =>
      Stack(
        alignment: const Alignment(0.6, 0.6),
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/icon.png'),
            radius: 100,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black45,
            ),
            child: Text(
              'Mia B',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
}
