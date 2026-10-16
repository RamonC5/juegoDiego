# Prompts de Diego

## carry_final

```text
Corrige SOLO las posturas de las cuatro figuras de esta hoja de sprites. Conserva exactamente el protagonista, acabado, ropa, cara, gafas, color y fondo transparente. Es una animación de CAMINAR CON LAS MANOS SOSTENIENDO UN OBJETO INVISIBLE delante del pecho. Debe haber cuatro fases claramente diferentes, no cuatro zancadas repetidas. Cuadrante superior izquierdo: piernas en zancada amplia con pie izquierdo adelantado. Cuadrante superior derecho: postura de paso intermedio, pie derecho sobre el suelo justo bajo la cadera y RODILLA IZQUIERDA LEVANTADA al frente, ambos pies próximos. Cuadrante inferior izquierdo: zancada opuesta, pie derecho adelantado e izquierdo atrás. Cuadrante inferior derecho: paso intermedio opuesto, pie izquierdo bajo la cadera y RODILLA DERECHA LEVANTADA al frente, ambos pies próximos. Manos juntas delante del pecho y vacías en las cuatro. Mantén tamaño uniforme y al menos un 8% de espacio transparente alrededor de cada figura. Lienzo cuadrado, cuadrícula 2x2 sin divisores. No añadir objeto, letras, sombras ni fondo.
```

Herramienta: `image_gen` integrada, con `transparent_background: true`. Cada acción se generó por separado, usando `concept_v001.png` como referencia. El concepto usó la foto adjunta y Terrón como referencia de acabado. La primera solicitud de concepto no produjo imagen; se repitió con el mismo encargo simplificado. Los intentos rectangulares de salto se sustituyeron por una secuencia cuadrada de cuatro poses. No se ha usado una API alternativa ni se ha retocado el PNG mediante código.

## base_initial

```text
Use case: identity-preserve / stylized-concept.
Asset type: canonical full-body 2D platform game protagonist sprite for Salto Heroes (Godot, Android and Windows).
Input image 1 is the supplied photograph, ONLY the boy is the identity reference: preserve his recognizable dark tousled straight fringe, large black softly rectangular eyeglasses, warm skin, face shape and cheerful smile. Do not reproduce the aquarium, fish or photographic clothes. Input image 2 is the existing enemy Terrón, ONLY a finish/material/light reference, do not borrow its anatomy.
Primary request: adapt this boy as the game's original child adventurer, naturally childlike proportions, slightly enlarged head for mobile readability, 4.5 heads tall. Costume proposal: ivory short-sleeve shirt, short teal textured canvas adventure vest with simple brass fastenings, small mustard-yellow neckerchief, blue knee-length cuffed shorts, sturdy tan ankle boots. No hat; hair and black glasses must remain clearly visible. Friendly, curious and determined. No weapons.
Style: highly polished high-resolution raster 2D game art with rich cloth/leather textures and soft modeled shading in the same finish as Terrón; no outlines, flat cartoon, comic, pixel art, 3D model or 3D scene.
Composition: ONE single complete character standing facing RIGHT in a consistent near-side-view (slight three-quarter face to make glasses and likeness readable), fixed orthographic side camera, relaxed ready stance, both feet visible. Upper-left soft light. Center the character with generous truly empty transparent padding (at least 80 px all sides); no ground or cast shadow outside body. 1024x1024 canvas. Clothing is simple enough to repeat consistently in later animation sheets. Genuine transparent RGBA background, no checkerboard, labels, text, logos or watermark.
```

## base_final

