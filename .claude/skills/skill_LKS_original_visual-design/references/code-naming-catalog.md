# 코드 명명 카탈로그 — 식별자 명명 패턴 추출 예시 (도메인 중립)

언어 무관 식별자 명명 패턴을 분류별 표로 정리 — 클래스·함수·속성·dict 키·prefix/suffix·인자·통계 변수·상수·정수 enum.

> **이 카탈로그의 지위 — 처방이 아니라 추출 예시.** 아래 패턴은 *사용자가 이미 쓰고 있는* 컨벤션을 분류·정리한 **예시**다. 새 명명을 강제하는 처방이 아니다. 상위 권위는 `memory:feedback_code_ownership_scope`(사용자 컨벤션 최우선 · 명명·인코딩 권위 3계층). **이 카탈로그의 어떤 패턴도 사용자 기존 표기와 충돌하면 사용자 표기가 이긴다.** 각 프로젝트의 실제 컨벤션은 그 프로젝트의 **마스터 모듈에서 추출**한다(§11) — 이 표의 예시 값을 그대로 이식하지 않는다.

## placeholder 표기

각 패턴의 슬롯을 나타내는 자리표시자 — 실제 값은 마스터 모듈에서 채운다.

| placeholder | 뜻 |
|---|---|
| `<DOMAIN>` | 3-letter 이내 UPPER 도메인 약어 (마스터 모듈에서 추출) |
| `<Domain>` | 4+ letter 도메인 단어 (PascalCase) |
| `<Role>` | 같은 도메인 내 역할 구분자 |
| `<Action>` | 동작 카테고리 (Parsing·Process·Save·Profile·Select 등) |
| `<Qualifier>` | 동작 세부 한정어 |
| `<KEY>` | 위치·식별 키 (dict 키 어휘와 동일) |
| `<N>` | 단계·순서 숫자 |
| `<base>` | 파생의 뿌리가 되는 식별자 |
| `<process>` | 가공 단계 이름 (denoised·smoothed·scaled 등) |
| `<ALGO>` / `<StdAbbr>` | 알고리즘 약어 / 표준 약어 (풀어쓰지 않고 그대로) |

## 핵심 원칙

명명 판단의 세 축 — 아래 모든 표는 이 원칙의 구체화다.

| 원칙 | 내용 |
|---|---|
| 도메인 약어 보존 | 수학·물리·화학·통계 표준 표기·알고리즘 약어·도메인 식별자는 풀어쓰지 않고 그대로 (`FFT`, `SNR`, `RMSE`) |
| 마스터 모듈 우선 추출 | 코드베이스에 사용자 원본(도메인 모델) 모듈이 있으면 그 명명 규칙성을 추출해 나머지에 일관 적용 (§11) — 새 처방 아님 |
| 의미 단위 통일 | 같은 의미 식별자를 모듈마다 다른 표기로 두지 않음 (풀단어 vs 약어 혼용 금지) |

## 1. 클래스명

단일 책임·비-도메인 = 단순 PascalCase · 도메인 모델만 도메인 약어 정책 적용.

| 패턴 | 사용처 | 예시 |
|---|---|---|
| 단순 PascalCase | 단일 책임 모델·UI 위젯·Worker·Dialog·Helper | `MainShell`, `RefreshWorker`, `HelpDialog`, `DataLoader` |
| `<Domain>` PascalCase | 4+ letter 도메인 단어 단일 모델 | `SensorData`, `OrderRecord` |
| `<Domain>_<Role>` (PascalCase + `_`) | 같은 도메인의 여러 역할 분리 | `Record_Match`, `Record_Merge` |
| `<DOMAIN>_<Role>` (3-letter UPPER prefix + PascalCase) | 도메인 약어가 3-letter 이내이고 자주 등장할 때 dataclass·Query·단일 책임 클래스 | `<DOMAIN>_Query`, `<DOMAIN>_Result` |

**규칙:**
- `<DOMAIN>` 이 3-letter 이내 약어이고 코드베이스에서 자주 등장하면 ALL CAPS prefix + `_` 분리. 약어 풀어쓰기(`Dom_Query`) 금지.
- `<Domain>` 이 4+ letter 일반 단어이면 그냥 PascalCase 결합(`SensorData`).
- `_<Role>` 분리는 동일 도메인에 여러 역할 클래스가 있을 때만. 단일 클래스는 단순 PascalCase.
- UI 위젯·헬퍼 등 도메인 모델이 아닌 클래스는 단순 PascalCase 로 충분.

