# R36 additional source evidence — static research only

Recorded 2026-11-17T23:43:46.020286+09:00. A1 /root/old_reference. This file extends the pre-R36 evidence; it is not final Step3 acceptance or Step4 product selection. No addon code, installer, game input or README command was executed.

## V42 source and actual full reads

Source post: https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=13140 . Exact literal archive: https://pds.inven.co.kr/upload/2026/11/17/addon/_forever_V42.zip . Root preserved 9,897,762 B, SHA256 7961B3AE6C308256345BE4DBE732019276AC04B0C123F63AB198B8F5A759A908. Same A4's single CRC/safe extraction gates: acquisition/r36/forever-v42-archive-checks.json, 1,831 files / 52,281,213 extracted B, unsafe/reparse arrays empty. This proves source integrity/extraction, not runtime compatibility.

V42 = work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/. All following paths relative to V42. A1 direct full reads in current context: !DevilUI/!DevilUI.lua1–1905 (windows1–280/281–560/561–840/841–1120/1121–1400/1401–1680/1681–1905); !DevilUI/minimap.lua1–1203 (1–260/261–520/521–780/781–1040/1041–1203); !DevilUI/!DevilUI.toc1–14; !DevilUI/load_Profile.xml1–17; Devilconfig/ForeverCompat.lua1–37; PitBull4/PitBull4.toc1–29. Prior context's failed core1561–1820 output was not counted; present complete windows restore that range.

| File | SHA256 |
|---|---|
| !DevilUI/!DevilUI.lua | 8abf8a330a8171c76340e0c4f387757e8166f64f815d949525efa27b5d6c4ebb |
| !DevilUI/minimap.lua | 4c3026579bb80fab7eb24d7fc3122668f82662b5b1f815f588f624c603594917 |
| !DevilUI/!DevilUI.toc | 5559f382156e5919d14e7b2b6a71a33c76ac4f69d455a75dfd3820739302621d |
| !DevilUI/load_Profile.xml | d513e31653a2cca627cdd2da4abe34a0a52af8ecbee8a68733a370ac5c65c749 |
| Devilconfig/ForeverCompat.lua | 0a96bdca8cde59bab90193bc0a649f20a354a394784c8a3bd6b036957bebce20 |
| PitBull4/PitBull4.toc | d37e38d99708c6661ea0b7515523733c8644957a77ad0ecfa305dec731bfaff6 |

## Literal mechanisms and bounded interpretation