```text
Crea un único protagonista original para el juego de plataformas 2D Salto Heroes, usando como referencia al niño de la primera imagen: conserva su pelo oscuro con flequillo, gafas negras grandes, sonrisa y rasgos reconocibles. Adapta su ropa a una aventura familiar: camiseta de manga corta color marfil, chaleco corto de tela verde azulado, pañuelo pequeño amarillo mostaza, pantalón azul hasta las rodillas y botas marrones. Cuerpo completo, postura relajada de perfil hacia la derecha, con la cara ligeramente visible y proporciones infantiles naturales adaptadas a un sprite. La segunda imagen es solamente referencia de la calidad del acabado: imagen raster 2D de alta resolución, texturas suaves de tela y cuero, luz cálida superior izquierda, sombreado suave con volumen aparente, sin contornos gruesos. Mantén una silueta sencilla y legible en móvil. Un solo personaje centrado en lienzo cuadrado de 1024 por 1024, margen vacío amplio en todos los lados. Fondo realmente transparente, sin suelo, sombras externas, letras, etiquetas ni otros personajes. No incluyas el acuario de la foto.
```

## idle

```text
Hoja de animación raster 2D para Godot del MISMO protagonista de la imagen de referencia. Mantén exactamente rostro, gafas negras, peinado oscuro, chaleco verde azulado con dos bolsillos, camiseta marfil, pañuelo mostaza, pantalón corto azul y botas marrones. Acabado texturizado y sombreado suave idéntico. Cámara lateral fija mirando a la derecha, ligera vista de la cara igual a la referencia. Ningún giro de cámara.
Una sola acción: reposo cíclico: (1) postura relajada lista, (2) inspirar y subir hombros apenas, (3) breve parpadeo con ligera flexión, (4) volver a la postura inicial. Pies firmes, respiración sutil.
CUADRÍCULA EXACTA de 2 columnas por 2 filas, 4 fotogramas de izquierda a derecha y luego de arriba abajo. Lienzo 1024 x 1024, celdas cuadradas iguales de 512x512 sin líneas ni divisores. Cada figura de cuerpo completo, misma escala (altura de pie 390 píxeles), centro horizontal en x256 y plano de apoyo local y460 en cada celda; margen transparente de al menos 25px en todos los bordes. No llenar el lienzo con un solo personaje: repetir el mismo personaje 4 veces, una pose por celda. Pies completos y gafas legibles. Fondo alfa realmente transparente, sin suelo, sin sombras externas, sin texto, números, marcas o efectos. Cambia únicamente la pose de la acción. No reinterpretes el vestuario.
```

## walk

```text
Hoja de animación raster 2D para Godot del MISMO protagonista de la imagen de referencia. Mantén exactamente rostro, gafas negras, peinado oscuro, chaleco verde azulado con dos bolsillos, camiseta marfil, pañuelo mostaza, pantalón corto azul y botas marrones. Acabado texturizado y sombreado suave idéntico. Cámara lateral fija mirando a la derecha, ligera vista de la cara igual a la referencia. Ningún giro de cámara.
Una sola acción: ciclo de caminar completo sin trasladarse: (1) contacto pie izquierdo adelante, (2) apoyo y bajada, (3) paso de cruce con izquierdo atrás, (4) contacto pie derecho adelante, (5) apoyo opuesto, (6) cruce opuesto que enlaza con1. Brazos alternados, pasos cortos.
CUADRÍCULA EXACTA de 3 columnas por 2 filas, 6 fotogramas de izquierda a derecha y luego de arriba abajo. Lienzo 1536 x 1024, celdas cuadradas iguales de 512x512 sin líneas ni divisores. Cada figura de cuerpo completo, misma escala (altura de pie 390 píxeles), centro horizontal en x256 y plano de apoyo local y460 en cada celda; margen transparente de al menos 25px en todos los bordes. No llenar el lienzo con un solo personaje: repetir el mismo personaje 6 veces, una pose por celda. Pies completos y gafas legibles. Fondo alfa realmente transparente, sin suelo, sin sombras externas, sin texto, números, marcas o efectos. Cambia únicamente la pose de la acción. No reinterpretes el vestuario.
```

## walk_correction

