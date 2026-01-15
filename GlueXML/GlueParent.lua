--------------------------------------------------------------------------------
-- GlueParent.lua
-- Core glue screen management for WoW (login, character selection, options)
-- Optimized for private server use - removed Blizzard subscription/retail systems
--------------------------------------------------------------------------------

-- =============================================================================
-- SCREEN REGISTRY
-- =============================================================================

GlueScreenInfo = {}
GlueScreenInfo["login"] = "AccountLogin"
GlueScreenInfo["charselect"] = "CharacterSelect"
GlueScreenInfo["charcreate"] = "CharacterCreate"
GlueScreenInfo["options"] = "OptionsFrame"

-- =============================================================================
-- CHARACTER MODEL FOG SETTINGS
-- =============================================================================

CharModelFogInfo = {}
CharModelFogInfo["HUMAN"] = { r=0.8, g=0.65, b=0.73, far=222 }
CharModelFogInfo["ORC"] = { r=0.5, g=0.5, b=0.5, far=270 }
CharModelFogInfo["DWARF"] = { r=0.85, g=0.88, b=1.0, far=500 }
CharModelFogInfo["NIGHTELF"] = { r=0.25, g=0.22, b=0.55, far=611 }
CharModelFogInfo["TAUREN"] = { r=1.0, g=0.61, b=0.42, far=153 }
CharModelFogInfo["SCOURGE"] = { r=0, g=0.22, b=0.22, far=26 }
CharModelFogInfo["DRAENEI"] = { r=0.85, g=0.88, b=1.0, far=500 }
CharModelFogInfo["BLOODELF"] = { r=0.8, g=0.65, b=0.73, far=222 }
CharModelFogInfo["DEATHKNIGHT"] = { r=0, g=0.22, b=0.22, far=26 }
CharModelFogInfo["CHARACTERSELECT"] = { r=0.8, g=0.65, b=0.73, far=222 }

-- =============================================================================
-- CHARACTER MODEL GLOW SETTINGS
-- =============================================================================

CharModelGlowInfo = {}
CharModelGlowInfo["HUMAN"] = 0.15
CharModelGlowInfo["DWARF"] = 0.15
CharModelGlowInfo["CHARACTERSELECT"] = 0.3

-- =============================================================================
-- AMBIENCE TRACKS
-- =============================================================================

GlueAmbienceTracks = {}
GlueAmbienceTracks["HUMAN"] = "GlueScreenHuman"
GlueAmbienceTracks["ORC"] = "GlueScreenOrcTroll"
GlueAmbienceTracks["DWARF"] = "GlueScreenDwarfGnome"
GlueAmbienceTracks["TAUREN"] = "GlueScreenTauren"
GlueAmbienceTracks["SCOURGE"] = "GlueScreenUndead"
GlueAmbienceTracks["NIGHTELF"] = "GlueScreenNightElf"
GlueAmbienceTracks["DRAENEI"] = "GlueScreenDraenei"
GlueAmbienceTracks["BLOODELF"] = "GlueScreenBloodElf"
GlueAmbienceTracks["DARKPORTAL"] = "GlueScreenIntro"
GlueAmbienceTracks["DEATHKNIGHT"] = "GlueScreenIntro"
GlueAmbienceTracks["CHARACTERSELECT"] = "GlueScreenIntro"

-- =============================================================================
-- RACE LIGHTING CONFIGURATION
-- =============================================================================
-- RaceLights[] duplicates the 3.2.2 color values in the models
-- Models no longer contain directional lights - managed here

