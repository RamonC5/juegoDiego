# Nóctilo · revisión del concepto volador

Fecha: **16 de octubre de 2026**. Alcance: una imagen 2D estática, versión 002. Estado: **concept_only**.

## Comprobación técnica final

```sh
python .agents/skills/generar-personajes-salto-heroes/scripts/validate_sprite.py art/characters/noctilo/concept_v002.png
```

Resultado: **correcto, código 0**. [Informe completo](qa-technical.json).

| Control | Resultado medido |
| --- | --- |
| Formato | PNG RGBA |
| Dimensiones | 1254 × 1254 px |
| Fotogramas | 1; concepto estático |
| Canal alfa | Existe fondo con alfa 0 |
| Límites de alfa no nulo | [29, 33, 1228, 1232] |
| Margen mínimo | 22 px; mínimo del comprobador: 4 px |
| Peso | 1334119 bytes |
| SHA-256 | `475a76a979e2feccbac0afebb0c324a3ea527b0c84d0b27ac84ef2264aca7f54` |

El prompt pidió un margen del 6 %. El resultado real se registra como 22 px y cumple el mínimo técnico del proyecto; no se afirma que cumpla el porcentaje solicitado. No se retocaron los píxeles del PNG final después de generarlo.

## Corrección realizada

La [versión 001](sources/concept_v001.png) tenía píxeles residuales de alfa 1 en el borde inferior. La silueta visible estaba completa, pero el comprobador midió margen 0 px y falló. Se conservan [el informe de esa fuente](qa-source-v001.json) y ambos [prompts exactos](prompts.md).

La versión 002 se obtuvo editando la primera mediante `image_gen` integrada, con transparencia solicitada. Mantiene identidad, materiales, orientación y pose general; la membrana resultante es algo más cálida. Solo la versión 002 se selecciona como concepto final.

## Revisión visual

Se inspeccionaron el concepto completo y una [vista de comparación reducida](qa-comparison.png) con Plumín, Moflete, Goterón y Vainete. La vista utiliza copias de inspección dentro de cuadros de 186 × 186 px sobre fondo claro #fffaf3 y oscuro #11202a; los archivos originales permanecen sin modificar.

- Las dos alas membranosas, las orejas, los pies y la cola están completos y separados del borde.
- El aleteo ascendente y los pies recogidos comunican vuelo; no es una pose de ave terrestre.
- Frente a Plumín: membranas frente a plumas, torso suspendido frente a pecho erguido y rostro alerta frente a gesto presumido.
- Frente a Moflete: cuerpo afinado, orejas grandes y patas recogidas; no repite las mejillas ni la postura del roedor.
- Las alas y orejas forman un contorno distinto de las masas bajas de Goterón y Vainete.
- Las membranas cobrizas, el ojo y la garganta conservan lectura sobre ambos fondos; no aparecen suelo, texto, marcas ni tablero dibujado.
- Se mantiene una cabeza blanda sin armadura ni pinchos. La futura animación de pisotón deberá recoger las orejas y comprobar que el sensor superior sea legible.

Para Terrón y Remiendo se consultaron las descripciones del catálogo; no se inspeccionaron sus PNG en esta revisión. La comparación reducida es una comprobación visual de autoría, no una prueba en un móvil físico ni una medición de contraste de interfaz.

## Pendiente de producción

El nombre, la paleta, la personalidad y la propuesta de vuelo no se registran como elecciones ya aprobadas por el usuario. Quedan la referencia completa de «opción A», las hojas de animación, el ancla estable de vuelo, los sensores, el código, la importación en Godot y las pruebas en Android y Windows.

No se han ejecutado pruebas de jugabilidad por esta entrega de concepto. La imagen y la documentación permanecen bajo `art/`, excluido de importación y exportación del juego.
