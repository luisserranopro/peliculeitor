import 'dart:ui';

import 'package:flutter/material.dart';

import '../config.dart';

/// Un botón de la barra inferior.
class DestinoBarra {
  final IconData icono;
  final IconData iconoActivo;
  final String etiqueta;

  const DestinoBarra({
    required this.icono,
    required this.iconoActivo,
    required this.etiqueta,
  });
}

/// Barra inferior flotante con fondo translúcido y una "píldora" que marca
/// la pestaña activa. Sustituye a la BottomNavigationView del original.
class BarraNavegacion extends StatelessWidget {
  final List<DestinoBarra> destinos;
  final int seleccionado;
  final ValueChanged<int> alSeleccionar;

  const BarraNavegacion({
    super.key,
    required this.destinos,
    required this.seleccionado,
    required this.alSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          // Desenfoca lo que pasa por debajo de la barra (efecto cristal)
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colores.superficie.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                for (var i = 0; i < destinos.length; i++)
                  // La pestaña activa ocupa el doble para que quepa su etiqueta
                  Expanded(
                    flex: i == seleccionado ? 2 : 1,
                    child: _BotonBarra(
                      destino: destinos[i],
                      activo: i == seleccionado,
                      onTap: () => alSeleccionar(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonBarra extends StatelessWidget {
  final DestinoBarra destino;
  final bool activo;
  final VoidCallback onTap;

  const _BotonBarra({required this.destino, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: activo,
      button: true,
      label: destino.etiqueta,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(horizontal: activo ? 16 : 10, vertical: 10),
            decoration: BoxDecoration(
              color: activo ? Colores.acento : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  activo ? destino.iconoActivo : destino.icono,
                  size: 22,
                  color: activo ? Colores.fondo : Colores.textoSecundario,
                ),
                // La etiqueta solo se ve en la pestaña activa
                Flexible(
                  child: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: activo
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            destino.etiqueta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colores.fondo,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
