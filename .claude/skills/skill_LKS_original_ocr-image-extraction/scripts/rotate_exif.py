# -*- coding: utf-8 -*-
"""EXIF Orientation 으로 눕혀 저장된 사진을 정방향 사본으로 만든다.

원본은 건드리지 않는다. 판독·엔진 처리는 전부 이 사본으로 한다.

사용:
    python rotate_exif.py --src <원본폴더> --dst <출력폴더>
    python rotate_exif.py --src ./photos --dst ./rotated --rotate 270
    python rotate_exif.py --src ./photos --dst ./rotated --ext .jpg .png

주의 — 파일명으로 중복을 거르지 않는다. 클라우드가 재업로드분을 `사진.jpg` /
`사진(1).jpg` 로 내려주지만 그중에는 부분 블러를 극복하려 의도적으로 다시 찍은
프레임이 섞여 있다. 파일명으로 걸러내면 그런 프레임이 파이프라인에서 통째로
사라진다. 중복 판정은 내용 해시로만 한다 (→ SKILL.md §유사 프레임 자동 제거 금지).
"""

import io as _io, sys as _sys
# Windows 기본 콘솔은 cp949 다. 한글·기호를 찍으면 UnicodeEncodeError 로 죽는다.
if hasattr(_sys.stdout, 'reconfigure'):
    _sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    _sys.stderr.reconfigure(encoding='utf-8', errors='replace')

import argparse
import os
import sys

from PIL import Image

ROTATIONS = {
    0: None,
    90: Image.ROTATE_90,
    180: Image.ROTATE_180,
    270: Image.ROTATE_270,
}


def main():
    ap = argparse.ArgumentParser(description='EXIF 회전 사진을 정방향 사본으로 만든다')
    ap.add_argument('--src', required=True, help='원본 폴더')
    ap.add_argument('--dst', required=True, help='출력 폴더 (없으면 만든다)')
    ap.add_argument('--ext', nargs='+', default=['.jpg', '.jpeg', '.png', '.webp'],
                    help='처리할 확장자 (기본: .jpg .jpeg .png .webp)')
    ap.add_argument('--rotate', type=int, default=270, choices=sorted(ROTATIONS),
                    help='시계방향 보정각. 휴대폰 세로 촬영(Orientation=6)은 270 (기본)')
    ap.add_argument('--quality', type=int, default=95, help='JPEG 저장 품질 (기본 95)')
    args = ap.parse_args()

    if not os.path.isdir(args.src):
        sys.exit(f'src 폴더가 없다: {args.src}')
    os.makedirs(args.dst, exist_ok=True)

    exts = tuple(e.lower() if e.startswith('.') else '.' + e.lower() for e in args.ext)
    files = sorted(f for f in os.listdir(args.src) if f.lower().endswith(exts))

    # 조용히 0 건으로 끝내면 "처리 완료" 로 오해된다. 확장자 불일치가 흔한 원인이다.
    if not files:
        sys.exit(f'대상 파일 0건 — {args.src} 에 {exts} 확장자가 없다')

    print(f'대상 {len(files)}장 · 보정각 {args.rotate}도 · 확장자 {exts}')
    op = ROTATIONS[args.rotate]
    done = 0
    for name in files:
        try:
            with Image.open(os.path.join(args.src, name)) as im:
                out = im if op is None else im.transpose(op)
                out.save(os.path.join(args.dst, name), quality=args.quality)
            done += 1
        except Exception as exc:
            print(f'  실패 {name} — {exc}')

    print(f'저장 {done}/{len(files)} -> {args.dst}')
    if done:
        print(f'  first: {files[0]}')
        print(f'  last : {files[-1]}')
    if done != len(files):
        sys.exit(1)


if __name__ == '__main__':
    main()
