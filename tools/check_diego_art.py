#!/usr/bin/env python3
"""Comprobar PNG y colocación efectiva de atlas sin modificar imágenes."""

import hashlib
import json
import subprocess
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "art/characters/diego"
CHECKER = ROOT / ".agents/skills/generar-personajes-salto-heroes/scripts/validate_sprite.py"


def inspect(path, columns=1, rows=1):
    image = Image.open(ROOT / path)
    args = [sys.executable, str(CHECKER), path, "--frame-width", str(image.width // columns),
            "--frame-height", str(image.height // rows), "--frames", str(columns * rows)]
    result = subprocess.run(args, cwd=ROOT, capture_output=True, text=True)
    return json.loads(result.stdout)


def main():
    layout = json.loads((ART / "atlas_layout.json").read_text())
    report = {"schema_version": 1, "concept": inspect("art/characters/diego/concept_v001.png"),
              "source_sheets": {}, "atlas": {"ok": True, "frames": [], "errors": []},
              "files": {}, "rgba8_bytes_without_compression": 0}
    for name, sheet in layout["sheets"].items():
        path = ROOT / sheet["path"]
        data = path.read_bytes()
        image = Image.open(path)
        count = len(sheet["frames"])
        report["source_sheets"][name] = inspect(sheet["path"], count // 2, 2)
        report["rgba8_bytes_without_compression"] += image.width * image.height * 4
        report["files"][sheet["path"]] = {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest(),
            "git_blob_sha": hashlib.sha1(f"blob {len(data)}\0".encode()+data).hexdigest()}
        for index, frame in enumerate(sheet["frames"]):
            x, y, width, height = frame["region"]
            alpha = image.getchannel("A").crop((x, y, x+width, y+height))
            visible = alpha.point(lambda a: 255 if a > 32 else 0).getbbox()
            if visible is None:
                report["atlas"]["errors"].append(f"{name}/{index}: región vacía")
                continue
            px, py = frame["pivot_source"]
            left, top, right, bottom = visible
            virtual = [512-px+x+left, 900-py+y+top, 512-px+x+right, 900-py+y+bottom]
            padding = min(virtual[0], virtual[1], 1024-virtual[2], 1024-virtual[3])
            record = {"sheet": name, "frame": index, "virtual_visible_bounds": virtual,
                      "virtual_minimum_padding": padding,
                      "foot_offset_logical_px": round((virtual[3]-900)*sheet["display_scale"], 3)}
            report["atlas"]["frames"].append(record)
            if padding < 4:
                report["atlas"]["errors"].append(f"{name}/{index}: margen virtual insuficiente")
            if abs(record["foot_offset_logical_px"]) > 3:
                report["atlas"]["errors"].append(f"{name}/{index}: apoyo inestable")
    report["source_grid_checks_passed"] = all(r["ok"] for r in report["source_sheets"].values())
    report["atlas"]["ok"] = not report["atlas"]["errors"]
    report["note"] = ("Las hojas fuente conservan avisos de cuadrícula y alfa residual. "
                      "La ejecución usa regiones explícitas, margen virtual y descarte suave de alfa. "
                      "La revisión gráfica y las pruebas del motor se registran aparte en qa.md.")
    (ART / "qa-technical.json").write_text(json.dumps(report, ensure_ascii=False, indent=2)+"\n")
    print(json.dumps({"concept_ok": report["concept"]["ok"],
                      "source_grid_ok": report["source_grid_checks_passed"],
                      "effective_atlas_ok": report["atlas"]["ok"],
                      "frames_checked": len(report["atlas"]["frames"]),
                      "errors": report["atlas"]["errors"]}, ensure_ascii=False))
    return 0 if report["atlas"]["ok"] and report["concept"]["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
