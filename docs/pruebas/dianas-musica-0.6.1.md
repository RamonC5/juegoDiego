# Super Diego 0.6.1 · Dianas destructibles y música moderna

Validación local del 17 de octubre de 2026 con Godot 4.7.2, sobre `49f18a1`.

La nueva suite de dianas comprueba 17 casos: rechazo de objetos libres y sostenidos, rotura por lanzamiento, ocho fragmentos de la textura original, un impacto por rotura, sensor desactivado, pausa de fragmentos, limpieza al terminar, apertura del puente, reparación de dianas anteriores al farol y de una rotura pendiente, conservación de llaves y pasos abiertos, segunda rotura tras reparar, ausencia de duplicación del mecanismo y ausencia de iconos flotantes.

Las suites anteriores conservan 711 comprobaciones, y audio añade una para distinguir el tema nuevo por sus 128 BPM y 192 pulsos. Total comprobado: **729 comprobaciones correctas** (34 de audio y 17 de dianas, además de las nueve suites restantes). No se dan por probados los dispositivos físicos.

La composición original **Esmeralda en marcha** cambia la dirección musical: 90 segundos, 48 compases a 128 BPM, batería, bajo FM, acordes anchos, arpegios y lead de sintetizador. Usa dos secciones melódicas y cambios de instrumentación. No utiliza la flauta ni los timbres de la versión anterior, ni samples de terceros. NumPy, SciPy y FFmpeg solo se usan para preparar el Ogg, sin dependencias nuevas durante la partida. Se mantiene el volumen persistente y la pausa.

Las capturas de CI añaden `preview_target_breaking` y `preview_target_broken` para revisar la fragmentación real con Compatibility. Los iconos de recursos del HUD se conservan; las insignias del escenario y las guías superpuestas se eliminan. Las dianas se reconstruyen al morir y pueden romperse otra vez al volver atrás; los mecanismos abiertos siguen resueltos.
