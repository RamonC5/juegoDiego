# Desarrollo y exportación

## Entorno mínimo

Instala Godot **4.7.2 estándar**, sin .NET. Importa `project.godot` desde el gestor de proyectos. El ejecutable de línea de comandos se denomina `godot` en los ejemplos; en Windows puede ser necesario usar la ruta completa al ejecutable de consola.

Las plantillas de exportación deben corresponder exactamente a la versión del motor. Se instalan desde **Editor → Administrar plantillas de exportación**.

## Qué debe ocurrir al ejecutar

F5 abre el entrenamiento de Diego, con plataformas, seis objetos arrojadizos, dianas, controles táctiles, HUD y pausa. Mundos, niveles definitivos, enemigos jugables y música se implementarán después. [Guía del protagonista](PROTAGONISTA.md).

## Acciones de entrada configuradas

| Acción | Teclado | Mando, disposición Xbox |
| --- | --- | --- |
| `move_left` | A o flecha izquierda | Stick izquierdo o cruceta izquierda |
| `move_right` | D o flecha derecha | Stick izquierdo o cruceta derecha |
| `jump` | Espacio | A |
| `grab_throw` | E | X |
| `pause` | Escape | Start / Menú |

`PlayerInputSource` mezcla acciones de teclado, mando, eje táctil analógico y contactos independientes. [Gestos y referencias](CONTROLES_TACTILES.md). `run` añade Mayús/B y puede sustituirse por carrera automática. Pausa permite reasignar teclas, ajustar recorrido y lados de los gestos y activar salto completo con una pulsación. Los menús tienen foco visible y navegación `ui_*`. Las opciones se guardan en `user://controls.cfg`.

## Comprobación local

