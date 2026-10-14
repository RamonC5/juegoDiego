# Desarrollo y exportación

## Entorno mínimo

Instala Godot **4.7.2 estándar**, sin .NET. Importa `project.godot` desde el gestor de proyectos. El ejecutable de línea de comandos se denomina `godot` en los ejemplos; en Windows puede ser necesario usar la ruta completa al ejecutable de consola.

Las plantillas de exportación deben corresponder exactamente a la versión del motor. Se instalan desde **Editor → Administrar plantillas de exportación**.

## Qué debe ocurrir al ejecutar

La escena principal contiene únicamente un nodo `Main` de tipo `Node2D`. Al pulsar F5 aparecerá una pantalla vacía del color de fondo configurado. No hay interacción, personajes, escenarios, música ni menús.

## Acciones de entrada configuradas

| Acción | Teclado | Mando, disposición Xbox |
| --- | --- | --- |
| `move_left` | A o flecha izquierda | Stick izquierdo o cruceta izquierda |
| `move_right` | D o flecha derecha | Stick izquierdo o cruceta derecha |
| `jump` | Espacio | A |
| `grab_throw` | E | X |
| `pause` | Escape | Start / Menú |

Las acciones solo están declaradas. Los controles táctiles futuros emitirán esas mismas acciones para permitir moverse y saltar simultáneamente. La navegación de menús usará las acciones `ui_*` de Godot y foco explícito. La reasignación de controles se implementará al crear los ajustes.

## Comprobación local

Desde la raíz del repositorio:

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --quit-after 3
```

La primera orden importa y analiza el proyecto. La segunda inicia la escena vacía y termina tras tres iteraciones. No verifican controles, gráficos finales, guardado ni compatibilidad real de dispositivos.

## Windows

El perfil **Windows** genera un ejecutable x86_64 con el paquete de recursos integrado. Crea antes `builds/windows/` y ejecuta:

```sh
godot --headless --path . --export-debug Windows builds/windows/salto-heroes.exe
```

La modificación de recursos del ejecutable y la firma están desactivadas en esta base; antes de distribuir una versión se configurarán el icono, los metadatos y la firma según corresponda.

## Android

El perfil **Android** prepara un APK ARM64 con el identificador `com.ramonc5.saltoheroes`, versión `0.0.0` y código de versión `1`. El identificador queda reservado para este proyecto y debe revisarse antes de publicar. No se solicita permiso de Internet.

1. Instala OpenJDK 17 y el SDK Android con los paquetes requeridos por [la guía oficial](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html).
2. En los ajustes del editor configura **Export → Android → Java SDK Path** y **Android SDK Path**.
3. Instala las plantillas de exportación de Godot 4.7.2.
4. Configura un keystore de depuración local en los ajustes del editor si no existe. Las rutas y contraseñas de firma no se guardan en el repositorio.
5. Crea `builds/android/` y exporta:

```sh
godot --headless --path . --export-debug Android builds/android/salto-heroes.apk
```

El perfil usa las plantillas APK precompiladas, sin Gradle. Los campos de SDK mínimo y objetivo quedan vacíos para utilizar los valores de dichas plantillas. Las versiones de Android y GPU admitidas deben comprobarse con las plantillas y dispositivos elegidos.

La distribución por Google Play necesitará una configuración posterior de Gradle, exportación AAB, firma de publicación y los requisitos vigentes de la tienda. Esta base no publica ninguna aplicación.

## Convenciones

- Archivos y carpetas: `snake_case`. Clases de GDScript: `PascalCase`.
- Usar tipos explícitos en interfaces, propiedades y métodos cuando se añadan scripts.
- Colocar escena, script y recursos de una funcionalidad en su carpeta.
- Mantener las definiciones de contenido separadas del progreso guardado.
- Añadir comprobaciones de comportamiento cuando se implemente una mecánica o un servicio; esta entrega no incluye una suite de pruebas de jugabilidad.
- Conservar en Git los archivos `.uid` de los scripts cuando Godot los genere. La caché `.godot/` y las exportaciones están excluidas.

## Integración continua

`.github/workflows/validate.yml` se ejecuta en cada envío y pull request. Descarga el motor oficial fijado, comprueba su SHA-512, importa el proyecto y ejecuta la escena vacía. Falla si cualquiera de las órdenes devuelve error o si Godot registra un error de análisis o de ejecución.

El workflow solo necesita permiso de lectura del repositorio. No exporta APK ni EXE, no utiliza credenciales y no despliega. La validación de cada plataforma se completará en el entorno de exportación y en dispositivos reales.
