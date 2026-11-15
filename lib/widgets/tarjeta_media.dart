import 'package:flutter/material.dart';

import '../config.dart';
import '../models/modelos.dart';
import '../navegacion.dart';
import '../textos.dart';
import 'comunes.dart';

String _asetSinFoto(ElementoMedia e) =>
    e.esSerie ? 'assets/images/sin_foto_serie.png' : 'assets/images/sin_foto_pelicula.png';

/// Tarjeta de película o serie que abre su ficha al pulsarla.
class TarjetaMedia extends StatelessWidget {
  final ElementoMedia elemento;
  final double ancho;

  /// Texto bajo el título. Si es null se muestra el año.
  final String? subtitulo;

  const TarjetaMedia({super.key, required this.elemento, this.ancho = 130, this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return TarjetaPoster(
      titulo: elemento.titulo,
      subtitulo: subtitulo ?? elemento.anio,
      urlImagen: Config.imagen(elemento.poster),
      nota: elemento.votoMedio,
      ancho: ancho,
      asetSinFoto: _asetSinFoto(elemento),
      onTap: () => abrirDetalle(context, elemento),
    );
  }
}

/// Tarjeta grande y horizontal del carrusel de destacadas: imagen de fondo,
/// degradado oscuro y título encima.
class TarjetaDestacada extends StatelessWidget {
  final ElementoMedia elemento;

  const TarjetaDestacada({super.key, required this.elemento});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Medidas.radio + 4),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ImagenRed(
            url: Config.imagenFondo(elemento.fondo) ?? Config.imagen(elemento.poster),
            asetSinFoto: _asetSinFoto(elemento),
          ),
          // Degradado para que el texto se lea sobre cualquier imagen
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xE6000000)],
                stops: [0.35, 1],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NotaBadge(nota: elemento.votoMedio),
                const SizedBox(height: 8),
                Text(
                  elemento.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                if (elemento.anio.isNotEmpty)
                  Text(
                    elemento.anio,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(onTap: () => abrirDetalle(context, elemento)),
          ),
        ],
      ),
    );
  }
}

/// Carrusel de tarjetas destacadas con indicador de página.
class CarruselDestacadas extends StatefulWidget {
  final List<ElementoMedia> elementos;

  const CarruselDestacadas({super.key, required this.elementos});

  @override
  State<CarruselDestacadas> createState() => _CarruselDestacadasState();
}

class _CarruselDestacadasState extends State<CarruselDestacadas> {
  final _controlador = PageController(viewportFraction: 0.88);
  int _pagina = 0;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.elementos.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _controlador,
            itemCount: widget.elementos.length,
            onPageChanged: (p) => setState(() => _pagina = p),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: TarjetaDestacada(elemento: widget.elementos[i]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.elementos.length, (i) {
            final activo = i == _pagina;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: activo ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: activo ? Colores.acento : Colores.superficieAlta,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Fila de lista con póster pequeño, título, tipo, año y nota.
/// Se usa en los resultados de búsqueda y en Mis listas.
class FilaMedia extends StatelessWidget {
  final ElementoMedia elemento;
  final Widget? accion;

  const FilaMedia({super.key, required this.elemento, this.accion});

  @override
  Widget build(BuildContext context) {
    final detalles = [
      elemento.esSerie ? Textos.serie : Textos.pelicula,
      if (elemento.anio.isNotEmpty) elemento.anio,
    ].join(' · ');

    return InkWell(
      onTap: () => abrirDetalle(context, elemento),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Medidas.margen, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 60,
                height: 90,
                child: ImagenRed(
                  url: Config.imagen(elemento.poster),
                  asetSinFoto: _asetSinFoto(elemento),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    elemento.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colores.texto,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(detalles,
                      style: const TextStyle(color: Colores.textoSecundario, fontSize: 13)),
                  if (elemento.votoMedio > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Colores.acento),
                        const SizedBox(width: 3),
                        Text(
                          elemento.votoMedio.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Colores.texto, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (accion != null) accion!,
          ],
        ),
      ),
    );
  }
}
