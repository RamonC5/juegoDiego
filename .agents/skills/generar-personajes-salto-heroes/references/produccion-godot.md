# Contrato de producción para Godot 2D

## Formato de trabajo

Separar concepto visual, recurso técnico verificado e integración probada. No prometer fotogramas exactos, consistencia o transparencia por el mero hecho de haberlos solicitado al generador.

| Parámetro | Punto de partida revisable |
| --- | --- |
| Imagen final | PNG RGBA, canal alfa real y fondo vacío |
| Vista | Lateral, cámara fija, personaje completo |
| Dirección | Derecha; utilizar espejo solo si las asimetrías permiten hacerlo |
| Celdas | 256 × 256 normales; 512 × 512 para jefes si hace falta |
| Margen | Al menos 4 píxeles transparentes dentro de cada borde de celda |
| Hoja | Una acción por hoja; cuadrícula regular sin separadores, orden de izquierda a derecha y después de arriba abajo |
| Tamaño de hoja | Hasta 2048 × 2048 inicialmente; dividir acciones largas en hojas antes de aumentarlo |
| Filtrado | Lineal, coherente con `project.godot` |
| Raíz | Punto estable por personaje, anotado en píxeles de la celda; proponer `[128, 224]` para celdas de 256, si la pose lo permite |

Son valores de autoría, no límites universales del motor. Una textura RGBA8 de 2048 × 2048 ocupa aproximadamente 16 MiB sin mipmaps ni compresión; el tamaño del PNG en disco no equivale a memoria de GPU. Medir en dispositivos reales antes de fijar presupuestos definitivos.

Mantener celda y raíz al cambiar de pose. La silueta puede variar al saltar o agacharse: no igualar a ciegas la caja visible ni recentrar cada fotograma por separado. No generar una vista isométrica ni una cámara que rote alrededor del personaje.

## Cobertura de animaciones

Usar la tabla para planificar un personaje completo; producir solo el subconjunto solicitado. Número de fotogramas y velocidad son propuestas, no requisitos ya fijados.

| Rol | Acciones previstas | Primeras pruebas sugeridas |
| --- | --- | --- |
| Protagonista | `idle`, `run`, `jump_up`, `fall`, `land`, `carry_idle`, `carry_run`, `throw`, `hurt`, `defeated` | Reposo de 4 fotogramas a 6 FPS y carrera de 6–8 a 12 FPS |
| Enemigo pisable | `idle` o `patrol`, `stomped`, `defeated` | Patrulla breve y reacción al pisotón de lectura clara |
| Jefe | `idle`, `telegraph`, `attack`, `vulnerable`, `hit_by_object`, `defeated` | Poses clave de anticipación, vulnerabilidad e impacto antes de completar ciclos |

No convertir `throw` en un ataque de puñetazo por defecto. Prever posición de agarre y fotograma de suelta cuando se solicite la animación de lanzamiento. No animar un objeto pegado a la mano si debe existir como entidad independiente sin dejarlo documentado.

Evitar asignar el daño a un fotograma únicamente por su apariencia. El código futuro decidirá los momentos de daño, pisotón y vulnerabilidad; el arte ofrece señales legibles y marcadores propuestos.

## Archivos y metadatos

- Recursos finales: `game/assets/textures/characters/<character_id>/<animation>_v001.png`.
- Material de autoría: `art/characters/<character_id>/brief.yaml`, `prompts.md`, referencias permitidas y `qa.md`. Crear `art/.gdignore` antes de guardar imágenes de autoría para que Godot no las importe.
- Registro por personaje: `art/characters/<character_id>/character.json`.
- Integración, solo si se pide: recursos en `game/features/player/`, `enemies/` o `bosses/` según su rol.

Registrar en `character.json` al menos:

| Campo | Contenido |
| --- | --- |
| `schema_version` | `1` |
| `character_id`, `role` | Identificador estable y `player`, `enemy` o `boss` |
| `world_ids` | Lista de mundos existentes o lista vacía si es compartido/no asignado |
| `design_status` | `proposed` o `user_selected`, con la evidencia de selección cuando exista |
| `visual_reference` | Ruta de la referencia usada y decisiones que se conservaron |
| `frame_size`, `pivot_px`, `display_scale` | Valores reales o propuestas marcadas como pendientes |
| `animations` | Por acción: ruta final, cuadrícula, fotogramas usados, FPS, bucle y marcadores si existen |
| `generation` | Herramienta usada, prompt exacto o su ruta y referencias usadas; no inventar un seed |
| `validation` | Informe técnico, revisión visual y comprobaciones aún pendientes |
| `integration_status` | `concept_only`, `sprite_checked` o `godot_checked`, según la evidencia |

No rellenar rutas de imágenes inexistentes como si fueran recursos terminados. Mantener los cambios de nombre visible separados de los identificadores usados por niveles y progreso.

## Verificación técnica y visual

Ejecutar `scripts/validate_sprite.py` desde el skill. El programa solo lee imágenes y devuelve JSON por la salida estándar, con código `0` si pasan sus comprobaciones y `1` si falla alguna. Requiere Python 3 y Pillow; no modifica ni corrige archivos.

Comprobar dimensiones divisibles por la celda, PNG RGBA, transparencia, margen de cada fotograma activo, ausencia de celdas activas vacías y ausencia de contenido en celdas declaradas sin usar. Pasar el número real de fotogramas; sin `--frames` se consideran activas todas las celdas.

Revisar además a simple vista identidad, anatomía, continuidad de materiales y vestuario, acción reconocible, ausencia de deslizamiento de raíz, bucles y señales legibles sin depender solo del color. Revisar bordes sobre fondos claros y oscuros. Estas propiedades no las valida el script.

Cuando exista una integración autorizada, comprobar `SpriteFrames` y pivote en Godot, reproducción de cada acción y lectura a 1280 × 720 y a un tamaño móvil menor. Mantener sensores y colisiones independientes del alfa. Ejecutar la importación y el arranque del proyecto y, cuando haya builds disponibles, probar Android y Windows. Registrar lo que no se haya comprobado; no declarar compatibilidad real solo por disponer de un preset.
