---
description: 스테이징된 변경으로 압축된 Conventional Commits 메시지를 만든다
argument-hint: [추가 맥락 — 생략 가능]
---

`skill:skill_LKS_custom_caveman-korean-commit` 을 실행해 **커밋 메시지를 작성한다.**

## 추가 맥락

$ARGUMENTS

## 진행

1. `git status --short` 와 `git diff --cached` 로 **스테이징된 것**을 본다.
   스테이징이 비어 있으면 메시지를 지어내지 말고 그 사실을 알린다.
2. 스킬 규칙대로 쓴다 — `<type>(<scope>): <명령형 요약>`, 제목 50자 이내.
3. **본문은 "왜"가 제목만으로 안 드러날 때만** 붙인다. 무엇을 바꿨는지는 diff 가 이미 말한다.
4. 이 커맨드는 **커밋 메시지만 생성한다** — `git commit`·staging·amend 를 실행하지 않는다(스킬 규약과 동일). 실제 커밋 실행은 master(오케스트레이션) 세션의 판단이다.

여러 관심사가 한 스테이징에 섞여 있으면 하나로 뭉뚱그리지 말고 **분리 커밋을 제안**한다.
