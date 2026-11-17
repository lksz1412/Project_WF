<!--ih-->
# PyQt / 데스크톱 UI 어댑터

코어 규칙(통일·타이포 원리·정렬)은 `core_principles.md`, 색·이중 인코딩은 `accessibility.md`. 여기는 **Qt 수단·수치**. 위젯 식별자·사용자 코드/라벨 불가침은 시각 아님 → 헌법 「코드 소유권·범위」.

---

## 1. 핵심 원칙 — layout shift 0

**좌측 끝 ↔ 첫 위젯 / 상단 끝 ↔ 첫 위젯 / 하단 끝 ↔ 마지막 위젯의 시각 여백이 시트별로 동일.** 시트 전환 시 outer chrome 이 1px 단위로 일치.

## 2. GroupBox 구조 표준 (★ 단일 소스)

**모든 GroupBox = `QVBoxLayout(self) outer + inner contents` 패턴.**

```python
class Some_Group(QGroupBox):
    def __init__(self):
        super().__init__("...")
        outer = QVBoxLayout(self)                      # ★ outer VBox
        outer.setContentsMargins(6, 12, 6, 6)          # ★ 표준
        outer.setSpacing(4)                            # ★ 표준
        # inner contents (grid / 다른 layout / 위젯)
        grid = QGridLayout()                           # parent 인자 없이
        grid.setContentsMargins(0, 0, 0, 0)            # outer 가 margins 담당
        grid.setHorizontalSpacing(6)                   # ★ 표준
        grid.setVerticalSpacing(3)                     # ★ 표준
        # ... grid.addWidget(...)
        outer.addLayout(grid)
```

| 항목 | 값 |
|---|---|
| `outer = QVBoxLayout(self)` | 필수(GroupBox 에 grid 직접 장착 금지) |
| `outer.setContentsMargins` | `(6, 12, 6, 6)` (상단 12 = title 글자 영역 보전) |
| `outer.setSpacing` | `4` |
| inner `grid.setContentsMargins` | `(0, 0, 0, 0)` |
| inner `grid.setHorizontalSpacing` | `6` |
| inner `grid.setVerticalSpacing` | `3` |

| 금지 |
|---|
| `QGridLayout(self)` 직접 장착(GroupBox 에 grid 바로 올림 = 시각 격차) |
| `QGroupBox()` (title 인자 없이) — 빈 title 영역(~12-15px gap) 강제 렌더 |
| GroupBox 에 `setFixedHeight(sizeHint.height())` — 고정값 ≠ 실 표시 높이. 자연 sizeHint 또는 `setMinimumHeight` + 부모 stretch 흡수 |

**권장**: `QSplitter` 하위 GroupBox 최대 2개(3개+ = top=12 누적 + border 누적으로 우측 패널 두께 인지).

**Lesson**: GroupBox 통일 = setContentsMargins 수치 일치가 아니라 **layout 구조(outer VBox) 일치 + outer/inner spacing 표준 일치**까지.

## 3. Container cascade — 단일 QSS 소스

**모든 시트의 모든 GroupBox title 폰트 = Container entry 의 단일 cascade 가 결정.**

```python
# Container entry
_GROUPBOX_TITLE_QSS = "QGroupBox::title { font-size: 9pt; font-weight: normal; }"

if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setStyleSheet(_GROUPBOX_TITLE_QSS)   # ★ 모든 시트 자식 GroupBox 자동 cascade
    ...
```

| 규칙 |
|---|
| Container = 단일 소스. **시트/위젯 레벨 `self.setStyleSheet("QGroupBox::title {...}")` 금지**(중복·시트별 편차 위험) |
| 향후 추가 시트도 자동 동일 적용 — 별도 작업 불요 |

per-instance override 금지 = 단일 소스 원리(`core_principles.md` §2)의 Qt 판.

## 4. 시트 root · 좌측 패널 여백

| 항목 | 값 |
|---|---|
| 시트 root `setContentsMargins` | `(4, 4, 4, 4)` |
| inner pane(control_pane/left_pane) | `(2, 2, 2, 2)` → 좌측 끝 ↔ 위젯 = root 4 + inner 2 = **6px** |
| Container `central` root | `(0, 0, 0, 0)` 보존(시트 root 가 그대로 시각 여백) |

```python
def build_ui(self):
    root = QVBoxLayout(self)
    root.setContentsMargins(4, 4, 4, 4)   # ★ 시트 표준
    root.setSpacing(...)                  # 시트 의미 단위 (default = 4 권장)
```

**Lesson**: 좌측 여백 어긋나면 inner layer 가 아니라 **root layer 부터 본다**.

## 5. 스크롤바 정책 — 공간 점유 0

**스크롤바가 레이아웃 공간을 점유하면 안 된다**(등장·소멸 시 인접 위젯 이동 = layout shift 위반, 행 폭 축소로 텍스트 잘림).

