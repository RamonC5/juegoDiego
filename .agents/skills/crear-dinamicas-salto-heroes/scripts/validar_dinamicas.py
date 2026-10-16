#!/usr/bin/env python3
"""Comprobar fichas de diseño JSON sin modificar archivos ni ejecutar el juego."""

import argparse
import json
import math
import re
from pathlib import Path


ESTADOS = {"propuesta", "ampliacion", "implementada"}
IDENTIFICADOR = re.compile(r"[a-z][a-z0-9]*(?:_[a-z0-9]+)*\Z")


class Revision:
    def __init__(self):
        self.errores = []

    def exigir(self, condicion, ruta, mensaje):
        if not condicion:
            self.errores.append(f"{ruta}: {mensaje}")
        return condicion

    def objeto(self, valor, ruta):
        if self.exigir(isinstance(valor, dict), ruta, "debe ser un objeto"):
            return valor
        return {}

    def lista(self, valor, ruta, permitir_vacia=False):
        if not self.exigir(isinstance(valor, list), ruta, "debe ser una lista"):
            return []
        self.exigir(permitir_vacia or bool(valor), ruta, "no puede estar vacía")
        return valor

    def texto(self, valor, ruta):
        correcto = isinstance(valor, str) and bool(valor.strip())
        if correcto:
            correcto = valor.strip().lower() not in {"todo", "<completar>", "..."}
        return valor.strip() if self.exigir(correcto, ruta, "completar un texto no vacío") else ""

    def identificador(self, valor, ruta):
        texto = self.texto(valor, ruta)
        self.exigir(bool(IDENTIFICADOR.fullmatch(texto)), ruta, "usar un identificador snake_case")
        return texto

    def numero(self, valor, ruta):
        try:
            numero = float(valor) if type(valor) in (int, float) else 0.0
        except (OverflowError, ValueError):
            numero = 0.0
        correcto = math.isfinite(numero) and numero > 0
        return numero if self.exigir(correcto, ruta, "debe ser un número positivo finito") else 0.0

    def intervalo(self, valor, ruta):
        lista = self.lista(valor, ruta)
        if not self.exigir(len(lista) == 2, ruta, "usar [mínimo, máximo]"):
            return (0.0, 0.0)
        bajo = self.numero(lista[0], ruta + "[0]")
        alto = self.numero(lista[1], ruta + "[1]")
        self.exigir(bajo <= alto, ruta, "el mínimo no puede superar el máximo")
        return bajo, alto

    def textos(self, valor, ruta, permitir_vacia=False, identificadores=False):
        lista = self.lista(valor, ruta, permitir_vacia)
        revisar = self.identificador if identificadores else self.texto
        resultado = [revisar(item, f"{ruta}[{i}]") for i, item in enumerate(lista)]
        self.exigir(len(resultado) == len(set(resultado)), ruta, "no repetir entradas")
        return resultado

    def campos_texto(self, valor, ruta, campos):
        objeto = self.objeto(valor, ruta)
        for campo in campos:
            self.texto(objeto.get(campo), f"{ruta}.{campo}")
        return objeto


def comunes(doc, r):
    r.exigir(type(doc.get("schema_version")) is int and doc["schema_version"] == 1,
             "schema_version", "usar la versión entera 1")
    r.identificador(doc.get("id"), "id")
    r.texto(doc.get("nombre"), "nombre")
    r.exigir(doc.get("estado") in ESTADOS if isinstance(doc.get("estado"), str) else False,
             "estado", "usar propuesta, ampliacion o implementada")
    for i, fuente in enumerate(r.lista(doc.get("fuentes"), "fuentes")):
        r.campos_texto(fuente, f"fuentes[{i}]", ("ruta", "revision", "observacion"))
    r.campos_texto(doc.get("persistencia"), "persistencia", ("al_morir", "al_cerrar", "al_rejugar"))
    r.campos_texto(doc.get("accesibilidad"), "accesibilidad", (
        "senales_no_solo_color", "equivalencia_visual_sonora", "legibilidad_movil", "ajustes_control"))
    validacion = r.objeto(doc.get("validacion"), "validacion")
    r.textos(validacion.get("funcional"), "validacion.funcional")
    r.textos(validacion.get("jugando"), "validacion.jugando")
    pruebas = r.textos(validacion.get("evidencias"), "validacion.evidencias", permitir_vacia=True)
    if doc.get("estado") == "implementada":
        r.exigir(bool(pruebas), "validacion.evidencias", "una implementación necesita evidencia real")


