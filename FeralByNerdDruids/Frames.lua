------------------------------------------------------------------------------------------------------------------------
--- FeralByNerdDruids - an addon by a collaborative work of many druids found in https://discord.com/invite/classicdruid

-- Frame file - used to create all frames we use
------------------------------------------------------------------------------------------------------------------------

--- Global var where all frames are stored
--- @type table
FeralByNerdDruidsFrames = {}
FeralByNerdDruidsFrames.events = { };


FeralByNerdDruidsFrames.textureList = {
    ["bear"] = nil,
    ["current"] = nil,
    ["next"] = nil,
    ["cat"] = nil,
    ["berserk"] = nil,
}

FeralByNerdDruidsFrames.textList = {
    ["bear"] = nil,
    ["cat"] = nil,
    ["berserk"] = nil,
    ["next"] = nil
}


--- Event Frame Start
------------------------------------------------------------------------------------------------------------------------
-- Create Event Frame
FeralByNerdDruidsFrames.eventFrame = CreateFrame("Frame")
-- Hook all incoming events to it
FeralByNerdDruidsFrames.eventFrame:SetScript("OnEvent", function(_, event, ...)
    if(event == "COMBAT_LOG_EVENT_UNFILTERED") then
        FeralByNerdDruidsFrames.events[event](CombatLogGetCurrentEventInfo())
    else
        FeralByNerdDruidsFrames.events[event](...)
    end
end)

-- Register the following Events to it
FeralByNerdDruidsFrames.eventFrame:RegisterEvent("ADDON_LOADED")
FeralByNerdDruidsFrames.eventFrame:RegisterEvent("PLAYER_LOGIN")
FeralByNerdDruidsFrames.eventFrame:RegisterEvent("PLAYER_ALIVE")
FeralByNerdDruidsFrames.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
FeralByNerdDruidsFrames.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
FeralByNerdDruidsFrames.eventFrame:RegisterEvent("COMBAT_RATING_UPDATE")
FeralByNerdDruidsFrames.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
FeralByNerdDruidsFrames.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
FeralByNerdDruidsFrames.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
FeralByNerdDruidsFrames.eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
------------------------------------------------------------------------------------------------------------------------
--- Event Frame End

-- Main Suggestion Frame Start
------------------------------------------------------------------------------------------------------------------------
function FeralByNerdDruidsFrames:InitializeFrames()
    -- Create Main Frame
    local mainFrame = CreateFrame(
            "Frame",
            "FeralByNerdDruids_MainFrame",
            UIParent,
            BackdropTemplateMixin and "BackdropTemplate")

    -- Set Properties
    mainFrame:SetFrameStrata("Low")
    mainFrame:SetWidth(250)
    mainFrame:SetHeight(90)
    mainFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32,
    })

    mainFrame:SetBackdropColor(0, 0, 0, 0.4)
    mainFrame:EnableMouse(true)
    mainFrame:SetMovable(true)
    mainFrame:SetClampedToScreen(true)
    mainFrame:SetScript("OnMouseDown", function(self)
        self:StartMoving()
    end)
    mainFrame:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
    end)
    mainFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    mainFrame:SetPoint("CENTER")

    mainFrame:SetScript("OnUpdate", function(_, elapsed)
        FeralByNerdDruidsFrames:OnUpdate(elapsed)
    end)

    FeralByNerdDruidsFrames.mainFrame = mainFrame;
------------------------------------------------------------------------------------------------------------------------
--- Main Suggestion Frame End

