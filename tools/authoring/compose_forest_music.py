"""Partitura original de Super Diego: flauta, madera, cuerdas y percusión suave.

Autoría offline reproducible; no se sintetiza ni descarga audio durante el juego.
Requiere numpy y ffmpeg. Compás 4/4, Sol mayor, 108 BPM, 32 compases.
Todas las ondas, notas y ruidos se generan aquí, sin samples de terceros.
"""
from pathlib import Path
import subprocess
import tempfile
import wave

import numpy as np

RATE = 44100
BPM = 108
BEAT = 60 / BPM
BARS = 32
LENGTH = round(BARS * 4 * BEAT * RATE)
mix = np.zeros((LENGTH, 2), dtype=np.float64)
rng = np.random.default_rng(311017)


def note(midi, start, beats, voice, gain, pan=0.0):
    duration = beats * BEAT
    tail = 0.55 if voice in ("wood", "pluck") else 0.2
    t = np.arange(round((duration + tail) * RATE)) / RATE
    f = 440 * 2 ** ((midi - 69) / 12)
    if voice == "flute":
        phase = 2 * np.pi * f * t + 0.022 * np.sin(2 * np.pi * 4.6 * t)
        sound = np.sin(phase) + 0.18 * np.sin(2 * phase) + 0.045 * np.sin(3 * phase)
        env = np.minimum(t / 0.07, 1) * np.minimum(np.maximum(duration + 0.12 - t, 0) / 0.16, 1)
        sound *= env * (0.94 + 0.06 * np.sin(2 * np.pi * 3.1 * t))
    elif voice in ("wood", "pluck"):
        sound = np.zeros_like(t)
        for harmonic, amplitude, decay in [(1, 1, 1.4), (2, .24, .55), (3, .13, .25), (4, .05, .12)]:
            sound += amplitude * np.sin(2 * np.pi * f * harmonic * t) * np.exp(-t / decay)
        sound *= np.minimum(t / 0.006, 1) * np.exp(-t / (0.32 if voice == "wood" else 0.65))
        sound *= np.minimum(np.maximum(duration + tail - t, 0) / 0.08, 1)
    elif voice == "strings":
        sound = (np.sin(2 * np.pi * f * .999 * t) + np.sin(2 * np.pi * f * 1.001 * t)) * .5
        sound += .12 * np.sin(4 * np.pi * f * t)
        sound *= np.minimum(t / .28, 1) * np.minimum(np.maximum(duration + .18 - t, 0) / .4, 1)
    else:
        sound = np.sin(2 * np.pi * f * t) + .18 * np.sin(4 * np.pi * f * t)
        sound *= np.minimum(t / .018, 1) * np.exp(-t / .8) * np.minimum(np.maximum(duration + .15 - t, 0) / .18, 1)
    add(sound * gain, start, pan)


def add(sound, beat, pan=0.0):
    indices = (np.arange(len(sound)) + round(beat * BEAT * RATE)) % LENGTH
    mix[indices, 0] += sound * np.sqrt((1 - pan) / 2)
    mix[indices, 1] += sound * np.sqrt((1 + pan) / 2)


# G, D/F#, Em, C, Am, D, G, D; bajos y voces ligadas de registro cálido.
chords = [(43, [67, 71, 74]), (42, [66, 69, 74]), (40, [64, 67, 71]), (36, [64, 67, 72]),
          (45, [64, 69, 72]), (38, [66, 69, 74]), (43, [67, 71, 74]), (38, [66, 69, 74])]
# Frases de dos compases, con respiraciones y final que regresa a Sol.
phrases = [
    [(0, 79, 1), (1.5, 81, .5), (2, 83, 1), (3, 86, .75), (4.5, 81, 1), (6, 78, 1.5)],
    [(0, 79, .75), (1, 83, .75), (2, 86, 1.5), (4, 84, 1), (5.5, 83, .5), (6, 79, 1.5)],
    [(0, 81, 1.5), (2, 84, .75), (3, 83, .75), (4, 81, 1), (5.5, 78, .5), (6, 76, 1)],
    [(0, 79, 1.5), (2, 83, .75), (3, 81, .75), (4, 78, 1), (5.5, 81, .5), (6, 74, 1)],
]

for bar in range(BARS):
    beat = bar * 4
    root, chord = chords[bar % 8]
    for i, pitch in enumerate(chord):
        note(pitch - 12, beat, 4, "strings", .025, (i - 1) * .45)
    note(root, beat, 1.8, "bass", .15)
    note(root + 7, beat + 2, 1.5, "bass", .09)
    order = [0, 1, 2, 1, 0, 2, 1, 2]
    for i, index in enumerate(order):
        note(chord[index] - 12, beat + i * .5, .55, "pluck", .09 if i % 2 == 0 else .06, -.32)
    for offset, pitch in [(1, chord[1]), (3, chord[2])]:
        note(pitch, beat + offset, .6, "wood", .07, .4)
    # Golpe grave y semillas muy suaves, sin sobresaltos ni transitorios duros.
    t = np.arange(round(.18 * RATE)) / RATE
    kick = np.sin(2 * np.pi * (62 * t - 18 * t * t)) * np.exp(-t * 30) * np.minimum(t / .008, 1)
    for offset in [0, 2]:
        add(kick * .065, beat + offset)
    for offset in [.5, 1.5, 2.5, 3.5]:
        noise = rng.normal(0, 1, round(.07 * RATE))
        noise = noise - np.roll(noise, 1)
        envelope = np.sin(np.linspace(0, np.pi, len(noise))) ** 2
        add(noise * envelope * .007, beat + offset, .35)

for phrase in range(BARS // 2):
    for offset, pitch, duration in phrases[phrase % 4]:
        # Segunda mitad con respuesta de madera y distinta intensidad.
        voice = "wood" if phrase in (8, 9, 12, 13) else "flute"
        note(pitch, phrase * 8 + offset, duration, voice, .12 if voice == "flute" else .18, .16)

# Cola circular: la reverberación cruza el final sin hueco ni chasquido.
dry = mix.copy()
for seconds, gain in [(.113, .16), (.229, .11), (.367, .07), (.523, .045)]:
    mix += np.roll(dry[:, ::-1], round(seconds * RATE), axis=0) * gain
mix = np.tanh(mix * 1.1)
mix *= .78 / max(np.max(np.abs(mix)), 1e-9)
destination = Path(__file__).resolve().parents[2] / "game/assets/audio/music/bosque_esmeralda.ogg"
destination.parent.mkdir(parents=True, exist_ok=True)
with tempfile.TemporaryDirectory() as tmp:
    source = Path(tmp) / "score.wav"
    with wave.open(str(source), "wb") as wav:
        wav.setnchannels(2)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        wav.writeframes((mix * 32767).astype("<i2").tobytes())
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", str(source), "-c:a", "libvorbis", "-q:a", "3",
                    "-metadata", "title=Senderos de Esmeralda", "-metadata", "artist=Super Diego",
                    "-metadata", "comment=Original score; reproducible synthesis; no third-party samples",
                    str(destination)], check=True)
print(f"{destination.name}: {LENGTH / RATE:.3f} s, {BARS} bars, {BPM} BPM")