def dinamica(doc, r):
    for campo in ("objetivo", "recompensa", "dificultad"):
        r.texto(doc.get(campo), campo)
    r.campos_texto(doc.get("controles"), "controles", ("tactil", "teclado", "mando"))
    r.campos_texto(doc.get("aprendizaje"), "aprendizaje", ("presentacion", "practica", "combinacion"))
    r.campos_texto(doc.get("reglas"), "reglas", ("activacion", "exito", "fallo", "recuperacion"))
    r.textos(doc.get("feedback"), "feedback")
    r.intervalo(doc.get("minutos_estimados"), "minutos_estimados")
    dependencias = []
    for i, valor in enumerate(r.lista(doc.get("dependencias"), "dependencias", permitir_vacia=True)):
        ruta = f"dependencias[{i}]"
        dep = r.objeto(valor, ruta)
        dependencias.append(r.identificador(dep.get("id"), ruta + ".id"))
        estado = dep.get("estado")
        r.exigir(isinstance(estado, str) and estado in ESTADOS, ruta + ".estado", "estado desconocido")
        r.texto(dep.get("detalle"), ruta + ".detalle")
        if doc.get("estado") == "implementada":
            r.exigir(estado == "implementada", ruta, "la ficha implementada depende de trabajo pendiente")
    r.exigir(len(dependencias) == len(set(dependencias)), "dependencias", "no repetir identificadores")