## 2. 함수 / 메서드명

snake_case 기본 · 표준 약어는 대문자 그대로 노출 · 도메인 파이프라인은 `<DOMAIN>_<Action>`.

| 패턴 | 사용처 | 예시 |
|---|---|---|
| snake_case | 일반 | `save_pkl`, `load_data`, `process_folder` |
| ALL CAPS 약어 | 알고리즘·수식 약어 그대로 노출 | `FFT`, `_auto_SNR`, `<ALGO>` |
| 약어 + 숫자 | 단계·순서 분기 | `RMSE_1/2/3/4`, `merging2`, `draw_graphs2` |
| 동사 + 숫자 + 약어 | 데이터 흐름(A→B→C) 표기 | `csv2json`, `dat2pkl` |
| `*_one` / `*_all` | 단/복수 분기 | `peak_one` / `peak_all` |
| `_` prefix | private | `_iteration_first`, `_check_snr` |
| 약어 보존 + snake_case | 약어가 일부 토큰만 차지 | `slope_win`, `_convert_<DOMAIN>_input` |
| `<DOMAIN>_<Action>` / `<DOMAIN>_<Action>_<Qualifier>` | 도메인 데이터 파이프라인 모듈-전역 함수 (parsing·processing·saving·extraction·aggregation) | `<DOMAIN>_Parsing`, `<DOMAIN>_Process_Time`, `<DOMAIN>_Save_Prepare`, `<DOMAIN>_Profile_Extract`, `<DOMAIN>_Aggregate` |
| `<Action>_<Qualifier>` (도메인 prefix 없음) | 도메인 무관 범용 유틸 (저장·단위 변환 등) | `Save_DAT`, `Unit_Convert` |

**규칙 (도메인 파이프라인 함수):**
- `<DOMAIN>` = 3-letter UPPER 약어 · Action/Qualifier = PascalCase.
- 한 도메인 안에서 같은 Action 카테고리(`Process`·`Save`·`Profile`·`Select`)는 통일. 추가 동작은 새 카테고리(`<DOMAIN>_Quality_Check`).
- 도메인 prefix 없는 범용 유틸(`Save_DAT`·`Unit_Convert`)은 PascalCase + `_` 만 → 도메인 prefix 함수와 시각 구분.

**규칙 (기타):**
- private 함수에도 도메인 약어·PascalCase 보존 가능 (도메인 객체 변환 함수일 때).
- 같은 모듈의 단계 시리즈 숫자는 1-base 또는 0-base 통일 (혼용 금지).

## 3. 인스턴스 속성 / 지역 변수

함수의 1-차 데이터 컨테이너 = UPPER_SNAKE · 한두 줄 임시값 = snake_case.

| 패턴 | 사용처 | 예시 |
|---|---|---|
| snake_case | computation 임시값 | `last_per_file`, `offsets`, `kind`, `mask`, `rename_map`, `drop_cols`, `seen` |
| 도메인 약어 PascalCase | 물리·화학·수학 단축 표기 | `Freq` (Frequency), `Temp` (Temperature) |
| 도메인 약어 ALL CAPS | 알고리즘·통계·단위 약어 | `SNR`, `RMS`, `PSD` |
| `<base><N>` + `<base>f` | 단계 시리즈 + final | `M0/M1/M2/M3/Mf`, `result1/result2/.../resultf` |
| `<base>_<KEY>` | 위치·키 접미 | `col_X`, `arr_IN` |
| 복수 컬렉션 (`s` 또는 `_list`) | dict·list 모음 | `node_list`, `DATA_PARTs` |
| `DATA_<DOMAIN>` UPPER_SNAKE | 함수 내 1-차 DataFrame (도메인 데이터의 primary container) | `DATA_<DOMAIN>`, `DATA_WORK`, `DATA_<DOMAIN>_ARR` |
| `PATH_<KEY>` UPPER_SNAKE | 함수 내 1-차 Path 객체 | `PATH_IN`, `PATH_OUT`, `PATH_DAT`, `PATH_DIR`, `PATH_ALL` |
| UPPER_SNAKE 1-차 중간 객체 | 의미 있는 단일 단어 중간 결과 (groupby·merge·가공 결과) | `BASE`, `MERGED`, `WEIGHTED`, `GROUPED`, `AGG`, `OUT`, `LAST`, `SUB` |

