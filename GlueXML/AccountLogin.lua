--------------------------------------------------------------------------------
-- AccountLogin.lua
--------------------------------------------------------------------------------

-- =============================================================================
-- INITIALIZATION & CONFIGURATION
-- =============================================================================
DEFAULT_TOOLTIP_COLOR = {0.8, 0.8, 0.8, 0.09, 0.09, 0.09};

--- Automatically accepts all legal agreements (EULA, TOS, Termination Notice)
-- @return void
local function AcceptLegalAgreements()
	if not EULAAccepted() then
		AcceptEULA();
	end
	if not TOSAccepted() then
		AcceptTOS();
	end
	if not TerminationWithoutNoticeAccepted() then
		AcceptTerminationWithoutNotice();
	end
end

--- Initializes the login screen background with BLP sequence animation
-- Creates a fullscreen texture and starts the BLP sequence player
-- @return void
local function InitializeBackgroundAnimation()
	local texture = AccountLoginBackground;
	if not texture then return; end

	local parent = AccountLogin;
	texture:ClearAllPoints();
	texture:SetPoint("CENTER", parent, "CENTER", 0, 0);
	texture:SetWidth(parent:GetWidth());
	texture:SetHeight(parent:GetHeight());

	-- Create BLP sequence: 150 files, 300 frames (2 per file in horizontal atlas), 30 FPS, looping
	BLPSequence:Create("LoginScreen", "Interface\\AccountLoginUI\\ui\\frame_", 300, 30, true, {
		filesPerFrame = 2,
		layout = "horizontal"
	});
	BLPSequence:Play("LoginScreen", texture);
end

--- Main initialization handler called when the login frame loads
-- @param self Frame - The AccountLogin frame
-- @return void
function AccountLogin_OnLoad(self)
	self:RegisterEvent("SHOW_SERVER_ALERT");

	AcceptLegalAgreements();
	InitializeBackgroundAnimation();

	SetAtlas(self.TopBackgroundOverlay, "charactercreate-vignette-top", true);
	SetAtlas(self.BottomBackgroundOverlay, "charactercreate-vignette-bottom", true);
	SetAtlas(self.LeftBackgroundOverlay, "charactercreate-vignette-sides", true);

	StopGlueMusic();
	StopGlueAmbience();
end

-- =============================================================================
-- FRAME EVENT HANDLERS
-- =============================================================================

--- Handler called when the login screen becomes visible
-- Restarts audio, animation, and populates saved credentials
-- @param self Frame - The AccountLogin frame
-- @return void
function AccountLogin_OnShow(self)
	-- Stop all audio sources
	StopMusic();
	StopGlueMusic();
	StopGlueAmbience();

	-- Play custom login music only
	PlayMusic("Interface\\AccountLoginUI\\music\\loginscreen_background_music.mp3");

	-- Restart BLP animation from beginning
	BLPSequence:Stop("LoginScreen");
	BLPSequence:SetFrame("LoginScreen", 1);
	BLPSequence:Resume("LoginScreen");

	-- Load saved account and focus appropriate field
	local accountName = GetSavedAccountName();
	AccountLogin.UI.AccountEditBox:SetText(accountName);
	AccountLogin.UI.PasswordEditBox:SetText("");

	if accountName == "" then
		AccountLogin_FocusAccount();
	else
		AccountLogin_FocusPassword();
	end
end

--- Handler called when the login screen is hidden
-- Stops audio and clears saved account if checkbox is unchecked
-- @param self Frame - The AccountLogin frame
-- @return void
function AccountLogin_OnHide(self)
	BLPSequence:Stop("LoginScreen");
	StopAllSFX(1.0);

	if not AccountLoginSaveAccountName:GetChecked() then
		SetSavedAccountList("");
	end
end

--- Handles keyboard input on the login screen
-- @param key string - The key that was pressed
-- @return void
function AccountLogin_OnKeyDown(self, key)
	if key == "ESCAPE" then
		AccountLogin_Exit();
	elseif key == "ENTER" then
		AccountLogin_Login();
	elseif key == "PRINTSCREEN" then
		Screenshot();
	end
end

--- Handles game events for the login screen
-- @param event string - Event name
-- @param ... mixed - Event arguments
-- @return void
function AccountLogin_OnEvent(event, ...)
	if event == "SHOW_SERVER_ALERT" then
		local message = select(1, ...);
		ServerAlertText:SetText(message);
		ServerAlertFrame:Show();
	end
end

-- =============================================================================
-- USER ACTIONS
-- =============================================================================

--- Sets focus to the password edit box
-- @return void
function AccountLogin_FocusPassword()
	AccountLogin.UI.PasswordEditBox:SetFocus();
end

--- Sets focus to the account edit box
-- @return void
function AccountLogin_FocusAccount()
	AccountLogin.UI.AccountEditBox:SetFocus();
end

--- Handler called when an edit box gains focus
-- Highlights all text in the edit box for easy replacement
-- @param self EditBox - The edit box that gained focus
-- @return void
function AccountLogin_OnEditFocusGained(self)
	self:HighlightText();
end

--- Handler called when an edit box loses focus
-- Removes text highlighting
-- @param self EditBox - The edit box that lost focus
-- @return void
function AccountLogin_OnEditFocusLost(self)
	self:HighlightText(0, 0);
end

--- Handler called when Escape key is pressed in an edit box
-- Clears focus from the edit box
-- @param self EditBox - The edit box where Escape was pressed
-- @return boolean - Always returns true to indicate the event was handled
function AccountLogin_OnEscapePressed(self)
	self:ClearFocus();
	return true;
end

--- Handler called when text changes in the account edit box
-- Clears saved account name if the text differs from saved data
-- Shows or hides the placeholder text based on whether the field is empty
-- @param self EditBox - The edit box whose text changed
-- @return void
function AccountLogin_OnTextChanged(self)
	local account_name = GetSavedAccountName();
	if (account_name ~= "" and account_name ~= self:GetText()) then
		SetSavedAccountName("");
		AccountLogin_UpdateSavedData(AccountLogin);
	end

	if(self:GetText() ~= "") then
		self.Fill:Hide();
	else
		self.Fill:Show();
	end
end

--- Attempts to log in with the provided credentials
-- Saves account name if the save checkbox is checked
-- @return void
function AccountLogin_OnEnterPressed()
	PlaySound("gsLogin");

	local accountName = AccountLogin.UI.AccountEditBox:GetText();
	local password = AccountLogin.UI.PasswordEditBox:GetText();

	DefaultServerLogin(accountName, password);
	AccountLogin.UI.PasswordEditBox:SetText("");
end

--- Updates the login form with saved account data
-- Populates the account edit box if a saved account exists, otherwise focuses the account field
-- @param self Frame - The AccountLogin frame
-- @return void
function AccountLogin_UpdateSavedData(self)
	local account_name = GetSavedAccountName();
	if (account_name == "") then
		AccountLogin_FocusAccount();
	else
		self.UI.AccountEditBox:SetText(account_name);
		AccountLogin_FocusPassword();
	end
end

--- Exits the game completely
-- @return void
function AccountLogin_Exit()
	QuitGame();
end