# Verificación de entrada y mundos · 0.9.0

Base revisada: main, 48a1e5fd1ea71b862c82ce615225e208bf0f662d, 18-10-2026. Motor Godot 4.7.2 Compatibility. No se alteran los niveles ni los guardados de colección y resultados.

- `test_entrance.gd`: 84 comprobaciones correctas en ejecución real headless. Ocho mundos únicos, única ruta del bosque, IDs desconocidos, ocho poses, preferencia persistente, foco, toques reales mediante Input, siete bloqueos, entrada al nivel, ausencia de salto heredado incluso manteniendo la acción de teclado, pausa, vuelta y liberación de la escena.
- Ocho regresiones Python de preparación Android correctas.
- Captura Compatibility con Mesa llvmpipe: ocho viñetas, mapa móvil, isla bloqueada, mapa tablet y presentación con movimiento reducido, sin errores de script o renderizado. Revisión visual de legibilidad, proporciones, zonas táctiles y agarre de la cuerda; corrección del contraste del botón con foco.
- La ilustración de ocho islas es nueva; las poses y la vasija se reutilizan del repositorio. Las zonas de toque cubren cada isla completa. Los otros siete nombres son avances visuales editables y siguen sin niveles.

CI ejecuta las regresiones anteriores del bosque y las capturas; la prueba Android instala el APK ARM64 y recorre entrada, Jugar ahora, un mundo bloqueado y bosque antes de comprobar los gestos de juego. Su resultado corresponde al registro de Actions de cada compilación. Las pruebas en Android y Windows físicos siguen pendientes; la validación automática no acredita tacto ni rendimiento en el dispositivo del usuario.
