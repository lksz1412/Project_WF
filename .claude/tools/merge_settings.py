#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""settings.json 비클로버 병합 헬퍼 — POSIX·Windows 두 설치기 공용.

사용:
    python3 merge_settings.py <src_settings> <dst_settings> <interp>
      <src_settings> : 패키지 원본 settings.json (훅 명령 = 'python3 -c ...')
      <dst_settings> : 사용자 ~/.claude/settings.json (없으면 생성)
      <interp>       : 훅 명령 인터프리터 — 'python3'(Mac/Linux) | 'python'(Windows)

규칙:
    - 비-hooks 키(model·env·permissions ...) = 패키지 값으로 설정하되, dict 하위값이
      리스트면(permissions.ask/allow/deny 등) 통째로 덮지 않고 사용자+패키지 합집합으로
      병합한다 — 사용자 항목 먼저, 패키지 항목 중 사용자에 없는 것만 순서 보존해 뒤에 붙이고,
      완전히 동일한 항목만 중복 배제한다. 재-merge 해도 결과 불변(멱등).
      dict 하위값이 dict 면(modelSettings 의 모델별 항목) 그 안에서 패키지 칸만 이기고
      사용자의 다른 칸은 남긴다.
    - hooks = 사용자 기존 훅(옵저버·알림 훅 등)은 보존하고, 이 패키지 훅만 전 이벤트에서
      걷어낸 뒤(센티널 _BADA_HOOK= + 레거시 파일명 매칭) 소스 판으로 다시 넣는다. 소스에서
      폐기돼 사라진 이벤트(예: 1.1.8 UserPromptSubmit)의 유령 등록도 함께 정리된다.
      interp != 'python3' 이면 각 훅 명령 선두 'python3 -c' 를 <interp> 로 치환(Windows=python).
    - 재실행 멱등: sweep-후-재삽입이라 우리 훅은 소스에 적힌 등록 수만큼 유지(같은 파일을 본체·색인
      전용으로 두 번 등록하는 BADA_recall 은 2건 · 중복·유령 0).

