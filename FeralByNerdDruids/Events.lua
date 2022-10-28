function FeralByNerdDruidsFrames.events.ADDON_LOADED(addon)
    if addon ~= "FeralByNerdDruids" then
        return
    end

    local _, playerClass = UnitClass("player")
    local playerLevel = UnitLevel("player")

    FeralByNerdDruidsFrames.playerGUID = UnitGUID("player");

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

    if not FeralByNerdDruidsDB.targetStrategy then
        FeralByNerdDruidsDB.targetStrategy = { };
    end

    FeralByNerdDruidsFrames:InitializeFrames();
    FeralByNerdDruidsOptions:initializeOptionFrames();

    FeralByNerdDruids.weavingType = FeralByNerdDruidsDB.weaveType;

    SLASH_FERALBYNERDDRUIDS1 = "/fbnd";
    SLASH_FERALBYNERDDRUIDS2 = "/feralbynerddruids";
    SlashCmdList["FERALBYNERDDRUIDS"] = function(msg)
        if(msg == "lw") then
            FeralByNerdDruidsOptions:changeWeavingType("Lacerateweave", true);
        elseif(msg == "mw") then
            FeralByNerdDruidsOptions:changeWeavingType("Mangleweave", true);
        elseif(msg == "mc") then
            FeralByNerdDruidsOptions:changeWeavingType("Monocat", true);
        elseif(msg == "target lw") then
            local targetName = UnitName("target");
            if(targetName) then
                FeralByNerdDruidsDB.targetStrategy[targetName] = "Lacerateweave";
                FeralByNerdDruidsOptions:changeWeavingType("Lacerateweave", false)
            end
        elseif(msg == "target mw") then
            local targetName = UnitName("target");
            if(targetName) then
                FeralByNerdDruidsDB.targetStrategy[targetName] = "Mangleweave";
                FeralByNerdDruidsOptions:changeWeavingType("Mangleweave", false);
            end
        elseif(msg == "target mc") then
            local targetName = UnitName("target");
            if(targetName) then
                FeralByNerdDruidsDB.targetStrategy[targetName] = "Monocat";
                FeralByNerdDruidsOptions:changeWeavingType("Monocat", false);
            end
        elseif(msg == "options") then
            FeralByNerdDruidsOptions:openOptionsFrame();
        else
            print("|cffFF0000/fbnd|r |cff0000FFoptions:|r Open settings");
            print("|cffFF0000/fbnd|r |cff0000FFlw:|r Set default strategy to Lacerateweave");
            print("|cffFF0000/fbnd|r |cff0000FFmw:|r Set default strategy to Mangleweave");
            print("|cffFF0000/fbnd|r |cff0000FFmc:|r Set default strategy to Monocat");
            print("|cffFF0000/fbnd|r |cff0000FFtarget lw:|r Set strategy for current target to Lacerateweave (Saved)");
            print("|cffFF0000/fbnd|r |cff0000FFtarget mw:|r Set strategy for current target to Mangleweave  (Saved)");
            print("|cffFF0000/fbnd|r |cff0000FFtarget mc:|r Set strategy for current target to Monocat (Saved)");

        end
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
        local unitName = UnitName("target");
        if(FeralByNerdDruidsDB.targetStrategy[unitName] ~= nil and FeralByNerdDruidsDB.targetStrategy[unitName] ~= FeralByNerdDruidsDB.weaveType) then
            FeralByNerdDruidsOptions:changeWeavingType(FeralByNerdDruidsDB.targetStrategy[unitName], false);
        else
            if(FeralByNerdDruids.weavingType ~= FeralByNerdDruidsDB.weaveType) then
                FeralByNerdDruidsOptions:changeWeavingType(FeralByNerdDruidsDB.weaveType, false);
            end
        end
        FeralByNerdDruids.currentTarget.guid = UnitGUID("target")
        if(UnitAffectingCombat("player")) then
            FeralByNerdDruids.sTime = GetTime();
            FeralByNerdDruids.damage = 0;
            FeralByNerdDruids.pHealth = UnitHealth("target");
        end
    else
        if(FeralByNerdDruids.weavingType ~= FeralByNerdDruidsDB.weaveType) then
            FeralByNerdDruidsOptions:changeWeavingType(FeralByNerdDruidsDB.weaveType, false);
        end
        FeralByNerdDruids.currentTarget.guid = "A"
    end
end

function FeralByNerdDruidsFrames.events.COMBAT_LOG_EVENT_UNFILTERED(_, subevent, _, sourceGUID, _, _, _, _, _, _, _, ...)
    --
    if(sourceGUID == FeralByNerdDruidsFrames.playerGUID and subevent == "SPELL_AURA_APPLIED") then
        local _, spellName = ...;
        if(spellName == L["Rip"]) then
            FeralByNerdDruids.ripStartTime = GetTime();
        end
    end

    if(sourceGUID == FeralByNerdDruidsFrames.playerGUID and (subevent == "SWING_DAMAGE" or subevent == "SWING_MISSED")) then
        FeralByNerdDruids.lastSwingTimer = GetTime();
    end
end

function FeralByNerdDruidsFrames.events.COMBAT_RATING_UPDATE(_)
    FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("COMBAT_RATING_UPDATE")
end

function FeralByNerdDruidsFrames.events.PLAYER_REGEN_ENABLED(...)
    FeralByNerdDruids.damage = 0;
end

function FeralByNerdDruidsFrames.events.PLAYER_REGEN_DISABLED(...)
    FeralByNerdDruids.sTime = GetTime();
    FeralByNerdDruids.damage = 0;
    FeralByNerdDruids.pHealth = UnitHealth("target");
    FeralByNerdDruids.pTime = GetTime();
end

function FeralByNerdDruidsFrames.events.PLAYER_EQUIPMENT_CHANGED(...)
    FeralByNerdDruidsFrames.eventFrame:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
end