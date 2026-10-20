# Bosque 1-3 · Las raíces de Nudor

La tercera aventura cierra el recorrido del Bosque Esmeralda y desbloquea a **Nudor, el Roble Furioso**. Conserva una aventura completa antes del encuentro: tres llaves abren la salida y después aparece **Enfrentarse a Nudor**. El selector permite repetir las aventuras y el jefe.

## Recorrido integrado · 0.15.0

Dieciséis tramos combinan cinco puentes de diana, cuatro troncos viajeros, cuatro setas, tres barrancos de cinco lianas y dieciséis portones de dos marcas. Hay 58 patrullas terrestres y siete Nóctilos con vuelos fijos. Se combinan acciones aprendidas en 1-1 y 1-2, sin añadir gestos. Las piñas se reponen.

| Elemento | Posición | Regla |
| --- | --- | --- |
| Llave 1 | (19100, 550) | Después de La primera raíz |
| Llave 2 | (43100, 550) | Después de La segunda raíz |
| Llave 3 | (71900, 550) | Después de La tercera raíz |
| Faroles | (19320,600), (38520,600), (57720,600) | Exactamente tres, sin curación |
| Cristales máximos | (18845,-90), (42845,-90), (71645,-90) | Desvíos opcionales |
| Salida | (76620, 600) | Solo exige las tres llaves |

Los cristales ofrecen el mayor reto opcional del bosque: desde la terraza a y=345, subir por tres ramas de 170 px de ancho a y=215,85,−45. Los huecos son de 40 px; se puede volver por el mismo camino o al suelo. No condicionan el jefe ni los trajes. La colección usa IDs propios; los recursos e IDs de 1-1 y 1-2 se mantienen.

Presupuesto de primera partida: **18–22 minutos estimados**, excluyendo secretos, pausas, cinemáticas y reintentos. La ruta automática protegida tardó 518,3 segundos simulados; acredita geometría, no duración humana ni dificultad infantil.

## Secreto pendiente de elección

Propuesta presentada el 20-10-2026: **gruta bajo las raíces junto al segundo farol**, con tótem, entrada agachándose, hojas, brote de vida y regreso en ascensor. No se recibió validación. `secret_grove` y `canopy_secret` permanecen desactivados; no se ha construido el secreto ni su arte.

La ficha queda en `ampliacion`, con validación pendiente, según el [skill de dinámicas](../.agents/skills/crear-dinamicas-salto-heroes/SKILL.md). El recorrido y el combate pueden probarse independientemente.

## Claro de Nudor

Exige completar las tres aventuras. El encuentro no añade faroles ni llaves: su entrada es el reintento local del combate. Morir reinicia salud, estado y piñas de Nudor sin repetir 1-3. La colección y el equipo se conservan. La victoria se guarda como `world_01_boss`, una vez por intento, sin abrir otros mundos.

[Contrato de Nudor](jefes/nudor.md) · [Ficha](niveles/world_01_level_03.json) · [Pruebas y límites](pruebas/bosque-1-3-nudor.md).