```text
Edición técnica de esta hoja de sprites: elimina completamente el fondo marrón, los halos de luz, la viñeta y cualquier sombra fuera de las figuras. Debe quedar transparencia real de alfa cero alrededor y entre los SEIS personajes. Conserva las seis poses, rostro, gafas, ropa, colores y proporciones exactamente como están. Conserva el lienzo horizontal 1536x1024 y la cuadrícula exacta de 3 columnas y 2 filas con celdas de 512x512. Ajusta solo la escala común de las seis figuras al 85% de la actual alrededor del centro de cada celda para dejar 30px transparentes mínimos en TODOS los bordes y entre filas. Ninguna figura puede tocar o cruzar su celda. Sin suelo, sin sombras, sin fondo de ningún color, sin cuadrícula dibujada, sin texto. Entrega un PNG con fondo realmente transparente. No añadas una escena.
```

## run

```text
Hoja de animación raster 2D para Godot del MISMO protagonista de la imagen de referencia. Mantén exactamente rostro, gafas negras, peinado oscuro, chaleco verde azulado con dos bolsillos, camiseta marfil, pañuelo mostaza, pantalón corto azul y botas marrones. Acabado texturizado y sombreado suave idéntico. Cámara lateral fija mirando a la derecha, ligera vista de la cara igual a la referencia. Ningún giro de cámara.
Una sola acción: ciclo de correr completo en el sitio: (1) contacto pie izquierdo adelante y derecho atrás, (2) compresión y empuje izquierdo, (3) fase aérea de cruce piernas, (4) contacto derecho adelante e izquierdo atrás, (5) compresión y empuje derecho, (6) vuelo opuesto que enlaza con1. Tronco inclinado, pasos amplios, brazos alternados claramente.
CUADRÍCULA EXACTA de 3 columnas por 2 filas, 6 fotogramas de izquierda a derecha y luego de arriba abajo. Lienzo 1536 x 1024, celdas cuadradas iguales de 512x512 sin líneas ni divisores. Cada figura de cuerpo completo, misma escala (altura de pie 390 píxeles), centro horizontal en x256 y plano de apoyo local y460 en cada celda; margen transparente de al menos 25px en todos los bordes. No llenar el lienzo con un solo personaje: repetir el mismo personaje 6 veces, una pose por celda. Pies completos y gafas legibles. Fondo alfa realmente transparente, sin suelo, sin sombras externas, sin texto, números, marcas o efectos. Cambia únicamente la pose de la acción. No reinterpretes el vestuario.
```

## run_correction

```text
Edición técnica de esta hoja de sprites: elimina completamente el fondo marrón, los halos de luz, la viñeta y cualquier sombra fuera de las figuras. Debe quedar transparencia real de alfa cero alrededor y entre los SEIS personajes. Conserva las seis poses, rostro, gafas, ropa, colores y proporciones exactamente como están. Conserva el lienzo horizontal 1536x1024 y la cuadrícula exacta de 3 columnas y 2 filas con celdas de 512x512. Ajusta solo la escala común de las seis figuras al 85% de la actual alrededor del centro de cada celda para dejar 30px transparentes mínimos en TODOS los bordes y entre filas. Ninguna figura puede tocar o cruzar su celda. Sin suelo, sin sombras, sin fondo de ningún color, sin cuadrícula dibujada, sin texto. Entrega un PNG con fondo realmente transparente. No añadas una escena.
```

## jump

```text
Hoja de animación raster 2D para Godot del MISMO protagonista de la imagen de referencia. Mantén exactamente rostro, gafas negras, peinado oscuro, chaleco verde azulado con dos bolsillos, camiseta marfil, pañuelo mostaza, pantalón corto azul y botas marrones. Acabado texturizado y sombreado suave idéntico. Cámara lateral fija mirando a la derecha, ligera vista de la cara igual a la referencia. Ningún giro de cámara.
Una sola acción: un salto completo en el sitio, seis fases DISTINTAS: (1) impulso con pierna extendida y brazos arriba; (2) ascenso con rodillas recogidas; (3) ápice compacto con brazos abiertos; (4) descenso con pies hacia abajo preparados; (5) aterrizaje claramente agachado absorbiendo impacto; (6) recuperar postura. No trasladar al personaje fuera del centro de su celda: la física del juego moverá el sprite.
CUADRÍCULA EXACTA de 3 columnas por 2 filas, 6 fotogramas de izquierda a derecha y luego de arriba abajo. Lienzo 1536 x 1024, celdas cuadradas iguales de 512x512 sin líneas ni divisores. Cada figura de cuerpo completo, misma escala (altura de pie 390 píxeles), centro horizontal en x256 y plano de apoyo local y460 en cada celda; margen transparente de al menos 25px en todos los bordes. No llenar el lienzo con un solo personaje: repetir el mismo personaje 6 veces, una pose por celda. Pies completos y gafas legibles. Fondo alfa realmente transparente, sin suelo, sin sombras externas, sin texto, números, marcas o efectos. Cambia únicamente la pose de la acción. No reinterpretes el vestuario.
```

