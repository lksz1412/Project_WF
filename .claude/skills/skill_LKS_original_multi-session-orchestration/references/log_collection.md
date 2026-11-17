# 참조 — 훈련 데이터용 로그 저장

훈련 자료로 쓸 로그를 수집하는 작업에서만 적용한다. 그 밖의 작업에서는 아래 manifest 를 만들지 않는다.

Claude Code 자동 저장(master가 인지·활용):

- master 대화 풀 트레이스: `~/.claude/projects/<proj-hash>/<sess-id>.jsonl` — Agent 호출은 prompt + 최종 return만 남는다.
- 서브에이전트 풀 트레이스: `~/.claude/projects/<proj-hash>/<sess-id>/subagents/agent-<hash>.jsonl` — 서브 안의 모든 LLM ↔ tool 상호작용이 보존된다.
- 메타: `agent-<hash>.meta.json` — subagent_type / timestamp 등.

Master가 보강 — `Claude/results/handoffs/<task-name>/LOG_MANIFEST.md` 를 작성한다:

- 각 작업 단위 종료 시 manifest에 기록: task / branch / master session id, iter별 작업 sub jsonl hash + 그 iter 의 `work_log.md` 경로 + 검수 sub jsonl hash + `audit_log.md` 경로, 통합 결과 문건 경로.
- master는 sub spawn 직전 subagents/ 디렉터리를 스냅샷하고, spawn 직후 새로 생긴 `agent-<hash>.jsonl`을 식별해 manifest에 기록한다.

**훈련 데이터 추출:** `LOG_MANIFEST.md`의 hash → 해당 `subagents/agent-<hash>.jsonl` 직접 파싱. jsonl의 `message.content`가 user/assistant 턴 + tool_use/tool_result 이므로 표준 fine-tuning 포맷으로 변환 가능.