| Confirmed static fact | Exact source and original fragment | A1 interpretation / limit |
|---|---|---|
| Current integration has API adaptations | Devilconfig/ForeverCompat.lua4–6 `(C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata`;7–18 combat guard/AceConfigDialog;20–29 gradient/resize fallbacks | Actual adaptation code exists, beyond a TOC label. Availability and correct execution in this PC remain unverified |
| Five core profile variants exist | !DevilUI.lua4–47: Wide / Wide_B / Wide_WH / Wide_P / Wide_T | Fan/Standard/Special/GamePad/Tablet differ; cannot combine defaults or assume three chats in every variant |
| Three-message-window layout is explicit in Wide and Wide_WH | !DevilUI.lua308–349 `extraChat = {guildChat = ... , lootChat = ...}`;351–354 Wide_B `singleChat = true`;971–976 two named native extra windows | A main window plus two extra windows is source-backed for those variants. This does not prove the photograph used this build/profile |
| Extra windows are native chat frames | !DevilUI.lua1140–1207:1172 `FCF_OpenNewWindow(definition.name, true)`,1194 `FCF_UnDockFrame(chat)` | Reuses native message/input machinery rather than drawing fake transcript panels. Current behavior still requires later game verification |
| Extra-window configuration changes filters | !DevilUI.lua1174–1184 `remove(chat)` / `clear_channels(chat)` / `add(chat, group)` / `remove_general(ChatFrame1, group)` | Not a filter-preserving appearance-only operation. Historical guild/loot split is distribution policy, not user's preference |
| Main/combat filters are also replaced | minimap.lua807–839:815–822 `remove(chat)` then default message groups, followed by ConfigureExtraChat | Copying installer chat initialization would overwrite selected classifications; preserve user filters in future design instead |
| This code does not hide every chat tab | !DevilUI.lua1198–1199 `if tab then tab:Show() end`; minimap.lua1138 `ChatFrame2Tab:Show()` in Tablet path | No whole-bundle no-tab/title claim. Additional theme modules would need their own evidence |
| Main and extra positioning have native/panel/manual branches | minimap.lua197–226; !DevilUI.lua1096–1138. `cfg.x * w`, `cfg.y * h`, `cfg.w * w`, `cfg.h * h`; panel inset6/10 and size minus14/28 | Current source uses normalized fractions in some paths. User's 4K bottom-up rule supersedes copying those fractions as a new target |
| Native layout edits are persisted explicitly | !DevilUI.lua765–806 CommitNativeChat uses C_EditMode SaveLayouts; minimap.lua88–103 commits then ReloadUI;487–513 captures saved placement | Useful lifecycle reference, not a demonstrated safe drop-in. Event hooks and selected input mode are part of integration |
| Layout execution is guarded | minimap.lua771–787 checks enabled/applying/moving/combat/EditMode/native dirty; !DevilUI.lua524–535 validates EditMode methods/presets | Shows intended scheduling/guards; no runtime PASS inferred |
| Square/default map is a saved per-profile choice | minimap.lua12–31/605–627; map1px backdrop235–237, square mask707 | Reference mechanism separate from exact old Devil border/ornament fidelity and input testing |
| Installer performs wider configuration changes | !DevilUI.lua1595–1675:1618 import_presets;1643–1644 useUiScale1 and uiScale0.9/0.7;1667 Reflux switch | Whole installer is unsuitable as an appearance-only transplant; no command was run |
| Current skin differs from Alpha literal | !DevilUI.lua1375–1379 sets `SkinID = "Onyx Classic"` for partial Masque migration | Preserve distinction from Alpha Onyx and from image-level skin identity; profile literal data may add evidence |
| Source load chain is connected | TOC10–14:core→profile XML→minimap→libs/media; minimap.lua3/118/1202 calls FinishProfileLoad/LoadChatSetup/LoadInstaller defined in core176/967/1213 | Source profile loading and chat/installer definitions are statically connected. No source code execution used |
| PitBull version/build is a distributor declaration | PitBull4.toc2 `Confirmed Forever 1.60.1 build 70291`,19 `4.2.49-Forever-v42`,15–16 distributor/original authors | 70291 differs from historical local70938; neither TOC nor these core reads verify full PitBull implementation/runtime |

## Intake checkpoint at 2026-11-17 23:43 (historical)

Other-post1932 multipart RAR and3461 BlackEdition2 ZIP public retrieval/static comparison are pending at this record. idx45 four date-pattern candidates returned404; author public fallback found no selected binary URL. These are bounded failures, not proof that original files never existed. Root normal-browser old-row link was login-only; no authentication attempted. Additional observed legacy-prefix candidates may be checked by the same A4 within the parent's bounded dispatch. Final source-package coverage will be appended after actual returns.


## Other supplied posts: new direct packages and relevant source reads

B08 = work/old-reference-r36-13d5mmwk/extracted-idx1932-rar. BE2 = work/old-reference-r36-13d5mmwk/extracted-idx3461-sfx. Public acquisition receipt acquisition/r36/other-posts/package-acquisition.json records3461 literal ZIP and1932 literalpart2/PREDICTEDpart1 counterpart separately. A1 directly read all3receipt records, then queried all gate fields excluding huge name-only arrays. Initial overly broad candidate output truncated; no fullcandidate-array reading claimed. Subsequent targeted name query and fullgate-field output restored actual gate evidence.

