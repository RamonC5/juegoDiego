# Visibilidad de enemigos en el APK

El usuario informa de que no ve enemigos al jugar el APK en «1-1 Bosque Esmeralda». No se conoce todavía el identificador de su APK instalado ni su modelo de teléfono. No atribuir el caso a una versión antigua sin comprobarlo.

## Auditoría del paquete anterior

Los APK 0.4.1-ci.28 y 0.4.1-ci.29 contienen el script de enemigos, las dos texturas importadas y los datos de nueve patrullas. El recurso binario del nivel conserva los encuentros añadidos en x=1010 y x=7180. Esto demuestra inclusión en el paquete; no demuestra visibilidad en un dispositivo Android.

## Cambios de diagnóstico

- Fallo reproducido en Android: `ForestStage.start` intenta leer `enemy_kinds[0]`, pero el `PackedStringArray` se ha guardado vacío en el recurso binario del APK. La excepción interrumpe la creación de enemigos y la interfaz del bosque continúa. Los nombres «terron» y «moflete» tampoco aparecen en ese recurso binario, aunque sí hay nueve posiciones. Se sustituye por `Array[String]` tanto en el contrato como en el `.tres` y se comprueba el recurso extraído del APK.
- Referencias `preload` explícitas para Terrón y Moflete, conservando arte, dimensiones, físicas y posiciones.
- Primer enemigo señalado con «Enemigo · Terrón / Salta encima». Su arte de roca cubierta de musgo se parece al terreno; es una mejora de reconocimiento, no una causa confirmada del caso del teléfono.
- Versión de compilación visible al abrir Pausa, leída del `build-info.json` empaquetado; alternativa a la versión de proyecto en escritorio.
- Instalación del APK ARM64 real en emulador Android y movimiento mediante arrastre táctil. Capturas del inicio, acercamiento al primer enemigo y pausa, junto con logcat y checksum del APK instalado.
- Registro de arranque de depuración con el número de patrullas y sprites cargados. Este registro no sustituye la revisión visual.
- Comparación opcional en ejecución manual con 0.4.1-ci.29 mientras se conserve su artefacto en Actions. La caducidad de esa referencia no impide probar el APK actual.

## Validación

El código de juego de `9b400a3bc2d97102489990f164d041dd93e6b767` supera 294 comprobaciones: 88 del protagonista, 63 de objetos, 61 del bosque, 55 de puentes y 27 de plataformas móviles. La exportación y la firma Android son correctas.

APK de diagnóstico: **0.4.2-ci.35**, código Android **1035**, paquete `com.ramonc5.saltoheroes`, ARM64. SHA-256: `859fe7b1ea6bd0d37ec8e2d8b5bcc0d312b0173326a79e1f0c56092987d5057b`. Reproduce el fallo; no distribuir como solución. El checksum coincide con el artefacto de Actions y los scripts compilados difieren de 0.4.1.

[Diagnóstico que reproduce el fallo](https://github.com/RamonC5/juegoDiego/actions/runs/39013148592). Pendiente de validar el APK corregido y revisar sus capturas.

La comprobación en el teléfono del usuario sigue pendiente. El recorrido de 45 segundos es una observación del usuario; no hay una nueva medición de duración.
