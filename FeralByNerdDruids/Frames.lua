------------------------------------------------------------------------------------------------------------------------
--- FeralByNerdDruids - an addon by a collaborative work of many druids found in https://discord.com/invite/classicdruid

-- Frame file - used to create all frames we use
------------------------------------------------------------------------------------------------------------------------

--- Global var where all frames are stored
--- @type table
FeralByNerdDruidsFrames = {}
FeralByNerdDruidsFrames.lastUpdated = GetTime();
FeralByNerdDruidsFrames.events = { };


FeralByNerdDruidsFrames.textureList = {
    ["bear"] = nil,
    ["current"] = nil,
    ["next"] = nil,
    ["cat"] = nil,
    ["berserk"] = nil,
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

function FeralByNerdDruidsFrames:InitializeFrames()
    local mainFrame = CreateFrame(
            "Frame",
            "FeralByNerdDruids_MainFrame",
            UIParent,
            BackdropTemplateMixin and "BackdropTemplate")

    -- Set Properties
    mainFrame:SetFrameStrata("Low")
    mainFrame:SetWidth(1)
    mainFrame:SetHeight(1)
    mainFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 1,
    });
    mainFrame:SetBackdropColor(0, 0, 0, 0.1);
    mainFrame:EnableMouse(false);
    mainFrame:SetMovable(false);
    mainFrame:SetClampedToScreen(true);
    mainFrame:SetScript("OnMouseDown", nil)
    mainFrame:SetScript("OnMouseUp", nil);
    mainFrame:SetPoint("TOPRIGHT");

    mainFrame:SetScript("OnUpdate", function(_, elapsed)
        FeralByNerdDruidsFrames:OnUpdate(elapsed)
    end)

    FeralByNerdDruidsFrames.mainFrame = mainFrame;
end

function FeralByNerdDruidsFrames:OnUpdate(elapsed)
    FeralByNerdDruids.timeSinceLastUpdate = FeralByNerdDruids.timeSinceLastUpdate + elapsed;

    local attackSpeed = UnitAttackSpeed("player");

    if(FeralByNerdDruids.lastSwingTimer ~= 0) then
        FeralByNerdDruids.timeToNextSwing = math.max(FeralByNerdDruids.lastSwingTimer - GetTime() + attackSpeed, 0);
    else
        FeralByNerdDruids.timeToNextSwing = 0;
    end

    while (FeralByNerdDruids.timeSinceLastUpdate >= FeralByNerdDruidsDB.updateInterval) do
        local catform, _, _, _, _, _, _, _, _ = AuraUtil.FindAuraByName(FeralByNerdDruidsLocalization.L["Cat Form"], "player", "HELPFUL")
        local bearform, _, _, _, _, _, _, _, _ = AuraUtil.FindAuraByName(FeralByNerdDruidsLocalization.L["Dire Bear Form"], "player", "HELPFUL")
        local _, _, _, _, currRank, _ = GetTalentInfo(2, 27)

        if (((catform ~= nil) or (bearform ~= nil)) and currRank ~= 0) then
            FeralByNerdDruids:decideOnSpellInRotation()
        end
        FeralByNerdDruids.timeSinceLastUpdate = FeralByNerdDruids.timeSinceLastUpdate - FeralByNerdDruidsDB.updateInterval;
    end
end