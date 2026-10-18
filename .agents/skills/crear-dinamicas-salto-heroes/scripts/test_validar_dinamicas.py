"""Regresiones de reglas de diseño; no constituyen pruebas jugables."""

import copy
import io
import json
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path

import validar_dinamicas as comprobador


ASSETS = Path(__file__).resolve().parents[1] / "assets"


def leer(nombre):
    return json.loads((ASSETS / nombre).read_text(encoding="utf-8"))


def mundo_ejemplo():
    niveles = []
    for orden in (1, 2, 3):
        nivel = leer("ejemplo-nivel-bosque.json")
        nivel.update(id=f"world_01_level_{orden:02d}", orden=orden)
        nivel["desbloqueo_requiere"] = [] if orden == 1 else [f"world_01_level_{orden-1:02d}"]
        nivel["coleccionables"][0]["id"] = f"objeto_nivel_{orden}"
        nivel["coleccionables"][0]["dificultad"] = ("inicial", "intermedia", "maxima")[orden - 1]
        niveles.append(nivel)
    jefe = copy.deepcopy(niveles[0])
    jefe.update(id="world_01_boss", categoria="jefe", orden=4, nombre="Encuentro propuesto de ejemplo")
    jefe["desbloqueo_requiere"] = [nivel["id"] for nivel in niveles]
    jefe["dinamicas_nuevas_obligatorias"] = ["jefe_lanzamientos"]
    jefe["segmentos"] = [{"id": "combate", "nombre": "Aprender el patrón", "principal": True,
                          "minutos_estimados": [6, 8], "dinamicas": ["jefe_lanzamientos"],
                          "proposito": "Esquivar ataques anunciados y lanzar durante la vulnerabilidad."}]
    jefe["llaves"] = []
    jefe["zonas_secretas"] = []
    jefe["coleccionables"] = []
    jefe["salida"]["condicion"] = "jefe_derrotado"
    jefe["salida"]["descripcion"] = "Completar al derrotar al jefe mediante objetos lanzados."
    jefe["puntos_control"] = []
    jefe["intervalo_maximo_faroles_minutos"] = 8
    jefe["duracion"].update(minimo_primera_partida_minutos=6, objetivo_minutos=[6, 8])
    return niveles + [jefe]


