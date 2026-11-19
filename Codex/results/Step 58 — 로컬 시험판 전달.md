# Step 58 — 로컬 시험판 전달

Phase 28.2 · 2026-11-19 · 로컬 파일 대조 완료 · 최종 출시 확인 대기

로컬 전달 폴더에 .NET을 자체 포함한 Windows x64 실행 파일, 기본 PitBull4 ZIP과 최신 안내를 준비했다. 선택 FUF와 게임 시험용 비교 ZIP은 각각의 승인 실물로 연결했다. 전달 파일 다섯 개의 바이트·전체 SHA-256을 다시 대조했다. [실물 경로와 해시](audit-installer/local-delivery.json)

- [Windows 설치기](../../_local_only/phase26-work-r151-20261119/DevilForever-Windows-x64-0.1.0-local-test/DevilForeverSetup.exe) · [기본 PitBull4 ZIP](../../_local_only/phase26-work-r151-20261119/DevilForever-Windows-x64-0.1.0-local-test/DevilForever-0.1.0.zip) · [사용 안내](../../_local_only/phase26-work-r151-20261119/DevilForever-Windows-x64-0.1.0-local-test/사용안내.md)
- [선택 FUF ZIP](../../_local_only/phase26-work-r151-20261119/step47-candidate-02/archives/DevilForever-0.1.0-fuf.zip) · [한 접속 비교 ZIP](../../_local_only/phase26-work-r151-20261119/step47-candidate-02/archives/DevilForever-0.1.0-one-session.zip)

현재 Windows에서 배포 EXE의 창과 명령줄, 실제 설치·검증, 두 판 전환, 원래 파일 복원, 중단 처리와 충돌 차단을 확인했다. 전달 폴더의 실제 EXE로 `PitBull4 → FUF → PitBull4`를 다시 실행해 각 승인 ZIP의 파일 해시와 원래 대역 파일이 맞음을 확인했다. 전달 파일의 해시와 역할을 독립 검수했고 중대·중간·경미 0건이었다. [배포본의 양방향 전환 기록](../../_local_only/phase26-work-r151-20261119/step58-final-variants/result.json)

최종 출시 확정에는 Step 56의 별도 청정 Windows와 Step 57의 실제 게임 관측이 남아 있다. 게임에서 사용자 직접 판단이 필요한 항목은 4K에서 평소 거리로 퀘스트 글자를 읽을 수 있는지다. 비교와 기록의 순서는 [한 접속 확인표](../../References/codex-verify/one-session-review.md)에 있다.