**규칙 (UPPER_SNAKE 1-차 vs snake_case 임시):**
- **UPPER_SNAKE** = "이 함수의 주요 데이터 컨테이너" — DataFrame·Path·핵심 중간 결과(groupby aggregate·merged frame). 함수 시그니처 인자이거나 함수 끝까지 살아있는 객체.
- **snake_case** = "한두 줄 안에서만 살아있는 임시 계산값"(mask·offsets·kind·rename_map). Pipe 중간 단계.
- 같은 의미라도 함수 시그니처 인자 = UPPER_SNAKE(`DATA_<DOMAIN>`), 짧은 람다·comprehension 안의 변수 = snake_case(`for col in DATA_<DOMAIN>.columns`).

## 4. dict 키

도메인 약어·짧은 단어·단일 문자·호출 인자명을 그대로 · 코드베이스 전체 동일 표기.

| 패턴 | 사용처 | 예시 |
|---|---|---|
| ALL CAPS 약어 (위치·식별자) | 도메인 약어 | `'X'`, `'Y'`, `'IN'`, `'OUT'` |
| 짧은 단어·옵션 | 의미 전달용 단어 | `'opt'`, `'1st'`, `'soft'`, `'hard'` |
| 단일 알파벳 | 물리량·표준 표기 | `'t'`, `'x'`, `'y'`, `'f'` |
| 마스터 함수 인자명 그대로 | 외부 라이브러리 호출 인자에 직접 매핑되는 키 | `'slope_window'`, `'method'` (호출 인자명 그대로) |

**규칙:**
- 같은 의미의 dict 키는 모듈·코드베이스 전체에서 동일 표기. 직접 비교용 string(예: row_type)도 dict 키와 같은 어휘로 통일.
- 외부 함수 호출 시 인자명을 dict 로 전달하는 케이스(`func(**kwargs)`)는 dict 키를 호출 대상 인자명 그대로(대소문자·구두점 일치) 사용.

## 5. prefix / suffix 어휘

의미가 고정된 관용 표기 · 새 도메인에도 같은 의미면 그대로 재사용.

| 종류 | 패턴 | 의미 | 예시 |
|---|---|---|---|
| prefix | `_` | private | `_internal_func` |
| prefix | `mask_` | boolean mask 배열 | `mask_1st`, `mask_2nd_step0` |
| prefix | `id_` | 정수 인덱스 | `id_s`, `id_e` |
| prefix | `i*` | interpolated 값 | `iVal`, `iFreq` |
| prefix | `init_` | 초기값 | `init_state`, `init_val` |
| prefix | `modi_` | modified 값 | `modi_val`, `modi_Temp` |
| prefix | `path_` / `paths_` (snake) | 일반 경로 변수 / 경로 list (computation 단계) | `path_dat`, `paths_raw` |
| prefix | `PATH_` (UPPER) | 함수 시그니처 / 1-차 Path 객체 | `PATH_IN`, `PATH_OUT`, `PATH_DAT` |
| prefix | `DATA_` (UPPER) | 함수 시그니처 / 1-차 DataFrame 객체 | `DATA_<DOMAIN>`, `DATA_WORK` |
| suffix | `_s` / `_e` | start / end | `id_s`, `id_e`, `search_id_s/e` |
| suffix | `_a` / `_b` | pair (range·boundary) | `boundary_a/b`, `range_a/b` |
| suffix | `_old` / `_asis` / `_modi` | 시간·상태 | `params_old`, `params_asis`, `params_modi` |
| suffix | `_<KEY>` | 위치·dict 키 접미 | `val_X`, `arr_IN` |
| suffix | `f` (단계 시리즈) | final | `Mf`, `Af`, `Bf` (M0/M1/M2/M3 → Mf) |
| suffix | `<N>` | 단계·서브단계 | `mask_1st`, `mask_2nd_step0`, `params2` |
| suffix | 소문자 `s` (UPPER 토큰 직접 결합, `_` 없음) | UPPER 1-차 객체의 list·collection | `DATA_PARTs`, `PATH_PARTs` (`_list` 대신) |
| suffix | `_dt` | data targeted (마스크 적용된 데이터) | `val_dt`, `sig_dt` |
| suffix | `_rs` | residual | `val_rs`, `fit_rs` |
| suffix | `_<process>` | 가공 단계 | `_denoise`/`_denoised`, `_processed`, `_smoothed`, `_scaled`, `_re`, `_short`, `_wide` |

