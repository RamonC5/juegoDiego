class_name EnemyMotionProfiles
extends RefCounted
## Articulaciones sobre el PNG original, en coordenadas normalizadas antes del espejo.
## Las zonas elípticas aíslan cada miembro sin cortar ni repintar el recurso raster.

const IDS: Array[String] = ["terron", "moflete", "goteron", "vainete", "plumin", "remiendo", "noctilo"]
const NAMES: Array[String] = ["Terrón", "Moflete", "Goterón", "Vainete", "Plumín", "Remiendo", "Nóctilo"]


static func joint(label: String, pivot: Vector2, zone: Vector4, amplitude: float, phase: float = 0.0, mode: String = "limb") -> Dictionary:
	return {"name": label, "pivot": pivot, "zone": zone, "amplitude": amplitude, "phase": phase, "mode": mode}


static func get_profile(id: String) -> Dictionary:
	var joints: Array[Dictionary] = []
	var region := Rect2(0, 0, 1, 1)
	var frequency: float = 1.5
	match id:
		"terron":
			region = Rect2(0.0215, 0.3198, 0.9665, 0.4482)
			frequency = 1.1
			joints = [
				joint("raíz trasera", Vector2(0.24, 0.67), Vector4(0.24, 0.72, 0.17, 0.07), 0.14),
				joint("raíz delantera", Vector2(0.76, 0.67), Vector4(0.76, 0.72, 0.17, 0.07), 0.14, PI),
			]
		"moflete":
			region = Rect2(0.2321, 0.1212, 0.5997, 0.7887)
			frequency = 1.8
			joints = [
				joint("brazo cercano", Vector2(0.59, 0.51), Vector4(0.65, 0.48, 0.13, 0.09), 0.20),
				joint("mano cercana", Vector2(0.70, 0.44), Vector4(0.71, 0.42, 0.045, 0.055), 0.20, 0.35, "hand"),
				joint("brazo lejano", Vector2(0.70, 0.51), Vector4(0.76, 0.46, 0.045, 0.10), 0.16, PI),
				joint("mano lejana", Vector2(0.76, 0.43), Vector4(0.77, 0.41, 0.033, 0.04), 0.18, PI + 0.35, "hand"),
				joint("pie trasero", Vector2(0.40, 0.77), Vector4(0.37, 0.86, 0.10, 0.08), 0.12, PI),
				joint("pie delantero", Vector2(0.56, 0.77), Vector4(0.60, 0.86, 0.12, 0.08), 0.12),
			]
		"goteron":
			frequency = 0.85
			joints = [
				joint("cuello de gel", Vector2(0.65, 0.64), Vector4(0.77, 0.45, 0.24, 0.22), 0.065, 0.0, "soft"),
				joint("cola de gel", Vector2(0.35, 0.68), Vector4(0.19, 0.69, 0.20, 0.07), 0.08, 1.2, "soft"),
			]
		"vainete":
			frequency = 1.4
			for index in 6:
				var x: float = [0.20, 0.29, 0.49, 0.60, 0.79, 0.89][index]
				joints.append(joint("raíz %d" % (index + 1), Vector2(x, 0.61), Vector4(x, 0.70, 0.075, 0.10), 0.18, PI * (index % 2)))
		"plumin":
			frequency = 1.2
			joints = [
				joint("ala plegada", Vector2(0.56, 0.42), Vector4(0.49, 0.49, 0.15, 0.13), 0.16, 0.0, "wing"),
				joint("plumas del ala", Vector2(0.48, 0.48), Vector4(0.40, 0.53, 0.11, 0.07), 0.12, -0.45, "tip"),
				joint("pata de apoyo", Vector2(0.52, 0.69), Vector4(0.54, 0.82, 0.13, 0.12), 0.13),
				joint("pata alzada", Vector2(0.68, 0.65), Vector4(0.78, 0.73, 0.15, 0.10), 0.16, PI),
			]
		"remiendo":
			frequency = 1.05
			joints = [
				joint("brazo cercano", Vector2(0.51, 0.37), Vector4(0.55, 0.56, 0.12, 0.19), 0.20),
				joint("mano cercana", Vector2(0.58, 0.62), Vector4(0.61, 0.67, 0.075, 0.07), 0.24, -0.45, "hand"),
				joint("brazo cruzado", Vector2(0.67, 0.44), Vector4(0.62, 0.51, 0.09, 0.09), 0.12, PI),
				joint("mano cruzada", Vector2(0.62, 0.48), Vector4(0.59, 0.48, 0.065, 0.045), 0.17, PI - 0.45, "hand"),
				joint("pie grande", Vector2(0.47, 0.74), Vector4(0.39, 0.86, 0.16, 0.075), 0.10, PI),
				joint("pie pequeño", Vector2(0.56, 0.73), Vector4(0.59, 0.84, 0.09, 0.07), 0.10),
			]
		"noctilo":
			frequency = 2.2
			joints = [
				joint("ala cercana", Vector2(0.64, 0.65), Vector4(0.34, 0.36, 0.43, 0.38), 0.23, 0.0, "wing"),
				joint("punta cercana", Vector2(0.43, 0.23), Vector4(0.23, 0.15, 0.23, 0.15), 0.16, -0.45, "tip"),
				joint("ala lejana", Vector2(0.58, 0.73), Vector4(0.33, 0.65, 0.24, 0.15), 0.19, 0.08, "wing"),
				joint("punta lejana", Vector2(0.40, 0.58), Vector4(0.24, 0.60, 0.13, 0.09), 0.12, -0.37, "tip"),
			]
	return {"joints": joints, "region": region, "frequency": frequency, "flying": id == "noctilo"}
