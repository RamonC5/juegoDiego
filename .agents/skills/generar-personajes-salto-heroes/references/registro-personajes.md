# Registro de personajes e imágenes

1. Leer `docs/PERSONAJES.md` y buscar el identificador antes de crear o modificar un personaje. Conservar su ID al cambiar el nombre visible.
2. Crear o actualizar `art/characters/<character_id>/ficha.md` con identidad, función, requisitos, decisiones propuestas, estado e imagen real. Añadir texto alternativo descriptivo y enlaces relativos.
3. Guardar el PNG del concepto en esa misma carpeta con un nombre versionado, por ejemplo `concept_v001.png`. Conservar las referencias de edición necesarias en `sources/`. Mantener `art/.gdignore`.
4. Conservar `brief.yaml`, `prompts.md`, `character.json`, `qa.md` y el informe técnico junto a la imagen. Registrar medidas y resultados reales; separar concepto, animaciones y pruebas de integración.
5. Añadir una fila al catálogo vivo con nombre, ID, rol, mundos y estado. Enlazar ficha e imagen; no duplicar la ficha completa en el skill ni registrar como entregada una imagen inexistente.
6. Si se solicita subir a Git, comprobar los archivos afectados, incluir los PNG binarios y la documentación en el mismo cambio y verificar el commit remoto y sus rutas antes de afirmar que se ha subido. Reutilizar el flujo de acceso al repositorio disponible; no guardar credenciales.
7. Entregar enlaces al catálogo, a la ficha o al commit y aclarar el estado real. Mantener recursos de autoría fuera de las exportaciones; llevar a `game/assets/textures/characters/` únicamente los finales cuya producción se haya encargado.

