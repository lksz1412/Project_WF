local SQ = LibStub("AceAddon-3.0"):NewAddon("SmoothQuest", "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0", "LibSink-2.0")

local L = LibStub("AceLocale-3.0"):GetLocale("SmoothQuest")

local db
local defaults = {
	profile = {
		morework = true,
		jobsdone = true,
		sinkOptions = {},
	}
}

local tags = {
	[ELITE] = "+",
	[GROUP] = "g",
	[LFG_TYPE_DUNGEON] = "d",
	[RAID] = "r",
	[PVP_ENABLED] = "p",
	[DUNGEON_DIFFICULTY2]="d+",
	[DAILY] = "\226\128\162"
}
-- temp patch for foreignese font problem with the circle for dailies
if GetLocale() == "zhTW" or GetLocale() == "zhCN" or GetLocale() == "koKR" then
	tags[DAILY] = "o"
end
local objects_pattern = '^' .. QUEST_OBJECTS_FOUND:gsub('(%%%d?$?.)', '(.+)') .. '$' --QUEST_OBJECTS_FOUND = "%s: %d/%d"
local monsters_pattern = '^' .. QUEST_MONSTERS_KILLED:gsub('(%%%d?$?.)', '(.+)') .. '$' --QUEST_MONSTERS_KILLED = "%s slain: %d/%d"
local faction_pattern = '^' .. QUEST_FACTION_NEEDED:gsub('(%%%d?$?.)', '(.+)') .. '$' --QUEST_FACTION_NEEDED = "%s: %s / %s"

local err_obj_pattern = '^' .. ERR_QUEST_ADD_ITEM_SII:gsub('(%%%d?$?.)', '(.+)') ..'$' -- "%s: %d/%d";
local err_found_pattern = '^' .. ERR_QUEST_ADD_FOUND_SII:gsub('(%%%d?$?.)', '(.+)') ..'$' -- "%s: %d/%d";
local err_kill_pattern = '^' .. ERR_QUEST_ADD_KILL_SII:gsub('(%%%d?$?.)', '(.+)') ..'$'-- "%s slain: %d/%d";
local err_compl_pattern  = '^' .. ERR_QUEST_OBJECTIVE_COMPLETE_S:gsub('(%%%d?$?.)', '(.+)'):gsub('%(','%%('):gsub('%)', '%%)') ..'$' -- "%s (Complete)"; 

local factionLabels = {}
do
	local gender = UnitSex("player")
	for i=1, #FACTION_BAR_COLORS do
		local faction = GetText("FACTION_STANDING_LABEL"..i, gender)
		factionLabels[faction] = i
	end
end

local function ColorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end

	local num = select('#', ...) / 3

	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

local function rgb2hex( r, g, b )
	if type(r) == "table" then
		g = r.g
		b = r.b
		r = r.r
	end
	return string.format("%02x%02x%02x", r*255, g*255, b*255)
end


local function GetTaggedTitle(i)
	local name, level, tag, group, header, _, _, daily = GetQuestLogTitle(i)
	if header or not name then return end
	if not group or group == 0 then group = nil end
	return string.format("|cff%s[%s%s%s%s] %s|r", rgb2hex(GetQuestDifficultyColor(level)), level, tag and tags[tag] or "", daily and tags[DAILY] or "", group or "", name)
end

local function GetChatTaggedTitle(i)
	if not i then return nil end
	local name, level, tag, group, header, _, _, daily = GetQuestLogTitle(i)
	if header or not name then return end
	if not group or group == 0 then group = nil end
	return string.format("(%s%s%s%s) %s", level, tag and tags[tag] or "", daily and tags[DAILY] or "", group or "", name)
end

local function GetColoredTitle(i)
	local name, level, tag, group, header, _, _, daily = GetQuestLogTitle(i)
	if header or not name then return end
	return string.format("|cff%s %s|r", rgb2hex(GetQuestDifficultyColor(level)), name)
end

local function giveOptions()
	local options = {
		type = "group",
		name = L["Smooth Quest"],
		get = function( k ) return db[k.arg] end,
		set = function( k, v ) db[k.arg] = v end,
		args = {
			soundheader = {
				type = "header",
				name = L["Sound Configuration"],
				order = 1,
			},
			sounddesc = {
				type = "description",
				name = L["Configure the sounds you want to hear with the toggles below."],
				order = 2,
			},
			morework = {
				name = L["More Work?!"],
				desc = L["Toggle playing the 'More Work?!' sound after completing an objective."],
				type = "toggle",
				arg = "morework",
				order = 3,
			},
			jobsdone = {
				name = L["Job's Done!"],
				desc = L["Toggle playing the 'Job's Done!' sound after completing a quest."],
				type = "toggle",
				arg = "jobsdone",
				order = 4,
			},
			header = {
				type = "header",
				name = L["Progress Output"],
				order = 9,
			},
			desc = {
				type = "description",
				name = L["You can select where you want progress messages displayed using the options below."],
				order = 10,
			},
			sink = SQ:GetSinkAce3OptionsDataTable(),
		}
	}
	
	-- haxy tricks to make this look good
	options.args.sink.order = 11
	options.args.sink.inline = true
	options.args.sink.name = ""
	return options
