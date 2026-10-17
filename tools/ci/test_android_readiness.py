"""Regresión del falso fallo Android por mantener el recuento del bosque largo."""

import unittest

from test_android_apk import (EXPECTED_ENEMIES, FOREST_LEVEL,
                              enemy_count_from_level, forest_art_ready)


class ForestReadinessTests(unittest.TestCase):
    def test_recorded_android_startup_matches_current_level(self):
        # Registro real de Actions 141: la aplicación y sus texturas sí arrancaron.
        record = ("10-17 20:02:18.321 2914 3153 I godot : "
                  "SALTO_FOREST_READY level=world_01_level_01 enemies=45 art=45\n")
        self.assertEqual(enemy_count_from_level(FOREST_LEVEL.read_text()), 45)
        self.assertTrue(forest_art_ready(record, EXPECTED_ENEMIES))

    def test_stale_large_forest_and_missing_art_are_rejected(self):
        self.assertFalse(forest_art_ready(
            "SALTO_FOREST_READY level=world_01_level_01 enemies=81 art=81", 45))
        self.assertFalse(forest_art_ready(
            "SALTO_FOREST_READY level=world_01_level_01 enemies=45 art=44", 45))
        self.assertFalse(forest_art_ready(
            "SALTO_FOREST_READY level=world_01_level_01 enemies=45 art=450", 45))

    def test_count_tracks_content_changes_without_counting_other_vectors(self):
        source = ("other = Vector4(0, 0, 0, 0)\n"
                  "enemy_spawns = Array[Vector4]([\nVector4(1, 2, 3, 4),\n"
                  "Vector4(5, 6, 7, 8)\n])\n")
        self.assertEqual(enemy_count_from_level(source), 2)
        self.assertTrue(forest_art_ready(
            "SALTO_FOREST_READY level=world_01_level_01 enemies=2 art=2", 2))

    def test_missing_or_empty_spawn_configuration_fails(self):
        for source in ("other = Vector4(0, 0, 0, 0)", "enemy_spawns = Array[Vector4]([])"):
            with self.subTest(source=source), self.assertRaises(ValueError):
                enemy_count_from_level(source)


if __name__ == "__main__":
    unittest.main()
