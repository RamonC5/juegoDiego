# Visibilidad de enemigos en el APK

El usuario informa de que no ve enemigos al jugar el APK en «1-1 Bosque Esmeralda». No se conoce todavía el identificador de su APK instalado ni su modelo de teléfono. No atribuir el caso a una versión antigua sin comprobarlo.

## Auditoría del paquete anterior

Los APK 0.4.1-ci.28 y 0.4.1-ci.29 contienen el script de enemigos, las dos texturas importadas y los datos de nueve patrullas. El recurso binario del nivel conserva los encuentros añadidos en x=1010 y x=7180. Esto demuestra inclusión en el paquete; no demuestra visibilidad en un dispositivo Android.

## Cambios de diagnóstico

- Referencias `preload` explícitas para Terrón y Moflete, conservando arte, dimensiones, físicas y posiciones.
- Primer enemigo señalado con «Enemigo · Terrón / Salta encima». Su arte de roca cubierta de musgo se parece al terreno; es una mejora de reconocimiento, no una causa confirmada del caso del teléfono.
- Versión de compilación visible al abrir Pausa, leída del `build-info.json` empaquetado; alternativa a la versión de proyecto en escritorio.
- Instalación del APK ARM64 real en emulador Android y movimiento mediante arrastre táctil. Capturas del inicio, acercamiento al primer enemigo y pausa, junto con logcat y checksum del APK instalado.
- Registro de arranque de depuración con el número de patrullas y sprites cargados. Este registro no sustituye la revisión visual.
- Comparación con 0.4.1-ci.29 mientras se conserve su artefacto en Actions. La caducidad de esa referencia no impide probar el APK actual.

## Validación

Pendiente de completar con el resultado de CI y la revisión de las capturas Android. La comprobación en el teléfono del usuario sigue pendiente. El recorrido de 45 segundos es una observación del usuario; no hay una nueva medición de duración.
