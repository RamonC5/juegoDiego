# Nudor, el Roble Furioso

Jefe del Bosque Esmeralda, ID `nudor`. Integrado en 0.15.0 como encuentro posterior a las tres aventuras. La petición del 20-10-2026 de crear Bosque 1-3 con su enemigo final autoriza cerrar el recorrido con este combate; se reutiliza el concepto archivado.

## Identidad y arena

Roble corpulento de corteza, raíces y musgo, rostro ceñudo, manos grandes y bellota dorada protegida por placas del pecho. [Ficha e imágenes](../../art/characters/nudor/ficha.md). Claro de 1280 px con suelo continuo y extremos cerrados, sin barrancos ni esbirros. Diego entra en (250,600); Nudor espera en (1010,600). Piñas renovables en (310,574) y (760,574). El zoom adapta el claro completo al ancho de pantalla.

## Ciclo de combate

| Acción | Aviso | Ataque y evasión | Recuperación |
| --- | --- | --- | --- |
| Manotazo de raíces | Brazo elevado y raíces en el suelo durante 1,6 s. Posición fijada al empezar el aviso. | Zona de 170 × 120 px durante 0,48 s. Apartarse de la marca. | Pecho abierto durante 3,5 s. |
| Barrido | Retira el brazo durante 1,6 s, sin daño. | Raíz de 160 × 55 px por el suelo a 440 px/s. Saltar sobre ella. | Pecho abierto durante 3,5 s. |

Presentación de 1,8 s sin daño. Primero manotazo y después barrido; los ciclos alternan con los mismos avisos, sin acelerar ni solaparse. Forma, postura y movimiento comunican el peligro sin rótulos ni sonido obligatorio. Ayuda completa en pausa. Son parámetros iniciales implementados, con dificultad humana pendiente de medición.

## Segunda fase del combate · 0.16.0

Tras el tercer impacto (Nudor queda con **dos de cinco puntos**), se activa una transformación de 1,8 s, sin ataques ni daño de contacto del tronco. Las articulaciones se agitan y el HUD indica **Fase 2**, también mediante descripciones accesibles. No hay un nuevo requisito de llaves ni coleccionables.

En la **fase 1**, cada ciclo consiste en un manotazo *o* un barrido, con aviso de 1,6 s y apertura de 3,5 s. En la **fase 2**, Nudor combina **ambos ataques antes de cada apertura**. Alterna el orden entre barrido → manotazo y manotazo → barrido; cada ataque mantiene su aviso de 1,6 s. El suelo muestra una señal visual para ambos avisos, pero solo los ataques activos causan daño. La bellota no puede recibir impactos durante la transformación ni entre los dos ataques. No se acelera el ritmo, no hay ataques simultáneos y los cinco impactos totales no cambian.

Derrota, pausa y muerte conservan sus contratos: al reintentar se restaura **fase 1**, salud máxima, secuencia inicial, avisos y piñas. La transformación no se guarda por separado. La documentación del combate se consulta en pausa; ninguna señal depende solo del sonido o del color.

## Daño y munición

Cinco impactos, uno por apertura. **Solo recibe daño de objetos lanzados válidos en la bellota durante la apertura**. Rechaza pisotones, contacto, objetos libres/sostenidos, tiros lentos o caducados y golpes a raíces. No tiene sensor `StompTarget`. Cada objeto lleva `launch_serial`: un lanzamiento ya aceptado no vuelve a dañar en otra ventana, pero recoger y lanzar el mismo objeto permite otro impacto.

Saltar y lanzar permite alcanzar el pecho. La ventana da tiempo para preparar el tiro. El barrido de `ThrowableObject` entrega el impacto antes de asentar/romper el objeto; la protección consume el tiro sin quitar salud. Ambas piñas se reponen a los tres segundos o al salir del claro; perderlas no agota el combate.

El quinto impacto detiene todo daño y emite victoria una sola vez; Diego celebra. No hay premio nuevo ni requisito de cristales, hojas, secreto o ropa. El resultado separado del jefe no sustituye el de 1-3.

## Composición y recuperación

- `game/boot/forest_boss.tscn` y `forest_boss.gd` reutilizan UI, controles, música, colección y guardado de `main.gd` mediante `_create_stage()`.
- `ForestBossStage` compone suelo, piñas y Nudor, sin llaves ni faroles adicionales. Los tres faroles pertenecen a 1-3. La entrada sirve de reintento local del encuentro.
- `game/features/bosses/nudor.gd` define espera, entrada, avisos, manotazo, barrido, apertura, daño y derrota. Morir congela el combate; reintentar limpia salud, relojes, pose, avisos y piñas. Salir o reiniciar libera la escena; no guarda fase.
- `NudorVisual` articula dos poses de `game/assets/textures/characters/nudor/poses_v001.png`: hombros, muñecas y raíces, fundido de apertura, reacción y descenso de derrota. No son hojas completas de fotogramas por acción.
- `progress.json` conserva esquema 1. El selector verifica las tres aventuras incluso ante un registro aislado de 1-3. Colección/equipo persistentes, sin autoloads ni cambios en IDs previos.

## Evidencia y límites

`test_nudor.gd` comprueba contratos, contacto desde arriba, evasión/daño, pausa, muerte durante ambos ataques, munición y cinco impactos aéreos físicos desde la mano. [Informe](../pruebas/bosque-1-3-nudor.md).

Pendientes: Compatibility y revisión del ciclo, dispositivos físicos y dificultad infantil. El PNG conserva alfa residual tenue en márgenes y no pasa el comprobador estricto; el shader lo descarta y se midieron los márgenes visibles. No se declara arte listo para producción sin revisión gráfica.