## jump_correction

```text
Edición técnica de esta hoja de sprites: elimina completamente el fondo marrón, los halos de luz, la viñeta y cualquier sombra fuera de las figuras. Debe quedar transparencia real de alfa cero alrededor y entre los SEIS personajes. Conserva las seis poses, rostro, gafas, ropa, colores y proporciones exactamente como están. Conserva el lienzo horizontal 1536x1024 y la cuadrícula exacta de 3 columnas y 2 filas con celdas de 512x512. Ajusta solo la escala común de las seis figuras al 85% de la actual alrededor del centro de cada celda para dejar 30px transparentes mínimos en TODOS los bordes y entre filas. Ninguna figura puede tocar o cruzar su celda. Sin suelo, sin sombras, sin fondo de ningún color, sin cuadrícula dibujada, sin texto. Entrega un PNG con fondo realmente transparente. No añadas una escena.
```

## jump_final

```text
Hoja de sprites CUADRADA, CUATRO poses del MISMO protagonista de la referencia en DOS columnas y DOS filas. Fondo transparente alfa cero. Cada figura pequeña y completa, ocupando SOLO el 60% central de su cuadrante, con un margen amplio totalmente vacío alrededor. Nunca deben tocarse, superponerse ni cruzar los límites entre cuadrantes. Mantén mismo tamaño, dirección hacia la derecha, rostro, pelo oscuro, gafas negras grandes, chaleco de tela verde azulado, camiseta marfil, pañuelo mostaza, pantalón corto azul y botas marrones. Mismo acabado raster 2D texturizado, luz suave desde arriba izquierda y cámara lateral fija. No representar un modelo ni una escena 3D.
Acción única, en orden izquierda a derecha y después abajo: Salto completo: 1 impulso con brazos elevados y pies extendidos, 2 ápice con rodillas recogidas, 3 descenso con pies preparados abajo, 4 aterrizaje agachado.
No hay suelo, sombras externas, halo, fondo, letras, números, bordes ni cuadrícula pintada. Todo el espacio entre figuras debe estar completamente vacío y transparente.
```

## carry

```text
Crea una hoja de sprites 2D con CUATRO fotogramas del mismo personaje de referencia, cuadrícula de DOS columnas y DOS filas sobre un lienzo CUADRADO. No generar imagen panorámica. Cada cuadrante es una celda idéntica, con la figura COMPLETA dentro y amplio espacio vacío de un 12% en TODOS sus bordes. Altura del personaje de pie solo el 70% de la altura de la celda, pies en el 85% de la altura local, mismo tamaño en las cuatro poses. Personaje en el centro de cada celda mirando a la derecha. Conserva su rostro, pelo oscuro, gafas negras grandes, chaleco verde azulado, camiseta marfil, pañuelo mostaza, pantalones cortos azules y botas marrones, con el mismo acabado raster texturizado y sombreado suave. Cámara lateral idéntica fija.
ÚNICA ACCIÓN, orden de izquierda a derecha y después abajo: Ciclo de caminar sujetando un objeto invisible con ambas manos delante del pecho: 1 contacto izquierdo, 2 cruce izquierdo, 3 contacto derecho, 4 cruce derecho. Las manos se mantienen juntas delante del pecho. No dibujar el objeto.
Las manos van VACÍAS, cualquier objeto se dibujará en el juego. PNG RGBA con transparencia total ALFA CERO en todo lo que no sea cuerpo o ropa, incluso entre las cuatro figuras y en los bordes. Sin halo, viñeta, degradado, luz fuera del cuerpo, sombras en el suelo, fondo coloreado, líneas, números ni texto.
```

