# Troncos viajeros · segunda dinámica del Bosque Esmeralda 1-1

Diego salta sobre una plataforma de raíces, suelta el movimiento para viajar y vuelve a saltar al llegar. Primero lo aprende en un trayecto horizontal sobre suelo seguro; después utiliza un tronco ascendente para alcanzar la tercera llave de ramas.

Esta entrega añade `troncos_viajeros` a `puente_diana` en el mismo nivel `world_01_level_01`. Son dos dinámicas nuevas: las dos estaciones de cada una enseñan y practican la misma acción. La ficha [troncos_viajeros.json](troncos_viajeros.json) conserva fuentes, recuperación, controles, accesibilidad y validación. Estado: **implementada en 0.4.0**. La [CI de la implementación](https://github.com/RamonC5/juegoDiego/actions/runs/39007441949) supera 292 comprobaciones en las cinco suites, incluidas 27 de troncos viajeros y el encuadre del ascensor.

| Tramo | Datos | Propósito |
| --- | --- | --- |
| Ensayo horizontal | Centro de `(5600,545)` a `(5900,545)`, ancho 240 | Embarcar, viajar sin arrastrar y bajar. La plataforma de llegada y el cristal son opcionales. |
| Tronco ascendente | Centro de `(6460,545)` a `(6460,295)`, ancho 260 | Ganar altura para llegar a la repisa. |
| Recompensa | Repisa `x=6630–6890`, `y=260`; llave 3 en `(6760,211)` | Saltar desde el borde derecho del tronco a una superficie ancha. |
| Recuperación | Suelo continuo `x=5220–6900`, `y=600` | Caer, volver al puesto y reintentar sin daño causado por la mecánica. |

Cada viaje dura 3 segundos y se detiene 1,5 segundos en cada extremo. Las salidas y llegadas son suaves. La guía de trayecto, los rótulos numerados, las flechas, la marca de apoyo y las pistas comunican la relación sin depender solo del color ni del sonido. El sprite raster reutiliza las raíces y el musgo del puente ya existente.

En táctil se usan arrastre y deslizamiento arriba; se suelta el arrastre para viajar. Teclado y mando conservan movimiento y salto, con los ajustes actuales. No se añade interacción de toque que pueda confundirse con coger o lanzar objetos.

## Recuperación y progresión

Las plataformas se atraviesan desde abajo. No hay techo ni daño de aplastamiento en sus recorridos. El farol posterior al puente principal sigue siendo el punto seguro previo al nuevo tramo. Las patrullas se alejan de los puestos de embarque para enseñar la acción sin daño lateral.

Los ciclos vuelven solos a sus puestos. Al morir, Diego reaparece en tierra y después reinician los troncos; conserva las llaves y puentes resueltos. La repisa permite volver al suelo y regresar a una llave pendiente. Reiniciar o rejugar repone las tres llaves y mecanismos, conservando mejores marcas. Cerrar la aplicación sigue perdiendo el intento actual.

## Implementación y comprobación

`MovingPlatformDefinition` guarda extremos, ancho y tiempos. `ForestMovingPlatform`, un `AnimatableBody2D`, mueve su superficie en física; el cuerpo del protagonista recibe el transporte mediante las colisiones existentes. `ForestStage` compone las estaciones, guía, pistas y recuperación con referencias explícitas. No se modifica el controlador de Diego ni se añaden autoloads.

```sh
godot --headless --fixed-fps 60 --path . --script tools/tests/test_moving_platforms.gd
python3 .agents/skills/crear-dinamicas-salto-heroes/scripts/validar_dinamicas.py docs/dinamicas/troncos_viajeros.json
```

La nueva suite supera 27 comprobaciones de transporte real, pausa, descenso, recuperación, conservación y duplicación de llaves, acceso a la repisa, gestos normales e intercambiados y reinicio. Las suites del bosque y los puentes incorporan el ascensor a sus recorridos completos con entradas reales. El ayudante de recorrido no teletransporta al jugador, no altera velocidades ni reinicia ciclos.

[Registro de las 27 comprobaciones](../../art/levels/bosque_esmeralda/qa-moving-tests.txt). La CI también genera capturas reales del ensayo, ascensor y repisa en móvil, tablet y panorámico y exporta un APK firmado. La revisión visual sitúa el rótulo del ascensor junto al trayecto, fuera de la plataforma y de la cabecera del HUD. La cámara acompaña el ascenso para mantener a Diego y la repisa por debajo de las pistas, con pausa y transición suave al volver a tierra.

El presupuesto de esta dinámica es **2–4 minutos estimados**, sin muestras con el público objetivo. No acredita que el nivel completo dure 15 minutos. El mínimo de la aventura completa, tacto, comprensión y rendimiento en dispositivos físicos siguen pendientes de medición.