Desde la raíz del repositorio:

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --quit-after 3
```

La primera orden importa y analiza el proyecto; la segunda inicia el entrenamiento. Para comprobar el protagonista, ejecutar además `godot --headless --fixed-fps 60 --path . --script tools/tests/test_player.gd`: son 88 pruebas. Para los seis objetos, ejecutar `godot --headless --fixed-fps 60 --path . --script tools/tests/test_throwables.gd`: son 63 comprobaciones adicionales. El renderizado se ha revisado en Compatibility a 1280 × 720 y 1024 × 768; los dispositivos físicos siguen pendientes.

## Windows

El perfil **Windows** genera un ejecutable x86_64 con el paquete de recursos integrado. Crea antes `builds/windows/` y ejecuta:

```sh
godot --headless --path . --export-debug Windows builds/windows/salto-heroes.exe
```

La modificación de recursos del ejecutable y la firma están desactivadas en esta base; antes de distribuir una versión se configurarán el icono, los metadatos y la firma según corresponda.

## Android

El perfil **Android** prepara un APK ARM64 con el identificador `com.ramonc5.saltoheroes`, versión `0.1.0` y código de versión `2`. El identificador queda reservado para este proyecto y debe revisarse antes de publicar. No se solicita permiso de Internet.

1. Instala OpenJDK 17 y el SDK Android con los paquetes requeridos por [la guía oficial](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html).
2. En los ajustes del editor configura **Export → Android → Java SDK Path** y **Android SDK Path**.
3. Instala las plantillas de exportación de Godot 4.7.2.
4. Configura un keystore de depuración local en los ajustes del editor si no existe. Las rutas y contraseñas de firma no se guardan en el repositorio.
5. Crea `builds/android/` y exporta:

```sh
godot --headless --path . --export-debug Android builds/android/salto-heroes.apk
```

El perfil usa las plantillas APK precompiladas, sin Gradle. Los campos de SDK mínimo y objetivo quedan vacíos para utilizar los valores de dichas plantillas. Las versiones de Android y GPU admitidas deben comprobarse con las plantillas y dispositivos elegidos.

El proyecto activa la importación ETC2/ASTC requerida por Android y S3TC/BPTC para Windows. Estas opciones están en `Rendering → Textures → VRAM Compression` dentro de los ajustes del proyecto.

`game/assets/icon.svg` proporciona un icono provisional con las iniciales SH para la aplicación. Se registra en `Application → Config → Icon` para que Godot exporte el APK sin errores de metadatos; no forma parte de la escena de juego.

La distribución por Google Play necesitará una configuración posterior de Gradle, exportación AAB, firma de publicación y los requisitos vigentes de la tienda. Esta base no publica ninguna aplicación.

## Convenciones

- Archivos y carpetas: `snake_case`. Clases de GDScript: `PascalCase`.
- Usar tipos explícitos en interfaces, propiedades y métodos cuando se añadan scripts.
- Colocar escena, script y recursos de una funcionalidad en su carpeta.
- Mantener las definiciones de contenido separadas del progreso guardado.
- Añadir comprobaciones de comportamiento cuando se implemente una mecánica o un servicio; esta entrega no incluye una suite de pruebas de jugabilidad.
- Conservar en Git los archivos `.uid` de los scripts cuando Godot los genere. La caché `.godot/` y las exportaciones están excluidas.

## Integración continua

`.github/workflows/validate.yml` (**Validar y generar APK Android**) se ejecuta en cada envío, pull request y ejecución manual con **Run workflow**. Necesita permiso de lectura del repositorio y publica el resultado como un artefacto de la ejecución.

El flujo realiza estas operaciones:

1. Prepara Java 17 y el SDK Android de la imagen `ubuntu-24.04`, instalando Platform Tools, Build Tools 35.0.1 y la plataforma Android 35.
2. Descarga Godot con la versión de `.godot-version` y comprueba el SHA-512 registrado en `tools/godot-linux-x86_64.sha512`.
3. Descarga las plantillas de esa misma versión, comprueba `tools/godot-export-templates.sha256` e instala las plantillas APK Android. El checksum procede del campo `digest` de la [publicación oficial de Godot 4.7.2](https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable).
4. Recupera o crea una clave de depuración fuera del repositorio y configura las rutas de Java, SDK y firma en un directorio temporal mediante `tools/ci/configure_android.py`.
5. Importa el proyecto, comprueba el arranque, ejecuta las 88 pruebas del protagonista, 63 de objetos, 58 del bosque y 55 de puentes y exporta con `--headless --export-debug Android`. Falla ante errores de Godot y pruebas fallidas.
6. Verifica el APK con `apksigner`, comprueba el paquete `com.ramonc5.saltoheroes` y la biblioteca ARM64, y calcula el SHA-256 del archivo.
7. Publica el APK, su checksum y los metadatos de compilación durante 30 días. Si falla la compilación, conserva los registros disponibles durante 7 días.

Se usan las plantillas APK precompiladas, sin compilar código nativo ni ejecutar Gradle; este flujo no necesita descargar NDK ni CMake. Las acciones de GitHub están fijadas por SHA. Una compilación nueva en la misma referencia cancela la anterior si todavía está en curso.

### Descargar el resultado

Abre [el workflow del repositorio](https://github.com/RamonC5/juegoDiego/actions/workflows/validate.yml), selecciona una ejecución verde y descarga **Artifacts → salto-heroes-android-<número>**. Debes iniciar sesión en GitHub con acceso al repositorio privado. Descomprime el ZIP y abre `salto-heroes.apk` en el móvil. Android puede pedir que habilites la instalación desde el navegador o gestor de archivos utilizado.

El resumen de cada ejecución también enlaza directamente al artefacto. La descarga incluye:

| Archivo | Uso |
| --- | --- |
| `salto-heroes.apk` | Instalador Android ARM64 de pruebas |
| `salto-heroes.apk.sha256` | Comprobación de integridad del APK |
| `build-info.json` | Versión de Godot, versión Android, commit y ejecución de origen |

El código de versión del APK es `1000 + GITHUB_RUN_NUMBER`. El nombre toma `config/version` del proyecto y añade `-ci.<número>`, actualmente `0.1.0-ci.<número>`. Solo se modifica la copia del perfil dentro del runner. Una repetición conserva el mismo código y puede reinstalarse. Al preparar la primera publicación habrá que revisar esta numeración.

### Firma de pruebas y actualizaciones

No hace falta configurar secretos para generar e instalar estos APK. Se usa una clave de depuración con alias `androiddebugkey` y la contraseña estándar de pruebas `android`. Se genera en el runner y se conserva mediante la caché `salto-heroes-android-debug-keystore-v1`; nunca se añade al repositorio ni al artefacto de descarga. Esta clave sirve únicamente para builds de desarrollo.

La caché permite reutilizar la firma en ejecuciones posteriores cuando está disponible. No es un almacén permanente: si GitHub elimina la caché o una rama no puede recuperarla, se genera otra clave. Android no permite actualizar una aplicación con otra firma; en ese caso será necesario desinstalar la versión anterior antes de instalar la nueva, lo que puede borrar el progreso local. Para distribución estable se configurará una clave permanente respaldada y almacenada como secreto.

El APK abre el entrenamiento de Diego. La CI verifica importación, arranque, 118 comprobaciones de comportamiento, exportación y firma; el tacto y rendimiento deben comprobarse en Android y tablet Windows físicos.

### Actualizar Godot

Al cambiar `.godot-version`, actualiza el checksum del editor y el de las plantillas, manteniendo los nombres de archivo correspondientes. Revisa también las herramientas SDK requeridas por la versión nueva y el nombre del archivo de ajustes del editor generado por `tools/ci/configure_android.py`. Confirma la compilación y la instalación antes de dar la actualización por terminada.


## Dianas y puentes del bosque

La versión 0.3.0 integra dos estaciones en el nivel 1. Ejecutar también `godot --headless --fixed-fps 60 --path . --script tools/tests/test_bridges.gd`. Sus 55 comprobaciones cubren control táctil y teclado, recuperación, pausa, reaparición y recorrido completo con las tres llaves. La CI ejecuta esta suite antes de las capturas y exportación. Los presupuestos de duración y las pruebas en dispositivos físicos siguen pendientes.