end




function SQ:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("SmoothQuestDB", defaults, "Default")
	db = self.db.profile
	
	self:SetSinkStorage(self.db.profile.sinkOptions)
	
	local acreg = LibStub("AceConfigRegistry-3.0")
	acreg:RegisterOptionsTable("Smooth Quest", giveOptions)	
	local acdia = LibStub("AceConfigDialog-3.0")
	acdia:AddToBlizOptions("Smooth Quest", L["Smooth Quest"])	

    self:RegisterChatCommand("smoothquest", function() InterfaceOptionsFrame_OpenToCategory(acdia.BlizOptions["Smooth Quest"].frame) end)
    self:RegisterChatCommand("sq", function() InterfaceOptionsFrame_OpenToCategory(acdia.BlizOptions["Smooth Quest"].frame) end)	
	
end

local first = true
function SQ:OnEnable()
	self:SecureHook("QuestLog_Update")
	self:SecureHook(QuestLogScrollFrame, "update", "QuestLog_Update")
	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("GOSSIP_SHOW")
	self:RegisterEvent("QUEST_GREETING")
	self:HookScript(GameTooltip, "OnTooltipSetItem")
	self:HookScript(GameTooltip, "OnTooltipSetUnit")
	self:RawHookScript(UIErrorsFrame, "OnEvent", "UIErrorsFrame_OnEvent", true)
	
	self:SetupEnvProxy()
	self:SetupChatFilter()
	
	self:QUEST_LOG_UPDATE()
end

local items, mobs, progress = {}, {}, {}
local mcache, pcache = {}, {}
local complete, oldcomplete = {}, {}
local quests = {}

function SQ:UIErrorsFrame_OnEvent(frame, event, message)
	if event == "UI_INFO_MESSAGE" then
		local name, numItems, numNeeded = message:match(err_obj_pattern)
		if not name then
			name, numItems, numNeeded = message:match(err_kill_pattern)
		end
		if not name then
			name, numItems, numNeeded = message:match(err_found_pattern)
		end
		if not name then
			name = message:match(err_compl_pattern)
			if name then
				numItems = 1
				numNeeded = 1
			end
		end
		if not name then
			if message == ERR_QUEST_UNKNOWN_COMPLETE then
				name = message
				numItems = 1
				numNeeded = 1
			end
		end
		if name then
			local perc = tonumber(numItems) / tonumber(numNeeded)
			self:Pour(message, ColorGradient( perc, 1,0,0, 1,1,0, 0,1,0))
			return
		end
	end
	return self.hooks[frame].OnEvent(frame, event, message)
end

local lines = {}
do
	local i = 1
	repeat
		lines[i] = _G["GameTooltipTextLeft"..i]
		i = i + 1
	until not _G["GameTooltipTextLeft"..i] 
end

function SQ:OnTooltipSetUnit( tooltip, ... )
	--self.hooks[tooltip].OnTooltipSetUnit( tooltip, ...)
	local numLines = tooltip:NumLines()
	for i = 1, numLines, 1 do
		local text = lines[i]:GetText()
		if progress[text] then
			lines[i]:SetText(string.format(" - |cff%s%s|r", rgb2hex( ColorGradient( progress[text].perc, 1,0,0, 1,1,0, 0,1,0) ), text ))
			tooltip:Show()
		elseif quests[text] then
			lines[i]:SetText( GetTaggedTitle(quests[text]) )
			tooltip:Show()
		end
	end
end

function SQ:OnTooltipSetItem( tooltip, ...)
	--self.hooks[tooltip].OnTooltipSetItem( tooltip, ...)
	local name = tooltip:GetItem()
	if items[name] then
		local it = items[name]
		if progress[it] then
			tooltip:AddLine(GetTaggedTitle(progress[it].qid))
			local text = GetQuestLogLeaderBoard(progress[it].lid, progress[it].qid)
			tooltip:AddLine(string.format(" - |cff%s%s|r", rgb2hex( ColorGradient( progress[it].perc, 1,0,0, 1,1,0, 0,1,0) ), text ))
			tooltip:Show()
		end
	end
end

local function getPCache()
	local t = next(pcache)
	if t then
		pcache[t] = nil
	else t = {} end
	return t
end

local function getMCache()
	local t = next(mcache)
	if t then
		mcache[t] = nil
	else t = {} end
	return t
