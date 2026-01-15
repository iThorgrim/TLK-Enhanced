--------------------------------------------------------------------------------
-- GlueDialog.lua
-- Dialog system for WoW Glue screens (login, character selection, options)
-- Cleaned for private server use - removed Blizzard retail features
--------------------------------------------------------------------------------

-- =============================================================================
-- CONSTANTS
-- =============================================================================

--- Maximum number of buttons allowed per dialog
MAX_NUM_GLUE_DIALOG_BUTTONS = 3

-- =============================================================================
-- DIALOG TYPE DEFINITIONS
-- =============================================================================

--- Table containing all dialog configurations
-- Each dialog has: text, buttons, callbacks, and display options
GlueDialogTypes = {}

---
--- System & Settings Dialogs
---

--- Critical error: System doesn't support SSE instructions
GlueDialogTypes["SYSTEM_INCOMPATIBLE_SSE"] = {
	text = SYSTEM_INCOMPATIBLE_SSE,
	button1 = OKAY,
	html = 1,
	showAlert = 1,
	escapeHides = true,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
}

--- Confirmation dialog for resetting video settings
GlueDialogTypes["CONFIRM_RESET_VIDEO_SETTINGS"] = {
	text = CONFIRM_RESET_SETTINGS,
	button1 = ALL_SETTINGS,
	button2 = CURRENT_SETTINGS,
	button3 = CANCEL,
	showAlert = 1,
	OnAccept = function()
		VideoOptionsFrame_SetAllToDefaults()
	end,
	OnCancel = function()
		VideoOptionsFrame_SetCurrentToDefaults()
	end,
	OnAlt = function()
	end,
	escapeHides = true,
}

--- Confirmation dialog for resetting audio settings
GlueDialogTypes["CONFIRM_RESET_AUDIO_SETTINGS"] = {
	text = CONFIRM_RESET_SETTINGS,
	button1 = ALL_SETTINGS,
	button2 = CURRENT_SETTINGS,
	button3 = CANCEL,
	showAlert = 1,
	OnAccept = function()
		AudioOptionsFrame_SetAllToDefaults()
	end,
	OnCancel = function()
		AudioOptionsFrame_SetCurrentToDefaults()
	end,
	OnAlt = function()
	end,
	escapeHides = true,
}

--- Client restart required notification
GlueDialogTypes["CLIENT_RESTART_ALERT"] = {
	text = CLIENT_RESTART_ALERT,
	button1 = OKAY,
	showAlert = 1,
}

---
--- Connection & Login Dialogs
---

--- Disconnected from server notification
GlueDialogTypes["DISCONNECTED"] = {
	text = DISCONNECTED,
	button1 = OKAY,
	OnShow = function()
		if RealmList then RealmList:Hide() end
		StatusDialogClick()
	end,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
}

--- Client account expansion mismatch (BC vs WotLK)
GlueDialogTypes["CLIENT_ACCOUNT_MISMATCH"] = {
	button1 = RETURN_TO_LOGIN,
	button2 = EXIT_GAME,
	html = 1,
	OnAccept = function()
		SetGlueScreen("login")
	end,
	OnCancel = function()
		PlaySound("gsTitleQuit")
		QuitGame()
	end,
}

--- Trial account notification
GlueDialogTypes["CLIENT_TRIAL"] = {
	text = CLIENT_TRIAL,
	button1 = RETURN_TO_LOGIN,
	button2 = EXIT_GAME,
	html = 1,
	OnAccept = function()
		SetGlueScreen("login")
	end,
	OnCancel = function()
		PlaySound("gsTitleQuit")
		QuitGame()
	end,
}

---
--- Generic Status Dialogs
---

--- Generic cancel dialog (used during connection)
GlueDialogTypes["CANCEL"] = {
	text = "",
	button1 = CANCEL,
	OnAccept = function()
		StatusDialogClick()
	end,
	OnCancel = function()
	end,
}

--- Generic OK dialog
GlueDialogTypes["OKAY"] = {
	text = "",
	button1 = OKAY,
	OnShow = function()
	end,
	OnAccept = function()
		StatusDialogClick()
	end,
	OnCancel = function()
	end,
}

