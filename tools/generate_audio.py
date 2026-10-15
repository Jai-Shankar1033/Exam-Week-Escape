#!/usr/bin/env python3
"""
Procedural audio generator for Exam Week Escape.

Everything here is synthesised from scratch (oscillators, envelopes, noise),
so the music and sound effects are original and free of licensing concerns.

Usage (from the project root):
    pip install numpy scipy
    python tools/generate_audio.py

Output:
    assets/audio/music/menu.wav   calm lo-fi "study break" loop (home screen)
    assets/audio/music/game.wav   upbeat chiptune loop (during play)
    workshop/sounds/jump.wav, score.wav, hit.wav, swoosh.wav   sound effects

Music loops are rendered with circular effects (delay, filtering), so they
repeat seamlessly with no click at the loop point.
"""

from pathlib import Path

import numpy as np
from scipy import signal
from scipy.io import wavfile

SR = 22050  # sample rate (mono, 16-bit): small files, plenty for chiptune
PROJECT = Path(__file__).resolve().parent.parent
ROOT = PROJECT / "assets" / "audio"
SFX_DIR = PROJECT / "workshop" / "sounds"
rng = np.random.default_rng(7)


# --------------------------------------------------------------------------
# Synth building blocks
# --------------------------------------------------------------------------
def midi(m):
    return 440.0 * 2.0 ** ((m - 69) / 12.0)


def osc(kind, freq, n, duty=0.5, vib=None):
    """Oscillator. `freq` is a number or an array of length n (for sweeps)."""
    t = np.arange(n) / SR
    f = np.full(n, float(freq)) if np.isscalar(freq) else np.asarray(freq, float)
    if vib:  # (rate Hz, depth fraction)
        f = f * (1.0 + vib[1] * np.sin(2 * np.pi * vib[0] * t))
    phase = np.cumsum(f) / SR  # in cycles
    frac = phase % 1.0
    if kind == "sine":
        return np.sin(2 * np.pi * phase)
    if kind == "square":
        return np.where(frac < duty, 1.0, -1.0)
    if kind == "tri":
        return 4.0 * np.abs(frac - 0.5) - 1.0
    if kind == "saw":
        return 2.0 * frac - 1.0
    raise ValueError(kind)


def adsr(n, a=0.005, d=0.05, s=0.7, r=0.05):
    a_n = min(int(a * SR), n)
    d_n = int(d * SR)
    r_n = min(int(r * SR), n // 2)
    env = np.full(n, float(s))
    if a_n > 0:
        env[:a_n] = np.linspace(0.0, 1.0, a_n, endpoint=False)
    d_end = min(a_n + d_n, n)
    if d_end > a_n:
        env[a_n:d_end] = np.linspace(1.0, s, d_end - a_n)
    if r_n > 0:
        env[n - r_n:] *= np.linspace(1.0, 0.0, r_n)
    return env


def note(kind, m, dur, gain=1.0, duty=0.5, vib=None, **env):
    n = max(int(dur * SR), 8)
    return gain * osc(kind, midi(m), n, duty, vib) * adsr(n, **env)


def noise(n):
    return rng.uniform(-1.0, 1.0, n)


def highpass(x, hz, order=2):
    sos = signal.butter(order, hz, "hp", fs=SR, output="sos")
    return signal.sosfilt(sos, x)


def lowpass(x, hz, order=2):
    sos = signal.butter(order, hz, "lp", fs=SR, output="sos")
    return signal.sosfilt(sos, x)


def kick(gain=1.0):
    n = int(0.22 * SR)
    t = np.arange(n) / SR
    f = 45.0 + 110.0 * np.exp(-t * 32.0)
    return gain * np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 16.0)


def snare(gain=1.0):
    n = int(0.16 * SR)
    t = np.arange(n) / SR
    body = np.sin(2 * np.pi * 190 * t) * np.exp(-t * 38.0) * 0.45
    hiss = highpass(noise(n), 1500) * np.exp(-t * 26.0)
    return gain * (body + hiss)


def hat(gain=1.0, decay=95.0):
    n = int(0.06 * SR)
    t = np.arange(n) / SR
    return gain * highpass(noise(n), 5200) * np.exp(-t * decay)


