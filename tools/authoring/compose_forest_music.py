"""Esmeralda en marcha: composición original de plataformas de estilo electrónico moderno.

48 compases, 128 BPM, 4/4. Bajo FM, acordes anchos, lead polifónico,
arpegios, batería y transiciones; sin samples externos ni sonidos de 8 bits.
La síntesis ocurre solo en autoría. Dependencias: NumPy, SciPy y FFmpeg.
"""
from pathlib import Path
import subprocess
import tempfile
import wave

import numpy as np
from scipy.signal import butter, sosfilt

RATE = 44100
BPM = 128
BEAT = 60 / BPM
BARS = 48
LENGTH = round(BARS * 4 * BEAT * RATE)
music = np.zeros((LENGTH, 2), dtype=np.float64)
drums = np.zeros_like(music)
rng = np.random.default_rng(610128)


def add(signal, beat, gain, pan=0.0, percussion=False, echo=False):
    indices = (np.arange(len(signal)) + round(beat * BEAT * RATE)) % LENGTH
    target = drums if percussion else music
    target[indices, 0] += signal * gain * np.sqrt((1 - pan) / 2)
    target[indices, 1] += signal * gain * np.sqrt((1 + pan) / 2)
    if echo:
        for delay, level in [(0.75, .18), (1.5, .09)]:
            shifted = (indices + round(delay * BEAT * RATE)) % LENGTH
            target[shifted, 0] += signal * gain * level * np.sqrt((1 + pan) / 2)
            target[shifted, 1] += signal * gain * level * np.sqrt((1 - pan) / 2)


def note(midi, beat, duration, voice, gain, pan=0.0):
    seconds = duration * BEAT
    t = np.arange(round((seconds + .16) * RATE)) / RATE
    f = 440 * 2 ** ((midi - 69) / 12)
    release = np.minimum(np.maximum(seconds + .14 - t, 0) / .15, 1)
    if voice == "bass":
        phase = 2 * np.pi * f * t
        sound = np.sin(phase + .65 * np.sin(phase * 2) * np.exp(-t * 6))
        sound += .25 * np.sin(phase * 2) + .08 * np.sin(phase * 3)
        sound *= np.minimum(t / .006, 1) * np.exp(-t * 2.2) * release
    elif voice == "chord":
        sound = np.zeros_like(t)
        for detune in [.997, 1.0, 1.003]:
            for harmonic in range(1, 9):
                sound += np.sin(2 * np.pi * f * detune * harmonic * t) * np.exp(-harmonic / 2.8) / harmonic / 3
        sound *= np.minimum(t / .025, 1) * np.exp(-t * 2.4) * release
    elif voice == "lead":
        sound = np.zeros_like(t)
        for detune in [.998, 1.002]:
            phase = 2 * np.pi * f * detune * t + .012 * np.sin(2 * np.pi * 5.2 * t)
            sound += np.sin(phase) + .33 * np.sin(phase * 2) + .16 * np.sin(phase * 3) + .07 * np.sin(phase * 4)
        sound = np.tanh(sound * .65)
        sound *= np.minimum(t / .015, 1) * (0.7 + .3 * np.exp(-t * 6)) * release
    else:
        phase = 2 * np.pi * f * t
        sound = np.sin(phase + 1.3 * np.sin(phase * 2) * np.exp(-t * 8))
        sound *= np.minimum(t / .004, 1) * np.exp(-t * 6) * release
    add(sound, beat, gain, pan, echo=voice in ("lead", "arp"))


progression = [(43, [59, 62, 66, 69]), (38, [57, 62, 66, 69]),
               (40, [55, 59, 62, 66]), (36, [55, 59, 64, 67]),
               (45, [55, 60, 64, 67]), (38, [57, 60, 66, 69]),
               (43, [59, 62, 67, 71]), (38, [57, 62, 66, 69])]
theme_a = [
    [(0, 79, .5), (.75, 83, .5), (1.5, 86, .75), (2.5, 83, .5), (3.25, 81, .5), (4, 78, 1), (5.5, 81, .5), (6.5, 86, 1)],
    [(0, 83, .75), (1, 79, .5), (2, 78, .5), (2.75, 79, 1), (4.25, 76, .75), (5.5, 79, .5), (6.5, 83, .75)],
    [(0, 81, .5), (.75, 84, .5), (1.5, 88, .75), (2.5, 86, .5), (3.25, 84, .5), (4, 81, .75), (5.25, 78, .5), (6, 81, 1.5)],
    [(0, 83, .5), (.75, 86, .75), (2, 91, 1), (3.25, 86, .5), (4, 81, 1), (5.5, 78, .5), (6.5, 74, .75)],
]
theme_b = [
    [(0, 86, 1.25), (1.75, 83, .75), (3, 81, .5), (4, 78, 1.25), (5.75, 81, .75), (7, 83, .5)],
    [(0, 88, 1), (1.5, 86, .5), (2.5, 83, 1), (4, 84, 1), (5.5, 83, .5), (6.5, 79, 1)],
    [(0, 88, .75), (1, 91, .75), (2, 88, 1), (3.5, 86, .5), (4.5, 84, .75), (6, 81, 1.5)],
    [(0, 86, 1), (1.5, 83, .5), (2.5, 79, .75), (4, 81, 1), (5.5, 78, .5), (6.5, 74, 1)],
]