RaceLights = {
	HUMAN = {
		{1, 0, 0.000000, 0.000000, -1.000000, 1.0, 0.27, 0.27, 0.27, 1.0, 0, 0, 0},
		{1, 0, -0.45756075, -0.58900136, -0.66611975, 1.0, 0.000000, 0.000000, 0.000000, 1.0, 0.19882353, 0.34921569, 0.43588236},
		{1, 0, -0.64623469, 0.57582057, -0.50081086, 1.0, 0.000000, 0.000000, 0.000000, 2.0, 0.52196085, 0.44, 0.29764709},
	},
	ORC = {
		{1, 0, 0.00000, 0.00000, -1.00000, 1.0, 0.15000, 0.15000, 0.15000, 1.0, 0.00000, 0.00000, 0.00000},
		{1, 0, -0.74919, 0.35208, -0.56103, 1.0, 0.00000, 0.00000, 0.00000, 1.0, 0.44706, 0.54510, 0.73725},
		{1, 0, 0.53162, -0.84340, 0.07780, 1.0, 0.00000, 0.00000, 0.00000, 2.0, 0.55, 0.338625, 0.148825},
	},
	DWARF = {
		{1, 0, -0.00000, -0.00000, -1.00000, 1.0, 0.30000, 0.30000, 0.30000, 0.0, 0.00000, 0.00000, 0.00000},
		{1, 0, -0.88314, 0.42916, -0.18945, 1.0, 0.00000, 0.00000, 0.00000, 2.0, 0.44706, 0.67451, 0.760785},
	},
	TAUREN = {
		{1, 0, -0.48073, 0.71827, -0.50297, 1.0, 0.00000, 0.00000, 0.00000, 2.0, 0.65, 0.397645, 0.2727},
		{1, 0, -0.49767, -0.78677, 0.36513, 1.0, 0.00000, 0.00000, 0.00000, 1.0, 0.60000, 0.47059, 0.32471},
	},
	SCOURGE = {
		{1, 0, 0.00000, 0.00000, -1.00000, 1.0, 0.20000, 0.20000, 0.20000, 1.0, 0.00000, 0.00000, 0.00000},
	},
	NIGHTELF = {
		{1, 0, -0.00000, -0.00000, -1.00000, 1.0, 0.09020, 0.09020, 0.17020, 1.0, 0.00000, 0.00000, 0.00000},
	},
	DRAENEI = {
		{1, 0, 0.61185, 0.62942, -0.47903, 1.0, 0.00000, 0.00000, 0.00000, 1.0, 0.56941, 0.52000, 0.60000},
		{1, 0, -0.64345, -0.31052, -0.69968, 1.0, 0.00000, 0.00000, 0.00000, 1.0, 0.60941, 0.60392, 0.70000},
		{1, 0, -0.46481, -0.14320, 0.87376, 1.0, 0.00000, 0.00000, 0.00000, 2.0, 0.5835, 0.48941, 0.60000},
	},
	BLOODELF = {
		{1, 0, -0.82249, -0.54912, -0.14822, 1.0, 0.00000, 0.00000, 0.00000, 2.0, 0.581175, 0.50588, 0.42588},
		{1, 0, 0.00000, -0.00000, -1.00000, 1.0, 0.60392, 0.61490, 0.70000, 1.0, 0.00000, 0.00000, 0.00000},
		{1, 0, 0.02575, 0.86518, -0.50081, 1.0, 0.00000, 0.00000, 0.00000, 1.0, 0.59137, 0.51745, 0.63471},
	},
	DEATHKNIGHT = {
		{1, 0, 0.00000, 0.00000, -1.00000, 1.0, 0.38824, 0.66353, 0.76941, 1.0, 0.00000, 0.00000, 0.00000},
	},
	CHARACTERSELECT = {
		{1, 0, 0.00000, 0.00000, -1.00000, 1.0, 0.15000, 0.15000, 0.15000, 1.0, 0.00000, 0.00000, 0.00000},
		{1, 0, -0.74919, 0.35208, -0.56103, 1.0, 0.00000, 0.00000, 0.00000, 1.0, 0.44706, 0.54510, 0.73725},
		{1, 0, 0.53162, -0.84340, 0.07780, 1.0, 0.00000, 0.00000, 0.00000, 2.0, 0.55, 0.338625, 0.148825},
	},
}

-- Light indices for ModelFFX:Add*Light
LIGHT_LIVE = 0
LIGHT_GHOST = 1

-- =============================================================================
-- FADE ANIMATION SYSTEM
-- =============================================================================

FADEFRAMES = {}
CURRENT_GLUE_SCREEN = nil
PENDING_GLUE_SCREEN = nil

-- Fade durations (in seconds)
LOGIN_FADE_IN = 1.5
LOGIN_FADE_OUT = 0.5
CHARACTER_SELECT_FADE_IN = 0.75

-- =============================================================================
-- GENDER CONSTANTS
-- =============================================================================

SEX_NONE = 1
SEX_MALE = 2
SEX_FEMALE = 3

-- =============================================================================
-- SCREEN MANAGEMENT
-- =============================================================================

--- Switches to the specified glue screen
function SetGlueScreen(name)
	local newFrame
	
	-- Hide all screens, find the target screen
	for index, value in pairs(GlueScreenInfo) do
		local frame = _G[value]
		if frame then
			frame:Hide()
			if index == name then
				newFrame = frame
			end
		end
	end
	
	-- Show target screen if found
	if newFrame then
		newFrame:Show()
		SetCurrentScreen(name)
		SetCurrentGlueScreenName(name)
	end