--- Generic OK dialog with HTML support
GlueDialogTypes["OKAY_HTML"] = {
	text = "",
	button1 = OKAY,
	html = 1,
	OnShow = function()
	end,
	OnAccept = function()
		StatusDialogClick()
	end,
	OnCancel = function()
	end,
}

--- OK dialog with Exit option (HTML support)
GlueDialogTypes["OKAY_HTML_EXIT"] = {
	text = "",
	button1 = OKAY,
	button2 = EXIT_GAME,
	html = 1,
	OnShow = function()
	end,
	OnAccept = function()
		StatusDialogClick()
	end,
	OnCancel = function()
		AccountLogin_Exit()
	end,
}

---
--- Character Creation Dialogs
---

--- Invalid character name notification
GlueDialogTypes["INVALID_NAME"] = {
	text = CHAR_CREATE_INVALID_NAME,
	button1 = OKAY,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
}

-- =============================================================================
-- DIALOG DISPLAY FUNCTIONS
-- =============================================================================

--- Shows a dialog with specified type and optional text/data
-- @param which string - Dialog type key from GlueDialogTypes table
-- @param text string|nil - Optional custom text (overrides dialog default)
-- @param data any|nil - Optional data passed to dialog callbacks
-- @return void
function GlueDialog_Show(which, text, data)
	local dialogInfo = GlueDialogTypes[which]
	if not dialogInfo then
		return
	end

	-- Hide previous dialog if showing different type
	if GlueDialog:IsShown() then
		if GlueDialog.which ~= which then
			if GlueDialogTypes[GlueDialog.which] and GlueDialogTypes[GlueDialog.which].OnHide then
				GlueDialogTypes[GlueDialog.which].OnHide()
			end
			GlueDialog:Hide()
		end
	end

	-- Store dialog data
	GlueDialog.which = which
	GlueDialog.data = data

	-- Select text display (HTML or plain)
	local glueText
	if dialogInfo.html then
		glueText = GlueDialogHTML
		GlueDialogHTML:Show()
		GlueDialogText:Hide()
	else
		glueText = GlueDialogText
		GlueDialogHTML:Hide()
		GlueDialogText:Show()
	end

	-- Set dialog text
	if text then
		glueText:SetText(text)
	else
		glueText:SetText(dialogInfo.text or "")
	end

	-- Configure buttons
	if dialogInfo.button3 then
		-- 3 buttons
		GlueDialogButton1:ClearAllPoints()
		GlueDialogButton2:ClearAllPoints()
		GlueDialogButton3:ClearAllPoints()

		if dialogInfo.displayVertical then
			GlueDialogButton3:SetPoint("BOTTOM", "GlueDialogBackground", "BOTTOM", 0, 16)
			GlueDialogButton2:SetPoint("BOTTOM", "GlueDialogButton3", "TOP", 0, 0)
			GlueDialogButton1:SetPoint("BOTTOM", "GlueDialogButton2", "TOP", 0, 0)
		else
			GlueDialogButton1:SetPoint("BOTTOMLEFT", "GlueDialogBackground", "BOTTOMLEFT", 60, 16)
			GlueDialogButton2:SetPoint("LEFT", "GlueDialogButton1", "RIGHT", -8, 0)
			GlueDialogButton3:SetPoint("LEFT", "GlueDialogButton2", "RIGHT", -8, 0)
		end

		GlueDialogButton2:SetText(dialogInfo.button2)
		GlueDialogButton2:Show()
		GlueDialogButton3:SetText(dialogInfo.button3)
		GlueDialogButton3:Show()
	elseif dialogInfo.button2 then
		-- 2 buttons
		GlueDialogButton1:ClearAllPoints()
		GlueDialogButton2:ClearAllPoints()

		if dialogInfo.displayVertical then
			GlueDialogButton2:SetPoint("BOTTOM", "GlueDialogBackground", "BOTTOM", 0, 16)
			GlueDialogButton1:SetPoint("BOTTOM", "GlueDialogButton2", "TOP", 0, 0)
		else
			GlueDialogButton1:SetPoint("BOTTOMRIGHT", "GlueDialogBackground", "BOTTOM", -6, 16)
			GlueDialogButton2:SetPoint("LEFT", "GlueDialogButton1", "RIGHT", 13, 0)
		end

		GlueDialogButton2:SetText(dialogInfo.button2)
		GlueDialogButton2:Show()
		GlueDialogButton3:Hide()
	else
		-- 1 button
		GlueDialogButton1:ClearAllPoints()
		GlueDialogButton1:SetPoint("BOTTOM", "GlueDialogBackground", "BOTTOM", 0, 16)
		GlueDialogButton2:Hide()
		GlueDialogButton3:Hide()
	end

	GlueDialogButton1:SetText(dialogInfo.button1)

	-- Show/hide alert icon
	if dialogInfo.showAlert then
		GlueDialogBackground:SetWidth(GlueDialogBackground.alertWidth)
		GlueDialogAlertIcon:Show()
	else
		GlueDialogBackground:SetWidth(GlueDialogBackground.origWidth)
		GlueDialogAlertIcon:Hide()
	end
	GlueDialogText:SetWidth(GlueDialogText.origWidth)

	-- EditBox setup (if needed)
	if dialogInfo.hasEditBox then
		GlueDialogEditBox:Show()
		if dialogInfo.maxLetters then
			GlueDialogEditBox:SetMaxLetters(dialogInfo.maxLetters)
		end
		if dialogInfo.maxBytes then
			GlueDialogEditBox:SetMaxBytes(dialogInfo.maxBytes)
		end
	else
		GlueDialogEditBox:Hide()
	end

	-- Size width first
	if dialogInfo.displayVertical then
		GlueDialogBackground:SetWidth(16 + GlueDialogButton1:GetWidth() + 16)
	elseif dialogInfo.button3 then
		local displayWidth = 45 + GlueDialogButton1:GetWidth() + 8 + GlueDialogButton2:GetWidth() + 8 + GlueDialogButton3:GetWidth() + 45
		GlueDialogBackground:SetWidth(displayWidth)
		GlueDialogText:SetWidth(displayWidth - 40)
	end

	-- Get text height
	local textHeight
	if dialogInfo.html then
		local _, _, _, height = GlueDialogHTML:GetBoundsRect()
		textHeight = height
	else
		textHeight = GlueDialogText:GetHeight()
	end

	-- Size dialog height
	if dialogInfo.hasEditBox then
		GlueDialogBackground:SetHeight(16 + textHeight + 8 + GlueDialogEditBox:GetHeight() + 8 + GlueDialogButton1:GetHeight() + 16)
	elseif dialogInfo.displayVertical then
		local displayHeight = 16 + textHeight + 8 + GlueDialogButton1:GetHeight() + 16
		if dialogInfo.button2 then
			displayHeight = displayHeight + 8 + GlueDialogButton2:GetHeight()
		end
		if dialogInfo.button3 then
			displayHeight = displayHeight + 8 + GlueDialogButton3:GetHeight()
		end
		GlueDialogBackground:SetHeight(displayHeight)
	else
		GlueDialogBackground:SetHeight(16 + textHeight + 8 + GlueDialogButton1:GetHeight() + 16)
	end

	GlueDialog:Show()