def nivel(doc, r):
    mundo = r.texto(doc.get("mundo_id"), "mundo_id")
    r.exigir(bool(re.fullmatch(r"world_0[1-8]", mundo)), "mundo_id", "usar world_01 a world_08")
    categoria = doc.get("categoria")
    r.exigir(categoria in ("aventura", "jefe"), "categoria", "usar aventura o jefe")
    aventura = categoria == "aventura"
    orden = doc.get("orden")
    correcto = type(orden) is int and orden in ((1, 2, 3) if aventura else (4,))
    if r.exigir(correcto, "orden", "usar 1–3 para aventura o 4 para jefe"):
        esperado = f"{mundo}_level_{orden:02d}" if aventura else f"{mundo}_boss"
        r.exigir(doc.get("id") == esperado, "id", f"debe ser {esperado}")
    desbloqueo = r.textos(doc.get("desbloqueo_requiere"), "desbloqueo_requiere", True, True)
    r.exigir(doc.get("id") not in desbloqueo, "desbloqueo_requiere", "un nivel no puede requerirse a sí mismo")
    if aventura and correcto and orden > 1:
        r.exigir(f"{mundo}_level_{orden - 1:02d}" in desbloqueo,
                 "desbloqueo_requiere", "incluir la aventura anterior")
    if categoria == "jefe":
        requeridos = {f"{mundo}_level_{i:02d}" for i in (1, 2, 3)}
        r.exigir(requeridos.issubset(desbloqueo), "desbloqueo_requiere", "el jefe exige las tres aventuras")

    nuevas = r.textos(doc.get("dinamicas_nuevas_obligatorias"), "dinamicas_nuevas_obligatorias", True, True)
    r.exigir(len(nuevas) <= 2, "dinamicas_nuevas_obligatorias", "introducir como máximo dos por nivel")
    segmentos = {}
    principales = []
    conocidas = set()
    for i, valor in enumerate(r.lista(doc.get("segmentos"), "segmentos")):
        ruta = f"segmentos[{i}]"
        seg = r.objeto(valor, ruta)
        identificador = r.identificador(seg.get("id"), ruta + ".id")
        r.exigir(identificador not in segmentos, ruta + ".id", "segmento duplicado")
        r.campos_texto(seg, ruta, ("nombre", "proposito"))
        r.exigir(type(seg.get("principal")) is bool, ruta + ".principal", "usar true o false")
        tiempos = r.intervalo(seg.get("minutos_estimados"), ruta + ".minutos_estimados")
        acciones = r.textos(seg.get("dinamicas"), ruta + ".dinamicas", identificadores=True)
        segmentos[identificador] = seg.get("principal") is True
        if seg.get("principal") is True:
            principales.append((identificador, tiempos))
            conocidas.update(acciones)
    r.exigir(bool(principales), "segmentos", "falta recorrido principal")
    r.exigir(set(nuevas).issubset(conocidas), "dinamicas_nuevas_obligatorias", "deben aparecer en la ruta principal")

    llaves = r.lista(doc.get("llaves"), "llaves", permitir_vacia=not aventura)
    r.exigir(len(llaves) == (3 if aventura else 0), "llaves", "usar tres en aventura y ninguna en jefe")
    ranuras, destinos = [], []
    for i, valor in enumerate(llaves):
        ruta = f"llaves[{i}]"
        llave = r.objeto(valor, ruta)
        ranura = llave.get("ranura")
        if r.exigir(type(ranura) is int and ranura in (1, 2, 3), ruta + ".ranura", "usar entero 1, 2 o 3"):
            ranuras.append(ranura)
        destino = r.identificador(llave.get("segmento_id"), ruta + ".segmento_id")
        destinos.append(destino)
        r.exigir(segmentos.get(destino) is True, ruta, "situar la llave en un segmento principal existente")
        r.texto(llave.get("obtencion"), ruta + ".obtencion")
    if aventura:
        r.exigir(sorted(ranuras) == [1, 2, 3], "llaves", "exigir las tres ranuras diferentes")
        r.exigir(len(set(destinos)) == 3, "llaves", "repartirlas en tres segmentos diferentes")
    salida = r.objeto(doc.get("salida"), "salida")
    condicion = "tres_llaves" if aventura else "jefe_derrotado"
    r.exigir(salida.get("condicion") == condicion, "salida.condicion", f"usar {condicion}")
    r.texto(salida.get("descripcion"), "salida.descripcion")
    r.exigir(salida.get("retorno_objetivos_pendientes") is True, "salida", "mantener retorno a objetivos pendientes")

    puntos = r.lista(doc.get("puntos_control"), "puntos_control", permitir_vacia=not aventura)
    nombres_puntos, cortes = [], []
    for i, valor in enumerate(puntos):
        ruta = f"puntos_control[{i}]"
        punto = r.objeto(valor, ruta)
        nombres_puntos.append(r.identificador(punto.get("id"), ruta + ".id"))
        destino = r.identificador(punto.get("despues_de_segmento_id"), ruta + ".despues_de_segmento_id")
        cortes.append(destino)
        r.exigir(segmentos.get(destino) is True, ruta, "el farol debe seguir a un segmento principal existente")
    r.exigir(len(nombres_puntos) == len(set(nombres_puntos)), "puntos_control", "no repetir identificadores")
    r.exigir(len(cortes) == len(set(cortes)), "puntos_control", "no duplicar un punto de control")
    limite = r.numero(doc.get("intervalo_maximo_faroles_minutos"), "intervalo_maximo_faroles_minutos")
    tramo, mayor = 0.0, 0.0
    for identificador, tiempos in principales:
        tramo += tiempos[1]
        if identificador in cortes:
            mayor = max(mayor, tramo)
            tramo = 0.0
    mayor = max(mayor, tramo)
    r.exigir(mayor <= limite + 1e-8, "puntos_control", f"hay un tramo estimado de {mayor:g} min sin farol; límite {limite:g}")

    duracion = r.objeto(doc.get("duracion"), "duracion")
    minimo = r.numero(duracion.get("minimo_primera_partida_minutos"), "duracion.minimo_primera_partida_minutos")
    if aventura:
        r.exigir(minimo >= 15, "duracion", "el mínimo de aventura es 15 minutos")
    objetivo = r.intervalo(duracion.get("objetivo_minutos"), "duracion.objetivo_minutos")
    bajo = math.fsum(t[0] for _, t in principales)
    alto = math.fsum(t[1] for _, t in principales)
    r.exigir(objetivo[0] >= minimo, "duracion.objetivo_minutos", "el objetivo no puede rebajar el mínimo")
    r.exigir(bajo + 1e-8 >= minimo, "duracion", f"la ruta principal solo suma {bajo:g} min mínimos estimados")
    r.exigir(bajo + 1e-8 >= objetivo[0] and alto <= objetivo[1] + 1e-8,
             "duracion", f"el presupuesto principal [{bajo:g}, {alto:g}] no cabe en el objetivo")
    r.exigir(duracion.get("estado") in ("estimada", "medida"), "duracion.estado", "usar estimada o medida")
    muestras = r.lista(duracion.get("muestras"), "duracion.muestras", permitir_vacia=True)
    if duracion.get("estado") == "medida":
        r.exigir(bool(muestras), "duracion.muestras", "la duración medida necesita muestras reales")
    ids_muestras = []
    for i, valor in enumerate(muestras):
        ruta = f"duracion.muestras[{i}]"
        muestra = r.objeto(valor, ruta)
        ids_muestras.append(r.identificador(muestra.get("id"), ruta + ".id"))
        r.exigir(muestra.get("perfil") == "primera_partida_publico_objetivo", ruta + ".perfil", "usar primera partida del público objetivo")
        minutos = r.numero(muestra.get("minutos_ruta_principal"), ruta + ".minutos_ruta_principal")
        r.exigir(minutos >= minimo, ruta, "la muestra queda por debajo del mínimo; revisar el nivel")
        for campo in ("pausas_cargas_excluidas", "reintentos_excluidos", "opcionales_excluidos"):
            r.exigir(muestra.get(campo) is True, ruta + "." + campo, "confirmar exclusión con true")
    r.exigir(len(ids_muestras) == len(set(ids_muestras)), "duracion.muestras", "no repetir muestras")
    return f"ruta principal: {bajo:g}–{alto:g} min estimados; duración {duracion.get('estado', 'desconocida')}"


