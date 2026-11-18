# 오프라인 배치 미리보기

이 이미지는 게임 적용 전 제안입니다. 아이콘·체력·마나·지역·지도와 ‘키’는 자리표시입니다. 실제 주문·특성·단축키를 배정하지 않았습니다. 점선 대상 창은 원본에서 별도로 관측된 창이 아니라 추가 배치 제안입니다.

- 전체: preview-full-4k.png, 3840×2160. 실제 모니터·게임 해상도와 UI scale은 미검증입니다.
- 하단: preview-bottom-native.png, 전체 이미지의 y1360–2159를 그대로 자른 3840×800. 확대·축소하지 않았으며 본인·대상 제안을 포함합니다.
- 긴 줄36칸, 하단8×3의24칸, 좌우4×3의12칸씩, 총84칸. 중립 아이콘26개, 나머지는 빈 프레임입니다.
- 버튼 외곽80px·작은 버튼68px·하단 묶음248px·검정 하단부392px. 전체 화면 비율 변환 없이 layout-spec.json의 명시 좌표를 사용했습니다.
- 글자22/24px, 회수2002.TTF 사용. 밝은 글자/어두운 바탕 계산 대비 17.45:1. 실제 거리·긴 단축키 문자열 가독성은 미검증입니다.

원본 참고: [2022년 공개 게시물](https://www.inven.co.kr/board/wow/1636/31588). 이미지 확보 기록은 reference-acquisition.json, 원본 근사 좌표는 original-image-geometry.md, 회수 설정 대조는 source-comparison.md입니다.

회수한 Onyx Classic·Glamour7·좌우 장식 파일을 읽기 전용으로 합성했습니다. Devil2 파일은 확인했지만 정확한 게임식8구획 테두리 대신 중립4px 경계를 사용했습니다. 우측 장식의 가려진 모양을 복원한 결과가 아닙니다. 게임 배경은 단색 자리표시이며 개인 채팅·캐릭터명·원본 주문 아이콘을 옮기지 않았습니다.

기계 검사 결과: PASS, 122개 사각형 처리·84칸·입력 요소 충돌0·원본 크기 crop 픽셀 일치. 상세 좌표·글자 경계·자산 해시는 preview-checks.json에 있습니다. 독립 이미지 판독·B 검수는 대기 중입니다. 실제 게임 입력·프로필 수용·전투·재접속·미니맵 작동은 실행하지 않았습니다.

다시 생성하려면 기존 Python과 Pillow로 다음을 실행합니다. 출력은 새 빈 폴더를 지정합니다.

```powershell
$env:PYTHONIOENCODING='utf-8'
python render-layout.py --project-root D:/Projects/Project_WF --spec D:/Projects/Project_WF/Codex/results/layout-design/layout-spec.json --output-dir <새_출력_폴더>
```