end

--- Hides the active dialog
-- @return void
function GlueDialog_Hide()
	GlueDialog:Hide()
end

-- =============================================================================
-- FRAME EVENT HANDLERS
-- =============================================================================

--- Initializes the GlueDialog frame
-- @param self Frame - The GlueDialog frame
-- @return void
function GlueDialog_OnLoad(self)
	self:RegisterEvent("OPEN_STATUS_DIALOG")
	self:RegisterEvent("UPDATE_STATUS_DIALOG")
	self:RegisterEvent("CLOSE_STATUS_DIALOG")
	GlueDialogText.origWidth = GlueDialogText:GetWidth()
	GlueDialogBackground.origWidth = GlueDialogBackground:GetWidth()
	GlueDialogBackground.alertWidth = 600
end

--- Called when dialog is shown
-- @param self Frame - The GlueDialog frame
-- @return void
function GlueDialog_OnShow(self)
	local OnShow = GlueDialogTypes[self.which] and GlueDialogTypes[self.which].OnShow
	if OnShow then
		OnShow()
	end
end

--- Updates button textures based on current screen
-- @param self Frame - The GlueDialog frame
-- @param elapsed number - Time since last update
-- @return void
function GlueDialog_OnUpdate(self, elapsed)
	for i = 1, MAX_NUM_GLUE_DIALOG_BUTTONS do
		local button = _G["GlueDialogButton" .. i]
		if button and (CURRENT_GLUE_SCREEN == "login" or CURRENT_GLUE_SCREEN == "realmwizard" or CURRENT_GLUE_SCREEN == "movie") then
			button:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up-Blue")
			button:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down-Blue")
			button:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight-Blue")
		else
			button:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up")
			button:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down")
			button:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight")
		end
	end