1932 static multipart gates: list/test/extract RC0; integrityTestRuns1;2407files/38,791,956B, unsafe/missing/unexpected/reparse arrays empty, listed/extracted per-file and total bytes equal.3461 outerZIP1file CRC1 passed; innerNSIS list/test/extract RC0,integrity1,2936files/40,624,475B,unsafe/missing/unexpected/reparse empty. NSIS listedsize-1 means listed-byte equality null, not confirmed. Exact new payloads remain unexecuted. Preservation receipts and final profile/media data follow helper output.

A1 full direct reads: B08/Interface/AddOns/NeonChat/{NeonChat.toc1–8,NeonChat.lua1–57}; SisterChatMods/{SisterChatMods.toc1–23,SisterChatMods.xml1–39,SisterChatMods.lua1–483 windows1–245/246–483}; unique distribution-template chat-cache.txt1–292; distribution-template AddOns.txt1–123. BE2/Interface/AddOns/!DevilUI/{!DevilUI.toc1–13,load_Profile.xml1–28,!DevilUI.lua1–295 windows1–170/171–295,minimap.lua1–135}. Printed UTF8 source lines; source hash/read-count manifest follows. The source template's placeholder account/server/character path is not current user game data. No bindings/macro/config-cache source was opened.

| Static finding | Source quote/pin | Meaning and bound |
|---|---|---|
| 1932 uses a different chat-module generation | NeonChat.toc Interface20400 and SisterChatMods.toc Interface20400; template AddOns.txt marks SisterChatMods/NeonChat/eePanels2/Bartender4 enabled | Actual bundled code/default enablement, not currentPC state; 3.0.2 article may bundle older-tagged modules |
| Left controls hide and native editbox moves | SisterChatMods.lua56 `hide(ChatFrameMenuButton)`;64–65 up/downhide;83–93 MoveEditBox branch. Default MoveEditBox=false9 | Source mechanism exists; default is below-chat placement, not always-above. Saved flag interpretation remains separate |
| Scroll return button is conditional | SisterChatMods.lua152–183 wheel,178–182 hide/show based AtBottom | Not all controls absent in every input/scroll state |
| ChatFade means native message fading here | SisterChatMods.lua477–483 `chatframe:SetFading(SCMSaved.chatFade)` | Do not convert comment wording into whole-frame or title/tab auto-hide evidence |
| 1932 active input gets a new border | NeonChat.lua32–37 hides regions6..8, then tooltip edgeSize14;44–57 channel-color update | Same old design pattern as2009 DChat, not fully borderless or absent typing UI |
| 1932 saved template has only one shown window | chat-cache.txt74–80 WINDOW1 SHOWN1;127–133 WINDOW2 SHOWN0;151–157 WINDOW3 SHOWN0;172–178 WINDOW4 SHOWN0;5–10 also0 | Contrasts with2009 template three shown1/3/4. Does not satisfy user's3chat by itself and not assumed identical to picture/default installer state |
| 3461 initializer creates one extra native window | !DevilUI.lua68–125 reset then WINDOW3 creation, NORMAL/else branches;127–178 alpha/font14 and group reset of1/3 | Main plus guild window3, with combat2 docked; no fourth-window creation in this file. Different from AlphaSPECIAL three-window initializer |
| 3461 map starts at upper right | minimap.lua7–13 SQUARE/scale1.1/TOPRIGHT;124 square mask | Distinct from target45sample4 lower-square map; not a remembered-original replacement merely because author matches |
| 3461 initializer provides thin panel helper | !DevilUI.lua6–21 CreatePanel uses blankbg/edge andedgeSize1 | Function availability alone not proof every panel used it or sample4 used this asset |
| 3461 has a stale profile include | load_Profile.xml6 `<Script file="Profile\CAN_Chat.lua"/>`; actual Profile directory25filenames contains no CAN_Chat.lua | Original content issue, no repair. Do not apply AlphaSTANDARD saved CAN flags to this package |
| 3461 CAN implementation is exact byte match to Alpha common modules | A1 read-only bytes/SHA comparison core/toc/buttons/chattab/config/mouseover/sharedmedia:7/7 equal | Existing Alpha full-code interpretation can describe identical module bytes, while this package's caller/default/profile loading differs. Not a new source-execution test or current support proof |

