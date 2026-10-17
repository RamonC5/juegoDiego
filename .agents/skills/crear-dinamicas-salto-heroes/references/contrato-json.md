# Contrato de fichas JSON, versión 1

Usar JSON UTF-8 sin comentarios ni claves repetidas. Las plantillas contienen campos vacíos intencionados y deben completarse antes de validar. Mantener identificadores `snake_case`, textos en español y un estado honesto.

## Campos compartidos

| Campo | Regla |
| --- | --- |
| `schema_version` | Entero `1`. |
| `tipo` | `dinamica` o `nivel`. |
| `id`, `nombre` | Identificador estable y nombre descriptivo no vacío. |
| `estado` | `propuesta`, `ampliacion` o `implementada`. |
| `fuentes` | Lista no vacía de objetos con `ruta`, `revision` y `observacion`. Identificar instrucciones del usuario como fuente de diseño, sin atribuirles un commit. |
| `persistencia` | Objeto con textos `al_morir`, `al_cerrar` y `al_rejugar`; describir el comportamiento previsto y distinguirlo del actual. |
| `accesibilidad` | Textos `senales_no_solo_color`, `equivalencia_visual_sonora`, `legibilidad_movil` y `ajustes_control`. |
| `validacion` | Listas no vacías `funcional` y `jugando`, más `evidencias` (lista de textos, vacía si no hay pruebas). Exigir evidencia cuando `estado` sea `implementada`. |

Una ruta de fuente identifica un archivo del proyecto o una URL observada. Registrar la revisión real usada. No marcar una ficha como implementada a partir de una propuesta, un concepto de arte o una prueba documental.

## Ficha de dinámica

Completar `objetivo`; `dependencias` con objetos `{id, estado, detalle}`; `controles` con textos para `tactil`, `teclado` y `mando`; `aprendizaje` con `presentacion`, `practica` y `combinacion`; y `reglas` con `activacion`, `exito`, `fallo` y `recuperacion`.

Añadir `feedback` (lista no vacía), `recompensa` (texto), `minutos_estimados` (intervalo de dos números positivos ordenados) y `dificultad` (texto). Una ficha implementada no puede depender de una capacidad declarada como propuesta o ampliación.

Los tiempos de la dinámica ayudan a diseñar situaciones. No volver a sumarlos cuando ya estén presupuestados dentro de los segmentos de un nivel.

## Ficha de nivel

| Campo | Regla |
| --- | --- |
| `mundo_id` | `world_01` a `world_08`. |
| `categoria` | `aventura` o `jefe`. |
| `orden` | Entero 1–3 para aventura; 4 para jefe. |
| `id` | `world_XX_level_0N` según el orden; `world_XX_boss` para jefe. |
| `desbloqueo_requiere` | Lista de identificadores. El jefe requiere las tres aventuras de su mundo. |
| `dinamicas_nuevas_obligatorias` | Lista sin repetidos; máximo inicial de dos, presentes en segmentos principales. |
| `segmentos` | Lista ordenada, sin identificadores repetidos. Cada entrada tiene `id`, `nombre`, `principal` booleano, `minutos_estimados`, `dinamicas` (lista no vacía) y `proposito`. |
| `llaves` | Tres objetos `{ranura, segmento_id, obtencion}` con ranuras enteras 1, 2 y 3 y tres segmentos principales diferentes. Vacía para un jefe. |
| `salida` | `condicion`: `tres_llaves` en aventura o `jefe_derrotado` en jefe. Añadir `descripcion` y `retorno_objetivos_pendientes`: `true`. |
| `puntos_control` | Lista de objetos con `id` y `despues_de_segmento_id`, siempre referidos a segmentos principales. Para aventuras, al menos uno. |
| `intervalo_maximo_faroles_minutos` | Número positivo; presupuesto máximo entre inicio, faroles y final, usando los máximos de cada segmento principal. Inicialmente cuatro. |
| `duracion` | Objeto descrito abajo. |

La lista de segmentos expresa el recorrido en orden. Para alternativas, registrar como principal el presupuesto del recorrido válido más corto; dejar los otros recorridos como opcionales y describir la elección. La ficha no sustituye un grafo de navegación ni demuestra alcanzabilidad física.

En `duracion`, incluir:

- `minimo_primera_partida_minutos`: número positivo, al menos 15 por defecto para aventuras; la petición posterior y explícita del usuario permite excepción documentada. No trasladar ese mínimo automáticamente al jefe.
- `excepcion_duracion_usuario` (opcional en aventuras): objeto `{fecha: "YYYY-MM-DD", solicitud: "texto explícito del usuario"}` para justificar un mínimo inferior a 15. Sin excepción se mantiene la validación estricta.
- `objetivo_minutos`: intervalo ordenado con mínimo igual o superior al mínimo exigido; usar inicialmente `[18, 22]` para aventuras.
- `estado`: `estimada` o `medida`.
- `muestras`: lista de objetos anónimos con `id`, `perfil`: `primera_partida_publico_objetivo`, `minutos_ruta_principal` y booleanos verdaderos `pausas_cargas_excluidas`, `reintentos_excluidos`, `opcionales_excluidos`. Excluir también cinemáticas.

La suma de mínimos y máximos de segmentos principales debe caber en el objetivo y su mínimo debe alcanzar el exigido. Los segmentos opcionales no contribuyen. `medida` requiere muestras; si alguna queda por debajo del mínimo, la ficha necesita revisión. Una muestra no demuestra por sí sola la edad, metodología ni tiempo de todos los jugadores.

## Uso y límites del comprobador

```sh
python3 .agents/skills/crear-dinamicas-salto-heroes/scripts/validar_dinamicas.py ruta/dinamica.json ruta/nivel.json
python3 .agents/skills/crear-dinamicas-salto-heroes/scripts/validar_dinamicas.py --mundo ruta/level_01.json ruta/level_02.json ruta/level_03.json ruta/boss.json
```

Usar `--mundo` con las cuatro fichas de nivel de un solo mundo. El comprobador revisa cantidad, órdenes, desbloqueos y ciclos; también admite fichas de dinámicas en la misma llamada. Sin esa opción, se puede comprobar una ficha aislada aunque sus niveles previos no se hayan adjuntado.

El proceso devuelve 0 cuando la estructura es coherente, 1 ante errores de fichas y 2 ante uso incorrecto de la línea de órdenes. No modifica archivos, no ejecuta el juego y no certifica diversión, física, rendimiento, accesibilidad total ni duración real. Mantener esas revisiones en `validacion.jugando` y registrar evidencia real después.
