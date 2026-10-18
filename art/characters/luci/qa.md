# Revisión de Luci

PNG RGBA de 1254 × 1254, cuadrícula 2 × 2 con cuatro poses. Inspección visual: cuerpo completo, alas de apertura distinta, abdomen luminoso, coherencia de identidad. La transparencia bruta contiene ruido de alfa muy bajo en los márgenes, como otros recursos del proyecto; el shader existente lo elimina. El comprobador con margen bruto 4 falla esta propiedad; con margen 0 valida estructura, alfa y celdas no vacías. Los márgenes efectivos a alfa > 0,13 son 39, 31, 15 y 36 px.

Prueba de integración: compañero sin colisión, desbloqueo con tres fragmentos, activación/descanso, pausa, señal del secreto y retorno junto al jugador. La hoja se reproduce a 12 FPS con pivotes de ojo independientes. Ver capturas `preview_outfit_*.png` y `preview_wardrobe_*.png`, generadas por Compatibility.

Pendiente: tacto, rendimiento y accesibilidad en Android y tablet Windows físicos. El acompañamiento no acredita que todos los jugadores descubran el secreto sin ayuda.

