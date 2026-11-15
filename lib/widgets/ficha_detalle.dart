import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../data/listas_db.dart';
import '../models/modelos.dart';
import '../textos.dart';
import 'comunes.dart';

/// Esqueleto común de las fichas de película, serie y actor
/// (activity_vista_media.xml, activity_vista_media_serie.xml, activity_vista_actor.xml):
/// imagen de fondo grande que se funde con la pantalla, póster, título,
/// datos principales, géneros, botones de acción y el resto del contenido.
class FichaDetalle extends StatelessWidget {
  final String? urlFondo;
  final String? urlPoster;
  final String asetSinFoto;
  final Alignment alineacionFondo;
  final double altoCabecera;
  final String titulo;
  final List<String> datos; // p. ej. ["2019", "2 h 19 min"]
  final double nota;
  final int votos;
  final List<String> etiquetas; // géneros
  final Widget? acciones;
  final List<Widget> contenido;

  const FichaDetalle({
    super.key,
    required this.titulo,
    required this.contenido,
    this.urlFondo,
    this.urlPoster,
    this.asetSinFoto = 'assets/images/sin_foto_pelicula.png',
    this.alineacionFondo = Alignment.center,
    this.altoCabecera = 280,
    this.datos = const [],
    this.nota = 0,
    this.votos = 0,
    this.etiquetas = const [],
    this.acciones,
  });

  @override
  Widget build(BuildContext context) {
    final datosVisibles = datos.where((d) => d.isNotEmpty).join('  ·  ');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: altoCabecera,
            backgroundColor: Colores.fondo,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            // Botón de volver redondo y semitransparente (antes, buttonBack + finish())
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.black45),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ImagenRed(
                    url: urlFondo ?? urlPoster,
                    asetSinFoto: asetSinFoto,
                    alineacion: alineacionFondo,
                  ),
                  // La imagen se funde con el color de fondo por abajo
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x66000000), Colors.transparent, Colores.fondo],
                        stops: [0, 0.4, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(Medidas.margen, 4, Medidas.margen, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (urlPoster != null) ...[
                        _PosterSombra(url: urlPoster, asetSinFoto: asetSinFoto),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titulo,
                              style: const TextStyle(
                                color: Colores.texto,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                            if (datosVisibles.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(datosVisibles,
                                  style: const TextStyle(color: Colores.textoSecundario)),
                            ],
                            if (nota > 0) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: Colores.acento, size: 22),
                                  const SizedBox(width: 4),
                                  Text(
                                    nota.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colores.texto,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Text(' /10',
                                      style: TextStyle(color: Colores.textoSecundario)),
                                  if (votos > 0)
                                    Flexible(
                                      child: Text(
                                        '   ${Textos.votos(votos)}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colores.textoSecundario, fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (etiquetas.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Medidas.margen, 18, Medidas.margen, 0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: etiquetas.map((e) => _Etiqueta(e)).toList(),
                    ),
                  ),
                if (acciones != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Medidas.margen, 20, Medidas.margen, 0),
                    child: acciones,
                  ),
                ...contenido,
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterSombra extends StatelessWidget {
  final String? url;
  final String asetSinFoto;

  const _PosterSombra({required this.url, required this.asetSinFoto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ImagenRed(url: url, asetSinFoto: asetSinFoto),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;

  const _Etiqueta(this.texto);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colores.superficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colores.superficieAlta),
      ),
      child: Text(texto, style: const TextStyle(color: Colores.texto, fontSize: 12.5)),
    );
  }
}

/// Fila de botones de acción de una película o serie:
/// Tráiler (si hay) · Favorita · Quiero ver.
class AccionesMedia extends StatelessWidget {
  final ElementoMedia elemento;
  final Future<String?> urlTrailer;

  const AccionesMedia({super.key, required this.elemento, required this.urlTrailer});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Un FutureBuilder puede devolver un Expanded porque no dibuja nada
        // propio entre el Row y el Expanded.
        FutureBuilder<String?>(
          future: urlTrailer,
          builder: (context, snapshot) {
            final url = snapshot.data;
            if (url == null) return const SizedBox.shrink();
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _BotonAccion(
                  icono: Icons.play_arrow_rounded,
                  etiqueta: Textos.verTrailer,
                  destacado: true,
                  // Antes, Intent.ACTION_VIEW con la URL de YouTube
                  onTap: () =>
                      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
                ),
              ),
            );
          },
        ),
        Expanded(child: BotonLista(elemento: elemento, lista: Lista.favoritos)),
        const SizedBox(width: 10),
        Expanded(child: BotonLista(elemento: elemento, lista: Lista.porVer)),
      ],
    );
  }
}

