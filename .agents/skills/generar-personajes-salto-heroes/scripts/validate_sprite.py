#!/usr/bin/env python3
"""Inspeccionar PNG de sprites sin modificar los archivos; emitir un informe JSON."""

import argparse
import json
from pathlib import Path


def positive(value):
    number = int(value)
    if number <= 0:
        raise argparse.ArgumentTypeError("El valor debe ser mayor que cero.")
    return number


def nonnegative(value):
    number = int(value)
    if number < 0:
        raise argparse.ArgumentTypeError("El valor no puede ser negativo.")
    return number


def inspect_sprite(options):
    from PIL import Image

    report = {"path": str(options.path), "ok": False, "errors": [], "frames": []}
    errors = report["errors"]
    try:
        with Image.open(options.path) as image:
            width, height = image.size
            report.update({"size": [width, height], "mode": image.mode})
            if image.format != "PNG":
                errors.append("El archivo debe ser PNG.")
            if image.mode != "RGBA":
                errors.append("El PNG debe usar RGBA con canal alfa explícito.")
            if max(width, height) > options.max_size:
                errors.append(f"La imagen supera el máximo configurado de {options.max_size} píxeles por lado.")
            frame_width = options.frame_width or width
            frame_height = options.frame_height or height
            if width % frame_width or height % frame_height:
                errors.append("Las dimensiones no forman una cuadrícula exacta con la celda indicada.")
            if errors:
                return report

            columns, rows = width // frame_width, height // frame_height
            capacity = columns * rows
            active_frames = options.frames if options.frames is not None else capacity
            report.update({"grid": [columns, rows], "frame_size": [frame_width, frame_height], "active_frames": active_frames})
            if active_frames > capacity:
                errors.append("El número de fotogramas supera las celdas disponibles.")
                return report

            alpha = image.getchannel("A")
            if alpha.getextrema()[0] != 0:
                errors.append("No hay píxeles completamente transparentes en el fondo.")

            for index in range(capacity):
                x = (index % columns) * frame_width
                y = (index // columns) * frame_height
                bounds = alpha.crop((x, y, x + frame_width, y + frame_height)).getbbox()
                if index >= active_frames:
                    if bounds is not None:
                        errors.append(f"La celda sin usar {index} contiene píxeles visibles.")
                    continue
                record = {"index": index, "alpha_bounds": list(bounds) if bounds else None}
                report["frames"].append(record)
                if bounds is None:
                    errors.append(f"El fotograma activo {index} está vacío.")
                    continue
                left, top, right, bottom = bounds
                padding = min(left, top, frame_width - right, frame_height - bottom)
                record["minimum_padding"] = padding
                if padding < options.min_padding:
                    errors.append(f"El fotograma {index} tiene {padding} píxeles de margen mínimo; requiere {options.min_padding}.")
    except (OSError, ValueError, Image.DecompressionBombError) as error:
        errors.append(f"No se pudo inspeccionar la imagen: {error}")
    report["ok"] = not errors
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", type=Path)
    parser.add_argument("--frame-width", type=positive)
    parser.add_argument("--frame-height", type=positive)
    parser.add_argument("--frames", type=positive)
    parser.add_argument("--min-padding", type=nonnegative, default=4)
    parser.add_argument("--max-size", type=positive, default=2048)
    options = parser.parse_args()
    if (options.frame_width is None) != (options.frame_height is None):
        parser.error("Indicar --frame-width y --frame-height juntos.")
    try:
        report = inspect_sprite(options)
    except ImportError:
        print(json.dumps({"ok": False, "errors": ["Falta Pillow en el entorno de desarrollo."]}, ensure_ascii=False))
        return 2
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
