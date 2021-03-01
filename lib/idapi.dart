import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
/*
[{"data_iniSE":1612051200000,"SE":202105,"casos_est":22.0,"casos_est_min":18,"casos_est_max":30,"casos":10,"p_rt1":0.977524,"p_inc100k":0.338522,"Localidade_id":0,"nivel":2,"id":330455720210518681,"versao_modelo":"2021-02-23","tweet":null,"Rt":2.0,"pop":6498837.0,"tempmin":25.0,"umidmax":null,"receptivo":1,"transmissao":0,"nivel_inc":0,"notif_accum_year":55},
{"data_iniSE":1612656000000,"SE":202106,"casos_est":15.0,"casos_est_min":9,"casos_est_max":28,"casos":6,"p_rt1":0.444606,"p_inc100k":0.230811,"Localidade_id":0,"nivel":2,"id":330455720210618681,"versao_modelo":"2021-02-23","tweet":null,"Rt":1.0,"pop":6498837.0,"tempmin":23.0,"umidmax":null,"receptivo":1,"transmissao":0,"nivel_inc":0,"notif_accum_year":55},
{"data_iniSE":1613260800000,"SE":202107,"casos_est":22.0,"casos_est_min":11,"casos_est_max":45,"casos":3,"p_rt1":0.713468,"p_inc100k":0.338522,"Localidade_id":0,"nivel":2,"id":330455720210718681,"versao_modelo":"2021-02-23","tweet":2.0,"Rt":1.0,"pop":6498837.0,"tempmin":24.0,"umidmax":null,"receptivo":1,"transmissao":0,"nivel_inc":0,"notif_accum_year":55}]
 */

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

  Stats({this.SE, this.casos_est, this.casos, this.tweet, this.Rt});

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      SE: json['SE'],
      casos_est: json['casos_est'],
      casos: json['casos'],
      tweet: json['tweet'],
      Rt: json['Rt']
    );
  }
}



