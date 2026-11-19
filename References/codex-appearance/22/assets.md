# stage 자산

아래는 퇴역한 시안의 자산 기록이다. 최신 테마는 별도의 제작 이미지와 패키지 경로를 쓴다. [최신 제작 지시](fantasy-art-prompts.md) · [최신 패키지 TGA와 파일 해시](fantasy-asset-provenance.json)

공통 패널·막대·구분선 질감의 생성 코드는 `tools/generate_stage_assets.py`다. 아래의 `stage_left.tga`·`stage_right.tga`는 이전 시안에 사용했다.

|파일|크기|SHA256|
|---|---|---|
|`stage_bar.tga`|(32, 128) RGBA|`5a133f21666bc2ee7189bf94139b5d2bbf34bfa9804c204d72ca0734268a5429`|
|`stage_divider.tga`|(16, 128) RGBA|`3aa3de914c0cd13588e4d0c199e555ac1a9d3fd6ff7aa48df1e214449a21d7a2`|
|`stage_left.tga`|(256, 256) RGBA|`e8350f63497f71062a1e203eba0fffbb7032aef3a544d051680b1b1b714d9767`|
|`stage_panel.tga`|(128, 128) RGBA|`7416b6e32b5576d3e076efeb2a271d1ca9241c771e11d45af87fad58c9b24384`|
|`stage_right.tga`|(256, 256) RGBA|`71790cd53298c14412777985ccbea2288514ad175cd246616bdeaac38a0ff18b`|

## 설치 후보의 대안 테마 장식

ImageGen 기본 도구로 새 그림 두 장을 만들고 각 그림을 좌우로 잘라 투명 TGA로 변환했다. 원본 PNG는 `_local_only/theme-layout-r118/ink-source.png`, `stage-source.png`에 있다. 네 파일은 모두 256×256 RGBA다.

| 테마 | 그림 | 새 TGA의 SHA256 |
|---|---|---|
| Ink | `moon_jar.tga` | `5a31e884d5e1f26b536b6768a61dfdac122b436c1d31c1ab2ce295f2347ea5ba` |
| Ink | `inkstone.tga` | `d56ab5d82a295a5303453ad43b90d64c846c02dd378012c21f02899cc3bcc86b` |
| Stage | `monitor.tga` | `6fe0e5727ab993be10f5709ee0c84e663692d569f1aaeee2fa7b2d50df051259` |
| Stage | `mixer.tga` | `7150d390033409ff045faec13d537b2fc684825deae72cf0dfe0d0db8a5c0d3d` |