class Mix:
    """A fixed-length loop buffer with a tail that wraps onto the start."""

    def __init__(self, seconds, tail=2.5):
        self.length = int(seconds * SR)
        self.buf = np.zeros(self.length + int(tail * SR))

    def add(self, at_sec, x):
        i = int(at_sec * SR)
        if i >= self.length:
            return
        j = min(i + len(x), len(self.buf))
        self.buf[i:j] += x[: j - i]

    def render(self):
        out = self.buf[: self.length].copy()
        over = self.buf[self.length:]
        out[: len(over)] += over  # wrap the tail -> seamless loop
        return out


def circular_delay(x, seconds, feedback, mix, taps=3):
    out = x.copy()
    d = int(seconds * SR)
    for k in range(1, taps + 1):
        out += mix * (feedback ** (k - 1)) * np.roll(x, d * k)
    return out


def seamless_filter(x, fn):
    """Filter a loop without a seam: filter 3 copies, keep the middle one."""
    y = fn(np.tile(x, 3))
    return y[len(x): 2 * len(x)]


def finish_music(x, target_rms=0.16, ceiling=0.92):
    x = x - np.mean(x)
    x = x * (target_rms / (np.sqrt(np.mean(x**2)) + 1e-9))
    x = np.tanh(x * 1.15) / np.tanh(1.15)  # gentle soft limiter
    x = x * min(1.0, ceiling / (np.max(np.abs(x)) + 1e-9))
    return x


def save(path, x, peak=0.9):
    path.parent.mkdir(parents=True, exist_ok=True)
    x = np.asarray(x, float)
    m = np.max(np.abs(x))
    if m > peak:
        x = x * (peak / m)
    wavfile.write(path, SR, (np.clip(x, -1, 1) * 32767).astype(np.int16))


# --------------------------------------------------------------------------
# MUSIC 1: "Study Break" - lo-fi, 92 BPM, A minor (menu / home)
# --------------------------------------------------------------------------
def make_menu_music():
    bpm, bars = 92, 16
    beat = 60.0 / bpm
    m = Mix(bars * 4 * beat)

    # One chord per bar; the 8-bar progression plays twice.
    prog = [
        ("Am9", 45, [57, 60, 64, 67]),
        ("Fmaj7", 41, [53, 57, 60, 64]),
        ("Cmaj7", 48, [52, 55, 59, 60]),
        ("G6", 43, [55, 59, 62, 64]),
        ("Am9", 45, [57, 60, 64, 67]),
        ("Fmaj7", 41, [53, 57, 60, 64]),
        ("Dm9", 38, [53, 57, 60, 64]),
        ("E7", 40, [52, 56, 59, 62]),
    ]

    # Melody phrases: (beat in bar, midi, length in beats)
    phrase_a = [
        [(0, 76, 1), (1, 74, .5), (1.5, 72, .5), (2, 69, 2)],
        [(0, 72, 1), (1, 69, .5), (1.5, 72, .5), (2, 76, 1.5), (3.5, 74, .5)],
        [(0, 79, 1), (1, 76, 1), (2, 74, .5), (2.5, 72, 1.5)],
        [(0, 71, 1), (1, 74, 1), (2, 76, 2)],
    ]
    phrase_b = [
        [(0, 69, 1), (1, 72, 1), (2, 76, 1), (3, 79, 1)],
        [(0, 81, 1.5), (1.5, 79, .5), (2, 76, 1), (3, 72, 1)],
        [(0, 74, 1), (1, 77, 1), (2, 76, 1), (3, 72, 1)],
        [(0, 71, 1), (1, 68, 1), (2, 76, 2)],
    ]
    phrases = phrase_a + phrase_b

    for bar in range(bars):
        t0 = bar * 4 * beat
        _, root, pad = prog[bar % 8]

        # Warm pad: two slightly detuned oscillators per note
        for p in pad:
            for det in (-0.06, 0.06):
                x = note("tri", p + det, 4.2 * beat, 0.05,
                         a=0.3, d=0.4, s=0.75, r=0.6)
                m.add(t0, x)

        # Bass (sine + triangle): root, push, fifth
        fifth = root + 7
        for (b, mm, ln) in [(0, root, 1.5), (2, root, 0.75),
                            (2.75, fifth, 0.5), (3.5, root + 12, 0.5)]:
            m.add(t0 + b * beat, note("tri", mm, ln * beat, 0.30,
                                      a=0.01, d=0.1, s=0.7, r=0.08))
            m.add(t0 + b * beat, note("sine", mm, ln * beat, 0.22,
                                      a=0.01, d=0.1, s=0.7, r=0.08))

        # Lo-fi drums with swing on the off-beat hats
        m.add(t0, kick(0.55))
        m.add(t0 + 2.5 * beat, kick(0.45))
        m.add(t0 + 1 * beat, snare(0.22))
        m.add(t0 + 3 * beat, snare(0.22))
        for e in range(8):
            swing = 0.09 * beat if e % 2 else 0.0
            m.add(t0 + e * 0.5 * beat + swing, hat(0.07 if e % 2 else 0.10))

        # Lead melody (soft pulse wave with gentle vibrato)
        for (b, mm, ln) in phrases[bar % 8]:
            m.add(t0 + b * beat,
                  note("square", mm, ln * beat * 0.95, 0.075, duty=0.25,
                       vib=(5.0, 0.004), a=0.02, d=0.12, s=0.6, r=0.12))

        # Second pass: add an arpeggiated pluck layer for variety
        if bar >= 8:
            order = [0, 2, 1, 3, 2, 1, 3, 2]
            for e in range(8):
                p = pad[order[e]] + 12
                x = note("sine", p, 0.45 * beat, 0.06, a=0.003, d=0.2,
                         s=0.0, r=0.1)
                m.add(t0 + e * 0.5 * beat, x)

    x = m.render()

    # Vinyl crackle (circular, so it loops seamlessly)
    crackle = np.zeros_like(x)
    idx = rng.integers(0, len(x), int(len(x) / SR * 9))
    crackle[idx] = rng.uniform(0.2, 0.8, len(idx)) * rng.choice([-1, 1], len(idx))
    x += 0.04 * lowpass(crackle, 6000, 1)

    x = circular_delay(x, beat * 0.75, 0.45, 0.22)  # dotted-8th echo
    x = seamless_filter(x, lambda y: lowpass(y, 4200, 2))  # warm lo-fi top end
    return finish_music(x)