SisterChatMods full code also wraps native ChatFrame_OnEvent/AddMessage and stores nickname/class data. Those nonvisual behaviors are not required for visual restoration; no collected identities are copied into this report. Its title/tab complete hide was not established by the selected module. Source style/defaults, saved template, and actual runtime remain distinct.


## Fully parsed additional literal settings and partial V42 boundary

acquisition/r36/other-posts/selected-new-literal-settings-compact.json contains8 successfully whole-token-parsed source datasets; A1 checked all8 token counts equal and duplicate key arrays empty. Raw typedsource remains ignoredcache/new-selected-literal-full-typed.json. Delivery omits profileKeys and SCMDataBase:12containers/326entries, exact source spans/counts in selected-new-literal-exclusions.json. This is an explicit filtered subset, not an unmodified whole-source JSON. Original9 parsed datasets remain separate and are not rerun.

- 1932 eePanels2 Default has6 named panels Recount/Minimap/Chat1/BarBG/Bottom/Omen, all mouse=false. All six border.texture values are Interface\None (source45/120/242/270/350/441); BarBG.border.media separately says Blizzard Tooltip. Do not infer actual edge rendering from one field alone. Nativechat templateonlywindow1 is consistent with Chat1 singlepanel but not proof of every runtime state.
- 1932 SCMSaved values: FadeMenuButton=true, MoveEditBox=false, chatFade=true; NeonChatDB border1/background0.75. These saved flags connect to fully read module branches. Bartender4 Default ActionBars uses scale1.25/padding−7 on selected rows, skinID Vol II; absent columns/numButtons fields are not invented into measured8×3.
- 3461 kgPanels Normal/WideX/Wide each5panels map/Recount/Bar/Omen/Chat, all border_texture Devil2/edge10/mouse=true. Wide source map border1002/mouse1010, Bar1195/1198, Chat1377/1380. These mouse flags are unlike AlphaSPECIAL noninteractive panel defaults; current click behavior still untested.
- 3461 Masque Normal/Wide/WideX uses Darion Clean (e.g.Wide ActionBar SkinID49), distinct from Alpha Onyx and later Onyx Classic. Wide/WideX Dominos frames1/3/5/6 each12buttons/spacing2/scale0.9, columns absent; no exact raster row reconstruction claimed.
- V42 kgPanels/Dominos/Masque whole-source parsing stopped at indexed Wide_T assignments at2269/3409/5822. Three records are not whole-token success and yield no final-profile totals or final-values claim. The direct core/minimap full reads support the scoped current reference comparison without expanding parser implementation. Source tails were inspected only as literal-data boundary examples, not executed or called complete code reads.
- V42 and3461 media/sharedmedia.lua each1–21 fully read: Devil/Devil2/Devil3/roth registrations10–13 and angel/demon backgrounds6–7. SameA4 V42 four border byte-hash comparison is separate from actual panel usage or picture identity.

Durable original receipt preserved-original-copies.json confirms source/copy SHA equality3/3 for3461 ZIP and1932 two RAR parts in SourceArchive/post-3461-2015-03-04/originals and SourceArchive/post-1932-2008-11-02/originals. No repeated GET/CRC. RAR physicalheaders3167 vs listedentries3166 is actually reconciled: the same rawfilename has part1splitAfter@5241818 and part2splitBefore@20; rawhex identical. See rar-header-count-reconciliation.json, arithmetic1389+1778−1=3166=2407files+759dirs. This is observed split continuation, not a guessed count explanation.

## X2 historical original-family retrieval and safety boundary

