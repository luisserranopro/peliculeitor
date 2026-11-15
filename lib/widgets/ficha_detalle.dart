import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../textos.dart';
import 'comunes.dart';

/// Esqueleto común de las fichas de película, serie y actor
/// (activity_vista_media.xml, activity_vista_media_serie.xml, activity_vista_actor.xml):
/// imagen grande arriba, botón de volver y, opcionalmente, botón de favorito.
class FichaDetalle extends StatelessWidget {
  final String? urlImagen;
  final String asetSinFoto;
  final Widget? accion;
  final List<Widget> contenido;

  const FichaDetalle({
    super.key,
    required this.urlImagen,
    required this.contenido,
    this.asetSinFoto = 'assets/images/sin_foto_pelicula.png',
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 460,
            backgroundColor: Colores.fondoOscuro,
            foregroundColor: Colores.texto,
            // La flecha de volver la pone Flutter sola (antes, buttonBack + finish()).
            actions: [if (accion != null) accion!],
            flexibleSpace: FlexibleSpaceBar(
              background: ImagenRed(url: urlImagen, asetSinFoto: asetSinFoto),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: contenido,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Título grande + estrellas.
class TituloFicha extends StatelessWidget {
  final String titulo;
  final double? valoracion;

  const TituloFicha({super.key, required this.titulo, this.valoracion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colores.texto,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (valoracion != null) ...[
            const SizedBox(height: 8),
            Estrellas(valor: valoracion!, tamano: 24),
          ],
        ],
      ),
    );
  }
}

/// Párrafo de texto largo (sinopsis o biografía).
class TextoLargo extends StatelessWidget {
  final String texto;

  const TextoLargo(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    if (texto.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(texto, style: const TextStyle(color: Colores.texto, height: 1.4)),
    );
  }
}

/// Corazón de favorito. Sustituye al CheckBox con checkbox_selector.xml y
/// su OnCheckedChangeListener.
class BotonFavorito extends StatefulWidget {
  final Future<bool> Function() comprobar;
  final Future<void> Function(bool favorito) cambiar;

  const BotonFavorito({super.key, required this.comprobar, required this.cambiar});

  @override
  State<BotonFavorito> createState() => _BotonFavoritoState();
}

class _BotonFavoritoState extends State<BotonFavorito> {
  bool? _favorito; // null mientras se consulta la base de datos

  @override
  void initState() {
    super.initState();
    widget.comprobar().then((valor) {
      if (mounted) setState(() => _favorito = valor);
    });
  }

  Future<void> _alternar() async {
    final nuevo = !(_favorito ?? false);
    setState(() => _favorito = nuevo);
    await widget.cambiar(nuevo);
  }

  @override
  Widget build(BuildContext context) {
    final fav = _favorito ?? false;
    return IconButton(
      tooltip: Textos.favoritos,
      onPressed: _favorito == null ? null : _alternar,
      icon: Icon(
        fav ? Icons.favorite : Icons.favorite_border,
        color: fav ? Colors.redAccent : Colores.texto,
        size: 30,
      ),
    );
  }
}

/// Botón "VER TRÁILER": solo aparece si hay tráiler y lo abre en YouTube
/// (antes, Intent.ACTION_VIEW con la URL).
class BotonTrailer extends StatelessWidget {
  final Future<String?> urlTrailer;

  const BotonTrailer({super.key, required this.urlTrailer});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: urlTrailer,
      builder: (context, snapshot) {
        final url = snapshot.data;
        if (url == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colores.boton),
            icon: const Icon(Icons.play_arrow),
            label: Text(Textos.verTrailer),
            onPressed: () =>
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
          ),
        );
      },
    );
  }
}