stdlib 전용·UTF-8 명시. 실패해도 설치기 전체를 죽이지 않도록 호출측에서 판단한다.
"""
import json
import sys

# ── Windows stdout 인코딩 방어 (cp949 크래시 차단 · 패키지 CLI 도구 표준) ──
# 파이프로 캡처되면 Python 은 콘솔 CP 가 아니라 ANSI(한국어=cp949)로 인코딩 →
# '—'(U+2014) 등 cp949 밖 문자에서 UnicodeEncodeError. UTF-8 로 못박아 안전
# (BADA_recall 훅과 동일 방어를 전 CLI 도구로 표준화).
if sys.platform == "win32":
    try:
        import ctypes
        ctypes.windll.kernel32.SetConsoleOutputCP(65001)
    except Exception:
        pass
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8")
    except Exception:
        pass


def _warn(msg):
    # 경고는 stderr 가 아니라 stdout 으로 낸다. Windows install.ps1 은 이 헬퍼를
    # `& python … 2>&1` 로 호출하는데, PowerShell 5.1 은 $ErrorActionPreference='Stop'
    # 하에서 네이티브 명령의 stderr 를 NativeCommandError 종료 오류로 감싸 설치를 통째로
    # 중단시킬 수 있다. stdout 은 그 함정을 타지 않는다. (usage 오류는 main 에서 stderr 유지.)
    sys.stdout.write(msg + "\n")


# 이 패키지 훅의 소유 판정 — 2단이다.
# (1) 센티널: 훅 명령에 심어 둔 불변 소유 태그(`_BADA_HOOK='<이름>';`, settings.json 원본).
#     파일명·확장자·인터프리터(python/python3)·경로가 바뀌어도 이 토큰은 불변이라 우리 훅을
#     안정적으로 식별한다 — 내용 해시가 아니다(명령은 interp·경로로 정당하게 변하므로 해시로는
#     자기 훅을 놓친다). 소유 판정의 1차 근거.
# (2) 레거시 파일명 마커: 센티널이 없던 구 등록(1.1.5 powershell caveman-activate.ps1,
#     소문자 bada_recall.py, 1.1.8 이전 UserPromptSubmit BADA_recall 유령 등)을 전환기에
#     한 번 걷어내기 위한 보조 매칭. 센티널이 두 버전 이상 정착하면 축소한다.
_PKG_HOOK_SENTINEL = "_BADA_HOOK="
_PKG_HOOK_LEGACY_MARKERS = ("caveman_activate.py", "BADA_recall.py",
                            "caveman-activate.ps1", "bada_recall.py")


def _is_pkg_hook(cmd):
    c = cmd or ""
    return (_PKG_HOOK_SENTINEL in c) or any(m in c for m in _PKG_HOOK_LEGACY_MARKERS)


def merge(src_path, dst_path, interp):
    with open(src_path, encoding="utf-8-sig") as f:
        src = json.load(f)
    try:
        # utf-8-sig: 사용자 settings.json 에 선두 BOM 이 있으면(메모장 편집 등) 순수 utf-8
        # json.load 가 터진다 → 아래 except 로 빠져 병합 대신 전체 대체(사용자 훅 소실) 사고.
        # utf-8-sig 는 BOM 을 흡수하고 BOM 없는 파일도 그대로 읽는다. (쓰기는 utf-8 = BOM 미추가.)
        with open(dst_path, encoding="utf-8-sig") as f:
            cur = json.load(f)
        if not isinstance(cur, dict):
            _warn("경고: 기존 settings.json 이 JSON 객체가 아니다 — 패키지 값으로 대체한다"
                  "(사용자 hooks 소실 가능). 백업에서 복원할 수 있다.")
            cur = {}
    except FileNotFoundError:
        cur = {}  # 신규 설치 — 조용히 생성한다.
    except (OSError, ValueError) as e:
        # 파일은 있으나 못 읽음(손상 JSON 등) = 사용자 hooks 소실 위험 → 조용히 넘기지 않는다.
        _warn("경고: 기존 settings.json 을 읽지 못했다({}) — 패키지 값으로 대체한다"
              "(사용자 hooks 소실 가능). 백업에서 복원할 수 있다.".format(e))
        cur = {}

    for k, v in src.items():
        if k == "hooks":
            continue
        # env·permissions 같은 dict 키는 병합 — 패키지 하위키가 이기되 사용자가
        # 추가한 하위키(커스텀 env 변수 등)는 보존한다(통째 대체 방지). 단 하위값이
        # 리스트면(permissions.ask/allow/deny 등) 패키지 값으로 덮지 않고 합집합으로 병합한다
        # — 사용자 리스트 먼저, 패키지 항목 중 사용자에 없는 것만 순서 보존해 뒤에 붙이고
        # 완전히 동일한 항목만 중복 배제한다. 그래야 사용자가 ask 에 추가한 항목(예:
        # 파괴 Bash 패턴)이 재설치 때 소실되지 않는다. 재-merge 결과 불변(멱등).
        if isinstance(v, dict) and isinstance(cur.get(k), dict):
            merged = dict(cur[k])
            for sk, sv in v.items():
                if isinstance(sv, list) and isinstance(merged.get(sk), list):
                    combined = list(merged[sk])          # 사용자 항목 먼저(순서 보존)
                    for item in sv:                      # 패키지 항목 append(dedup: 완전 동일만)
                        if item not in combined:
                            combined.append(item)
                    merged[sk] = combined
                elif isinstance(sv, dict) and isinstance(merged.get(sk), dict):
                    # 하위값이 dict 면(modelSettings 의 모델별 항목 등) 한 단계 더 병합 — 패키지 칸이
                    # 이기고 사용자가 같은 항목에 저장한 다른 칸(autoCompactWindow 등)은 남는다(멱등).
                    inner = dict(merged[sk])
                    inner.update(sv)
                    merged[sk] = inner
                else:
                    merged[sk] = sv                      # 리스트·dict 아닌 하위키는 패키지 우선(현행)
            cur[k] = merged
        else:
            cur[k] = v

    if not isinstance(cur.get("hooks"), dict):
        cur["hooks"] = {}  # 기존 hooks 값이 dict 가 아니면(손상) 안전하게 초기화한다.

    # (1) 전 이벤트 sweep — 사용자 설정의 '모든' 이벤트에서 이 패키지 훅을 걷어낸다.
    #     소스에 아직 있는 이벤트(SessionStart)뿐 아니라, 소스에서 통째로 사라진 이벤트
    #     (예: 1.1.8 에서 폐기된 UserPromptSubmit 의 BADA_recall 유령)까지 정리한다.
    #     사용자 훅(옵저버·알림 훅)은 보존하고, 우리 훅만 빠져 빈 그룹·빈 이벤트가 되면 제거한다.
    for event in list(cur["hooks"].keys()):
        kept_groups = []
        for g in cur["hooks"].get(event) or []:
            kept = [h for h in (g.get("hooks") or [])
                    if not _is_pkg_hook(h.get("command"))]
            if kept:
                ng = dict(g)
                ng["hooks"] = kept
                kept_groups.append(ng)
        if kept_groups:
            cur["hooks"][event] = kept_groups
        else:
            del cur["hooks"][event]  # 우리 훅만 있던 이벤트는 통째 제거(유령 이벤트 잔재 방지).

    # (2) 소스 훅을 현재 interp 판으로 재삽입 — 위에서 보존된 사용자 훅 뒤에 붙인다.
    #     sweep 뒤라 우리 훅은 소스에 적힌 등록 수만큼만 남는다(재실행·교차-interp 멱등).
    for event, groups in (src.get("hooks") or {}).items():
        merged_groups = cur["hooks"].get(event) or []
        for g in groups:
            add = []
            for h in (g.get("hooks") or []):
                cmd = h.get("command") or ""
                if interp != "python3":
                    cmd = cmd.replace("python3 -c", interp + " -c", 1)
                if cmd:
                    nh = dict(h)
                    nh["command"] = cmd
                    add.append(nh)
            if add:
                ng = dict(g)
                ng["hooks"] = add
                merged_groups.append(ng)
        cur["hooks"][event] = merged_groups

    with open(dst_path, "w", encoding="utf-8") as f:
        json.dump(cur, f, ensure_ascii=False, indent=2)
    return cur


def main():
    if len(sys.argv) != 4:
        sys.stderr.write("usage: merge_settings.py <src> <dst> <python|python3>\n")
        sys.exit(2)
    try:
        cur = merge(sys.argv[1], sys.argv[2], sys.argv[3])
    except Exception as e:
        # 실패해도 stderr 를 내지 않는다 — Windows install.ps1 이 EAP='Stop' 하 `2>&1` 로
        # 부르면 네이티브 stderr 가 설치를 중단시킬 수 있다. 상태는 stdout·exit≠0 로 알린다.
        print("settings.json 병합 실패: {}".format(e))
        sys.exit(1)
    print("settings.json 병합 완료 (interp={}, model={})".format(
        sys.argv[3], cur.get("model")))


if __name__ == "__main__":
    main()