## grab

```text
Crea una hoja de sprites 2D con CUATRO fotogramas del mismo personaje de referencia, cuadrícula de DOS columnas y DOS filas sobre un lienzo CUADRADO. No generar imagen panorámica. Cada cuadrante es una celda idéntica, con la figura COMPLETA dentro y amplio espacio vacío de un 12% en TODOS sus bordes. Altura del personaje de pie solo el 70% de la altura de la celda, pies en el 85% de la altura local, mismo tamaño en las cuatro poses. Personaje en el centro de cada celda mirando a la derecha. Conserva su rostro, pelo oscuro, gafas negras grandes, chaleco verde azulado, camiseta marfil, pañuelo mostaza, pantalones cortos azules y botas marrones, con el mismo acabado raster texturizado y sombreado suave. Cámara lateral idéntica fija.
ÚNICA ACCIÓN, orden de izquierda a derecha y después abajo: recoger un objeto invisible frente a sí: (1) agacharse con rodillas flexionadas; (2) extender ambos brazos hacia delante y abajo, manos vacías; (3) levantarse acercando ambas manos al pecho; (4) terminar con manos sosteniendo un espacio vacío delante del pecho. NO dibujar ningún objeto.
Las manos van VACÍAS, cualquier objeto se dibujará en el juego. PNG RGBA con transparencia total ALFA CERO en todo lo que no sea cuerpo o ropa, incluso entre las cuatro figuras y en los bordes. Sin halo, viñeta, degradado, luz fuera del cuerpo, sombras en el suelo, fondo coloreado, líneas, números ni texto.
```

## throw

```text
Crea una hoja de sprites 2D con CUATRO fotogramas del mismo personaje de referencia, cuadrícula de DOS columnas y DOS filas sobre un lienzo CUADRADO. No generar imagen panorámica. Cada cuadrante es una celda idéntica, con la figura COMPLETA dentro y amplio espacio vacío de un 12% en TODOS sus bordes. Altura del personaje de pie solo el 70% de la altura de la celda, pies en el 85% de la altura local, mismo tamaño en las cuatro poses. Personaje en el centro de cada celda mirando a la derecha. Conserva su rostro, pelo oscuro, gafas negras grandes, chaleco verde azulado, camiseta marfil, pañuelo mostaza, pantalones cortos azules y botas marrones, con el mismo acabado raster texturizado y sombreado suave. Cámara lateral idéntica fija.
ÚNICA ACCIÓN, orden de izquierda a derecha y después abajo: lanzar hacia la derecha con ambas manos: (1) recoger brazos y manos vacías junto al pecho, (2) anticipar rotando torso atrás sin cambiar cámara, (3) extender ambos brazos claramente hacia la derecha y abrir las manos: este es el fotograma de SUELTA, (4) seguimiento con brazos descendiendo y torso hacia delante. Sin objeto, sin proyectiles, sin efectos.
Las manos van VACÍAS, cualquier objeto se dibujará en el juego. PNG RGBA con transparencia total ALFA CERO en todo lo que no sea cuerpo o ropa, incluso entre las cuatro figuras y en los bordes. Sin halo, viñeta, degradado, luz fuera del cuerpo, sombras en el suelo, fondo coloreado, líneas, números ni texto.
```

## hurt