end

local function emptyAll()
	for k, v in pairs(items) do
		items[k] = nil
	end
	for k, v in pairs(oldcomplete) do
		oldcomplete[k] = nil
	end
	for k, v in pairs(complete) do
		oldcomplete[k] = v
		complete[k] = nil
	end
	for k, v in pairs(progress) do
		if type(v) == "table" then
			for kk, vv in pairs(v) do
				v[kk] = nil
			end
			pcache[v] = true
		end
		progress[k] = nil
	end
	for k, v in pairs(mobs) do
		if type(v) == "table" then
			for kk, vv in pairs(v) do
				v[kk] = nil
			end
			mcache[v] = true
		end
		mobs[k] = nil
	end
end

-- Modified update from Quixote
function SQ:QUEST_LOG_UPDATE(event)
	emptyAll()
	wipe(quests)
	local startingQuestLogSelection = GetQuestLogSelection()
	local numEntries, numQuests = GetNumQuestLogEntries()
	if numEntries > 0 then
		local questid
		for questid = 1, numEntries do
			SelectQuestLogEntry(questid) -- this is required for a few of the quest functions.
			local strQuestLogTitleText, strQuestLevel, strQuestTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(questid)
			if not isHeader then
				local strQuestDescription, strQuestObjectives = GetQuestLogQuestText(questid)
				--Many mods like to hook GetQuestLogTitle to add levels to the names.  This is annoying, so strip out the common format for it.
				if strQuestLogTitleText:match('^%[') then strQuestLogTitleText = strQuestLogTitleText:match("^%[[^%]]+%]%s?(.*)") end
				quests[strQuestLogTitleText] = questid
				local numObj = GetNumQuestLeaderBoards(questid)
				if( isComplete and isComplete > 0 ) or numObj == 0 then
					if not first and not oldcomplete[strQuestLogTitleText] and numObj > 0 then
						-- completed the quest
						self:Pour( ERR_QUEST_COMPLETE_S:format(strQuestLogTitleText), 0, 1, 0)
						if db.jobsdone then
							PlaySoundFile("Interface\\AddOns\\SmoothQuest\\sounds\\jobsdone.mp3")
						end
						if IsQuestWatched(questid) then
							RemoveQuestWatch(questid)
						end
					end
					complete[strQuestLogTitleText] = true
				end
				if numObj > 0 then
					local ii
					for ii=1, GetNumQuestLeaderBoards(questid) do
						local ndesc
						local desc, qtype, done = GetQuestLogLeaderBoard(ii, questid)
						if qtype == 'item' or qtype == 'object' then --'object' for the leaderboard in Dousing the Flames of Protection; maybe others.
							ndesc,numItems,numNeeded = desc:match(objects_pattern)
							items[ndesc] = desc -- used for tooltips
							-- items[desc] = ("%s: %d/%d"):format(strQuestLogTitleText, numItems, numNeeded)
						elseif qtype == 'monster' then
							mobName,numItems,numNeeded = desc:match(monsters_pattern)
							if mobName == nil or numItems == nil or numNeeded == nil then
								--Sometimes we get objectives like "Find Mankrik's Wife: 0/1", which are listed as "monster".
								mobName, numItems, numNeeded = desc:match(objects_pattern)
							end
							ndesc = mobName
							if mobs[ndesc] then
								--Another quest also wants this mob!  Convert mobs[desc] to a table.
								if type(mobs[ndesc]) == 'string' then
									local s = mobs[ndesc]
									mobs[ndesc] = getMCache()
									table.insert( mobs[ndesc], s)
									--mobs[ndesc][1] = s
								end
								table.insert( mobs[ndesc], desc)
