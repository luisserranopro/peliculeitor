import 'package:flutter/material.dart';

import '../config.dart';
import '../data/listas_db.dart';
import '../models/modelos.dart';
import '../services/tmdb_service.dart';
import '../textos.dart';
import '../widgets/comunes.dart';
import '../widgets/tarjeta_media.dart';

enum _Filtro { todo, peliculas, series }

/// Sustituye a FavoritosFragment y añade la lista "Quiero ver".
/// Lee los ids guardados en SQLite y pide a la API los datos de cada uno.
class MisListasScreen extends StatefulWidget {
  const MisListasScreen({super.key});

  @override
  State<MisListasScreen> createState() => _MisListasScreenState();
}

class _MisListasScreenState extends State<MisListasScreen> {
  final _db = ListasDb.instancia;
  final _api = TmdbService.instancia;

  Lista _lista = Lista.porVer;
  _Filtro _filtro = _Filtro.todo;

  Map<Lista, List<EntradaLista>> _entradas = {};
  bool _cargando = true;
  bool _error = false;

  /// Datos ya descargados, para no volver a pedirlos a la API cada vez que
  /// cambia una lista. Clave: "p123" (película) o "s456" (serie).
  final Map<String, ElementoMedia> _cache = {};

  static String _clave(int id, bool esSerie) => '${esSerie ? 's' : 'p'}$id';

  @override
  void initState() {
    super.initState();
    _cargar();
    // Cualquier cambio en las listas (desde una ficha o desde aquí) recarga la
    // pantalla. Sustituye al onResume() del fragment original.
    _db.cambios.addListener(_cargar);
  }

  @override
  void dispose() {
    _db.cambios.removeListener(_cargar);
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final porVer = await _db.entradas(Lista.porVer);
      final favoritos = await _db.entradas(Lista.favoritos);

      // Se descargan a la vez solo las que no estaban ya en la caché
      final pendientes = <String, EntradaLista>{};
      for (final e in [...porVer, ...favoritos]) {
        final clave = _clave(e.id, e.esSerie);
        if (!_cache.containsKey(clave)) pendientes[clave] = e;
      }
      await Future.wait(pendientes.values.map(_descargar));

      if (!mounted) return;
      setState(() {
        _entradas = {Lista.porVer: porVer, Lista.favoritos: favoritos};
        _cargando = false;
        _error = false;
      });
    } catch (e) {
      debugPrint('Error al cargar las listas: $e');
      if (mounted) {
        setState(() {
          _cargando = false;
          _error = true;
        });
      }
    }
  }

  Future<void> _descargar(EntradaLista e) async {
    try {
      final elemento = e.esSerie
          ? (await _api.serie(e.id)).comoElemento
          : (await _api.pelicula(e.id)).comoElemento;
      _cache[_clave(e.id, e.esSerie)] = elemento;
    } catch (error) {
      // Si falla una, se sigue con las demás (el original tampoco se paraba)
      debugPrint('No se pudo descargar ${e.id}: $error');
    }
  }

  /// Elementos de la lista elegida que pasan el filtro.
  List<ElementoMedia> _visibles(Lista lista) {
    return (_entradas[lista] ?? const <EntradaLista>[])
        .where((e) => switch (_filtro) {
              _Filtro.todo => true,
              _Filtro.peliculas => !e.esSerie,
              _Filtro.series => e.esSerie,
            })
        .map((e) => _cache[_clave(e.id, e.esSerie)])
        .whereType<ElementoMedia>()
        .toList();
  }

  int _total(Lista lista) => _entradas[lista]?.length ?? 0;

  Future<void> _quitar(ElementoMedia e) async {
    final lista = _lista;
    await _db.quitar(lista, id: e.id, esSerie: e.esSerie);
    if (!mounted) return;
    final nombre = lista == Lista.porVer ? Textos.quieroVer : Textos.favoritas;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(lista == Lista.porVer
            ? '${Textos.yaLaHeVisto}: ${e.titulo}'
            : Textos.quitadaDe(nombre)),
        action: SnackBarAction(
          label: Textos.deshacer,
          onPressed: () => _db.agregar(lista, id: e.id, esSerie: e.esSerie),
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _cabecera()),
        ..._contenido(),
        const SliverToBoxAdapter(child: SizedBox(height: Medidas.huecoBarra)),
      ],
    );
  }

  Widget _cabecera() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Medidas.margen, 16, Medidas.margen, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Textos.misListas,
              style: const TextStyle(
                color: Colores.texto,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            // Selector de lista: Quiero ver / Favoritas
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<Lista>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colores.superficie,
                  foregroundColor: Colores.textoSecundario,
                  selectedBackgroundColor: Colores.acento,
                  selectedForegroundColor: Colores.fondo,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                segments: [
                  ButtonSegment(
                    value: Lista.porVer,
                    icon: const Icon(Icons.bookmark_rounded, size: 18),
                    label: Text('${Textos.quieroVer} (${_total(Lista.porVer)})'),
                  ),
                  ButtonSegment(
                    value: Lista.favoritos,
                    icon: const Icon(Icons.favorite_rounded, size: 18),
                    label: Text('${Textos.favoritas} (${_total(Lista.favoritos)})'),
                  ),
                ],
                selected: {_lista},
                onSelectionChanged: (s) => setState(() => _lista = s.first),
              ),
            ),
            const SizedBox(height: 12),
            // Filtro: Todo / Películas / Series
            Wrap(
              spacing: 8,
              children: [
                for (final f in _Filtro.values)
                  ChoiceChip(
                    label: Text(switch (f) {
                      _Filtro.todo => Textos.todo,
                      _Filtro.peliculas => Textos.peliculas,
                      _Filtro.series => Textos.series,
                    }),
                    selected: _filtro == f,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _filtro = f),
                    backgroundColor: Colores.superficie,
                    selectedColor: Colores.superficieAlta,
                    side: BorderSide(
                      color: _filtro == f ? Colores.acento : Colors.transparent,
                    ),
                    labelStyle: TextStyle(
                      color: _filtro == f ? Colores.acento : Colores.textoSecundario,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _contenido() {
    if (_cargando) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
          ),
        ),
      ];
    }
    if (_error) {
      return [
        SliverToBoxAdapter(
          child: MensajeError(reintentar: () {
            setState(() => _cargando = true);
            _cargar();
          }),
        ),
      ];
    }

    final elementos = _visibles(_lista);
    if (elementos.isEmpty) {
      final esPorVer = _lista == Lista.porVer;
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 56, 40, 0),
            child: Column(
              children: [
                Icon(
                  esPorVer ? Icons.bookmark_border_rounded : Icons.favorite_border_rounded,
                  size: 56,
                  color: Colores.superficieAlta,
                ),
                const SizedBox(height: 16),
                Text(
                  esPorVer ? Textos.vacioPorVer : Textos.vacioFavoritas,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colores.textoSecundario, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    final esPorVer = _lista == Lista.porVer;
    return [
      SliverList.builder(
        itemCount: elementos.length,
        itemBuilder: (_, i) {
          final e = elementos[i];
          return FilaMedia(
            key: ValueKey(_clave(e.id, e.esSerie)),
            elemento: e,
            accion: IconButton(
              tooltip: esPorVer ? Textos.yaLaHeVisto : Textos.quitarFavorita,
              onPressed: () => _quitar(e),
              icon: Icon(
                esPorVer ? Icons.check_circle_outline_rounded : Icons.favorite_rounded,
                color: esPorVer ? Colores.textoSecundario : Colores.favorito,
              ),
            ),
          );
        },
      ),
    ];
  }
}