--- Helper Texture Frames
------------------------------------------------------------------------------------------------------------------------

    -- Display Frame for the current ability centered on the Main Frame
    local mainFrame_current = CreateFrame("Frame", "$parent_current", mainFrame)
    mainFrame_current:SetWidth(70)
    mainFrame_current:SetHeight(70)
    mainFrame_current:SetPoint("TOPLEFT", 90, -10)
    local t = mainFrame_current:CreateTexture(nil, "Low")
    t:SetTexture(nil)
    t:SetAllPoints(mainFrame_current)
    t:SetAlpha(.8)
    mainFrame_current.texture = t
    FeralByNerdDruidsFrames.textureList["current"] = t

    -- Display Frame for the next ability, bottom right on the main Frame
    local mainFrame_next = CreateFrame("Frame", "$parent_next", mainFrame)
    mainFrame_next:SetWidth(45)
    mainFrame_next:SetHeight(45)
    mainFrame_next:SetPoint("TOPLEFT", 200, -45)
    t = mainFrame_next:CreateTexture(nil, "Low")
    t:SetTexture(nil)
    t:SetAllPoints(mainFrame_next)
    t:SetAlpha(.8)
    mainFrame_next.texture = t
    local text = mainFrame_next:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetAllPoints();
    text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE, MONOCHROME")
    text:SetTextColor(1, 0, 0, 1);
    mainFrame_next.text = text;
    FeralByNerdDruidsFrames.textList["next"] = text;
    FeralByNerdDruidsFrames.textureList["next"] = t

    -- Display Frame for Bear Information, bottom left on the main Frame
    local mainFrame_bear = CreateFrame("Frame", "$parent_bear", mainFrame)
    mainFrame_bear:SetWidth(45)
    mainFrame_bear:SetHeight(45)
    mainFrame_bear:SetPoint("TOPLEFT", 0, -45)
    t = mainFrame_bear:CreateTexture(nil, "Low")
    t:SetTexture(nil)
    t:SetAllPoints(mainFrame_bear)
    t:SetAlpha(.8)
    mainFrame_bear.texture = t
    FeralByNerdDruidsFrames.textureList["bear"] = t
    text = mainFrame_bear:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetAllPoints();
    text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE, MONOCHROME")
    text:SetTextColor(1, 0, 0, 1);
    mainFrame_bear.text = text;
    FeralByNerdDruidsFrames.textList["bear"] = text;

    -- Display Frame for Cat Information, top left on the main Frame
    local mainFrame_cat = CreateFrame("Frame", "$parent_cat", mainFrame)
    mainFrame_cat:SetWidth(45)
    mainFrame_cat:SetHeight(45)
    mainFrame_cat:SetPoint("TOPLEFT", 0, 0)
    t = mainFrame_cat:CreateTexture(nil, "Low")
    t:SetTexture(nil)
    t:SetAllPoints(mainFrame_cat)
    t:SetAlpha(.8)
    mainFrame_cat.texture = t
    FeralByNerdDruidsFrames.textureList["cat"] = t
    text = mainFrame_cat:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetAllPoints();
    text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE, MONOCHROME")
    text:SetTextColor(1, 0, 0, 1);
    mainFrame_cat.text = text;
    FeralByNerdDruidsFrames.textList["cat"] = text;


    -- Display Frame for Berserk Data, top right on the main Frame
    local mainFrame_berserk = CreateFrame("Frame", "$parent_berserk", mainFrame)
    mainFrame_berserk:SetHeight(45)
    mainFrame_berserk:SetWidth(45)
    mainFrame_berserk:SetPoint("TOPLEFT", 200, 0)
    t = mainFrame_berserk:CreateTexture(nil, "Low")
    t:SetTexture(nil)
    t:SetAllPoints(mainFrame_berserk)
    t:SetAlpha(.8)
    mainFrame_berserk.texture = t
    FeralByNerdDruidsFrames.textureList["berserk"] = t
    text = mainFrame_berserk:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetAllPoints();
    text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE, MONOCHROME")
    text:SetTextColor(1, 0, 0, 1);
    mainFrame_berserk.text = text;
    FeralByNerdDruidsFrames.textList["berserk"] = text;


    FeralByNerdDruidsFrames.globalCooldownFrame = CreateFrame("Cooldown", "FeralByNerdDruids_GCDFrame", mainFrame_current, "CooldownFrameTemplate");
    FeralByNerdDruidsFrames.globalCooldownFrame:SetAllPoints();

    FeralByNerdDruidsFrames.mainFrame_current = mainFrame_current;
    FeralByNerdDruidsFrames.mainFrame_next = mainFrame_next;
    FeralByNerdDruidsFrames.mainFrame_bear = mainFrame_bear;
    FeralByNerdDruidsFrames.mainFrame_cat = mainFrame_cat;
    FeralByNerdDruidsFrames.mainFrame_berserk = mainFrame_berserk;
end
------------------------------------------------------------------------------------------------------------------------
-- Helper Texture Frames End

function FeralByNerdDruidsFrames:OnUpdate(elapsed)
    FeralByNerdDruids.timeSinceLastUpdate = FeralByNerdDruids.timeSinceLastUpdate + elapsed;

    local start, duration = GetSpellCooldown(L["Rake"])
    FeralByNerdDruidsFrames.globalCooldownFrame:SetCooldown(start, duration)

    local attackSpeed = UnitAttackSpeed("player");

    if(FeralByNerdDruids.lastSwingTimer ~= 0) then
        FeralByNerdDruids.timeToNextSwing = FeralByNerdDruids.lastSwingTimer - GetTime() + attackSpeed;
    else
        FeralByNerdDruids.timeToNextSwing = 0;
    end

    while (FeralByNerdDruids.timeSinceLastUpdate >= FeralByNerdDruidsDB.updateInterval) do
        local catform, _, _, _, _, _, _, _, _ = AuraUtil.FindAuraByName(L["Cat Form"], "player", "HELPFUL")
        local bearform, _, _, _, _, _, _, _, _ = AuraUtil.FindAuraByName(L["Dire Bear Form"], "player", "HELPFUL")
        local _, _, _, _, currRank, _ = GetTalentInfo(2, 27)

        if (((catform ~= nil) or (bearform ~= nil)) and currRank ~= 0) then
            FeralByNerdDruids:decideOnSpellInRotation()
        end
        FeralByNerdDruids.timeSinceLastUpdate = FeralByNerdDruids.timeSinceLastUpdate - FeralByNerdDruidsDB.updateInterval;
    end
end