# --------------------------------------------------------------------------
# MUSIC 2: "Crunch Time" - chiptune, 126 BPM, D minor (in-game)
# --------------------------------------------------------------------------
def make_game_music():
    bpm, bars = 126, 16
    beat = 60.0 / bpm
    s16 = beat / 4.0
    m = Mix(bars * 4 * beat, tail=1.5)

    prog = [
        ("Dm", 38, [62, 65, 69, 74]),
        ("Bb", 34, [58, 62, 65, 70]),
        ("F", 41, [60, 65, 69, 72]),
        ("C", 36, [60, 64, 67, 72]),
    ]

    lead_a = [
        [(0, 74, 1), (1, 77, .5), (1.5, 81, .5), (2, 79, 1), (3, 77, 1)],
        [(0, 77, 1), (1, 74, .5), (1.5, 70, .5), (2, 74, 2)],
        [(0, 72, .5), (.5, 77, .5), (1, 81, 1), (2, 84, 2)],
        [(0, 79, 1), (1, 76, 1), (2, 74, .5), (2.5, 72, 1.5)],
    ]
    lead_b = [
        [(0, 81, .5), (.5, 81, .5), (1, 77, 1), (2, 74, 1), (3, 77, 1)],
        [(0, 70, 1), (1, 74, 1), (2, 77, 1), (3, 82, 1)],
        [(0, 81, 1), (1, 77, 1), (2, 72, 1), (3, 69, 1)],
        [(0, 67, 1), (1, 72, 1), (2, 76, 1), (3, 79, 1)],
    ]
    lead = lead_a + lead_b  # 8 bars, played twice

    arp_pattern = [0, 1, 2, 3, 2, 1, 2, 3, 0, 1, 2, 3, 2, 1, 3, 2]

    for bar in range(bars):
        t0 = bar * 4 * beat
        _, root, chord = prog[bar % 4]

        # Drums: four-on-the-floor, backbeat snare, 16th hats
        for b in range(4):
            m.add(t0 + b * beat, kick(0.50 if b % 2 == 0 else 0.38))
        m.add(t0 + 1 * beat, snare(0.30))
        m.add(t0 + 3 * beat, snare(0.30))
        for s in range(16):
            accent = 0.12 if s % 4 == 2 else 0.06
            m.add(t0 + s * s16, hat(accent, decay=120.0))

        # Driving 8th-note bass (square + triangle)
        for e in range(8):
            mm = root + 12 if e in (2, 6) else root
            at = t0 + e * 0.5 * beat
            m.add(at, note("square", mm, 0.45 * beat, 0.11, duty=0.35,
                           a=0.003, d=0.05, s=0.6, r=0.04))
            m.add(at, note("tri", mm, 0.45 * beat, 0.30,
                           a=0.003, d=0.05, s=0.7, r=0.04))

        # Fast arpeggio (12.5% pulse is that classic NES shimmer)
        for s in range(16):
            p = chord[arp_pattern[s]]
            m.add(t0 + s * s16, note("square", p, 0.9 * s16, 0.045, duty=0.125,
                                     a=0.002, d=0.05, s=0.3, r=0.02))

        # Lead
        for (b, mm, ln) in lead[bar % 8]:
            m.add(t0 + b * beat,
                  note("square", mm, ln * beat * 0.92, 0.10, duty=0.5,
                       vib=(6.0, 0.003), a=0.005, d=0.08, s=0.65, r=0.05))
            if bar >= 8:  # second pass: octave-up shimmer layer
                m.add(t0 + b * beat,
                      note("square", mm + 12, ln * beat * 0.9, 0.035,
                           duty=0.25, a=0.005, d=0.08, s=0.5, r=0.05))

    x = m.render()
    x = circular_delay(x, beat * 0.75, 0.4, 0.14)
    x = seamless_filter(x, lambda y: lowpass(y, 7000, 2))
    return finish_music(x, target_rms=0.15)