# Batería con cuerpo y transitorios redondeados, sin samples de terceros.
t = np.arange(round(.32 * RATE)) / RATE
kick = np.sin(2 * np.pi * (48 * t + 1.8 * (1 - np.exp(-t * 35)))) * np.exp(-t * 15)
kick *= np.minimum(t / .002, 1)
snare_noise = rng.normal(0, 1, round(.22 * RATE))
snare_noise = sosfilt(butter(2, [700, 8500], btype="bandpass", fs=RATE, output="sos"), snare_noise)
st = np.arange(len(snare_noise)) / RATE
snare = (snare_noise * .55 + np.sin(2 * np.pi * 185 * st) * .28) * np.exp(-st * 19) * np.minimum(st / .003, 1)
hat_noise = rng.normal(0, 1, round(.09 * RATE))
hat_noise = sosfilt(butter(2, 7000, btype="highpass", fs=RATE, output="sos"), hat_noise)
ht = np.arange(len(hat_noise)) / RATE
hat = hat_noise * np.exp(-ht * 65) * np.minimum(ht / .001, 1)

for bar in range(BARS):
    beat = bar * 4
    bass, chord = progression[bar % 8]
    lighter = 16 <= bar < 20
    # Bajo sincopado y acordes con séptimas/novenas, con espacio para el motivo.
    for offset, pitch, length in [(0, bass, .65), (.75, bass, .35), (1.5, bass + 12, .4),
                                  (2.5, bass + 7, .45), (3.25, bass, .45)]:
        note(pitch, beat + offset, length, "bass", .23)
    for offset in [.5, 1.75, 2.5, 3.5]:
        for i, pitch in enumerate(chord):
            note(pitch, beat + offset, .55, "chord", .055 if lighter else .078, (i - 1.5) * .35)
    if bar >= 8:
        for i in range(8):
            note(chord[[0, 2, 1, 3, 2, 0, 3, 1][i]] + 12, beat + i * .5, .3, "arp", .028, -.55 if i % 2 else .55)
    if not lighter:
        for offset in [0, 1.5, 2, 3.5]:
            add(kick, beat + offset, .48, percussion=True)
        for offset in [1, 3]:
            add(snare, beat + offset, .24, percussion=True)
        for i in range(8):
            add(hat, beat + i * .5, .09 if i % 2 else .055, .5 if i % 2 else -.4, percussion=True)
    if bar % 8 == 7:
        for i in range(4):
            add(snare, beat + 3 + i * .25, .08 + i * .025, -.3 + i * .2, percussion=True)

for phrase in range(BARS // 2):
    melody = theme_b if 8 <= phrase < 16 else theme_a
    for offset, pitch, duration in melody[phrase % 4]:
        note(pitch, phrase * 8 + offset, duration, "lead", .13 if phrase < 16 else .15, .1)
        if phrase >= 16 and offset in (0, 4):
            note(pitch - 12, phrase * 8 + offset, duration, "lead", .038, -.3)

# Bombeo moderado del acompañamiento y espacio estéreo; el golpe conserva pegada.
time = np.arange(LENGTH) / RATE
phase = np.mod(time, BEAT)
duck = 1 - .17 * np.minimum(phase / .006, 1) * np.exp(-phase * 16)
music *= duck[:, None]
dry = music.copy()
for seconds, gain in [(.071, .10), (.137, .08), (.239, .055), (.413, .035)]:
    music += np.roll(dry[:, ::-1], round(seconds * RATE), axis=0) * gain
mix = np.tanh((music + drums) * 1.18)
mix *= .83 / np.max(np.abs(mix))
destination = Path(__file__).resolve().parents[2] / "game/assets/audio/music/bosque_esmeralda.ogg"
destination.parent.mkdir(parents=True, exist_ok=True)
with tempfile.TemporaryDirectory() as tmp:
    source = Path(tmp) / "score.wav"
    with wave.open(str(source), "wb") as wav:
        wav.setnchannels(2)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        wav.writeframes((mix * 32767).astype("<i2").tobytes())
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", str(source), "-c:a", "libvorbis", "-q:a", "4",
                    "-metadata", "title=Esmeralda en marcha", "-metadata", "artist=Super Diego",
                    "-metadata", "comment=Original modern platformer score; no third-party samples",
                    str(destination)], check=True)
print(f"{destination.name}: {LENGTH / RATE:.3f} s, {BARS} bars, {BPM} BPM")
