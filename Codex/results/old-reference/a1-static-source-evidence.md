# Step3 static code evidence

A1 direct source reading; no Lua/EXE execution or runtime compatibility claim. File line numbers refer to preserved extracted bytes decoded UTF8-sig; original hashes in acquisition inventory. Root aliases:
- OLD = work/old-reference-collection-0qlzzyxg/extracted-2009
- ALPHA = work/old-reference-collection-0qlzzyxg/extracted-alpha-nsis
- LATE = SourceArchive/2022-11-19/extracted/Interface/addons
All relative paths start at D:/Projects/Project_WF. Source files remain immutable. Quote fragments below are actual source, interpretation is A1.

## 2009 native chat and ornament mechanisms

| File and full actual reading | Actual quoted source | Interpretation / limit |
|---|---|---|
| OLD/Interface/AddOns/DChat/DChat.toc:1–6 | `## Interface: 30200`; `DChat.lua` | Historical client tag, not Forever support |
| DChat.lua:1–349; relevant100–119 | `CHAT_FONT_HEIGHTS = {`; values7..32 | Extends font-size choices, not fixed current font |
| DChat.lua:168–193 | `hide(ChatFrameMenuButton);`; `hide(x['ChatFrame'..i..'UpButton']);`; `c:EnableMouseWheel(true);` | Menu/navigation hiding plus wheel scroll. Bottom-return button can show when scrolled away from bottom |
| DChat.lua:199–213 | `ChatFrameEditBox:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -5, 0)`; `select(6, ChatFrameEditBox:GetRegions()):Hide()` | Moves existing input above first chat and hides three default border regions; does not remove native input |
| DChat.lua:238–266 | `edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border"`; `edgeSize = 15` | Adds a new channel-colored Neon backdrop. Completely borderless is an overclaim; CAN_Chat_Border/Background referenced but not defined in this file |
| OLD/Interface/AddOns/Devilconfig/{Devilconfig.toc1–14,Devilconfig.lua1–137,DevilSkin.lua1–36} | `ChatFrame1:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 12, 34)`; width426,height150 | Skin initializer covers ChatFrame1 only; not sufficient proof of three saved windows |
| OLD unique archive member suffix chat-cache.txt:1–305 | WINDOW1 line85 `SHOWN 1`; WINDOW3 line155 `SHOWN 1`; WINDOW4 line184 `SHOWN 1`; WINDOW2 line130 `SHOWN 0` | Three visible saved native windows1/3/4; per-window MESSAGES/CHANNELS blocks stored separately. This distributor template is not user's current channel preference. Exact member raw name preserved in archive inventory; no identifier-based lookup needed |

DChat contains nonvisual channel-sticky, Alt-invite, tell-target and URL message wrappers too. Source discovery is not authorization to copy those behaviors. Tab/titlebar hiding was not established from DChat; Skinner profile has ChatTabs=true, but that flag alone does not prove hiding semantics.

## Alpha variants and clean-chat mechanisms

| File and full actual reading | Actual quoted source | Interpretation / limit |
|---|---|---|
| ALPHA/Interface/addons/!DevilUI/!DevilUI.toc:1–13 and load_Profile.xml:1–24 | `## Interface: 60100`; `<Script file="Profile\CAN_Chat.lua"/>` | Historical6.1 payload. Common addon files and STANDARD/SPECIAL variant profile files are distinct, not merged |
| ALPHA/var/STANDARD/Interface/AddOns/!DevilUI/!DevilUI.lua:1–176 | `FCF_ResetChatWindows()` at41; first-frame position53–55 | General initializer. Its one first-frame placement must not stand in for SPECIAL bottom-focused layout |
| ALPHA/var/SPECIAL/Interface/AddOns/!DevilUI/!DevilUI.lua:1–255 | `FCF_OpenNewWindow("길드&귓말")`44; `FCF_OpenNewWindow("파티")`68; `ChatFrame4:Show()`71 | Wide branch creates/undocks windows3/4 alongside1. Normal branch differs. Native filters are explicitly set111–154; source channel names not copied as user's desired split |
| Same SPECIAL file76–90,103–109 | width formula `((GetScreenWidth()/2)-54)/2`; `FCF_SetWindowAlpha(ChatFrame1, 0)`; font13 | Historical proportional placement/default sizes, not a4K global-ratio prescription |
| Same STANDARD143–161 / SPECIAL225–240 | `SetCVar("scriptErrors", 0)`; `SetCVar("uiScale", 0.75)` | Initializers also reset chat/global settings and suppress errors. Read as evidence, not future execution instructions |
| ALPHA/Interface/addons/CAN_Chat/CAN_Chat.toc:1–16 | `channelshort.lua`12 | Actual directory has `1channelshort.lua`, no exact called filename; original package issue, unmodified/unexecuted |
| buttons.lua:1–70 | `hideButton(ChatFrameMenuButton)`25; Friends27; up/down/minimize44–46 | Removes left ornaments but bottom-return button visibility remains state-dependent |
| chattab.lua:1–126 | `frame.leftTexture:Hide()`57; `frame:SetAlpha(1)`76 | Removes tab textures and styles remaining text, not complete tab/title removal |
| mouseover.lua:1–13 | hyperlink HookScript loop10–13 | Tooltip behavior, not native window replacement |
| CAN_Chat.lua:1–423 (windows1–230/231–423); config.lua:1–620 (1–200/201–420/421–620) | `if CANChat["Edit"] ==1 then`330; config35 default1; STANDARDProfile/CAN_Chat.lua8 `Edit=0` | Existing edit boxes move above chat only when flag1; bundled profile explicitly0 overrides default1. Do not claim Alpha always relocates input above |
| CAN_Chat.lua350–357 / profile7 | OutLine==1 sets font13; bundled OutLine=0 | Conditional font treatment, not unconditional13px |
| CAN_Chat.lua388–423 | channel tint alpha0.7; `for i=6,8 do ...:Hide()`421 | Replaces input ornament with tinted backdrop on active native input; retains typing mechanism |
| config.lua37 and full directory search | `if CANChat["Hide"] == nil then CANChat["Hide"] = 0; end` | No consumer of this Hide flag found in CAN_Chat directory. Cannot infer tab auto-hide from profile key |

