import 'package:flutter/material.dart';

import '../config.dart';
import '../models/modelos.dart';
import '../navegacion.dart';
import 'comunes.dart';

/// Tarjeta de película o serie que abre su ficha al pulsarla.
class TarjetaMedia extends StatelessWidget {
  final ElementoMedia elemento;

  /// Se ejecuta al volver de la ficha (lo usa Favoritos para recargar).
  final VoidCallback? alVolver;

  const TarjetaMedia({super.key, required this.elemento, this.alVolver});

  @override
  Widget build(BuildContext context) {
    return TarjetaPoster(
      titulo: elemento.titulo,
      urlImagen: Config.imagen(elemento.poster),
      valoracion: elemento.valoracion,
      asetSinFoto: elemento.esSerie
          ? 'assets/images/sin_foto_serie.png'
          : 'assets/images/sin_foto_pelicula.png',
      onTap: () async {
        await abrirDetalle(context, elemento);
        alVolver?.call();
      },
    );
  }
}

/// Fila de resultado de búsqueda. Sustituye a find_item_layout.xml +
/// BusquedaPeliculaAdapter / BusquedaSerieAdapter.
class FilaBusqueda extends StatelessWidget {
  final ElementoMedia elemento;

  const FilaBusqueda({super.key, required this.elemento});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => abrirDetalle(context, elemento),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 50,
          height: 70,
          child: ImagenRed(
            url: Config.imagen(elemento.poster),
            asetSinFoto: elemento.esSerie
                ? 'assets/images/sin_foto_serie.png'
                : 'assets/images/sin_foto_pelicula.png',
          ),
        ),
      ),
      title: Text(elemento.titulo, style: const TextStyle(color: Colores.texto)),
      subtitle: Estrellas(valor: elemento.valoracion, tamano: 14),
    );
  }
}
