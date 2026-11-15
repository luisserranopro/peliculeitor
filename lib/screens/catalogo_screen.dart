import 'dart:async';

import 'package:flutter/material.dart';

import '../config.dart';
import '../models/modelos.dart';
import '../services/tmdb_service.dart';
import '../textos.dart';
import '../widgets/comunes.dart';
import '../widgets/tarjeta_media.dart';

/// Sustituye a PeliculasFragment y SeriesFragment, que eran casi idénticos
/// (mismo layout fragment_media_final.xml). Una sola pantalla con un parámetro.
class CatalogoScreen extends StatefulWidget {
  final bool esSeries;

  const CatalogoScreen({super.key, required this.esSeries});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final _api = TmdbService.instancia;
  final _controladorBusqueda = TextEditingController();

  late Future<List<ElementoMedia>> _recomendadas;
  late Future<List<ElementoMedia>> _mejorValoradas;

  List<ElementoMedia> _resultados = [];
  bool _buscando = false;
  Timer? _espera;
  String _ultimaBusqueda = '';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    if (widget.esSeries) {
      _recomendadas = _api.seriesRecomendadas().then(_series);
      _mejorValoradas = _api.seriesMejorValoradas().then(_series);
    } else {
      _recomendadas = _api.peliculasRecomendadas().then(_peliculas);
      _mejorValoradas = _api.peliculasMejorValoradas().then(_peliculas);
    }
  }

  List<ElementoMedia> _peliculas(List<Pelicula> l) => l.map((p) => p.comoElemento).toList();
  List<ElementoMedia> _series(List<Serie> l) => l.map((s) => s.comoElemento).toList();

  /// Sustituye al TextWatcher. Se espera 400 ms desde la última tecla antes de
  /// llamar a la API (el original lanzaba una petición por cada letra).
  void _alCambiarTexto(String texto) {
    _espera?.cancel();
    if (texto.trim().length <= 2) {
      setState(() {
        // Con 2 letras o menos se vuelven a mostrar las listas normales.
        _buscando = false;
        _resultados = [];
        _ultimaBusqueda = '';
      });
      return;
    }
    setState(() => _buscando = true);
    _espera = Timer(const Duration(milliseconds: 400), () => _buscar(texto.trim()));
  }

  Future<void> _buscar(String texto) async {
    _ultimaBusqueda = texto;
    try {
      final resultados = widget.esSeries
          ? _series(await _api.buscarSeries(texto))
          : _peliculas(await _api.buscarPeliculas(texto));
      // Si mientras tanto se ha escrito otra cosa, se descarta esta respuesta.
      if (!mounted || texto != _ultimaBusqueda) return;
      setState(() => _resultados = resultados);
    } catch (e) {
      debugPrint('Error en la búsqueda: $e');
    }
  }

  @override
  void dispose() {
    _espera?.cancel();
    _controladorBusqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            Textos.bienvenida,
            style: const TextStyle(
              color: Colores.texto,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _controladorBusqueda,
            onChanged: _alCambiarTexto,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: Textos.buscar,
              hintStyle: const TextStyle(color: Colors.black54),
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              suffixIcon: _controladorBusqueda.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () {
                        _controladorBusqueda.clear();
                        _alCambiarTexto('');
                      },
                    ),
              filled: true,
              fillColor: Colores.busqueda,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (_buscando)
          // Equivale a poner visible recycler_view_busqueda
          ..._resultados.map((e) => FilaBusqueda(elemento: e))
        else ...[
          CargaFutura<List<ElementoMedia>>(
            futuro: _recomendadas,
            reintentar: () => setState(_cargar),
            constructor: (lista) => SeccionHorizontal<ElementoMedia>(
              titulo: Textos.recomendadas,
              elementos: lista,
              constructor: (e) => TarjetaMedia(elemento: e),
            ),
          ),
          CargaFutura<List<ElementoMedia>>(
            futuro: _mejorValoradas,
            constructor: (lista) => SeccionHorizontal<ElementoMedia>(
              titulo: Textos.masValoradas,
              elementos: lista,
              constructor: (e) => TarjetaMedia(elemento: e),
            ),
          ),
        ],
      ],
    );
  }
}