class ReglasDeDiseno(unittest.TestCase):
    def assert_error(self, doc, fragmento):
        errores, _ = comprobador.validar(doc)
        self.assertTrue(any(fragmento in error for error in errores), errores)

    def test_ejemplos_completos(self):
        for nombre in ("ejemplo-dinamica-puente.json", "ejemplo-nivel-bosque.json"):
            with self.subTest(nombre=nombre):
                self.assertEqual(comprobador.validar(leer(nombre))[0], [])

    def test_plantillas_requieren_completar(self):
        for nombre in ("dinamica.template.json", "nivel.template.json"):
            with self.subTest(nombre=nombre):
                self.assertTrue(comprobador.validar(leer(nombre))[0])

    def test_llave_duplicada_no_abre_salida(self):
        doc = leer("ejemplo-nivel-bosque.json")
        doc["llaves"][2]["ranura"] = 2
        self.assert_error(doc, "tres ranuras")

    def test_llave_en_ruta_opcional_no_es_obligatoria_valida(self):
        doc = leer("ejemplo-nivel-bosque.json")
        doc["llaves"][0]["segmento_id"] = "cristales_opcionales"
        self.assert_error(doc, "segmento principal")

    def test_excepcion_duracion_debe_estar_autorizada(self):
        doc = leer("ejemplo-nivel-bosque.json")
        doc["duracion"]["minimo_primera_partida_minutos"] = 9
        self.assert_error(doc, "el mínimo de aventura es 15 minutos")
        doc["duracion"]["excepcion_duracion_usuario"] = {
            "fecha": "2026-10-17",
            "solicitud": "El usuario ha solicitado acortar este nivel a la mitad del tiempo anterior."
        }
        self.assertEqual(comprobador.validar(doc)[0], [])
        doc["duracion"]["excepcion_duracion_usuario"]["solicitud"] = ""
        self.assert_error(doc, "petición explícita del usuario")

    def test_opcionales_no_inflan_minimo(self):
        doc = leer("ejemplo-nivel-bosque.json")
        for segmento in doc["segmentos"]:
            segmento["minutos_estimados"] = [0.5, 1] if segmento["principal"] else [100, 200]
        self.assert_error(doc, "solo suma 6")

    def test_segmento_repetido_no_se_cuenta_dos_veces(self):
        doc = leer("ejemplo-nivel-bosque.json")
        doc["segmentos"].append(copy.deepcopy(doc["segmentos"][0]))
        self.assert_error(doc, "segmento duplicado")

    def test_farol_no_puede_referir_segmento_inexistente(self):
        doc = leer("ejemplo-nivel-bosque.json")
        doc["puntos_control"][0]["despues_de_segmento_id"] = "no_existe"
        self.assert_error(doc, "farol debe seguir")

    def test_tramo_largo_sin_control_requiere_revision(self):
        doc = leer("ejemplo-nivel-bosque.json")
        doc["puntos_control"] = doc["puntos_control"][:1]
        self.assert_error(doc, "sin farol")

    def test_duracion_medida_exige_muestras(self):
        doc = leer("ejemplo-nivel-bosque.json")
        doc["duracion"]["estado"] = "medida"
        self.assert_error(doc, "muestras reales")

    def test_muestra_con_exclusiones_y_minimo(self):
        doc = leer("ejemplo-nivel-bosque.json")
        muestra = dict(id="sesion_anonima_01", perfil="primera_partida_publico_objetivo",
                       minutos_ruta_principal=18, pausas_cargas_excluidas=True,
                       reintentos_excluidos=True, opcionales_excluidos=True)
        doc["duracion"].update(estado="medida", muestras=[muestra])
        self.assertEqual(comprobador.validar(doc)[0], [])
        muestra["minutos_ruta_principal"] = 14.9
        self.assert_error(doc, "por debajo del mínimo")
        muestra["minutos_ruta_principal"] = 18
        muestra["opcionales_excluidos"] = False
        self.assert_error(doc, "opcionales_excluidos")

    def test_implementacion_exige_evidencia_y_dependencias(self):
        doc = leer("ejemplo-dinamica-puente.json")
        doc["estado"] = "implementada"
        self.assert_error(doc, "evidencia real")
        doc["validacion"]["evidencias"] = ["Referencia de ensayo para comprobar la regla del script."]
        doc["dependencias"][1]["estado"] = "propuesta"
        self.assert_error(doc, "trabajo pendiente")

    def test_cada_aventura_actual_necesita_secreto_y_coleccion(self):
        for campo in ("zonas_secretas", "coleccionables"):
            for valor in (None, []):
                doc = leer("ejemplo-nivel-bosque.json")
                doc[campo] = valor
                with self.subTest(campo=campo, valor=valor):
                    self.assert_error(doc, campo)

    def test_secreto_con_totem_y_ruta_opcional(self):
        for cambio, error in (({"totem": None}, ".totem"), ({"opcional": False}, "opcional"),
                               ({"segmento_id": "entrada_segura"}, "segmento opcional"),
                               ({"salida": ""}, ".salida")):
            doc = leer("ejemplo-nivel-bosque.json")
            doc["zonas_secretas"][0].update(cambio)
            with self.subTest(cambio=cambio):
                self.assert_error(doc, error)

    def test_secreto_pendiente_es_propuesta_y_no_implementacion(self):
        doc = leer("ejemplo-nivel-bosque.json")
        self.assertEqual(comprobador.validar(doc)[0], [])
        doc["estado"] = "implementada"
        doc["validacion"]["evidencias"] = ["Ensayo sintético del comprobador, no evidencia del juego."]
        self.assert_error(doc, "antes de implementar")
        zona = doc["zonas_secretas"][0]
        zona["validacion_usuario"] = dict(estado="validada", fecha="2026-10-18",
            decision="Respuesta sintética exclusivamente para esta prueba.",
            ubicacion_validada=zona["ubicacion"], actividad_validada=zona["actividad"])
        self.assertEqual(comprobador.validar(doc)[0], [])
        zona["actividad"] = "Otra actividad todavía sin consultar."
        self.assert_error(doc, "consultar de nuevo")

    def test_validacion_no_se_inventa_con_estado_solo(self):
        doc = leer("ejemplo-nivel-bosque.json")
        doc["zonas_secretas"][0]["validacion_usuario"] = {"estado": "validada"}
        self.assert_error(doc, "fecha")
        self.assert_error(doc, "decision")
        self.assert_error(doc, "ubicacion_validada")

    def test_distribucion_intermedia_y_maxima_por_nivel(self):
        mundo = mundo_ejemplo()
        for orden, dificultad in ((1, "intermedia"), (1, "maxima"), (2, "maxima"), (3, "intermedia")):
            doc = copy.deepcopy(mundo[orden - 1])
            doc["coleccionables"][0]["dificultad"] = dificultad
            with self.subTest(orden=orden, dificultad=dificultad):
                self.assert_error(doc, "reservar para aventura")
        jefe = mundo[-1]
        item = copy.deepcopy(mundo[2]["coleccionables"][0])
        item["segmento_id"] = "combate"
        jefe["coleccionables"] = [item]
        self.assert_error(jefe, "antes del jefe")

    def test_mundo_sin_escalon_o_con_duplicados_es_incompleto(self):
        mundo = mundo_ejemplo()
        mundo[1]["coleccionables"][0]["id"] = mundo[0]["coleccionables"][0]["id"]
        self.assertTrue(any("duplicar IDs" in e for e in comprobador.validar_mundo(mundo)))
        mundo = mundo_ejemplo()
        mundo[2]["coleccionables"][0]["dificultad"] = "inicial"
        self.assertTrue(any("escalón" in e for e in comprobador.validar_mundo(mundo)))

    def test_version_1_se_conserva_pero_actual_la_rechaza(self):
        doc = leer("ejemplo-nivel-bosque.json")
        doc.update(schema_version=1)
        del doc["zonas_secretas"], doc["coleccionables"]
        self.assertEqual(comprobador.validar(doc)[0], [])
        with tempfile.TemporaryDirectory() as temporal:
            path = Path(temporal) / "legado.json"
            path.write_text(json.dumps(doc), encoding="utf-8")
            with redirect_stdout(io.StringIO()):
                self.assertEqual(comprobador.main([str(path)]), 0)
                self.assertEqual(comprobador.main(["--actual", str(path)]), 1)

    def test_numeros_y_tipos_invalidos_producen_diagnostico(self):
        for valor in (True, "18", float("nan"), float("inf"), -(10**6), 10**400):
            doc = leer("ejemplo-dinamica-puente.json")
            doc["minutos_estimados"] = [valor, 20]
            with self.subTest(valor=type(valor).__name__):
                self.assert_error(doc, "positivo finito")
        for doc in (None, [], {}, {"estado": [], "tipo": "nivel", "segmentos": [None]}):
            self.assertTrue(comprobador.validar(doc)[0])

    def test_mundo_y_jefe_con_duracion_propia(self):
        mundo = mundo_ejemplo()
        for nivel in mundo:
            self.assertEqual(comprobador.validar(nivel)[0], [])
        self.assertEqual(comprobador.validar_mundo(mundo), [])
        self.assertTrue(comprobador.validar_mundo(mundo[:-1]))
        mundo[-1]["desbloqueo_requiere"].pop()
        self.assert_error(mundo[-1], "tres aventuras")

    def test_ciclo_impide_desbloqueo(self):
        mundo = mundo_ejemplo()
        mundo[0]["desbloqueo_requiere"] = ["world_01_boss"]
        self.assertTrue(any("ciclo" in e for e in comprobador.validar_mundo(mundo)))

    def test_cli_rechaza_json_ambiguo_y_no_modifica_archivos(self):
        with tempfile.TemporaryDirectory() as temporal:
            path = Path(temporal) / "ficha.json"
            for contenido in ('{"id":"a","id":"b"}', '{"valor":NaN}', "{"):
                path.write_text(contenido, encoding="utf-8")
                with redirect_stdout(io.StringIO()):
                    self.assertEqual(comprobador.main([str(path)]), 1)
                self.assertEqual(path.read_text(encoding="utf-8"), contenido)
            path.write_text(json.dumps(leer("ejemplo-nivel-bosque.json")), encoding="utf-8")
            original = path.read_bytes()
            with redirect_stdout(io.StringIO()):
                self.assertEqual(comprobador.main([str(path)]), 0)
                self.assertEqual(comprobador.main([str(path), str(path)]), 1)
            self.assertEqual(path.read_bytes(), original)


if __name__ == "__main__":
    unittest.main()