```text
Crea una hoja de sprites 2D con CUATRO fotogramas del mismo personaje de referencia, cuadrícula de DOS columnas y DOS filas sobre un lienzo CUADRADO. No generar imagen panorámica. Cada cuadrante es una celda idéntica, con la figura COMPLETA dentro y amplio espacio vacío de un 12% en TODOS sus bordes. Altura del personaje de pie solo el 70% de la altura de la celda, pies en el 85% de la altura local, mismo tamaño en las cuatro poses. Personaje en el centro de cada celda mirando a la derecha. Conserva su rostro, pelo oscuro, gafas negras grandes, chaleco verde azulado, camiseta marfil, pañuelo mostaza, pantalones cortos azules y botas marrones, con el mismo acabado raster texturizado y sombreado suave. Cámara lateral idéntica fija.
ÚNICA ACCIÓN, orden de izquierda a derecha y después abajo: reacción leve de sorpresa al recibir un golpe en un videojuego familiar: (1) sobresalto y hombros elevados; (2) tronco retrocede con manos abiertas y ojos sorprendidos; (3) flexionar rodillas para recuperar equilibrio; (4) recuperar postura. Expresiones legibles sin violencia gráfica, sin heridas, sin destellos.
Las manos van VACÍAS, cualquier objeto se dibujará en el juego. PNG RGBA con transparencia total ALFA CERO en todo lo que no sea cuerpo o ropa, incluso entre las cuatro figuras y en los bordes. Sin halo, viñeta, degradado, luz fuera del cuerpo, sombras en el suelo, fondo coloreado, líneas, números ni texto.
```

## defeated

```text
Hoja de sprites CUADRADA, CUATRO poses del MISMO protagonista de la referencia en DOS columnas y DOS filas. Fondo transparente alfa cero. Cada figura pequeña y completa, ocupando SOLO el 60% central de su cuadrante, con un margen amplio totalmente vacío alrededor. Nunca deben tocarse, superponerse ni cruzar los límites entre cuadrantes. Mantén mismo tamaño, dirección hacia la derecha, rostro, pelo oscuro, gafas negras grandes, chaleco de tela verde azulado, camiseta marfil, pañuelo mostaza, pantalón corto azul y botas marrones. Mismo acabado raster 2D texturizado, luz suave desde arriba izquierda y cámara lateral fija. No representar un modelo ni una escena 3D.
Acción única, en orden izquierda a derecha y después abajo: derrota amable de videojuego familiar: (1) bajar cabeza con decepción; (2) rodillas se flexionan; (3) sentarse en el suelo de manera suave, manos en rodillas; (4) sentado mirando al jugador con expresión de 'lo intentaré de nuevo'. Mantener todas las extremidades y botas dentro de su celda. Sin daño, heridas, estrellas ni texto.
No hay suelo, sombras externas, halo, fondo, letras, números, bordes ni cuadrícula pintada. Todo el espacio entre figuras debe estar completamente vacío y transparente.
```

## victory

```text
Hoja de sprites CUADRADA, CUATRO poses del MISMO protagonista de la referencia en DOS columnas y DOS filas. Fondo transparente alfa cero. Cada figura pequeña y completa, ocupando SOLO el 60% central de su cuadrante, con un margen amplio totalmente vacío alrededor. Nunca deben tocarse, superponerse ni cruzar los límites entre cuadrantes. Mantén mismo tamaño, dirección hacia la derecha, rostro, pelo oscuro, gafas negras grandes, chaleco de tela verde azulado, camiseta marfil, pañuelo mostaza, pantalón corto azul y botas marrones. Mismo acabado raster 2D texturizado, luz suave desde arriba izquierda y cámara lateral fija. No representar un modelo ni una escena 3D.
Acción única, en orden izquierda a derecha y después abajo: celebración breve: (1) sonrisa con manos junto al pecho; (2) levantar un brazo con puño cerrado de alegría, (3) ambos brazos arriba sonriendo, (4) terminar orgulloso con una mano en cintura y otra saludando. No cambiar el ángulo de cámara.
No hay suelo, sombras externas, halo, fondo, letras, números, bordes ni cuadrícula pintada. Todo el espacio entre figuras debe estar completamente vacío y transparente.
```


## Agacharse · 16 de octubre de 2026

Herramienta integrada `image_gen`, referencia `concept_v001.png`, fondo transparente solicitado. El prompt completo se conserva en [crouch-prompt.txt](crouch-prompt.txt); resultado sin retoque por código: `game/assets/textures/characters/diego/crouch_v001.png`.
