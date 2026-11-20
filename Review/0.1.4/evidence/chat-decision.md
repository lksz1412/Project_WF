# 현재 채팅 구성과 Prat

초기 Phase 4에서는 Prat의 창 조정과 외관 적용을 검토했다. 이후 2026-11-19 사용자 요청 [CR112](../../../Codex/results/REQUEST_LEDGER_codex-phase25.md#cr112)에서 앞선 세션의 자체 채팅 설계를 우선 적용하도록 정했다. 당시 작업 대장에는 게임 기본 채팅과 입력, 데빌 세 창 배치와 자체 외관을 반영하고 Prat를 설치 후보에서 제외한다고 기록했다. [요구 연결 기록](../../../Codex/results/audit-installer/requirement-trace.md)

0.1.4 실제 ZIP 세 개의 채팅 담당은 `DevilForever_ChatSetup`과 `DevilForever_Skin_NativeChat`이다. Prat 폴더는 포함 목록에 없으며 Core의 로드 목록에도 Prat 기본값 파일이 올라 있지 않다. [0.1.4 파일 목록](../addon-files.json) · [현행 창 배치](../../../Collection/AddOns/DevilForever_ChatSetup/ChatLayout.lua) · [현행 채팅 스킨](../../../Collection/AddOns/DevilForever_Skin_NativeChat/Skin.lua)

이전 GitHub 설치 목록에는 Prat가 남아 있었다. 이 브랜치의 설치 목록을 실제 0.1.4 ZIP 세 판의 폴더 구성과 맞췄다. [현재 설치 목록](../../../Collection/install.json)

Prat를 별도 후보로 다시 검토할 때 쓸 원본 3.9.117 ZIP과 이전 분석은 기존 자료에 있다. [Prat 원본과 분석](../../../References/forever-addons/Prat-3.0)