Actual selected idx45 attachmentrow159: DevilUI-X2 R3.4.zip/client2.4.3/date2008-09-27. Predicted URL from observed legacy public prefix resolved HTTP200: https://pds.inven.co.kr/upload/wow/addonpds/file/DevilUI-X2%20R3.4.zip . URL basis remains PREDICTED after success, not an exposed fileID mapping.7,245,308B SHA256541F98566586F82FF88E464255EB0476F952CAF9E689C53AEB240D5AE54FF4EA; preservedcopy SourceArchive/post-45-2008-09-27/originals/DevilUI-X2 R3.4.zip. OuterZIP CRC1/path gates passed, oneEXE7,349,977B was extracted, never executed. R1/3.05 legacy probes were not attempted after primary success.

X2 innerNSIS list/test RC0 with integrity1 and4217listedfiles; whole extraction BLOCKED by288 unsafe NTFS names containing '?' under variant names read as Windows-incompatible by the extraction tool. Listeduncompressedsize−1, no reliable byte sum. No whole-inner extraction was run. Parent authorized exact safe-member data extraction using documented bz filename arguments; A1 selected46 actualsafeentries in a1-x2-safe-selected-members.json, retaining full blockedgate/inventory. SameA4 validates exactresolvedpaths/collisions and reconciles the subset only in a freshroot using Python argv, no wildcard/shell expansion/rename. Subset receipt/content analysis pending at this checkpoint; do not count46selected as recovered or4217full recovery.


## X2 exact safe subset: source interpretation

The sameA4's acquisition/r36/x2-selected-subset/X2_SUBSET_READY.json was directly checked: exactallowlist46/extracted46/940,901B,extractRC0,missing/unexpected/reparse/unsafeSelected empty, sourceExecuted=false, usedShell=false, newIntegrityTestRuns0. It binds the original inventorySHA and allowlistSHA. Whole4217entries/unsafe288 staysBLOCKED; this is only46selected files, not full recovery.

X2 = work/old-reference-r36-z41s_asv/selected-extracted/$HWNDPARENT. A1 full source reads are37files across all R36 selectedinputs in a1-r36-code-read-coverage.json, including X2common14 code/load files plus4nativechattemplates. X2Sister517 read windows1–260/261–517; BartenderDefaults312 whole; SharedMedia34 required strictCP949 decoding after UTF8 failed, bytes unchanged. All other selectedX2 code/templates read strictUTF8-sig. Original archives/EXE neverexecuted.

- X2commonSisterChatMods.lua57/65–66 hidesmenu/up/down,84–94 nativeeditplacement flag,157–188 wheel/conditionalbottomreturn,512–517 SetFading. NeonChat57lines removesregions6..8 then recreatesedge14 at32–37. DFontChatSizes.lua4–23 sets choices7..24; XML3/26–28 loads/calls it. This supplies concrete historical clean-chat mechanisms while preserving native typing. Complete tab/title hiding remains unproven by these selected files.
- OriginalX2Sister also contains gossip-selection wrapper127–128/432–453;1932customSister483 has that implementation removed, as its article says. Visual restoration does not require importing it, nickname collection, message wrappers or sticky-channel changes.
- Four X2variant nativechattemplates were read fully: SPECIAL282lines showsWINDOW1@78 and2@129; SPECIALW284lines shows1@78,2@127,3@151; STANDARD282 andSTANDARDW282 showonly1@78,2off@129,3off@152. Other windows areoff. SPECIALW has an actual saved three-window distribution; SPECIAL/Standard aredifferent. These default filters are not user's current choice and no sample4/buildidentity is inferred.
- Bartender3.toc13/26 declaresBT3DB/provider3.1.4 andloadsDefaults.lua42. Defaults.lua114–134 has Bars wildcard Rows1/Buttons12; savedvariant rows mayoverride. Defaults90–111 also contains keybinding conversion, which was only read and never run. A full modern bar implementation audit is outside this scope.
- SharedMedia.toc13–15→Core.lua11–28/30–73 registers/deferred-registers data; SharedMedia.lua16–18 registers RothSquare/DevilSquare/Devil2Square to actualborderfiles. Devil folder'sfive images andthreeSharedMedia borders are available within subset for byte/header checks only; no A1imageview or pictureassetidentity proof.

