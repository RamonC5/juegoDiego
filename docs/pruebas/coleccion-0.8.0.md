# Evidencia de colección y vestuario · 0.8.0

Base revisada: `main`, commit `3f324c02a4b5af369d297913b1a50e21b6b37b1c` (0.7.5). Godot oficial 4.7.2 estándar, checksum fijado por el repositorio.

## Regresión funcional local

La importación limpia y 18 suites Godot completaron **882 comprobaciones con cero fallos**, incluidas **40 de colección**. Se ejecutaron protagonista y controles, movimientos, objetos, animación enemiga, bosque, ampliación, pulido, audio y reaparición, recuperación por farol y retorno real, dianas, puentes, troncos, lianas, gruta y recorrido continuo. Se añaden cinco regresiones Python de preparación Android correctas.

La suite nueva verifica hitos, ropa bloqueada, equipo sin consumo, IDs y tipos inválidos, duplicados, carga real tras cerrar, copia ante archivo dañado, reversión por fallo de escritura, recogida por contacto físico, cambios de material desde el menú, independencia de previsualización, pausa y limpieza de contactos, desbloqueo y descanso de Luci, pista del secreto, pausa del aleteo y retorno tras muerte. Reabrir una escena conserva recompensas y mantiene el reinicio de llaves y mecanismos.

Las suites y capturas existentes inyectan un perfil de colección temporal antes de montar la escena. No leen ni modifican el guardado de colección del jugador y no dependen del orden de las pruebas.

El recorrido geométrico principal conserva su validación automatizada, con protección contra combate. No acredita duración de primera partida ni el descubrimiento natural de los tres fragmentos. La integración de la colección no amplía el presupuesto principal del nivel.

## Arte y revisión visual

El arte usa `image_gen`: cuatro poses de Luci y una textura de helechos para las prendas. Los prompts exactos y resultados se conservan junto al personaje. Se aplica el shader de alfa ya utilizado por el resto del reparto.

La comprobación estricta del margen del PNG de Luci detectó alfa residual de valores muy bajos en las cuatro celdas; el recurso no está recortado visualmente. Sobre el umbral efectivo del shader (alfa > 0,13), los márgenes mínimos son 39, 31, 15 y 36 px. La comprobación estructural con margen bruto 0 confirma RGBA, cuadrícula, transparencia y cuatro celdas no vacías. Esto no equivale a declarar correcto el margen bruto de 4 px. Revisar las capturas con Compatibility para acreditar la presentación final.

Se ejecutó `capture_collection.gd` con Compatibility real (Mesa llvmpipe), guardando ocho capturas: vestuario bloqueado, cinco variantes de equipo, móvil 1280 × 720 y tablet 1024 × 768. La inspección visual confirma textos legibles, foco visible, contadores completos, previsualización, materiales distintos y Luci separada del cuerpo de Diego. El listado usa desplazamiento para las prendas inferiores. La revisión de tacto, descubrimiento, lector de pantalla y rendimiento en Android y tablet Windows físicos continúa pendiente.
