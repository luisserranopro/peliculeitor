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
  static const _numDestacadas = 6;

  final _api = TmdbService.instancia;
  final _controladorBusqueda = TextEditingController();

  late Future<List<ElementoMedia>> _populares;
  late Future<List<ElementoMedia>> _mejorValoradas;

  bool _buscando = false;
  bool _cargandoBusqueda = false;
  List<ElementoMedia> _resultados = [];
  Timer? _espera;
  String _ultimaBusqueda = '';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    if (widget.esSeries) {
      _populares = _api.seriesRecomendadas().then(_series);
      _mejorValoradas = _api.seriesMejorValoradas().then(_series);
    } else {
      _populares = _api.peliculasRecomendadas().then(_peliculas);
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
      // Con 2 letras o menos se vuelven a mostrar las listas normales.
      setState(() {
        _buscando = false;
        _cargandoBusqueda = false;
        _resultados = [];
        _ultimaBusqueda = '';
      });
      return;
    }
    setState(() {
      _buscando = true;
      _cargandoBusqueda = true;
    });
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
      setState(() {
        _resultados = resultados;
        _cargandoBusqueda = false;
      });
    } catch (e) {
      debugPrint('Error en la búsqueda: $e');
      if (mounted && texto == _ultimaBusqueda) setState(() => _cargandoBusqueda = false);
    }
  }

  void _limpiarBusqueda() {
    _controladorBusqueda.clear();
    _alCambiarTexto('');
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _espera?.cancel();
    _controladorBusqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      // Al deslizar la lista se oculta el teclado
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(child: _cabecera(context)),
        if (_buscando) ..._resultadosBusqueda() else ..._secciones(),
        const SliverToBoxAdapter(child: SizedBox(height: Medidas.huecoBarra)),
      ],
    );
  }

  Widget _cabecera(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Medidas.margen, 16, Medidas.margen, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Textos.saludo,
              style: const TextStyle(color: Colores.textoSecundario, fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              Textos.queVer,
              style: const TextStyle(
                color: Colores.texto,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _controladorBusqueda,
              onChanged: _alCambiarTexto,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: Colores.texto),
              cursorColor: Colores.acento,
              decoration: InputDecoration(
                hintText: widget.esSeries ? Textos.buscarSeries : Textos.buscarPeliculas,
                hintStyle: const TextStyle(color: Colores.textoSecundario),
                prefixIcon: const Icon(Icons.search_rounded, color: Colores.textoSecundario),
                suffixIcon: _controladorBusqueda.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colores.textoSecundario),
                        onPressed: _limpiarBusqueda,
                      ),
                filled: true,
                fillColor: Colores.superficie,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Medidas.radio),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Medidas.radio),
                  borderSide: const BorderSide(color: Colores.acento, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Equivale a poner visible recycler_view_busqueda.
  List<Widget> _resultadosBusqueda() {
    if (_cargandoBusqueda) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
          ),
        ),
      ];
    }
    if (_resultados.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Text(Textos.sinResultados,
                  style: const TextStyle(color: Colores.textoSecundario)),
            ),
          ),
        ),
      ];
    }
    return [
      SliverList.builder(
        itemCount: _resultados.length,
        itemBuilder: (_, i) => FilaMedia(elemento: _resultados[i]),
      ),
    ];
  }

  List<Widget> _secciones() {
    return [
      SliverToBoxAdapter(
        child: CargaFutura<List<ElementoMedia>>(
          futuro: _populares,
          altoCargando: 260,
          reintentar: () => setState(_cargar),
          constructor: (lista) {
            final destacadas = lista.take(_numDestacadas).toList();
            final resto = lista.skip(_numDestacadas).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TituloSeccion(Textos.destacadas,
                    padding: const EdgeInsets.fromLTRB(Medidas.margen, 16, Medidas.margen, 12)),
                CarruselDestacadas(elementos: destacadas),
                SeccionHorizontal<ElementoMedia>(
                  titulo: Textos.populares,
                  elementos: resto,
                  constructor: (e) => TarjetaMedia(elemento: e),
                ),
              ],
            );
          },
        ),
      ),
      SliverToBoxAdapter(
        child: CargaFutura<List<ElementoMedia>>(
          futuro: _mejorValoradas,
          constructor: (lista) => SeccionHorizontal<ElementoMedia>(
            titulo: Textos.masValoradas,
            elementos: lista,
            constructor: (e) => TarjetaMedia(elemento: e),
          ),
        ),
      ),
    ];
  }
}