# --------------------------------------------------------------------------
# SOUND EFFECTS
# --------------------------------------------------------------------------
def fade_edges(x, ms=3):
    n = int(ms / 1000 * SR)
    if n * 2 < len(x):
        x = x.copy()
        x[:n] *= np.linspace(0, 1, n)
        x[-n:] *= np.linspace(1, 0, n)
    return x


def normalise_sfx(x, target_rms=0.20, ceiling=0.85):
    """Give every effect a similar perceived loudness without clipping."""
    x = x * (target_rms / (np.sqrt(np.mean(x**2)) + 1e-9))
    return x * min(1.0, ceiling / (np.max(np.abs(x)) + 1e-9))


def sweep(f0, f1, dur, kind="sine", curve="exp", gain=1.0, duty=0.5):
    n = int(dur * SR)
    t = np.linspace(0, 1, n)
    f = f0 * (f1 / f0) ** t if curve == "exp" else f0 + (f1 - f0) * t
    return gain * osc(kind, f, n, duty)


def seq(parts, gap=0.0):
    out = []
    for p in parts:
        out.append(p)
        if gap:
            out.append(np.zeros(int(gap * SR)))
    return np.concatenate(out)


def tone_ms(kind, m, dur, gain=0.6, **env):
    return note(kind, m, dur, gain, **env)