Full CAN core also wraps SendChatMessage135–139, supports automatic party-window hiding20–31 and message highlight/exclusion238–286. These are separate behavior changes; not needed merely to recover appearance or justified by three-window preservation.

## Later comparison and media registration

LATE/!DevilUI/{!DevilUI.lua1–207,load_Profile.xml1–21,!DevilUI.toc1–13} directly read. Source uses ShapaNormal/ShapaWide/ShapaWH switch names and different resolution/global-setting logic. No replay of prior CRC/extraction. This historical source does not reinstate rejected2022 target.

OLD/Interface/AddOns/mySharedMedia/{Core.lua1–73,LibStub.lua1–30,SharedMedia.lua1–37} directly read. SharedMedia16–18 registers RothSquare/DevilSquare/Devil2Square border paths. ALPHA common!DevilUI/media/{sharedmedia.lua1–21,load_media.xml1–3} registers Devil/Devil2/Devil3/roth borders, angel/demon/Minimap backgrounds, status bars and K_Damage. Asset existence/byte equality does not establish which asset rendered sample4 or license to redistribute.

## Static literal profile data

SavedVariables/profile tables are data, not executed addon code. A4 reused existing Python literal parser definitions without executing its old driver or Lua. acquisition/literal-table-parse-overview.json records9/9 full token consumption,0 duplicate keys. A1 directly queried full typed data by assignment/profile/layout/frame keys; not claiming source prose code-reading for these large literal tables. Integer/string keys preserved. Small final profile/media records and source-line mapping are linked by later append.


## Final profile/asset source pins

- 2009 kgPanels Default.layout=devil source495; six panels in11–480. border_texture lines42/120/198/276/354/432: None/None/None/Blizzard Tooltip/None/None. Exact key paths and originaltypedvalues in acquisition/literal-settings/2009-kgPanels.json.
- Alpha SPECIAL kgPanels Wide source766–1520; Wide.layout1528. border_texture chat2=Devil2 at849,chat1=Devil2 at944,middle=Blizzard Dialog1226,minimap=Devil2 at1320,chat3=Devil2 at1414. Those are data assignments, not a screenshot rendering proof.
- Alpha SPECIAL Dominos Wide frames3/4 source735–770 and771–807: each12buttons/4columns. Shape correspondence to approximate8x3 source observation is an A1 structural inference, not exact render identity. MasqueSPECIALNormal10–38/Wide39–67 have SkinID Onyx.
- Border byte comparison acquisition/border-asset-byte-comparison.json:11files/55pairs. Devil SHA9DE505F668137A32B3ADD4CD56ADB6B84883B798B0E3398C37B6CBCCED914504;Devil2 F4FAD956F5769C5A7C543D9A4541510898355CAC54091DAA00FA430C1E0255DD;roth49CA0BC8E0CBDD6ABED71748E3B686032F588C5E2829E6B844C9EC1F8B1A3AA9 match2009/Alpha/2022 respectively. Devil3 150DEC18668CCCB2EF33B37D1C8A9468FDE7478F42747CEFFC037037C215D86B matchesAlpha/2022. Header128x16 only; no image-content inspection ofasset here.
- Existing2022Masque is literaldata985lines, not fullyprose-read claim. A1 directly queried loaf subtree key SkinID from visible source29–119, including33 Onyx Classic; root independentlyparsed/observedpriorrecord. No currentproductidentification from this value alone.