end

function SetCurrentGlueScreenName(name)
	CURRENT_GLUE_SCREEN = name
end

function GetCurrentGlueScreenName()
	return CURRENT_GLUE_SCREEN
end

function SetPendingGlueScreenName(name)
	PENDING_GLUE_SCREEN = name
end

function GetPendingGlueScreenName()
	return PENDING_GLUE_SCREEN
end

-- =============================================================================
-- GLUE PARENT HANDLERS
-- =============================================================================

function GlueParent_OnLoad(self)
	local width = GetScreenWidth()
	local height = GetScreenHeight()
	
	-- Handle widescreen aspect ratios
	if width / height > 16 / 9 then
		local maxWidth = height * 16 / 9
		local barWidth = (width - maxWidth) / 2
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", barWidth, 0)
		self:SetPoint("BOTTOMRIGHT", -barWidth, 0)
	end
	
	-- Register events
	self:RegisterEvent("FRAMES_LOADED")
	self:RegisterEvent("SET_GLUE_SCREEN")
	self:RegisterEvent("DISCONNECTED_FROM_SERVER")
end

function GlueParent_OnEvent(event, arg1, arg2, arg3)
	if event == "FRAMES_LOADED" then
		LocalizeFrames()
	elseif event == "SET_GLUE_SCREEN" then
		GlueScreenExit(GetCurrentGlueScreenName(), arg1)
	elseif event == "DISCONNECTED_FROM_SERVER" then
		SetGlueScreen("login")
		GlueDialog_Show("DISCONNECTED")
		AddonList:Hide()
	end
end

-- =============================================================================
-- SCREEN TRANSITIONS
-- =============================================================================

function GlueScreenExit(currentFrame, pendingFrame)
	if currentFrame == "login" and pendingFrame == "charselect" then
		GlueFrameFadeOut(AccountLoginUI, LOGIN_FADE_OUT, GoToPendingGlueScreen)
		SetPendingGlueScreenName(pendingFrame)
	else
		SetGlueScreen(pendingFrame)
	end
end

function GoToPendingGlueScreen()
	SetGlueScreen(GetPendingGlueScreenName())
end

-- =============================================================================
-- FADE ANIMATION FUNCTIONS
-- =============================================================================

function GlueFrameFade(frame, timeToFade, mode, finishedFunction)
	if frame then
		frame.fadeTimer = 0
		frame.timeToFade = timeToFade
		frame.mode = mode
		if finishedFunction then
			frame.finishedFunction = finishedFunction
		end
		tinsert(FADEFRAMES, frame)
	end
end

function GlueFrameFadeIn(frame, timeToFade, finishedFunction)
	GlueFrameFade(frame, timeToFade, "IN", finishedFunction)
end

function GlueFrameFadeOut(frame, timeToFade, finishedFunction)
	GlueFrameFade(frame, timeToFade, "OUT", finishedFunction)
end

function GlueFrameFadeUpdate(elapsed)
	local index = 1
	while FADEFRAMES[index] do
		local frame = FADEFRAMES[index]
		frame.fadeTimer = frame.fadeTimer + elapsed
		
		if frame.fadeTimer < frame.timeToFade then
			if frame.mode == "IN" then
				frame:SetAlpha(frame.fadeTimer / frame.timeToFade)
			elseif frame.mode == "OUT" then
				frame:SetAlpha((frame.timeToFade - frame.fadeTimer) / frame.timeToFade)
			end
		else
			if frame.mode == "IN" then
				frame:SetAlpha(1.0)
			elseif frame.mode == "OUT" then
				frame:SetAlpha(0)
			end
			GlueFrameFadeRemoveFrame(frame)
			if frame.finishedFunction then
				frame.finishedFunction()
				frame.finishedFunction = nil
			end
		end
		index = index + 1
	end
end

function GlueFrameRemoveFrame(frame, list)
	local index = 1
	while list[index] do
		if frame == list[index] then
			tremove(list, index)
		end
		index = index + 1
	end
end

function GlueFrameFadeRemoveFrame(frame)
	GlueFrameRemoveFrame(frame, FADEFRAMES)
end

-- =============================================================================
-- CHARACTER MODEL LIGHTING
-- =============================================================================

