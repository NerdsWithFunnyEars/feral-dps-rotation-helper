function FeralByNerdDruidsFrames.events.ADDON_LOADED(addon)
    if addon ~= "FeralByNerdDruids" then
        return
    end

    local _, playerClass = UnitClass("player")
    local playerLevel = UnitLevel("player")

    if (playerClass ~= "DRUID" or playerLevel < 80) then
        FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("PLAYER_ALIVE")
        FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("ADDON_LOADED")
        FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("PLAYER_LOGIN")
        FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
        FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("COMBAT_RATING_UPDATE")
        FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
        FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
        FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
        return
    end

    -- Default saved variables
    if not FeralByNerdDruidsDB then
        FeralByNerdDruidsDB = {}
        FeralByNerdDruidsDB.versionNumber = 1
    end

    if not FeralByNerdDruidsDB.updateInterval then
        FeralByNerdDruidsDB.updateInterval = 0.1
    end

    if not FeralByNerdDruidsDB.useBite then
        FeralByNerdDruidsDB.useBite = false;
    end

    if not FeralByNerdDruidsDB.scale then
        FeralByNerdDruidsDB.scale = 0.7
    end

    if not FeralByNerdDruidsDB.weaveType then
        FeralByNerdDruidsDB.weaveType = "Mangleweave";
    end

    FeralByNerdDruidsFrames:InitializeFrames();
    FeralByNerdDruidsOptions:initializeOptionFrames();

    FeralByNerdDruidsFrames.mainFrame:SetScale(FeralByNerdDruidsDB.scale);
    if(FeralByNerdDruidsDB.locked) then
        FeralByNerdDruidsFrames.mainFrame:SetScript("OnMouseDown", nil)
        FeralByNerdDruidsFrames.mainFrame:SetScript("OnMouseUp", nil)
        FeralByNerdDruidsFrames.mainFrame:SetScript("OnDragStop", nil)
        FeralByNerdDruidsFrames.mainFrame:SetBackdropColor(0, 0, 0, 0)
        FeralByNerdDruidsFrames.mainFrame:EnableMouse(false)
    else
        FeralByNerdDruidsFrames.mainFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
        FeralByNerdDruidsFrames.mainFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
        FeralByNerdDruidsFrames.mainFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        FeralByNerdDruidsFrames.mainFrame:SetBackdropColor(0, 0, 0, .4)
        FeralByNerdDruidsFrames.mainFrame:EnableMouse(true)
    end

    FeralByNerdDruids.weavingType = FeralByNerdDruidsDB.weaveType;

    SLASH_FERALBYNERDDRUIDS1 = "/fbnd";
    SLASH_FERALBYNERDDRUIDS2 = "/feralbynerddruids";
    SlashCmdList["FERALBYNERDDRUIDS"] = function(msg)
        FeralByNerdDruidsOptions:openOptionsFrame();
    end

end

function FeralByNerdDruidsFrames.events.PLAYER_ALIVE()
    FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("PLAYER_ALIVE")
end

function FeralByNerdDruidsFrames.events.PLAYER_LOGIN()
    FeralByNerdDruidsFrames.playerName = UnitName("player");
end

function FeralByNerdDruidsFrames.events.PLAYER_TARGET_CHANGED(...)
    if UnitGUID("target") then
        FeralByNerdDruids.currentTarget.guid = UnitGUID("target")
    else
        FeralByNerdDruids.currentTarget.guid = "A"
    end
end

function FeralByNerdDruidsFrames.events.COMBAT_LOG_EVENT_UNFILTERED(_, event, _, _, _, _, _, _, _, _, _, arg12, ...)
    FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function FeralByNerdDruidsFrames.events.COMBAT_RATING_UPDATE(_)
    FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("COMBAT_RATING_UPDATE")
end

function FeralByNerdDruidsFrames.events.PLAYER_REGEN_ENABLED(...)
    FeralByNerdDruids.damage = nil;

    for i = 1, 10 do
        FeralByNerdDruids.currentTarget.hp[i] = 0;
        FeralByNerdDruids.currentTarget.dps[i] = 0;
        FeralByNerdDruids.currentTarget.time[i] = 0;
    end
end

function FeralByNerdDruidsFrames.events.PLAYER_REGEN_DISABLED(...)
    FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
end

function FeralByNerdDruidsFrames.events.PLAYER_EQUIPMENT_CHANGED(...)
    FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
end