import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:number_slide_animation/number_slide_animation.dart';
import 'package:infodengue_app/splashscreen.dart';
import 'package:infodengue_app/idapi.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _geocode = 3304557;
  String _name = "Rio de Janeiro";
  String _state = "RJ";

  static final showCard = true; // Set to false to show Stack
  GlobalKey<AutoCompleteTextFieldState<Municipios>> key = new GlobalKey();
  AutoCompleteTextField searchTextField;
  Municipios item_selected = Municipios.fromJson({
    "name_muni": "Rio de Janeiro",
    "code_muni": 3304557,
    "abbrev_state": "RJ"
  });
  TextEditingController controller = new TextEditingController();

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

  void _loadMuns() async {
    await MunicipiosViewModel.loadMunicipios();
  }

  @override
  void initState() {
    _loadMuns();
    _loadPrefs();
    super.initState();
    futureStats = fetchStats(item_selected.code_muni, 'dengue');
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  //load preferences
  _loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _geocode = (prefs.getInt('geocode') ?? 3304557);
      item_selected.code_muni = _geocode;
      _name = (prefs.getString('name') ?? "Rio de Janeiro");
      item_selected.name_muni = _name;
      _state = (prefs.getString('state') ?? "RJ");
      item_selected.abbrev_state = _state;
    });
  }

  //save preferences on selection of new city
  _savePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setInt('geocode', item_selected.code_muni);
      prefs.setString('name', item_selected.name_muni);
      prefs.setString('state', item_selected.abbrev_state);
    });
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
            child: Column(children: <Widget>[
              Text(
                "Selecione cidade:",
                style: localTheme.textTheme.headline5,
              ),
              searchTextField = AutoCompleteTextField<Municipios>(
                  style: new TextStyle(color: Colors.black, fontSize: 16.0),
                  decoration: new InputDecoration(
                      suffixIcon: Container(
                        width: 85.0,
                        height: 60.0,
                      ),
                      contentPadding:
                          EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 20.0),
                      filled: true,
                      hintText: 'Busque sua cidade',
                      hintStyle: TextStyle(color: Colors.black)),
                  itemSubmitted: (item) {
                    setState(() {
                      searchTextField.textField.controller.text = item.nome;
                      item_selected = item;
                      futureStats = fetchStats(item.code_muni, 'dengue');
                      _savePrefs();
                    });
                  },
                  clearOnSubmit: false,
                  key: key,
                  suggestions: MunicipiosViewModel.municipios,
                  itemBuilder: (context, item) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          item.name_muni,
                          style: TextStyle(fontSize: 16.0),
                        ),
                        Padding(
                          padding: EdgeInsets.all(15.0),
                        ),
                        Text(
                          item.abbrev_state,
                        )
                      ],
                    );
                  },
                  itemSorter: (a, b) {
                    return a.nome.compareTo(b.nome);
                  },
                  itemFilter: (item, query) {
                    return item.nome
                        .toLowerCase()
                        .startsWith(query.toLowerCase());
                  }),
            ]),
            // ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() => SizedBox(
        // This widget represents the stats cards.
        // Reads data from infodengue API.
        height: 210,
        child: Card(
          child: Column(
            children: [
              ExpansionTile(
                title: Text(
                    'Alerta ${item_selected.name_muni} - ${item_selected.abbrev_state}',
                    style: Theme.of(context).textTheme.headline6),
                subtitle: Text('Estatísticas:',
                    style: Theme.of(context).textTheme.bodyText1),
                leading: Icon(
                  Icons.location_city,
                  color: Colors.blue[500],
                  size: 40,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<List<Stats>>(
                  future: futureStats,
                  builder: (context, snapshot) {
                    final Map<int, Color> alertColors = {
                      1: Colors.green,
                      2: Colors.yellow,
                      3: Colors.orange,
                      4: Colors.red
                    };

                    if (snapshot.hasData) {
                      print(snapshot.data);
                      if (snapshot.data.length == 0) {
                        return Container(
                            color: Colors.grey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                    'Não há dados disponíveis para esta cidade.',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic)),
                              ],
                            ));
                      } else {
                        var yse = snapshot.data.last.SE.toString();
                        var ano = yse.substring(0, 4);
                        var ew = yse.substring(yse.length - 2);
                        return Container(
                            color: alertColors[snapshot.data.last.nivel],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Semana Epidemiológica: ${ew} de ${ano}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic)),
                                Text(
                                    'Casos notificados: ${snapshot.data.last.casos}'),
                                Text(
                                    'Casos estimados: ${snapshot.data.last.casos_est}'),
                                Text('Tweets: ${snapshot.data.last.tweet}'),
                                Text('Rt: ${snapshot.data.last.Rt}'),
                              ],
                            ));
                      }
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    // By default, show a loading spinner.
                    return CircularProgressIndicator();
                  },
                ),
              )
            ],
          ),
        ),
      );

  Widget _buildStack() => Stack(
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