**규칙:**
- 새 도메인에서도 동일한 의미면 같은 prefix/suffix 재사용 (수학·통계·알고리즘 영역에 거의 그대로 적용).
- 신규 도메인 약어 도입 시 `<base>_<KEY>` 패턴 우선 적용.

## 6. 함수 / 메서드 인자

snake_case 기본 · 표준 약어 casing 보존 · primary 데이터 객체는 UPPER.

| 패턴 | 사용처 | 예시 |
|---|---|---|
| snake_case | 일반 | `denoise_strength`, `slope_window`, `column_name` |
| 도메인 표준 표기 (특수 casing) | 학술·산업 표준 약어의 대소문자 보존 | `<StdAbbr>` (예: `dB`, `pH`) |
| ALL CAPS + snake_case | 약어 + 부속어 | `SNR_threshold_soft`, `SNR_threshold_hard` |
| ALL CAPS (인자) | loop 변수가 dict key·data 일 때 | `KEY`, `DATA`, `PATTERN`, `COL` |
| `DATA_<DOMAIN>` UPPER_SNAKE | 도메인 파이프라인 함수의 primary DataFrame 인자 | `def <DOMAIN>_Process_Time(DATA_<DOMAIN>)` |
| `PATH` / `PATH_<KEY>` UPPER | primary Path 인자 | `def <DOMAIN>_Parsing(PATH)`, `def <DOMAIN>_Convert(PATH_IN, PATH_OUT)` |

## 7. 통계 / 수식 변수

표준 통계 약어는 ALL CAPS 그대로 · 위치별은 `_<KEY>` 접미.

| 패턴 | 사용처 | 예시 |
|---|---|---|
| ALL CAPS + `_<KEY>` | 위치별 통계 메트릭 | `RMSE_<KEY>`, `RMSPE_<KEY>`, `STD_<KEY>`, `AME_<KEY>` |
| ALL CAPS 단독 | 단일 척도 | `SNR`, `MSE`, `MAE` |

## 8. 모듈 상수

public = UPPER_SNAKE_CASE · private = `_` prefix.

| 패턴 | 사용처 | 예시 |
|---|---|---|
| `UPPER_SNAKE_CASE` | public 모듈·클래스 상수 | `KEYS`, `POLL_INTERVAL_MS`, `STATE_COLOR` |
| `_UPPER_SNAKE_CASE` | private 모듈 상수 | `_FIXED_SAMPLE`, `_LEFT_PANE_MIN_PX` |

## 9. 적용 우선순위

충돌 해소 = 마스터 모듈 → 도메인 표준 → 언어 표준.

| 순위 | 기준 |
|---|---|
| 1 | 코드베이스 내 마스터 모듈(도메인 모델·사용자 원본)의 표기를 원본 채택 |
| 2 | 도메인 표준 표기(학술·산업 표준 약어) 보존 |
| 3 | 언어 표준(PEP 8·Google Style 등) 적용 |
| 충돌 | 위 1~3 끼리 충돌 시 1 → 2 → 3 순 우선 |

- 이 3계층 = `memory:feedback_code_ownership_scope` 의 명명·인코딩 권위 3계층과 동일 축 (사용자 코드 → 프로젝트 컨벤션 → 언어 표준).

## 10. 안티패턴

| 안티패턴 | 증상 | 교정 |
|---|---|---|
| 동일 의미 약어 혼용 | 한 코드베이스에서 같은 의미를 다른 표기로 (풀단어 `"input"` 와 약어 `'IN'` 직접 비교) | 한 어휘로 통일 |
| 약어 무리한 풀어쓰기 | 표준 약어를 일반 단어로 (`SNR` → `signal_to_noise_ratio`) | 표준 약어 보존 |
| 단계 시리즈 final 만 다른 표기 | `M0/M1/M2/M3/M_final` | `Mf` (또는 `M_f`) 권장 |
| 단순 위젯에 `<DOMAIN>_<Role>` 강제 | 비-도메인 UI·헬퍼에 도메인 패턴 강제 | 단순 PascalCase 로 충분 |
| 외부 호출 인자명 변형 | 외부 함수 인자 casing 을 자체 dict 키로 바꿔 저장 후 매핑 변환 (충돌·인지 부담) | 호출 인자명 그대로 |
| 사용자 정수 enum → 임의 문자열 매핑 | 정수 코드 컬럼에 derived 문자열 컬럼·alias 추가 | 정수 그대로 비교·저장 (§12) |
| 사용자 컬럼명·함수명 임의 변경 | 사용자 명명을 코드 내부에서 다른 이름으로 변환·alias | 사용자 표기 보존 |
| 추측 라벨 채워넣기 | enum 의 의미가 불확실할 때 추측 라벨로 채움 | 원본 보존 또는 사용자에게 질의 |