--								local t = mobs[ndesc]
--								t[#t+1] = desc -- ("%s: %d/%d"):format(strQuestLogTitleText, numItems, numNeeded)
							else
								mobs[ndesc] = desc -- ("%s: %d/%d"):format(strQuestLogTitleText, numItems, numNeeded)
							end
						elseif qtype == 'reputation' then
							ndesc,numItems,numNeeded = desc:match(faction_pattern)
							numItems, numNeeded = factionLabels[numItems], factionLabels[numNeeded]
						elseif qtype == 'event' then
							numNeeded = 1
							if done then
								numItems = 1
							else
								numItems = 0
							end
							ndesc = desc
						end
						numNeeded = tonumber(numNeeded)
						numItems = tonumber(numItems)
						if numNeeded and numNeeded > 0 then
							if not progress[desc] then
								progress[desc] = getPCache()
							end
							progress[desc].q = strQuestLogTitleText
							progress[desc].qid = questid
							progress[desc].lid = ii
							progress[desc].i = numItems
							progress[desc].n = numNeeded
							progress[desc].perc = numItems / numNeeded
							progress[desc].done = done
							local compl = strQuestLogTitleText .. desc
							if done then
								-- make sure we set it to complete regardless of playing sounds
								complete[compl] = true
							end
							if not first and not complete[strQuestLogTitleText] and done and not oldcomplete[compl] then
								-- objective completed
								if db.morework then
									PlaySoundFile("Sound\\Creature\\Peasant\\PeasantWhat3.wav")
								end
							end
						end
					end
				end
			end
		end
		first = nil
	end
	SelectQuestLogEntry(startingQuestLogSelection)
	self:QUEST_GREETING() -- update icons
	self:GOSSIP_SHOW() -- update icons
	WatchFrame_Update() -- run the full questwatch update.
end

-- almost verbatim from questfu
function SQ:QUEST_GREETING()
	if not QuestFrameGreetingPanel:IsVisible() then return end
	
	local numactive,numavailable = GetNumActiveQuests(), GetNumAvailableQuests()
	local title, level, button
	local o,GetTitle,GetLevel = 0,GetActiveTitle,GetActiveLevel
	for i=1, numactive + numavailable do
		if i == numactive + 1 then
			o,GetTitle,GetLevel = numactive,GetAvailableTitle,GetAvailableLevel
		end
		title,level = GetTitle(i-o), GetLevel(i-o)
		button = _G["QuestTitleButton"..i]
		button:SetText(string.format('|cff%s[%d]|r %s',rgb2hex(GetQuestDifficultyColor(level)), level,title))
	end
end

local function gossip_loop(buttonindex, do_texture, ...)
	local numQuests = select('#', ...)
	for i=2, numQuests, 3 do
		local button = _G["GossipTitleButton"..buttonindex]
		button:SetText(string.format('|cff%s[%d] %s|r', rgb2hex(GetQuestDifficultyColor(select(i, ...))), select(i,...), button:GetText()))
		if do_texture then
			local texture = _G["GossipTitleButton"..buttonindex.."GossipIcon"]
			if complete[select(i-1,...)] then
				texture:SetDesaturated(false)
			else
				texture:SetDesaturated(true)
			end
		end
		buttonindex = buttonindex + 1
	end
	return buttonindex + 1
end

function SQ:GOSSIP_SHOW()
	if not GossipFrame:IsVisible() then return end
	local buttonindex = 1
	if GetGossipAvailableQuests() then
		buttonindex = gossip_loop(buttonindex, false, GetGossipAvailableQuests())
	end
	if GetGossipActiveQuests() then
		buttonindex = gossip_loop(buttonindex, true, GetGossipActiveQuests())
	end
end


-- Add tags to the quest log, almost integral from QueLevel
function SQ:QuestLog_Update()

	for i,butt in pairs(QuestLogScrollFrame.buttons) do
		local qi = butt:GetID()
		local _, _, tag, _, _, _, complete, daily = GetQuestLogTitle(qi)
		local title = GetTaggedTitle(qi)
		-- local title, tag, daily, complete = GetTaggedTitle(qi)
		if title then butt:SetText("  "..title) end
		if (tag or daily) and not complete then butt.tag:SetText("") end
		QuestLogTitleButton_Resize(butt)
	end
	
end

--
-- Env. proxy. This way we most likely won't have to re-implement tons of stuff
-- every patch something changes.
-- This proxy is curtsey of haste, thanks mate!
function SQ:SetupEnvProxy()
	local env = setmetatable({
		GetQuestLogTitle = function( id )
			return GetTaggedTitle(id)
		end,
		GetQuestLogLeaderBoard = function( j, index )
			local text = GetQuestLogLeaderBoard(j, index)
			if progress[text] then
				text = string.format("|cff%s%s|r", rgb2hex( ColorGradient( progress[text].perc, 1,0,0, 1,1,0, 0,1,0) ), text )
			end
			return text
		end,
	}, {__index = _G})
	
	setfenv(WatchFrame_DisplayTrackedQuests, env)
end

function SQ:SetupChatFilter()
	local function replace( full, level, partial )
		return full:gsub(partial, GetChatTaggedTitle(quests[partial]) or "("..level..") "..partial)
	end
	local function filter(self, event, msg, ...)
		if msg then
			msg = msg:gsub("(|c%x+|Hquest:%d+:(%d+)|h%[([^|]*)%]|h|r)", replace)
			return false, msg, ...
		end
	end
	for _,event in pairs{"SAY", "GUILD", "GUILD_OFFICER", "WHISPER", "WHISPER_INFORM", "PARTY", "RAID", "RAID_LEADER", "BATTLEGROUND", "BATTLEGROUND_LEADER"} do ChatFrame_AddMessageEventFilter("CHAT_MSG_"..event, filter) end
end