/// Botón que añade o quita la película/serie de una lista.
/// Sustituye al CheckBox de favorito (checkbox_selector.xml + OnCheckedChangeListener).
class BotonLista extends StatefulWidget {
  final ElementoMedia elemento;
  final Lista lista;

  const BotonLista({super.key, required this.elemento, required this.lista});

  @override
  State<BotonLista> createState() => _BotonListaState();
}

class _BotonListaState extends State<BotonLista> {
  final _db = ListasDb.instancia;
  bool? _incluido; // null mientras se consulta la base de datos

  bool get _esFavoritos => widget.lista == Lista.favoritos;
  String get _nombreLista => _esFavoritos ? Textos.favoritas : Textos.quieroVer;

  @override
  void initState() {
    super.initState();
    _comprobar();
    // Si se cambia desde otra pantalla (p. ej. Mis listas), se actualiza solo
    _db.cambios.addListener(_comprobar);
  }

  @override
  void dispose() {
    _db.cambios.removeListener(_comprobar);
    super.dispose();
  }

  Future<void> _comprobar() async {
    final valor = await _db.contiene(widget.lista,
        id: widget.elemento.id, esSerie: widget.elemento.esSerie);
    if (mounted) setState(() => _incluido = valor);
  }

  Future<void> _alternar() async {
    final nuevo = !(_incluido ?? false);
    setState(() => _incluido = nuevo);
    final e = widget.elemento;
    if (nuevo) {
      await _db.agregar(widget.lista, id: e.id, esSerie: e.esSerie);
    } else {
      await _db.quitar(widget.lista, id: e.id, esSerie: e.esSerie);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(nuevo ? Textos.anadidaA(_nombreLista) : Textos.quitadaDe(_nombreLista)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final activo = _incluido ?? false;
    final IconData icono;
    if (_esFavoritos) {
      icono = activo ? Icons.favorite_rounded : Icons.favorite_border_rounded;
    } else {
      icono = activo ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined;
    }
    return _BotonAccion(
      icono: icono,
      etiqueta: _esFavoritos ? Textos.favorito : Textos.quieroVer,
      activo: activo,
      colorActivo: _esFavoritos ? Colores.favorito : Colores.acento,
      onTap: _incluido == null ? null : _alternar,
    );
  }
}

/// Botón cuadrado con icono y texto debajo.
class _BotonAccion extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final VoidCallback? onTap;
  final bool destacado;
  final bool activo;
  final Color colorActivo;

  const _BotonAccion({
    required this.icono,
    required this.etiqueta,
    required this.onTap,
    this.destacado = false,
    this.activo = false,
    this.colorActivo = Colores.acento,
  });

  @override
  Widget build(BuildContext context) {
    final Color fondo;
    final Color color;
    if (destacado) {
      fondo = Colores.acento;
      color = Colores.fondo;
    } else if (activo) {
      fondo = colorActivo.withValues(alpha: 0.16);
      color = colorActivo;
    } else {
      fondo = Colores.superficie;
      color = Colores.texto;
    }

    return Semantics(
      button: true,
      toggled: destacado ? null : activo,
      child: Material(
        color: fondo,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: activo && !destacado ? colorActivo.withValues(alpha: 0.5) : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icono, color: color, size: 24),
                const SizedBox(height: 4),
                Text(
                  etiqueta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pantalla que se muestra mientras llega la ficha (o si falla la carga).
class FichaCargando extends StatelessWidget {
  final Future<Object?> futuro;
  final VoidCallback reintentar;

  const FichaCargando({super.key, required this.futuro, required this.reintentar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CargaFutura<Object?>(
        futuro: futuro,
        altoCargando: 300,
        reintentar: reintentar,
        constructor: (_) => const SizedBox.shrink(),
      ),
    );
  }
}

/// "135" minutos -> "2 h 15 min".
String formatoDuracion(int? minutos) {
  if (minutos == null || minutos <= 0) return '';
  final h = minutos ~/ 60;
  final m = minutos % 60;
  if (h == 0) return '$m min';
  return m == 0 ? '$h h' : '$h h $m min';
}
