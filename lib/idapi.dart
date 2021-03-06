import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:convert';
import 'dart:io';


String loadAsset()  {
  String contents = new File('assets/munis.json').readAsStringSync();
  // final contents =  await rootBundle.loadString('assets/munis.json');
  return contents;
}

Map<String,int> read_municipios() {

  // loadAsset().then((contents){
  //   municipios = json.decode(contents);
  //   return municipios;
  // });
  return json.decode(loadAsset());
}


 Future<String> getLocation() async
{
  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  print('location: ${position.latitude}');
  final coordinates = new Coordinates(position.latitude, position.longitude);
  var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
  var first = addresses.first;
  print("${first.featureName} : ${first.addressLine}");
  return first.featureName;
}

List<Stats> StatsFromJson(String str) =>
    List<Stats>.from(
        json.decode(str).map((x) => Stats.fromJson(x)));

Future<List<Stats>> fetchStats(geocode, disease) async {
  var url = r'https://info.dengue.mat.br/api/alertcity/';
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



