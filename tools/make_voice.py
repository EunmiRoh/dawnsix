# 코치·집 운동 안내 녹음 음성 만들기
#
# voice/phrases.txt(한 줄에 한 문장)를 읽어 없는 것만 voice/<해시>.mp3로 만들고 voice/index.json(문장 → 파일)을 쓴다.
# 문장 목록은 앱의 voiceAllPhrases(true)가 만든다 — 안내 문장을 바꾸거나 운동을 추가하면 목록을 다시 뽑고 이 스크립트를 돌릴 것.
#
#   pip install edge-tts
#   python3 tools/make_voice.py
#
# 목소리: ko-KR-SunHiNeural, 속도 +5% (예전 speechSynthesis rate 1.05와 맞춤)
# ffmpeg가 있으면 앞뒤 무음을 잘라(원본은 끝에 0.8초 넘게 무음 → 숫자 세기가 늘어짐) 32kbps 모노로 줄인다.
import asyncio, hashlib, json, os, shutil, subprocess, sys

try:
    import certifi
    if os.path.exists("/root/.ccr/ca-bundle.crt"):          # 클라우드 세션 프록시 인증서
        certifi.where = lambda: "/root/.ccr/ca-bundle.crt"
except ImportError:
    pass
import edge_tts

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "voice")
VOICE, RATE = "ko-KR-SunHiNeural", "+5%"


def fname(text):
    return hashlib.md5(text.encode("utf-8")).hexdigest()[:10]


TRIM = ("silenceremove=start_periods=1:start_threshold=-50dB:start_silence=0.03,areverse,"
        "silenceremove=start_periods=1:start_threshold=-50dB:start_silence=0.08,areverse")


def trim(raw, path):
    if shutil.which("ffmpeg"):
        subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", raw, "-af", TRIM, "-ac", "1", "-ar", "24000", "-b:a", "32k", path], check=True)
        os.remove(raw)
    else:
        os.replace(raw, path)


async def make(text, sem):
    path = os.path.join(ROOT, fname(text) + ".mp3")
    if os.path.exists(path) and os.path.getsize(path) > 0:
        return
    async with sem:
        for _ in range(3):
            try:
                raw = path + ".raw.mp3"
                await edge_tts.Communicate(text, VOICE, rate=RATE).save(raw)
                trim(raw, path)
                if os.path.getsize(path) > 0:
                    return
            except Exception as e:
                print("retry", text, e, file=sys.stderr)
        raise SystemExit("실패: " + text)


async def main():
    with open(os.path.join(ROOT, "phrases.txt"), encoding="utf-8") as f:
        phrases = [l.strip() for l in f if l.strip()]
    sem = asyncio.Semaphore(8)
    await asyncio.gather(*(make(p, sem) for p in phrases))
    index = {p: fname(p) for p in phrases}
    with open(os.path.join(ROOT, "index.json"), "w", encoding="utf-8") as f:
        json.dump(index, f, ensure_ascii=False, separators=(",", ":"))
    keep = set(index.values())
    for n in os.listdir(ROOT):                                  # 목록에서 빠진 옛 파일 정리
        if n.endswith(".mp3") and n[:-4] not in keep:
            os.remove(os.path.join(ROOT, n))
    print(len(phrases), "문장")


asyncio.run(main())
