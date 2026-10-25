
import librosa
import numpy as np
import math

def sample_do_filter(audio, sr, original_length):
    START_SEC = 1.0
    END_SEC = 3.0
    PITCH_SEMITONES = 12.0
    CROSSFADE_SEC = 0.020

    start = round(START_SEC * sr)
    end = round(END_SEC * sr)

    if not (0 <= start < end <= original_length):
        raise ValueError("指定区間が音声の範囲外です")

    # 対象区間だけピッチシフトする。
    # librosaは通常、入力の長さと同じ長さの結果を返す。
    segment = audio[start:end]
    shifted = librosa.effects.pitch_shift(
        y=segment.T if audio.ndim == 2 else segment,
        sr=sr,
        n_steps=PITCH_SEMITONES,
    )

    if audio.ndim == 2:
        shifted = shifted.T

    if len(shifted) != len(segment):
        raise RuntimeError("ピッチシフト後の長さが一致しません")

    # 対象区間を置き換える
    result = audio.copy()
    result[start:end] = shifted

    # 境界をクロスフェードしてクリックノイズを軽減
    fade = min(round(CROSSFADE_SEC * sr), len(segment) // 2)

    if fade > 0:
        ramp = np.linspace(0.0, 1.0, fade, dtype=np.float32)
        shape = (fade, 1) if audio.ndim == 2 else (fade,)

        ramp = ramp.reshape(shape)

        # 区間の先頭：元音声から加工音声へ
        result[start:start + fade] = (
            audio[start:start + fade] * (1.0 - ramp)
            + shifted[:fade] * ramp
        )

        # 区間の末尾：加工音声から元音声へ
        result[end - fade:end] = (
            shifted[-fade:] * (1.0 - ramp)
            + audio[end - fade:end] * ramp
        )
    return result


# pitch_shiftのdocument
# https://librosa.org/doc/latest/api/generated/librosa.effects.pitch_shift.html

def do_filter(audio, sr, original_length):
    SEGLEN = round(sr * 0.01)
    SPEED = 0.1 # 1周期の秒数
    MIN_STEP = 0
    MAX_STEP = 7
    result = audio.copy()
    # CROSSFADE_SEC = 0.020
    CROSSFADE_SEC = 0.001
    for i in range(0, original_length-1, SEGLEN):
        segment = audio[i:i+SEGLEN]
        fade = min(round(CROSSFADE_SEC * sr), len(segment) // 2)
        scale = (math.sin((i*2*math.pi) / (sr*SPEED)) + 1) * (MAX_STEP-MIN_STEP) / 2 + MIN_STEP
        shifted = librosa.effects.pitch_shift(
            y=segment.T if audio.ndim == 2 else segment,
            sr=sr,
            n_steps=scale,
        )
        result[i:i+SEGLEN] = shifted
        if fade > 0:
            ramp = np.linspace(0.0, 1.0, fade, dtype=np.float32)
            shape = (fade, 1) if audio.ndim == 2 else (fade,)
            ramp = ramp.reshape(shape)
            result[i:i + fade] = (
                audio[i:i + fade] * (1.0 - ramp)
                + shifted[:fade] * ramp
            )
            if i+SEGLEN < original_length-1:
                end = i + SEGLEN
                result[end - fade:end] = (
                    shifted[-fade:] * (1.0 - ramp)
                    + audio[end - fade:end] * ramp
                )
    return result