```python
scroll.setWidgetResizable(True)
scroll.setHorizontalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAlwaysOff)
scroll.setVerticalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAlwaysOff)
```

| 옵션 | 점유 | 사용처 |
|---|---|---|
| (a) AlwaysOff + default 휠 | 0 | 신규 스크롤 영역 권장 |
| (b) AlwaysOff + 커스텀 드래그/휠(eventFilter) | 0 | 수평 드래그 스와이프 |
| (c) Auto-hide overlay 스크롤바 | 0(overlay) | 위치 단서 필요 시 |
| ~~Qt default `ScrollBarAsNeeded`~~ | **점유** ❌ | 표준 위반 · 신규 시트 금지 |

## 6. Splitter

| 규칙 |
|---|
| 좌·우 분할 = `setHandleWidth(0)`(핸들 드래그 비활성) + 좌측 `setFixedWidth(320)` |
| `setStretchFactor`/`setSizes` 는 fixed width 정책과 충돌 → 폐기(고정 폭일 때) |
| 빈 공간 유발하는 수직 splitter 는 단순 `QVBoxLayout`(stretch)으로 대체 |

## 7. 색 — 크롬 palette 추종 (테마 호환)

**하드코딩 색 금지 → palette 추종**(크롬 한정. 데이터·상태·plot 색은 명시값 유지 → `accessibility.md` §3).

| 금지 | 허용 |
|---|---|
| `color: #555;` · `background: #FFFFFF;` · `color: white;` | `palette(window-text)`·`palette(text)`·`palette(highlight)`·`palette(mid)`·`palette(base)`·`transparent` · `setForegroundRole(QPalette.ColorRole.WindowText)` |

### palette role 매핑 (크롬 변환 기준)

| 용도 | 하드코딩 예 | → palette role |
|---|---|---|
| 일반 배경 | 어두운/흰 bg | `palette(window)` 또는 `palette(base)`(입력류) |
| 본문 텍스트 | `#000`/`#fff` | `palette(text)` / `palette(button-text)` |
| 보조/비활성 텍스트 | `#888` | `palette(disabled, text)` 또는 `palette(mid)` |
| 테두리 | `#B22020` 등 | `palette(mid)` (강조 시 `palette(highlight)`) |
| 강조/선택 bg | `#D93A3A` 등 | `palette(highlight)` + `palette(highlighted-text)` |
| 로그창 | 검정 하드코딩 | 레퍼런스 로그창과 동일(palette 추종) |

## 8. 색 + 도형 4상태 (이중 인코딩)

4상태 인디케이터 = **4색 + 4도형**(◇ ▲ ■ ⬟ 또는 ○ ◔ ◑ ●) — 색약·다크테마 회색↔disabled 방어(WCAG 1.4.1). ProfileRow·Navigator·PoolItem 3곳 동기화. 상세 = `accessibility.md`.

## 9. 폰트 / 스케일 (pt)

| 대상 | 크기 |
|---|---|
| 기본 폰트 | 9pt |
| 신호등 도형(●, ⬟ 등 unicode) | 11pt + 폭 ≥ 20px(잘림 회피) |
| nav 슬롯 | 11px |
| 라벨 / 입력(QLineEdit·QSpinBox·QComboBox) | 9pt(입력은 `background: transparent` 로 부모 alternate-base 비침) |

## 10. 검증 (PyQt)

```bash
# 1. ruff F821 (false positive 기준선 기록)
ruff check --select F821 Lib_*.py

# 2. 모듈 cold import (헤드리스)
python -c "import importlib; [importlib.import_module(m) for m in [ ... ]]; print('import OK')"

# 3. 시트 전환 시 좌·상·하 outer chrome 시각 일관성
```

| 방법 |
|---|
| ruff F821 + 모듈 cold import + 시트 전환 시각 일관성 + **호출체인 정독**(cold import 통과 ≠ 완료) |
| 실데이터 대외비(사내) 시 = 구조·팔레트·import 만 자동 검증, **시각(테마 전환·색 일치)은 사용자 육안** |

## 11. 깊이 · 모션 (제안 등급 — 미채택 가능)

| 항목 | 내용 | 등급 |
|---|---|---|
| surface elevation | subtle shadow / rounded corner 로 플랫(Qt 기본) 탈출·깊이 부여(CardWidget 등) | 제안 |
| 모션 | compositor-friendly(`opacity`/`transform`)만 · reduced-motion 존중 · duration 짧게(≤150~200ms) | 제안(성능 무해 원리는 코어급) |
| 정보 밀도 토글 | 상태 완료 행 compact / 작업중 행 expanded 자동 토글 | 제안 |

제안 등급 = 리뷰 제안이라 확정 규칙과 구분. 채택 여부는 프로젝트 결정.
<!--/ih-->
