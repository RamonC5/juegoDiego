# Procedencia y selección de la base

Consulta realizada el 14 de octubre de 2026. Adaptación propia para los requisitos de Juego Diego; no se han instalado paquetes, ejecutado scripts externos de terceros ni copiado su implementación.

| Skill consultado | Valor para este proyecto | Decisión |
| --- | --- | --- |
| [OpenAI imagegen](https://github.com/openai/skills/blob/e6afb0d74cc75d220df2faf3dd6c635c2dc6a108/skills/.system/imagegen/SKILL.md) | Flujo de generación y edición raster, uso de referencias y herramienta integrada | Base metodológica elegida; añadir requisitos de personajes, acciones, transparencia y entrega para Godot |
| [Character Sprite Maker](https://github.com/Clad3815/character-sprite-maker/blob/main/SKILL.md) | Flujo especializado en personajes, secuencias y comprobación de hojas | Referencia comparativa; sus presets de pixel art/cartoon y su flujo de chroma no se adoptan como configuración de Salto Heroes |

Fijar la referencia de OpenAI al commit `e6afb0d74cc75d220df2faf3dd6c635c2dc6a108` para identificar la versión consultada. Leer la versión instalada de `imagegen` al ejecutar generación, ya que la interfaz y las capacidades de la herramienta pueden evolucionar.

Aplicar generación raster con la herramienta integrada y conservar referencias e invariantes al editar. Pedir alfa real en lugar de introducir una etapa de eliminación de chroma como camino predeterminado. No depender de un proveedor adicional, un modelo fijado en el código ni una clave API para el flujo integrado.

El nuevo skill aporta reglas propias para los requisitos conocidos del juego, estados de pisotón y lanzamiento, consistencia entre acciones, organización de archivos y un comprobador de PNG de solo lectura. Su existencia no instala un generador dentro de Godot ni modifica la jugabilidad.
