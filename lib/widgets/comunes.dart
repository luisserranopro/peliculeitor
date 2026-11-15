import 'package:flutter/material.dart';

import '../config.dart';
import '../textos.dart';

/// Imagen de red con imagen de "sin foto" si falta o falla. Sustituye a Picasso.
class ImagenRed extends StatelessWidget {
  final String? url;
  final String asetSinFoto;
  final BoxFit ajuste;

  const ImagenRed({
    super.key,
    required this.url,
    this.asetSinFoto = 'assets/images/sin_foto_pelicula.png',
    this.ajuste = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final sinFoto = Container(
      color: Colores.fondoOscuro,
      child: Image.asset(asetSinFoto, fit: BoxFit.contain),
    );
    if (url == null) return sinFoto;
    return Image.network(
      url!,
      fit: ajuste,
      errorBuilder: (_, __, ___) => sinFoto,
      loadingBuilder: (context, child, progreso) => progreso == null
          ? child
          : const ColoredBox(
              color: Colores.fondoOscuro,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
    );
  }
}

/// Sustituye al RatingBar: 5 estrellas con medias estrellas (stepSize 0.5).
class Estrellas extends StatelessWidget {
  final double valor; // de 0 a 5
  final double tamano;

  const Estrellas({super.key, required this.valor, this.tamano = 16});

  @override
  Widget build(BuildContext context) {
    final redondeado = (valor * 2).round() / 2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final IconData icono;
        if (redondeado >= i + 1) {
          icono = Icons.star;
        } else if (redondeado >= i + 0.5) {
          icono = Icons.star_half;
        } else {
          icono = Icons.star_border;
        }
        return Icon(icono, size: tamano, color: Colores.estrellas);
      }),
    );
  }
}

/// Tarjeta de póster con título y estrellas.
/// Sustituye a layout_movie_item_roundedcorners.xml + PeliculaAdapter/SerieAdapter.
class TarjetaPoster extends StatelessWidget {
  final String titulo;
  final String? urlImagen;
  final double? valoracion;
  final String asetSinFoto;
  final VoidCallback onTap;

  const TarjetaPoster({
    super.key,
    required this.titulo,
    required this.urlImagen,
    required this.onTap,
    this.valoracion,
    this.asetSinFoto = 'assets/images/sin_foto_pelicula.png',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 140,
                height: 200,
                child: ImagenRed(url: urlImagen, asetSinFoto: asetSinFoto),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              titulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colores.texto, fontWeight: FontWeight.w600),
            ),
            if (valoracion != null) ...[
              const SizedBox(height: 4),
              Estrellas(valor: valoracion!, tamano: 14),
            ],
          ],
        ),
      ),
    );
  }
}

/// Foto redonda + nombre. Sustituye a layout_cast_item.xml + CircleImageView.
class TarjetaPersona extends StatelessWidget {
  final String nombre;
  final String? urlFoto;
  final VoidCallback onTap;

  const TarjetaPersona({
    super.key,
    required this.nombre,
    required this.urlFoto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(55),
        child: Column(
          children: [
            ClipOval(
              child: SizedBox(
                width: 96,
                height: 96,
                child: urlFoto == null
                    ? Container(
                        color: Colores.fondoOscuro,
                        child: const Icon(Icons.person, size: 56, color: Colores.texto),
                      )
                    : ImagenRed(url: urlFoto),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              nombre,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colores.texto),
            ),
          ],
        ),
      ),
    );
  }
}

/// Título + lista horizontal. Sustituye a cada TextView + RecyclerView horizontal
/// (LinearLayoutManager.HORIZONTAL + adaptador).
class SeccionHorizontal<T> extends StatelessWidget {
  final String titulo;
  final List<T> elementos;
  final double alto;
  final Widget Function(T elemento) constructor;

  const SeccionHorizontal({
    super.key,
    required this.titulo,
    required this.elementos,
    required this.constructor,
    this.alto = 270,
  });

  @override
  Widget build(BuildContext context) {
    if (elementos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(
            titulo,
            style: const TextStyle(
              color: Colores.texto,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: alto,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: elementos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => constructor(elementos[i]),
          ),
        ),
      ],
    );
  }
}

/// Muestra un indicador mientras carga un Future, un error con botón de
/// reintentar si falla, y el contenido cuando llega.
/// Sustituye al ProgressBar + callbacks onResponse/onFailure.
class CargaFutura<T> extends StatelessWidget {
  final Future<T> futuro;
  final Widget Function(T datos) constructor;
  final VoidCallback? reintentar;

  const CargaFutura({
    super.key,
    required this.futuro,
    required this.constructor,
    this.reintentar,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: futuro,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          debugPrint('Error: ${snapshot.error}');
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Text(Textos.errorCarga, style: const TextStyle(color: Colores.texto)),
                if (reintentar != null)
                  TextButton(onPressed: reintentar, child: Text(Textos.reintentar)),
              ],
            ),
          );
        }
        return constructor(snapshot.data as T);
      },
    );
  }
}

/// Fila "Etiqueta: valor" de las fichas de detalle.
class FilaDato extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const FilaDato({super.key, required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    if (valor.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              etiqueta,
              style: const TextStyle(color: Colores.busqueda, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(valor, style: const TextStyle(color: Colores.texto))),
        ],
      ),
    );
  }
}