end

--- Handles server events for dialogs
-- @param self Frame - The GlueDialog frame
-- @param event string - Event name
-- @param arg1 any - First argument
-- @param arg2 any - Second argument
-- @param arg3 any - Third argument
-- @return void
function GlueDialog_OnEvent(self, event, arg1, arg2, arg3)
	if event == "OPEN_STATUS_DIALOG" then
		GlueDialog_Show(arg1, arg2, arg3)
	elseif event == "UPDATE_STATUS_DIALOG" and arg1 and strlen(arg1) > 0 then
		GlueDialogText:SetText(arg1)
		local buttonText = nil
		if arg2 then
			buttonText = arg2
		elseif GlueDialogTypes[GlueDialog.which] then
			buttonText = GlueDialogTypes[GlueDialog.which].button1
		end
		if buttonText then
			GlueDialogButton1:SetText(buttonText)
		end
		GlueDialogBackground:SetHeight(32 + GlueDialogText:GetHeight() + 8 + GlueDialogButton1:GetHeight() + 16)
	elseif event == "CLOSE_STATUS_DIALOG" then
		GlueDialog:Hide()
	end
end

--- Called when dialog is hidden
-- @return void
function GlueDialog_OnHide()
	-- Intentionally empty (sound commented out)
end

--- Handles button clicks
-- @param index number - Button index (1, 2, or 3)
-- @return void
function GlueDialog_OnClick(index)
	GlueDialog:Hide()
	if index == 1 then
		local OnAccept = GlueDialogTypes[GlueDialog.which] and GlueDialogTypes[GlueDialog.which].OnAccept
		if OnAccept then
			OnAccept()
		end
	elseif index == 2 then
		local OnCancel = GlueDialogTypes[GlueDialog.which] and GlueDialogTypes[GlueDialog.which].OnCancel
		if OnCancel then
			OnCancel()
		end
	elseif index == 3 then
		local OnAlt = GlueDialogTypes[GlueDialog.which] and GlueDialogTypes[GlueDialog.which].OnAlt
		if OnAlt then
			OnAlt()
		end
	end
	PlaySound("gsTitleOptionOK")
end

--- Handles keyboard input on dialogs
-- @param key string - Key pressed
-- @return void
function GlueDialog_OnKeyDown(key)
	if key == "PRINTSCREEN" then
		Screenshot()
		return
	end

	local info = GlueDialogTypes[GlueDialog.which]
	if not info or info.ignoreKeys then
		return
	end

	if info and info.escapeHides then
		if info.hideSound then
			PlaySound(info.hideSound)
		end
		GlueDialog:Hide()
	elseif key == "ESCAPE" then
		if GlueDialogButton2:IsShown() then
			GlueDialogButton2:Click()
		else
			GlueDialogButton1:Click()
		end
		if info.hideSound then
			PlaySound(info.hideSound)
		end
	elseif key == "ENTER" then
		GlueDialogButton1:Click()
		if info.hideSound then
			PlaySound(info.hideSound)
		end
	end
end

-- =============================================================================
-- UTILITY FUNCTIONS
-- =============================================================================

--- Closes status dialog (used during login/connection)
-- Does NOT cancel login - just closes the dialog to allow connection to proceed
-- @return void
function StatusDialogClick()
	GlueDialog:Hide()
end