## 11. 마스터 모듈에서 명명 규칙 추출 (6단계)

특정 모듈(코드베이스 내 원본·도메인 모델)의 명명을 다른 모듈에 일관 적용해야 할 때 — 새 처방이 아니라 사용자 기존 컨벤션의 추출.

1. **마스터 모듈 전수 read** — 부분 read 단정 금지.
2. **추출 대상 분류** — 클래스·함수·메서드·속성·dict 키·인자·지역 변수 별로 어휘를 표로 정리.
3. **규칙성 추출** — 각 분류 안에서 반복되는 패턴(prefix/suffix·약어·숫자·PascalCase/ALL CAPS 정책).
4. **line 인용으로 검증** — 추출한 각 규칙에 마스터 모듈의 line 번호 인용. 인용 못 하면 추측이므로 폐기.
5. **타깃 모듈 점검** — 각 타깃 모듈 식별자 인벤토리 → 마스터 패턴 위반·적용 가능 항목 명시.
6. **사용자 OK 후 적용** — 변경 범위·영향 line 을 사용자에게 보고하고 OK 받은 뒤 일괄 변경.

## 12. 정수 enum 코드 보존

도메인이 정수 코드 enum 을 원본으로 쓰면 어디에서도 문자열 라벨로 변환·alias 추가 X · 정수 그대로 비교·저장·조회.

```python
# 권장 — 정수 그대로 비교
DF["Type"].astype(int) == 2          # 코드 2 (의미는 마스터 모듈 디코더 참조)
QUERY.kinds = (1, 2, 3)

# 안티패턴 — 임의 문자열 매핑 / derived 컬럼 추가
TYPE_TO_LABEL = {1: "init", 2: "active", 3: "idle"}
DF["TypeLabel"] = DF["Type"].map(TYPE_TO_LABEL)
DF.loc[DF["TypeLabel"] == "active"]
```

**규칙:**
- 정수 enum 의 의미 매핑은 한 곳(`<DOMAIN>_MAPPING` dict 또는 매핑 옆 코멘트 디코더)에만 둔다.
- 사람용 라벨이 필요하면 **호출 시점**에서만 변환하고, 데이터 컬럼·저장·비교는 정수 그대로.
- 신규 derived 컬럼·신규 alias 함수는 사용자가 명시적으로 요청한 경우에만 추가.

**Why:** 정수 코드가 원본으로 존재할 때 임의 문자열 매핑·derived 컬럼·변환 레이어를 추가하면 사용자 컨벤션을 깨뜨리고 디버깅·리뷰 비용을 늘린다. 사용자가 정수 enum 으로 정의한 의도는 보통 "정수 그대로 다룬다"는 신호.

## 13. 메모-스트링 dict value

작은 enum(≤10개)을 한눈에 보이고 싶을 때 mapping dict 의 value 에 `'<역할명> = {코드:라벨, ...}'` 메모-스트링을 그대로 저장.

```python
STATE_MAPPING = {
    0: 'Index',
    2: 'Type = {1:"Init", 2:"Active", 3:"Idle", 8:"Repeat", 6:"완료"}',
    6: 'State = {64:"TimedOut", 65:"Reached", 69:""}',
    7: 'Pattern',
    # ...
}
```

**규칙:**
- 메모-스트링은 자기 문서화 용도. 실제 컬럼명을 추출할 때는 첫 토큰(` = ` 앞)만 사용.
- enum 코드 갯수가 많거나(10+) 별도 문서가 필요할 만큼 복잡하면 메모-스트링 대신 별도 dict·docs 파일로 이전.
- 사용자가 이 형식의 dict 를 넘기면 임의로 분리·정규화하지 말 것 (자기 문서화 의도 보존).
