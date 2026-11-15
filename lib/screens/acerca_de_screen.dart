import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../textos.dart';

/// Pantalla "Acerca de" con la atribución que exige TheMovieDB
/// (aviso + logo oficial en una sección de créditos), la política de
/// privacidad y las licencias de los paquetes que usa la app.
class AcercaDeScreen extends StatelessWidget {
  const AcercaDeScreen({super.key});

  void _abrir(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final traduccion = Textos.avisoTmdbTraducido;

    return Scaffold(
      appBar: AppBar(title: Text(Textos.acercaDe)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Medidas.margen, 8, Medidas.margen, 40),
        children: [
          // Nuestro logo, más grande que el de TMDB (lo piden sus condiciones)
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 96,
              height: 96,
              semanticLabel: 'Peliculeitor',
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: 'Pelicul'),
                TextSpan(text: 'eitor', style: TextStyle(color: Colores.acento)),
              ]),
              style: TextStyle(color: Colores.texto, fontSize: 28, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            Textos.descripcionApp,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colores.textoSecundario, height: 1.5),
          ),
          const SizedBox(height: 32),

          // ---------- Atribución a TheMovieDB ----------
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colores.superficie,
              borderRadius: BorderRadius.circular(Medidas.radio),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Textos.datos,
                  style: const TextStyle(
                    color: Colores.texto,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                // Logo oficial de TMDB. Hay que descargarlo de su web (ver README)
                // y guardarlo como assets/images/tmdb_logo.png. Si falta, no se
                // muestra nada en su lugar y la app sigue funcionando.
                Image.asset(
                  'assets/images/tmdb_logo.png',
                  height: 28,
                  semanticLabel: 'TMDB',
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),
                const Text(
                  Textos.avisoTmdb,
                  style: TextStyle(color: Colores.texto, height: 1.45),
                ),
                if (traduccion != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    traduccion,
                    style: const TextStyle(color: Colores.textoSecundario, height: 1.45),
                  ),
                ],
                const SizedBox(height: 8),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: Colores.acento,
                  ),
                  onPressed: () => _abrir(Config.urlTmdb),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text(Textos.visitarTmdb),
                ),
                const SizedBox(height: 4),
                Text(
                  Textos.notaTrailers,
                  style: const TextStyle(color: Colores.textoSecundario, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---------- Privacidad y licencias ----------
          Material(
            color: Colores.superficie,
            borderRadius: BorderRadius.circular(Medidas.radio),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: Colores.textoSecundario),
                  title: Text(Textos.privacidad, style: const TextStyle(color: Colores.texto)),
                  trailing: const Icon(Icons.open_in_new_rounded,
                      size: 18, color: Colores.textoSecundario),
                  onTap: () => _abrir(Config.urlPrivacidad),
                ),
                const Divider(height: 1, color: Colores.superficieAlta),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: Colores.textoSecundario),
                  title: Text(Textos.licencias, style: const TextStyle(color: Colores.texto)),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colores.textoSecundario),
                  // Pantalla de licencias que trae Flutter: lista todos los paquetes
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'Peliculeitor',
                    applicationIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset('assets/images/logo.png', width: 64, height: 64),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
