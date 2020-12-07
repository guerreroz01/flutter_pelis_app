import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:app_peliculas/src/models/actores.models.dart';
import 'package:app_peliculas/src/models/peliculas.models.dart';

class PeliculasProvider {
  String _apikey = '19320b317cc7917331b879e04fb619a5';
  String _url = 'api.themoviedb.org';
  String _language = 'es-ES';
  int _popularesPage = 0;
  bool _cargando = false;

  List<Pelicula> _populares = new List();

  final _popularesStreamController =
      StreamController<List<Pelicula>>.broadcast();

  Function(List<Pelicula>) get popularesSink =>
      _popularesStreamController.sink.add;
  Stream<List<Pelicula>> get popularesStream =>
      _popularesStreamController.stream;

  void disposeStreams() {
    _popularesStreamController?.close();
  }

  Future<List<Pelicula>> _procesarRespuesta(Uri url, String param) async {
    final respuesta = await http.get(url);
    final decodedData = json.decode(respuesta.body);
    final peliculas = new Peliculas.fromJsonList(decodedData[param]);

    return peliculas.items;
  }

  Future<List<Pelicula>> getEnCines() {
    final url = Uri.https(
      _url,
      '3/movie/now_playing',
      {'api_key': _apikey, 'language': _language},
    );
    final peliculas = _procesarRespuesta(url, 'results');
    return peliculas;
  }

  Future<List<Pelicula>> getPopulares() async {
    if (_cargando) return [];
    _cargando = true;
    _popularesPage++;

    final url = Uri.https(
      _url,
      '3/movie/popular',
      {
        'api_key': _apikey,
        'language': _language,
        'page': _popularesPage.toString()
      },
    );
    final respuesta = await _procesarRespuesta(url, 'results');
    _populares.addAll(respuesta);
    popularesSink(_populares);
    _cargando = false;
    return respuesta;
  }

  Future<List<Actor>> getCast(String peliId) async {
    final url = Uri.https(_url, '3/movie/$peliId/credits', {
      'api_key': _apikey,
      'language': _language,
    });

    final respuesta = await http.get(url);
    final decodedData = json.decode(respuesta.body);

    final cast = new Cast.fromJSONList(decodedData['cast']);

    return cast.actores;
  }

  Future<List<Pelicula>> buscarPelicula({String query}) {
    final url = Uri.https(
      _url,
      '3/search/movie',
      {'api_key': _apikey, 'language': _language, 'query': query},
    );

    final peliculas = _procesarRespuesta(url, 'results');
    return peliculas;
  }
}
