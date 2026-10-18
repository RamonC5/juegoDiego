"""Regresión del falso fallo Android por mantener el recuento del bosque largo."""

import unittest
import xml.etree.ElementTree as ET
from unittest.mock import patch

from test_android_apk import (EXPECTED_ENEMIES, FOREST_LEVEL,
                              enemy_count_from_level, forest_art_ready, platform_stand_ready,
                              exercise_platform_posture)
from test_android_apk import verify_installed_identity


class ForestReadinessTests(unittest.TestCase):
    def test_identity_recovers_observed_google_setup_startup_anr(self):
        dialog = ET.fromstring('<hierarchy><node package="android" text="com.google.android.googlesdksetup isn&apos;t responding" /><node text="Close app" /></hierarchy>')
        details = ET.fromstring('<hierarchy><node package="com.android.settings" text="Super Diego" /></hierarchy>')
        with patch('test_android_apk.adb') as adb_mock, \
                patch('test_android_apk.time.sleep'), \
                patch('test_android_apk.window_xml', side_effect=[dialog, details]), \
                patch('test_android_apk.tap_node', return_value=True) as tap, \
                patch('test_android_apk.screenshot'), \
                patch('test_android_apk.Path.write_bytes'):
            verify_installed_identity('test')
        tap.assert_called_once()
        self.assertEqual(adb_mock.call_count, 2)

    def test_identity_never_closes_a_game_or_unknown_app_anr(self):
        for name in ['Super Diego', 'Settings', 'Other app']:
            dialog = ET.fromstring(f'<hierarchy><node package="android" text="{name} isn&apos;t responding" /><node text="Close app" /></hierarchy>')
            with self.subTest(name=name), \
                    patch('test_android_apk.adb'), \
                    patch('test_android_apk.time.sleep'), \
                    patch('test_android_apk.time.monotonic', side_effect=[0, 0, 1, 91]), \
                    patch('test_android_apk.window_xml', return_value=dialog), \
                    patch('test_android_apk.tap_node') as tap, \
                    patch('test_android_apk.screenshot'), \
                    patch('test_android_apk.Path.write_bytes'):
                with self.assertRaisesRegex(RuntimeError, 'no mostró la ficha'):
                    verify_installed_identity('test')
                tap.assert_not_called()

    def test_posture_repeats_at_rest_after_observed_braking_drift(self):
        records = [
            'SALTO_POSTURE state=crouch x=703.24 y=599.93\nSALTO_POSTURE state=stand x=717.58 y=599.93',
            'SALTO_POSTURE state=crouch x=717.58 y=599.93\nSALTO_POSTURE state=stand x=717.58 y=599.93',
        ]
        self.assertFalse(platform_stand_ready(records[0]))
        with patch('test_android_apk.adb') as adb_mock, \
                patch('test_android_apk.time.sleep'), \
                patch('test_android_apk.logs', side_effect=records), \
                patch('test_android_apk.screenshot'):
            result = exercise_platform_posture(1280, 720, 'test')
        self.assertTrue(result['stood_under_platform'])
        self.assertFalse(result['teleported'])
        self.assertEqual(adb_mock.call_count, 3)

    def test_identity_reopens_settings_after_observed_return_to_launcher(self):
        home = ET.fromstring('<hierarchy><node package="com.google.android.apps.nexuslauncher" text="" /></hierarchy>')
        details = ET.fromstring('<hierarchy><node package="com.android.settings" text="Super Diego" /></hierarchy>')
        with patch('test_android_apk.adb') as adb_mock, \
                patch('test_android_apk.time.sleep'), \
                patch('test_android_apk.window_xml', side_effect=[home, details]), \
                patch('test_android_apk.screenshot'), \
                patch('test_android_apk.Path.write_bytes'):
            verify_installed_identity('test')
        self.assertEqual(adb_mock.call_count, 2)
        for call in adb_mock.call_args_list:
            self.assertEqual(call.args[1:5], ('am', 'start', '-W', '-a'))

    def test_slow_emulator_keeps_walking_until_the_real_platform(self):
        # Cuatro intentos no bastaban: el APK 0.8.0-ci.148 llegó solo a x=660.
        records = [
            f"SALTO_POSTURE state=crouch x={x:.2f} y=600.00\n"
            f"SALTO_POSTURE state=stand x={x:.2f} y=600.00"
            for x in [285, 474, 660, 664, 668, 740]
        ]
        with patch('test_android_apk.adb') as adb_mock, \
                patch('test_android_apk.time.sleep'), \
                patch('test_android_apk.logs', side_effect=records), \
                patch('test_android_apk.screenshot'):
            result = exercise_platform_posture(1280, 720, 'test')
        self.assertTrue(result['stood_under_platform'])
        self.assertFalse(result['teleported'])
        self.assertEqual(adb_mock.call_count, 12)

    def test_more_travel_attempts_do_not_accept_a_player_stuck_crouching(self):
        record = "SALTO_POSTURE state=crouch x=740.00 y=600.00"
        with patch('test_android_apk.adb'), patch('test_android_apk.time.sleep'), \
                patch('test_android_apk.logs', return_value=record):
            with self.assertRaisesRegex(RuntimeError, 'se quedó agachado'):
                exercise_platform_posture(1280, 720, 'test')

    def test_travel_timeout_still_fails_and_records_evidence(self):
        record = ("SALTO_POSTURE state=crouch x=300.00 y=600.00\n"
                  "SALTO_POSTURE state=stand x=300.00 y=600.00")
        with patch('test_android_apk.adb'), patch('test_android_apk.time.sleep'), \
                patch('test_android_apk.logs', return_value=record), \
                patch('test_android_apk.screenshot') as capture:
            with self.assertRaisesRegex(RuntimeError, 'Posiciones observadas'):
                exercise_platform_posture(1280, 720, 'test')
        capture.assert_called_once_with('test_recorrido_plataforma_incompleto.png')

    def test_stand_under_platform_requires_same_position_on_floor(self):
        self.assertTrue(platform_stand_ready(
            "SALTO_POSTURE state=crouch x=740.00 y=600.00\n"
            "SALTO_POSTURE state=stand x=740.00 y=600.00"))
        for record in (
            "SALTO_POSTURE state=crouch x=740.00 y=600.00",
            "SALTO_POSTURE state=stand x=740.00 y=600.00",
            "SALTO_POSTURE state=crouch x=180.00 y=600.00\nSALTO_POSTURE state=stand x=180.00 y=600.00",
            "SALTO_POSTURE state=crouch x=740.00 y=600.00\nSALTO_POSTURE state=stand x=910.00 y=600.00",
            "SALTO_POSTURE state=crouch x=740.00 y=515.00\nSALTO_POSTURE state=stand x=740.00 y=515.00",
        ):
            with self.subTest(record=record):
                self.assertFalse(platform_stand_ready(record))

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
