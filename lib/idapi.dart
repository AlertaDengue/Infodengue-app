import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:convert';


Future<Map<String,dynamic>> loadMap() async {
  String contents =  await rootBundle.loadString('assets/munis.json');
  Map<String,dynamic> mapa = await json.decode(contents);
  // print(mapa);
  return mapa;
}

Future<int> getGeocode(map, name) async {
  int geocode = await map[name];
  return geocode;
}


 Future<String> getLocation() async
{
  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  // print('location: ${position.latitude}');
  final coordinates = new Coordinates(position.latitude, position.longitude);
  var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
  var first = addresses.first;
  // print("${first.locality}, ${first.subLocality} : ${first.addressLine}");
  return first.locality;
}

List<Stats> StatsFromJson(String str) =>
    List<Stats>.from(
        json.decode(str).map((x) => Stats.fromJson(x)));

Future<List<Stats>> fetchStats(geocode, disease) async {
  var url = r'https://info.dengue.mat.br/api/alertcity/';
  // var mapmuni = await loadMap();
  // print(mapmuni);
  String locname = await getLocation();
  // print(locname);
  // var geocode = await getGeocode(mapmuni, locname);
  var qParams = 'geocode=$geocode&disease=$disease&format=json&ew_start=05&ey_start=2021&ew_end=09&ey_end=2021';
  var full_url = Uri.parse(url).replace(query: qParams);
  final response = await http.get(full_url);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return StatsFromJson(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.

    throw Exception('Failed to load Statistics from $full_url');
  }
}

class Stats {
  final int SE;
  final double casos_est;
  final int casos;
  final double tweet;
  final double Rt;
  final int nivel;
  final int receptivo;


  Stats({this.SE, this.casos_est, this.casos, this.tweet, this.Rt, this.nivel, this.receptivo});

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      SE: json['SE'],
      casos_est: json['casos_est'],
      casos: json['casos'],
      tweet: json['tweet'],
      Rt: json['Rt'],
      nivel: json['nivel'],
      receptivo: json['receptivo']
    );
  }
}

class Municipios {
  String name_muni;
  int code_muni;
  String abbrev_state;
  String nome;

  Municipios({
    this.name_muni,
    this.code_muni,
    this.abbrev_state,
    this.nome
  });

  factory Municipios.fromJson(Map<String, dynamic> parsedJson) {
    return Municipios(
        name_muni: parsedJson['name_muni'] as String,
        code_muni: parsedJson['code_muni'],
        abbrev_state: parsedJson['abbrev_state'] as String,
        nome: parsedJson['nome'] as String
    );
  }
}

class MunicipiosViewModel {
  static List<Municipios> municipios;

  static Future loadMunicipios() async {
    try {
      municipios = <Municipios>[];
      String jsonString = await rootBundle.loadString('assets/munis.json');
      List parsedJson = json.decode(jsonString);
      // var categoryJson = parsedJson['municipios'] as List;
      for (int i = 0; i < parsedJson.length; i++) {
        municipios.add(new Municipios.fromJson(parsedJson[i]));
      }
    } catch (e) {
      print(e);
    }
  }
}