def make_sfx():
    sfx = {}

    # flap: quick upward chirp
    n = int(0.13 * SR)
    sfx["flap"] = sweep(360, 760, 0.13, "tri", gain=0.8) * adsr(n, a=0.004, d=0.04, s=0.5, r=0.06)

    # score: bright two-note "coin"
    sfx["score"] = seq([
        tone_ms("square", 83, 0.07, 0.30, duty=0.5, a=0.002, d=0.02, s=0.8, r=0.02),
        tone_ms("square", 88, 0.22, 0.30, duty=0.5, a=0.002, d=0.12, s=0.35, r=0.1),
    ])

    # hit: thump + noise crash
    n = int(0.38 * SR)
    t = np.arange(n) / SR
    thump = np.sin(2 * np.pi * np.cumsum(55 + 150 * np.exp(-t * 22)) / SR) * np.exp(-t * 9)
    crash = lowpass(noise(n), 3500) * np.exp(-t * 14) * 0.7
    sfx["hit"] = thump + crash

    # swoosh: band-swept noise
    n = int(0.28 * SR)
    t = np.linspace(0, 1, n)
    nz = noise(n)
    sos_out = np.zeros(n)
    block = 512
    for i in range(0, n, block):
        centre = 500 + 2500 * (i / n)
        sos = signal.butter(2, [centre * 0.7, centre * 1.4], "bp", fs=SR, output="sos")
        sos_out[i:i + block] = signal.sosfilt(sos, nz[i:i + block])
    sfx["swoosh"] = sos_out * np.sin(np.pi * t) ** 1.5 * 1.8

    # levelup: rising arpeggio
    sfx["levelup"] = seq([
        tone_ms("square", 72, 0.08, 0.28, duty=0.25, a=0.002, d=0.03, s=0.7, r=0.02),
        tone_ms("square", 76, 0.08, 0.28, duty=0.25, a=0.002, d=0.03, s=0.7, r=0.02),
        tone_ms("square", 79, 0.08, 0.28, duty=0.25, a=0.002, d=0.03, s=0.7, r=0.02),
        tone_ms("square", 84, 0.28, 0.30, duty=0.25, a=0.002, d=0.1, s=0.4, r=0.12),
    ])

    # click: tiny UI tick
    n = int(0.045 * SR)
    sfx["click"] = (sweep(1500, 900, 0.045, "square", gain=0.35, duty=0.5)
                    * adsr(n, a=0.001, d=0.015, s=0.3, r=0.02))

    # catch: coffee "bloop"
    n = int(0.16 * SR)
    sfx["catch"] = sweep(520, 980, 0.16, "sine", gain=0.9) * adsr(n, a=0.003, d=0.05, s=0.5, r=0.07)

    # bad: dull buzzer
    n = int(0.3 * SR)
    sfx["bad"] = (osc("square", np.linspace(150, 70, n), n, 0.5, vib=(28, 0.04))
                  * adsr(n, a=0.004, d=0.08, s=0.55, r=0.1) * 0.5)

    # flip: card flick
    n = int(0.08 * SR)
    t = np.arange(n) / SR
    sfx["flip"] = (highpass(noise(n), 1800) * np.exp(-t * 55) * 0.5
                   + osc("sine", 640 - 2000 * t, n) * np.exp(-t * 60) * 0.3)

    # match: happy rising pair
    sfx["match"] = seq([
        tone_ms("sine", 79, 0.1, 0.55, a=0.003, d=0.04, s=0.7, r=0.03),
        tone_ms("square", 84, 0.26, 0.26, duty=0.25, a=0.003, d=0.1, s=0.4, r=0.12),
    ])

    # mismatch: soft falling pair
    sfx["mismatch"] = seq([
        tone_ms("tri", 67, 0.11, 0.6, a=0.003, d=0.05, s=0.7, r=0.04),
        tone_ms("tri", 62, 0.22, 0.6, a=0.003, d=0.1, s=0.4, r=0.1),
    ])

    # win: little fanfare
    sfx["win"] = seq([
        tone_ms("square", 72, 0.12, 0.26, duty=0.25, a=0.003, d=0.04, s=0.8, r=0.03),
        tone_ms("square", 76, 0.12, 0.26, duty=0.25, a=0.003, d=0.04, s=0.8, r=0.03),
        tone_ms("square", 79, 0.12, 0.26, duty=0.25, a=0.003, d=0.04, s=0.8, r=0.03),
        tone_ms("square", 84, 0.20, 0.28, duty=0.25, a=0.003, d=0.06, s=0.8, r=0.05),
        tone_ms("square", 79, 0.10, 0.26, duty=0.25, a=0.003, d=0.04, s=0.8, r=0.03),
        tone_ms("square", 84, 0.55, 0.30, duty=0.25, a=0.003, d=0.2, s=0.5, r=0.3),
    ])

    # gameover: sad descending line
    sfx["gameover"] = seq([
        tone_ms("tri", 64, 0.22, 0.7, a=0.004, d=0.08, s=0.7, r=0.08),
        tone_ms("tri", 62, 0.22, 0.7, a=0.004, d=0.08, s=0.7, r=0.08),
        tone_ms("tri", 60, 0.22, 0.7, a=0.004, d=0.08, s=0.7, r=0.08),
        tone_ms("tri", 57, 0.55, 0.7, a=0.004, d=0.2, s=0.5, r=0.3, vib=(5.5, 0.012)),
    ])

    # pause: two soft ticks
    sfx["pause"] = seq([
        tone_ms("sine", 76, 0.05, 0.5, a=0.002, d=0.02, s=0.5, r=0.02),
        tone_ms("sine", 71, 0.07, 0.5, a=0.002, d=0.03, s=0.4, r=0.03),
    ], gap=0.02)

    return {k: normalise_sfx(fade_edges(v)) for k, v in sfx.items()}


# --------------------------------------------------------------------------
def main():
    print("Rendering music...")
    save(ROOT / "music" / "menu.wav", make_menu_music(), peak=0.95)
    save(ROOT / "music" / "game.wav", make_game_music(), peak=0.95)
    print("Rendering sound effects...")
    effects = make_sfx()
    # The game uses these four; names match lib/workshop/game_settings.dart.
    for name, out in {"flap": "jump", "score": "score", "hit": "hit", "swoosh": "swoosh"}.items():
        save(SFX_DIR / f"{out}.wav", effects[name], peak=0.85)
    print("Done.")


if __name__ == "__main__":
    main()
