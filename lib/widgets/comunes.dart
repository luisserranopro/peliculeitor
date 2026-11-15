import 'package:flutter/material.dart';

import '../config.dart';
import '../textos.dart';

/// Imagen de red con imagen de "sin foto" si falta o falla. Sustituye a Picasso.
class ImagenRed extends StatelessWidget {
  final String? url;
  final String asetSinFoto;
  final BoxFit ajuste;
  final Alignment alineacion;

  const ImagenRed({
    super.key,
    required this.url,
    this.asetSinFoto = 'assets/images/sin_foto_pelicula.png',
    this.ajuste = BoxFit.cover,
    this.alineacion = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final sinFoto = Container(
      color: Colores.superficieAlta,
      padding: const EdgeInsets.all(12),
      child: Image.asset(asetSinFoto, fit: BoxFit.contain),
    );
    if (url == null) return sinFoto;
    return Image.network(
      url!,
      fit: ajuste,
      alignment: alineacion,
      errorBuilder: (_, __, ___) => sinFoto,
      // Aparece con un fundido en vez de "de golpe"
      frameBuilder: (context, child, frame, sincrono) {
        if (sincrono) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
    );
  }
}

/// Nota sobre 10 con una estrella, p. ej. "★ 7.8". Sustituye al RatingBar.
class NotaBadge extends StatelessWidget {
  final double nota;
  final bool compacta;

  const NotaBadge({super.key, required this.nota, this.compacta = false});

  @override
  Widget build(BuildContext context) {
    if (nota <= 0) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compacta ? 6 : 8, vertical: compacta ? 3 : 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: compacta ? 13 : 16, color: Colores.acento),
          const SizedBox(width: 3),
          Text(
            nota.toStringAsFixed(1),
            style: TextStyle(
              color: Colors.white,
              fontSize: compacta ? 11 : 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Póster con la nota encima y título y año debajo.
/// Sustituye a layout_movie_item_roundedcorners.xml + PeliculaAdapter/SerieAdapter.
class TarjetaPoster extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String? urlImagen;
  final double nota;
  final String asetSinFoto;
  final double ancho;
  final VoidCallback onTap;

  const TarjetaPoster({
    super.key,
    required this.titulo,
    required this.urlImagen,
    required this.onTap,
    this.subtitulo = '',
    this.nota = 0,
    this.asetSinFoto = 'assets/images/sin_foto_pelicula.png',
    this.ancho = 130,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ancho,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Medidas.radio),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImagenRed(url: urlImagen, asetSinFoto: asetSinFoto),
                    Positioned(top: 8, left: 8, child: NotaBadge(nota: nota, compacta: true)),
                    // Efecto de pulsación encima de la imagen
                    Material(
                      color: Colors.transparent,
                      child: InkWell(onTap: onTap),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colores.texto,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.25,
              ),
            ),
            if (subtitulo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colores.textoSecundario, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Foto redonda + nombre + personaje. Sustituye a layout_cast_item.xml + CircleImageView.
class TarjetaPersona extends StatelessWidget {
  final String nombre;
  final String? personaje;
  final String? urlFoto;
  final VoidCallback onTap;

  const TarjetaPersona({
    super.key,
    required this.nombre,
    required this.urlFoto,
    required this.onTap,
    this.personaje,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            ClipOval(
              child: SizedBox(
                width: 76,
                height: 76,
                child: urlFoto == null
                    ? Container(
                        color: Colores.superficieAlta,
                        child: const Icon(Icons.person_rounded,
                            size: 40, color: Colores.textoSecundario),
                      )
                    : ImagenRed(url: urlFoto, alineacion: Alignment.topCenter),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              nombre,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colores.texto, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            if (personaje != null && personaje!.isNotEmpty)
              Text(
                personaje!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colores.textoSecundario, fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }
}

/// Título de sección con el estilo común.
class TituloSeccion extends StatelessWidget {
  final String texto;
  final EdgeInsets padding;

  const TituloSeccion(
    this.texto, {
    super.key,
    this.padding = const EdgeInsets.fromLTRB(Medidas.margen, 28, Medidas.margen, 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        texto,
        style: const TextStyle(
          color: Colores.texto,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
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
    this.alto = 290,
  });

  @override
  Widget build(BuildContext context) {
    if (elementos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TituloSeccion(titulo),
        SizedBox(
          height: alto,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Medidas.margen),
            itemCount: elementos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
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
  final double altoCargando;

  const CargaFutura({
    super.key,
    required this.futuro,
    required this.constructor,
    this.reintentar,
    this.altoCargando = 120,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: futuro,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
            height: altoCargando,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
          );
        }
        if (snapshot.hasError) {
          debugPrint('Error: ${snapshot.error}');
          return MensajeError(reintentar: reintentar);
        }
        return constructor(snapshot.data as T);
      },
    );
  }
}

class MensajeError extends StatelessWidget {
  final VoidCallback? reintentar;

  const MensajeError({super.key, this.reintentar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colores.textoSecundario, size: 40),
          const SizedBox(height: 8),
          Text(Textos.errorCarga,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colores.textoSecundario)),
          if (reintentar != null)
            TextButton(onPressed: reintentar, child: Text(Textos.reintentar)),
        ],
      ),
    );
  }
}

/// Fila "Etiqueta   valor" de las fichas de detalle.
class FilaDato extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const FilaDato({super.key, required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    if (valor.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Medidas.margen, vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(etiqueta, style: const TextStyle(color: Colores.textoSecundario)),
          ),
          Expanded(
            child: Text(valor,
                style: const TextStyle(color: Colores.texto, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

/// Texto largo que se muestra recortado a unas líneas con "Leer más".
class TextoDesplegable extends StatefulWidget {
  final String texto;
  final int lineas;

  const TextoDesplegable(this.texto, {super.key, this.lineas = 4});

  @override
  State<TextoDesplegable> createState() => _TextoDesplegableState();
}

class _TextoDesplegableState extends State<TextoDesplegable> {
  bool _abierto = false;

  @override
  Widget build(BuildContext context) {
    if (widget.texto.trim().isEmpty) return const SizedBox.shrink();
    const estilo = TextStyle(color: Colores.texto, height: 1.5, fontSize: 14.5);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Medidas.margen),
      child: LayoutBuilder(builder: (context, restricciones) {
        // Se mide el texto para saber si hace falta el botón "Leer más"
        final medidor = TextPainter(
          text: TextSpan(text: widget.texto, style: estilo),
          maxLines: widget.lineas,
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: restricciones.maxWidth);
        final recortado = medidor.didExceedMaxLines;
        medidor.dispose();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              alignment: Alignment.topCenter,
              child: Text(
                widget.texto,
                style: estilo,
                maxLines: _abierto ? null : widget.lineas,
                overflow: _abierto ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ),
            if (recortado)
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: Colores.acento,
                ),
                onPressed: () => setState(() => _abierto = !_abierto),
                child: Text(_abierto ? Textos.leerMenos : Textos.leerMas),
              ),
          ],
        );
      }),
    );
  }
}