def validar(doc):
    r = Revision()
    doc = r.objeto(doc, "ficha")
    comunes(doc, r)
    resumen = "ficha de dinámica"
    if doc.get("tipo") == "dinamica":
        dinamica(doc, r)
    elif doc.get("tipo") == "nivel":
        resumen = nivel(doc, r)
    else:
        r.exigir(False, "tipo", "usar dinamica o nivel")
    return r.errores, resumen


def validar_mundo(documentos):
    r = Revision()
    niveles = [d for d in documentos if isinstance(d, dict) and d.get("tipo") == "nivel"]
    mundos = {d.get("mundo_id") for d in niveles if isinstance(d.get("mundo_id"), str)}
    r.exigir(len(niveles) == 4 and len(mundos) == 1, "mundo", "adjuntar las tres aventuras y su jefe de un único mundo")
    pares = [(d.get("categoria"), d.get("orden")) for d in niveles]
    esperados = [("aventura", 1), ("aventura", 2), ("aventura", 3), ("jefe", 4)]
    r.exigir(all(pares.count(p) == 1 for p in esperados), "mundo", "necesita aventuras 1, 2 y 3 y jefe 4")
    por_id = {d["id"]: d for d in niveles if isinstance(d.get("id"), str)}
    visitados, activos = set(), set()

    def visitar(identificador):
        if identificador in activos:
            r.exigir(False, "desbloqueo_requiere", "hay un ciclo de desbloqueo")
            return
        if identificador in visitados:
            return
        activos.add(identificador)
        dato = por_id[identificador]
        requisitos = dato.get("desbloqueo_requiere", [])
        for requerido in requisitos if isinstance(requisitos, list) else []:
            if not isinstance(requerido, str):
                continue
            if requerido in por_id:
                visitar(requerido)
            elif requerido.startswith(str(dato.get("mundo_id")) + "_"):
                r.exigir(False, "desbloqueo_requiere", f"no existe {requerido} en las fichas del mundo")
        activos.remove(identificador)
        visitados.add(identificador)

    for identificador in por_id:
        visitar(identificador)
    return r.errores


def sin_repetidos(pares):
    resultado = {}
    for clave, valor in pares:
        if clave in resultado:
            raise ValueError(f"clave JSON repetida: {clave}")
        resultado[clave] = valor
    return resultado


def rechazar_constante(valor):
    raise ValueError(f"número JSON no válido: {valor}")


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archivos", nargs="+", type=Path, help="Fichas JSON completadas")
    parser.add_argument("--mundo", action="store_true", help="Revisar juntas las tres aventuras y su jefe")
    args = parser.parse_args(argv)
    documentos, ids, errores = [], set(), 0
    for archivo in args.archivos:
        try:
            doc = json.loads(archivo.read_text(encoding="utf-8"), object_pairs_hook=sin_repetidos,
                             parse_constant=rechazar_constante)
        except (OSError, UnicodeError, ValueError, RecursionError) as exc:
            print(f"ERROR {archivo}: {exc}")
            errores += 1
            continue
        fallos, resumen = validar(doc)
        identificador = doc.get("id") if isinstance(doc, dict) else None
        if isinstance(identificador, str):
            if identificador in ids:
                fallos.append("id: ficha repetida entre archivos")
            ids.add(identificador)
        documentos.append(doc)
        errores += len(fallos)
        if fallos:
            for fallo in fallos:
                print(f"ERROR {archivo}: {fallo}")
        else:
            print(f"CORRECTO {archivo}: {resumen}")
    if args.mundo:
        for fallo in validar_mundo(documentos):
            print(f"ERROR {fallo}")
            errores += 1
    if errores:
        print(f"Revisar {errores} error(es). No se modificó ningún archivo.")
        return 1
    print("Consistencia documental correcta. Física, duración real y accesibilidad requieren pruebas jugando.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