function SetLighting(model, race)
	model:SetSequence(0)
	model:SetCamera(0)
	
	-- Apply fog settings
	local fogInfo = CharModelFogInfo[race]
	if fogInfo then
		model:SetFogColor(fogInfo.r, fogInfo.g, fogInfo.b)
		model:SetFogNear(0)
		model:SetFogFar(fogInfo.far)
	else
		model:ClearFog()
	end
	
	-- Apply glow settings
	local glowInfo = CharModelGlowInfo[race]
	if glowInfo then
		model:SetGlow(glowInfo)
	else
		model:SetGlow(0.3)
	end
	
	-- Reset and apply directional lights
	model:ResetLights()
	
	--[[
	ResetLights() sets all 6 light sets to default for the background:
		background - live / ghost
		character - live / ghost
		pet - live / ghost
	
	Adding a light to any set disables ALL defaults for that set.
	Up to 4 lights per set can be added and are merged in the engine.
	Only directional lights are supported (point lights come from models).
	]]
	
	local lightValues = RaceLights[race]
	if lightValues then
		for index, array in pairs(lightValues) do
			if array[1] == 1 then -- Is this light enabled?
				for j, f in pairs({model.AddCharacterLight, model.AddLight, model.AddPetLight}) do
					f(model, LIGHT_LIVE, unpack(array))
				end
			end
		end
	end
end

-- =============================================================================
-- BACKGROUND MODEL MANAGEMENT
-- =============================================================================

function SetBackgroundModel(model, name)
	local nameUpper = strupper(name)
	local path = "Interface\\Glues\\Models\\UI_" .. name .. "\\UI_" .. name .. ".m2"
	
	if model == CharacterCreate then
		SetCharCustomizeBackground(path)
	else
		SetCharSelectBackground(path)
	end
	
	PlayGlueAmbience(GlueAmbienceTracks[nameUpper], 4.0)
	SetLighting(model, nameUpper)
end

-- =============================================================================
-- TIME FORMATTING UTILITIES
-- =============================================================================

function SecondsToTime(seconds, noSeconds)
	local time = ""
	local count = 0
	local tempTime
	seconds = floor(seconds)
	
	if seconds >= 86400 then
		tempTime = floor(seconds / 86400)
		time = tempTime .. " " .. DAYS_ABBR .. " "
		seconds = mod(seconds, 86400)
		count = count + 1
	end
	if seconds >= 3600 then
		tempTime = floor(seconds / 3600)
		time = time .. tempTime .. " " .. HOURS_ABBR .. " "
		seconds = mod(seconds, 3600)
		count = count + 1
	end
	if count < 2 and seconds >= 60 then
		tempTime = floor(seconds / 60)
		time = time .. tempTime .. " " .. MINUTES_ABBR .. " "
		seconds = mod(seconds, 60)
		count = count + 1
	end
	if count < 2 and seconds > 0 and not noSeconds then
		seconds = format("%d", seconds)
		time = time .. seconds .. " " .. SECONDS_ABBR .. " "
	end
	return time
end

function MinutesToTime(mins, hideDays)
	local time = ""
	local count = 0
	local tempTime
	
	if mins > 1440 and not hideDays then
		tempTime = floor(mins / 1440)
		time = tempTime .. " " .. DAYS_ABBR .. " "
		mins = mod(mins, 1440)
		count = count + 1
	end
	if mins > 60 then
		tempTime = floor(mins / 60)
		time = time .. tempTime .. " " .. HOURS_ABBR .. " "
		mins = mod(mins, 60)
		count = count + 1
	end
	if count < 2 then
		tempTime = mins
		time = time .. tempTime .. " " .. MINUTES_ABBR .. " "
		count = count + 1
	end
	return time
end

-- =============================================================================
-- UI UTILITIES
-- =============================================================================

function TriStateCheckbox_SetState(checked, checkButton)
	local checkedTexture = _G[checkButton:GetName() .. "CheckedTexture"]
	if not checkedTexture then
		return
	end
	
	if not checked or checked == 0 then
		checkButton:SetChecked(nil)
		checkButton.state = 0
	elseif checked == 2 then
		checkButton:SetChecked(1)
		checkedTexture:SetVertexColor(1, 1, 1)
		checkedTexture:SetDesaturated(0)
		checkButton.state = 2
	else
		checkButton:SetChecked(1)
		local shaderSupported = checkedTexture:SetDesaturated(1)
		if not shaderSupported then
			checkedTexture:SetVertexColor(0.5, 0.5, 0.5)
		end
		checkButton.state = 1
	end
end