Fourvariant20literaldata parse/query was the last accessory data unit pending at that checkpoint; the current completed result follows below. Existing sourcecode/filter/geometry conclusions remain bounded as above; no more packages or originalfilename probes are needed perparent.


## Current closed R36 evidence: X2 variant data and limits

A1 directly queried all20 X2 selected literal source records: every whole-token count equals consumed tokens and every duplicate-key array is empty.4variants×5datasets =20, exact sourceSHA/spans in x2-selected-literal-parse-overview.json and x2-four-variant-settings-compact.json. Delivery intentionally omits4SCMDataBase containers/90entries, original fulltypedsource stays ignored. No V42parser extension occurred; old9/newother8/X2selected20 are three separate successful data groups, not fullarchive coverage.

- SPECIALW eePanels2 Default has9panels, allmousefalse: leftdemon/rightangel, middle18high@y160, bottom19high, minimapborder, RecountTooltip, chat1/chat2/chat3. Chat1 x0,width401;chat2 x399,width392;chat3 bottomright,width401;all y19,height143, border Blizzard Tooltip/edge16/path Interface\Tooltips\UI-Tooltip-Border (source467/542/665). These are distributiondata, not4K coordinates or a screenshot buildproof.
- SPECIAL has8panels andtwochatpanels; STANDARD/STANDARDW have5panels with no chat1/2/3 panelset. This matches distinct templatewindow-count evidence but does not authorize merging variants.
- SPECIALW Bartender3 Bars3/4 each Rows3 atsource67/74,Scale1.09 and nearlyequalPosY28.5. CommonDefaults124 has Buttons12; IF those defaults apply this yields two4×3blocks, structurally compatible with approximate8×3 observation. This is an A1 inference, not verified render/action ownership. No barcaller/runtime audit or keyconversion was executed. OtherBars1/5/6 lie aroundPosY128 in thatdata; exactlongrowcountinsample4 remains unproved.
- Allfour cyCircled defaultskin values are Onyx: Square Gloss (source16), distinct from AlphaMasqueOnyx,BE2DarionClean andlaterOnyxClassic. SPECIALW simpleMinimap data has lowmapPosition2≈64.52 andskins.skin2/borderfalse; do not interpret skin2 as square without its implementation. Picture geometry remains primary.
- Allfour SCMSaved keep FadeMenuButton=true,MoveEditBox=false,SkipGossip=false. This separates the presence of oldgossip wrapper from the shipped disabledflag and from the future visual-only proposal.
- Selectedasset8records are header/byte checks, noimageview. Devil/Devil2/roth each equal the previously preserved2009/Alpha/2022 same-namebytes. X2Devil/tooltip.tga also equalsDevil2 hashF4FAD956F5769C5A7C543D9A4541510898355CAC54091DAA00FA430C1E0255DD, but use of an installed globaltooltipoverride was not established by selectedsubset. FiveDevil-folderassets andthreeSharedMedia borders are not eight observedpictures or proofsample4assetidentity.

Final limits: X2 wholearchive remainsBLOCKED because tool-listed288paths wereWindows-incompatible; whether caused by originalnames or NSIS decoding is unverified. Only46selectedfiles recovered. V42threeprofiledatafiles notfullyparsed. Twoidx8906 sampleimages notobserved. Exactsample4-build/profile/render identity, assetredistributionrights andcurrentPC input/filter/combat/runtime areunverified. Allrequested34articles/50availableuniqueimages and selectedR36source comparison are accountedfor; independentB andStep4 remain pending.

Cross-generation role boundary: X2SPECIALW savedshown1/2/3, AlphaSPECIAL initializer1/3/4, currentV42 ConfigureChat handles2ascombat andallocates extraIDs>=3. Preserve three independent message-window roles, not oldnumericIDs/filters wholesale. No newAPIresearch or codeexecution.
