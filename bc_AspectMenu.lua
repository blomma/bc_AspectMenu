--[[

See the ReadMe.html file for more information.

--]]

-- Number of buttons for the menu defined in the XML file.
BCAM_NUM_BUTTONS = 12;

-- Constants used in determining menu width/height.
BCAM_BORDER_WIDTH = 15;
BCAM_BUTTON_HEIGHT = 12;

-- List of tracking abilities to look for.
bcAM_Abilities = {
	[BCAM_TEXT_HAWK] = 0,
	[BCAM_TEXT_CHEETA] = 0,
	[BCAM_TEXT_MONKEY] = 0,
	[BCAM_TEXT_PACK] = 0,
	[BCAM_TEXT_BEAST] = 0,
	[BCAM_TEXT_WILD] = 0,
}

-- ******************************************************************
function bcWrite(msg)
	if (msg and DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage(msg);
	end
end

-- ******************************************************************
function bcAM_OnLoad()
	-- Register for the neccessary events.
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("SPELLS_CHANGED");
	this:RegisterEvent("LEARNED_SPELL_IN_TAB");
	
	-- Create the slash commands to show/hide the menu.
	SlashCmdList["BCAM_SHOWMENU"] = bcAM_ShowMenu;
	SLASH_BCAM_SHOWMENU1 = "/bcam_showmenu";
	SlashCmdList["BCAM_HIDEMENU"] = bcAM_HideMenu;
	SLASH_BCAM_HIDEMENU1 = "/bcam_hidemenu";
	
	-- Create the slash command to output the cursor position.
	SlashCmdList["BCAM_GETLOC"] = bcAM_GetLocation;
	SLASH_BCAM_GETLOC1 = "/bcam_getloc";

	-- Create the slash commands to show/hide the options window.
	SlashCmdList["BCAM_SHOWOPTIONS"] = bcAM_ShowOptions;
	SLASH_BCAM_SHOWOPTIONS1 = "/bcam_showoptions";
	SlashCmdList["BCAM_HIDEOPTIONS"] = bcAM_HideOptions;
	SLASH_BCAM_HIDEOPTIONS1 = "/bcam_hideoptions";
	
	-- Let the user know the mod loaded.
	if ( DEFAULT_CHAT_FRAME ) then 
		bcWrite("BC Aspect Menu loaded");
	end
end

-- ******************************************************************
function bcAM_GetLocation()
	local x, y = GetCursorPosition();
	bcWrite("Cursor location: "..x..", "..y);
end

-- ******************************************************************
function bcAM_ShowMenu(x, y, anchor)
	if (bcAM_Popup:IsVisible()) then
		bcAM_Hide();
		return;
	end

	if (x == nil or y == nil) then
		-- Get the cursor position.  Point is relative to the bottom left corner of the screen.
		x, y = GetCursorPosition();
	end

	if (anchor == nil) then
		anchor = "center";
	end
	
	-- Adjust for the UI scale.
	x = x / UIParent:GetScale();
	y = y / UIParent:GetScale();

	-- Adjust for the height/width/anchor of the menu.
	if (anchor == "topright") then
		x = x - bcAM_Popup:GetWidth();
		y = y - bcAM_Popup:GetHeight();
	elseif (anchor == "topleft") then
		y = y - bcAM_Popup:GetHeight();
	elseif (anchor == "bottomright") then
		x = x - bcAM_Popup:GetWidth();
	elseif (anchor == "bottomleft") then
		-- do nothing.
	else
		-- anchor is either "center" or not a valid value.
		x = x - bcAM_Popup:GetWidth() / 2;
		y = y - bcAM_Popup:GetHeight() / 2;
	end

	-- Clear the current anchor point, and set it to be centered under the mouse.
	bcAM_Popup:ClearAllPoints();
	bcAM_Popup:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", x, y);
	bcAM_Show();
end

-- ******************************************************************
function bcAM_HideMenu()
	bcAM_Hide();
end

-- ******************************************************************
function bcAM_OnEvent()
	if (event == "VARIABLES_LOADED") then
		bcAM_InitializeOptions();
		bcAM_InitializeMenu();
		return;
	end
	
	if (event == "SPELLS_CHANGED" or event == "LEARNED_SPELL_IN_TAB") then
		-- When the player learns a new spell, re-initialize the menu's contents.
		bcAM_InitializeMenu();
		return;
	end
end

-- ******************************************************************
function bcAM_InitializeOptions()
	-- flag to determine if we show the menu when the mouse is over the icon.
	if (bcAM_ShowOnMouse == nil) then
		bcAM_ShowOnMouse = 1;
	end
	
	-- flag to determine if we show the menu when the icon is clicked.
	if (bcAM_ShowOnClick == nil) then
		bcAM_ShowOnClick = 0;
	end
	
	-- flag to determine if we show the menu when the bound key is pressed.
	if (bcAM_ShowOnButton == nil) then
		bcAM_ShowOnButton = 0;
	end
	
	-- flag to determine if we hide the menu when the mouse is not over the icon.
	if (bcAM_HideOnMouse == nil) then
		bcAM_HideOnMouse = 1;
	end
	
	-- flag to determine if we hide the menu when the icon is clicked.
	if (bcAM_HideOnClick == nil) then
		bcAM_HideOnClick = 0;
	end
	
	-- flag to determine if we hide the menu when the bound key is pressed.
	if (bcAM_HideOnButton == nil) then
		bcAM_HideOnButton = 0;
	end
	
	-- flag to determine if we hide the menu when a spell is cast.
	if (bcAM_HideOnCast == nil) then
		bcAM_HideOnCast = 0;
	end
	
	-- position of the icon around the border of the minimap.
	if (bcAM_Position == nil) then
		bcAM_Position = 15;
	end
	
	-- flag to determine if we hide the icon while dead.
	if (bcAM_HideWhileDead == nil) then
		bcAM_HideWhileDead = 1;
	end
	
	bcAM_CheckShowOnMouse:SetChecked(bcAM_ShowOnMouse);
	bcAM_CheckHideOnMouse:SetChecked(bcAM_HideOnMouse);
	bcAM_CheckShowOnClick:SetChecked(bcAM_ShowOnClick);
	bcAM_CheckHideOnClick:SetChecked(bcAM_HideOnClick);
	bcAM_CheckShowOnButton:SetChecked(bcAM_ShowOnButton);
	bcAM_CheckHideOnButton:SetChecked(bcAM_HideOnButton);
	bcAM_CheckHideOnCast:SetChecked(bcAM_HideOnCast);
	bcAM_CheckHideWhileDead:SetChecked(bcAM_HideWhileDead);
	bcAM_IconFrame:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", 52 - (80 * cos(bcAM_Position)), (80 * sin(bcAM_Position)) - 52);
end

-- ******************************************************************
function bcAM_InitializeMenu()
	-- Reset the available abilities.
	for spell, id in ipairs(bcAM_Abilities) do
		if (id > 0) then
			bcAM_Abilities[spellName] = 0
		end
	end

	-- Calculate the total number of spells known by scanning the spellbook.
	local numTotalSpells = 0;
	for i=1, MAX_SKILLLINE_TABS do
		local name, texture, offset, numSpells = GetSpellTabInfo(i);
		if (name) then
			numTotalSpells = numTotalSpells + numSpells
		end
	end

	bcAM_IconFrame.haveAbilities = false;
	
	-- Find the abilities available.
	for i=1, numTotalSpells do
		local spellName, subSpellName = GetSpellName(i, SpellBookFrame.bookType);
		if (spellName) then
			if (bcAM_Abilities[spellName]) then
				bcAM_IconFrame.haveAbilities = true;
				bcAM_Abilities[spellName] = i
			end
		end
	end
	
	if (bcAM_IconFrame.haveAbilities) then
		bcAM_IconFrame:Show();
	end

	-- Set the text for the buttons while keeping track of how many
	-- buttons we actually need.
	local count = 0;
	for spell, id in bcAM_pairsByKeys(bcAM_Abilities) do
		if (id > 0) then
			count = count + 1;
			local button = getglobal("bcAM_PopupButton"..count);
			button:SetText(spell);
			button.SpellID = id;
			button:Show();
		end
	end
	
	-- Set the width for the menu.
	local width = bcAM_TitleButton:GetWidth();
	for i = 1, count, 1 do
		local button = getglobal("bcAM_PopupButton"..i);
		local w = button:GetTextWidth();
		if (w > width) then
			width = w;
		end
	end
	bcAM_Popup:SetWidth(width + 2 * BCAM_BORDER_WIDTH);

	-- By default, the width of the button is set to the width of the text
	-- on the button.  Set the width of each button to the width of the
	-- menu so that you can still click on it without being directly
	-- over the text.
	for i = 1, count, 1 do
		local button = getglobal("bcAM_PopupButton"..i);
		button:SetWidth(width);
	end

	-- Hide the buttons we don't need.
	for i = count + 1, BCAM_NUM_BUTTONS, 1 do
		local button = getglobal("bcAM_PopupButton"..i);
		button:Hide();
	end
	
	-- Set the height for the menu.
	bcAM_Popup:SetHeight(BCAM_BUTTON_HEIGHT + ((count + 1) * BCAM_BUTTON_HEIGHT) + (3 * BCAM_BUTTON_HEIGHT));
end

-- ******************************************************************
function bcAM_ButtonClick()
-- Cast the selected spell.
	CastSpell(this.SpellID, "spell");
	
	if (bcAM_HideOnCast == 1) then
		bcAM_Hide();
	end
end

-- ******************************************************************
function bcAM_Show()
	-- Check to see if the tracking menu is shown.  If so, hide it before
	-- showing the aspect menu.
	if (bcTM_Popup) then
		if (bcTM_Popup:IsVisible()) then
			bcTM_Hide();
		end
	end

	bcAM_Popup:Show();
end

-- ******************************************************************
function bcAM_Hide()
	bcAM_Popup:Hide();
end

-- ******************************************************************
function bcAM_ShowOptions()
	bcAM_Options:Show();
end

-- ******************************************************************
function bcAM_HideOptions()
	bcAM_Options:Hide();
end

-- ******************************************************************
function bcAM_OnUpdate(elapsed)
	-- Check to see if the mouse is still over the menu or the icon.
	if (bcAM_HideOnMouse == 1 and bcAM_Popup:IsVisible()) then
		if (not MouseIsOver(bcAM_Popup) and not MouseIsOver(bcAM_IconFrame)) then
			-- If not, hide the menu.
			bcAM_Hide();
		end
	end
end

-- ******************************************************************
function bcAM_pairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
			else return a[i], t[a[i]]
		end
	end
	return iter
end

-- ******************************************************************
function bcAM_IconFrameOnEnter()
	-- Set the anchor point of the menu so it shows up next to the icon.
	bcAM_Popup:ClearAllPoints();
	bcAM_Popup:SetPoint("TOPRIGHT", "bcAM_IconFrame", "TOPLEFT");

	-- Set the anchor and text for the tooltip.
	GameTooltip:SetOwner(bcAM_IconFrame, "ANCHOR_BOTTOMRIGHT");
	GameTooltip:SetText(BCAM_TEXT_TOOLTIP);

	-- Show the menu.
	if (bcAM_ShowOnMouse == 1) then
		bcAM_Show();
	end
end

-- ******************************************************************
function bcAM_IconFrameOnClick()
	if (bcAM_Popup:IsVisible()) then
		if (bcAM_HideOnClick == 1) then
			bcAM_Hide();
		end
	else
		if (bcAM_ShowOnClick == 1) then
			bcAM_Show();
		end
	end

end