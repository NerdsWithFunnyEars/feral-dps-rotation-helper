------------------------------------------------------------------------------------------------------------------------
--- FeralByNerdDruids - an addon by a collaborative work of many druids found in https://discord.com/invite/classicdruid

-- Core File - builds up the main addon
------------------------------------------------------------------------------------------------------------------------

local _, playerClass = UnitClass("player")
local playerLevel = UnitLevel("player")

if (playerClass ~= "DRUID" or playerLevel < 80) then
    print("Disabling Feral By Nerd Druids: You are not a druid or not level 80");
    return
end

------------------------------------------------------------------------------------------------------------------------

-- Local Variables
------------------------------------------------------------------------------------------------------------------------

-- Main Array
FeralByNerdDruids = {}

FeralByNerdDruids.mainFrame = nil;
FeralByNerdDruids.mainFrame_last = nil;
FeralByNerdDruids.mainFrame_current = nil;
FeralByNerdDruids.mainFrame_next = nil;
FeralByNerdDruids.mainFrame_misc = nil;
FeralByNerdDruids.mainFrame_int = nil;


FeralByNerdDruids.playerName = nil;
FeralByNerdDruids.playerClass = nil;
FeralByNerdDruids.playerLevel = nil;
FeralByNerdDruids.globalCooldownFrame = nil;
FeralByNerdDruids.timeSinceLastUpdate = 0;
FeralByNerdDruids.currentTarget = {};
FeralByNerdDruids.currentTarget.guid = "A";
FeralByNerdDruids.currentTarget.id = 0000;
FeralByNerdDruids.currentTarget.unitType = 0000;
FeralByNerdDruids.currentTarget.hp = {}
FeralByNerdDruids.currentTarget.time = {}
FeralByNerdDruids.currentTarget.dps = {}



FeralByNerdDruids.currentTarget.hp = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
    [7] = 0,
    [8] = 0,
    [9] = 0,
    [10] = 0,
}
FeralByNerdDruids.currentTarget.dps = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
    [7] = 0,
    [8] = 0,
    [9] = 0,
    [10] = 0,
}
FeralByNerdDruids.currentTarget.time = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,
    [10] = 10,
}

-- Txt List
FeralByNerdDruids.textureList = {
    ["last"] = nil,
    ["current"] = nil,
    ["next"] = nil,
    ["misc"] = nil,
    ["int"] = nil,
}
------------------------------------------------------------------------------------------------------------------------
-- Local Variables end

-- Event Frame
------------------------------------------------------------------------------------------------------------------------

-- Create Event Frame
FeralByNerdDruids.eventFrame = CreateFrame("Frame")
-- Hook all incoming events to it
FeralByNerdDruids.eventFrame:SetScript("OnEvent", function(_, event, ...)
    FeralByNerdDruids.events[event](...)
end)

-- Register the following Events to it
FeralByNerdDruids.eventFrame:RegisterEvent("ADDON_LOADED")
FeralByNerdDruids.eventFrame:RegisterEvent("PLAYER_LOGIN")
FeralByNerdDruids.eventFrame:RegisterEvent("PLAYER_ALIVE")
FeralByNerdDruids.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
FeralByNerdDruids.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
FeralByNerdDruids.eventFrame:RegisterEvent("COMBAT_RATING_UPDATE")
FeralByNerdDruids.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
FeralByNerdDruids.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
FeralByNerdDruids.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
FeralByNerdDruids.eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
------------------------------------------------------------------------------------------------------------------------
-- Event Frame End

-- Main Suggestion Frame
------------------------------------------------------------------------------------------------------------------------
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

mainFrame:SetScript("OnUpdate", function(self, elapsed)
    FeralByNerdDruids:OnUpdate(elapsed)
end)

FeralByNerdDruids.mainFrame = mainFrame;
------------------------------------------------------------------------------------------------------------------------
-- Main Suggestion Frame End

-- Helper Texture Frames
------------------------------------------------------------------------------------------------------------------------
local mainFrame_last = CreateFrame("Frame", "$parent_last", mainFrame)
local mainFrame_current = CreateFrame("Frame", "$parent_current", mainFrame)
local mainFrame_next = CreateFrame("Frame", "$parent_next", mainFrame)
local mainFrame_misc = CreateFrame("Frame", "$parent_misc", mainFrame)
local mainFrame_int = CreateFrame("Frame", "$parent_int", mainFrame)

mainFrame_last:SetWidth(45)
mainFrame_current:SetWidth(70)
mainFrame_next:SetWidth(45)
mainFrame_misc:SetWidth(45)
mainFrame_int:SetWidth(45)

mainFrame_last:SetHeight(45)
mainFrame_current:SetHeight(70)
mainFrame_next:SetHeight(45)
mainFrame_misc:SetHeight(45)
mainFrame_int:SetHeight(45)

mainFrame_last:SetPoint("TOPLEFT", 0, -45)
mainFrame_current:SetPoint("TOPLEFT", 90, -10)
mainFrame_next:SetPoint("TOPLEFT", 200, -45)
mainFrame_misc:SetPoint("TOPLEFT", 0, 0)
mainFrame_int:SetPoint("TOPLEFT", 200, 0)

local t = mainFrame_last:CreateTexture(nil, "Low")
t:SetTexture(nil)
t:SetAllPoints(mainFrame_last)
t:SetAlpha(.8)
mainFrame_last.texture = t
FeralByNerdDruids.textureList["last"] = t

t = mainFrame_current:CreateTexture(nil, "Low")
t:SetTexture(nil)
t:ClearAllPoints()
t:SetAllPoints(mainFrame_current)
mainFrame_current.texture = t
FeralByNerdDruids.textureList["current"] = t

t = mainFrame_next:CreateTexture(nil, "Low")
t:SetTexture(nil)
t:SetAllPoints(mainFrame_next)
t:SetAlpha(.8)
mainFrame_next.texture = t
FeralByNerdDruids.textureList["next"] = t

t = mainFrame_misc:CreateTexture(nil, "Low")
t:SetTexture(nil)
t:SetAllPoints(mainFrame_misc)
t:SetAlpha(.8)
mainFrame_misc.texture = t
FeralByNerdDruids.textureList["misc"] = t

t = mainFrame_int:CreateTexture(nil, "Low")
t:SetTexture(nil)
t:SetAllPoints(mainFrame_int)
t:SetAlpha(.8)
mainFrame_int.texture = t
FeralByNerdDruids.textureList["int"] = t

FeralByNerdDruids.globalCooldownFrame = CreateFrame("Cooldown", "FeralByNerdDruids_GCDFrame", mainFrame_current, "CooldownFrameTemplate");
FeralByNerdDruids.globalCooldownFrame:SetAllPoints();

FeralByNerdDruids.mainFrame_last = mainFrame_last;
FeralByNerdDruids.mainFrame_current = mainFrame_current;
FeralByNerdDruids.mainFrame_next = mainFrame_next;
FeralByNerdDruids.mainFrame_misc = mainFrame_misc;
FeralByNerdDruids.mainFrame_int = mainFrame_int;

------------------------------------------------------------------------------------------------------------------------
-- Helper Texture Frames End

-- Define our Event Handlers here
FeralByNerdDruids.events = {}

function FeralByNerdDruids.events.ADDON_LOADED(addon)
    if addon ~= "FeralByNerdDruids" then
        return
    end

    local _, playerClass = UnitClass("player")
    local playerLevel = UnitLevel("player")

    if (playerClass ~= "DRUID" or playerLevel < 80) then
        FeralByNerdDruids.eventFrame:UnregisterEvent("PLAYER_ALIVE")
        FeralByNerdDruids.eventFrame:UnregisterEvent("ADDON_LOADED")
        FeralByNerdDruids.eventFrame:UnregisterEvent("PLAYER_LOGIN")
        FeralByNerdDruids.eventFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
        FeralByNerdDruids.eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        FeralByNerdDruids.eventFrame:UnregisterEvent("COMBAT_RATING_UPDATE")
        FeralByNerdDruids.eventFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
        FeralByNerdDruids.eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        FeralByNerdDruids.eventFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
        FeralByNerdDruids.eventFrame:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
    end

    -- Default saved variables
    if not FeralByNerdDruidsDB then
        FeralByNerdDruidsDB = {}
        FeralByNerdDruidsDB.versionNumber = 1
    end

    if not FeralByNerdDruidsDB.updateInterval then
        FeralByNerdDruidsDB.updateInterval = 0.1
    end
end

function FeralByNerdDruids.events.PLAYER_ALIVE()
    FeralByNerdDruids.eventFrame:UnregisterEvent("PLAYER_ALIVE")
end

function FeralByNerdDruids.events.PLAYER_LOGIN()
    FeralByNerdDruids.playerName = UnitName("player");
end

function FeralByNerdDruids.events.PLAYER_TARGET_CHANGED(...)
    if UnitGUID("target") then
        FeralByNerdDruids.currentTarget.guid = UnitGUID("target")
    else
        FeralByNerdDruids.currentTarget.guid = "A"
    end
end

function FeralByNerdDruids.events.COMBAT_LOG_EVENT_UNFILTERED(_, event, _, _, _, _, _, _, _, _, _, arg12, ...)
    FeralByNerdDruids.eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function FeralByNerdDruids.events.COMBAT_RATING_UPDATE(_)
    FeralByNerdDruids.eventFrame:UnregisterEvent("COMBAT_RATING_UPDATE")
end

function FeralByNerdDruids.events.PLAYER_REGEN_ENABLED(...)
    FeralByNerdDruids.damage = nil;

    for i = 1, 10 do
        FeralByNerdDruids.currentTarget.hp[i] = 0;
        FeralByNerdDruids.currentTarget.dps[i] = 0;
        FeralByNerdDruids.currentTarget.time[i] = 0;
    end
end

function FeralByNerdDruids.events.PLAYER_REGEN_DISABLED(...)
    FeralByNerdDruids.eventFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
end

function FeralByNerdDruids.events.PLAYER_EQUIPMENT_CHANGED(...)
    FeralByNerdDruids.eventFrame:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
end


function FeralByNerdDruids:estimatedFightLength()
    local currentTime = GetTime();

    for i = 1, 9 do
        FeralByNerdDruids.currentTarget.hp[i] = FeralByNerdDruids.currentTarget.hp[i + 1]
        FeralByNerdDruids.currentTarget.time[i] = FeralByNerdDruids.currentTarget.time[i + 1]
        FeralByNerdDruids.currentTarget.dps[i] = FeralByNerdDruids.currentTarget.dps[i + 1]
    end

    FeralByNerdDruids.currentTarget.hp[10] = UnitHealth("target")

    if FeralByNerdDruids.currentTarget.hp[10] > FeralByNerdDruids.currentTarget.hp[9] then
        for i = 1, 9 do
            FeralByNerdDruids.currentTarget.hp[i] = FeralByNerdDruids.currentTarget.hp[10] - 10 * (10 - i)
        end
    end
    FeralByNerdDruids.currentTarget.time[10] = currentTime
    FeralByNerdDruids.currentTarget.dps[10] = (FeralByNerdDruids.currentTarget.hp[9] - FeralByNerdDruids.currentTarget.hp[10]) / (FeralByNerdDruids.currentTarget.time[10] - FeralByNerdDruids.currentTarget.time[9])

    FeralByNerdDruids.damage = 0.15 * FeralByNerdDruids.currentTarget.dps[10] + 0.14 * FeralByNerdDruids.currentTarget.dps[9]
            + 0.13 * FeralByNerdDruids.currentTarget.dps[8] + 0.12 * FeralByNerdDruids.currentTarget.dps[7]
            + 0.11 * FeralByNerdDruids.currentTarget.dps[6] + 0.10 * FeralByNerdDruids.currentTarget.dps[5] + 0.08 * FeralByNerdDruids.currentTarget.dps[4]
            + 0.07 * FeralByNerdDruids.currentTarget.dps[3] + 0.06 * FeralByNerdDruids.currentTarget.dps[2] + 0.04 * FeralByNerdDruids.currentTarget.dps[1];

    if (FeralByNerdDruids.currentTarget.hp[1] > 0 and FeralByNerdDruids.currentTarget.dps[1] > 0) then
        if(FeralByNerdDruids.damage == 0) then
            FeralByNerdDruids.damage = 1;
        end
        return UnitHealth("target") / FeralByNerdDruids.damage
    else
        return 9999999
    end
end

-- Get default setting or boss/npc specific setting
-- 0 = None
-- 1 = Mangle
-- 2 = Lacerate
-- 3 = Flower
function FeralByNerdDruids:getWeavingType()
    return 2;
end

-- Ported from https://github.com/wowsims/wotlk/
function FeralByNerdDruids:checkQueueMaul(rotationData)
    local furorCap = rotationData.furorEnergyCap;
    local ripRefreshPending = rotationData.ripRefreshPending;
    local playerInputDelay = rotationData.catLatency;
    local energyLeeway = furorCap - 15 - 10 * (rotationData.globalCooldown + playerInputDelay);
    local hasToShift = rotationData.catEnergy > energyLeeway;

    if(ripRefreshPending) then
        hasToShift = hasToShift or (rotationData.ripDuration < (rotationData.globalCooldown + 3));
    end

    local lacerateNext = false;
    local emergencyLacerateNext = false;
    local mangleNext = false;

    if(self:getWeavingType() == 2) then
        if(rotationData.lacerateBearDuration == nil) then
            rotationData.lacerateBearDuration = 0;
        end
        local lacerateLeeway = rotationData.lacerateBearDuration + rotationData.globalCooldown;
        lacerateNext = rotationData.lacerateBearActive or
                (rotationData.lacerateBearStacks < 5) or
                (rotationData.lacerateBearDuration <= lacerateLeeway);
        local emergencyLeeway = rotationData.globalCooldown + 3 + (2 * playerInputDelay);
        emergencyLacerateNext = rotationData.lacerateBearActive and (rotationData.lacerateBearDuration <= emergencyLeeway);
        mangleNext = rotationData.mangleBearCooldown < rotationData.globalCooldown;
    elseif(self:getWeavingType() == 1) then
        mangleNext = rotationData.mangleBearCooldown < rotationData.globalCooldown;
        lacerateNext = rotationData.lacerateUp and ((rotationData.lacerateStacks < 5) or (rotationData.lacerateTime < (rotationData.globalCooldown + 4)));
    end

    local maulRageThreshold = 10;
    if(emergencyLacerateNext) then
        maulRageThreshold = rotationData.lacerateRage + maulRageThreshold;
    elseif(hasToShift) then
        maulRageThreshold = 10;
    elseif(mangleNext) then
        maulRageThreshold = rotationData.mangleBearRage + maulRageThreshold;
    elseif(lacerateNext) then
        maulRageThreshold = rotationData.lacerateRage + maulRageThreshold;
    end

    if(rotationData.bearRage >= maulRageThreshold) then
        return true;
    else
        return false;
    end

end

function FeralByNerdDruids:nextSpell(rotationData)
    if(rotationData.fairyFireDuration == nil and rotationData.fairyFireFeralDuration == nil and rotationData.faerieFireFeralReady) then
        return L["Faerie Fire (Feral)"]
    end

    if(rotationData.catForm == true and rotationData.tigersFuryReady and rotationData.berserkActive == false and rotationData.kingOfTheJungleEnergy < 100 - rotationData.catEnergy) then
        return L["Tiger's Fury"];
    end

    if(rotationData.catForm ~= true) then
        local shiftNow = (rotationData.catEnergy + 15.0 + (10.0 * rotationData.catLatency) > rotationData.furorEnergyCap) or
                (rotationData.ripRefreshPending and (rotationData.ripDuration < (3.0)));


        local shiftNext = rotationData.catEnergy + 30.0 +
                (10.0*rotationData.catLatency) > rotationData.furorEnergyCap or
                    (rotationData.ripRefreshPending and (rotationData.ripDuration < 4.5));

        shiftNow = shiftNow or rotationData.bearRage < 10;

        local buildLacerate = rotationData.lacerateBearActive == false or rotationData.lacerateBearStacks < 5;
        local maintainLacerate = buildLacerate == false and (rotationData.lacerateBearDuration <= rotationData.strategyLacerateTime) and
                (rotationData.bearRage < 38 or shiftNext) and
                (rotationData.lacerateBearDuration < rotationData.encounterTimeRemaining);
        local lacerateNow = self:getWeavingType() == 2
                and (buildLacerate or maintainLacerate);
        local emergencyLacerate = self:getWeavingType() == 2 and rotationData.lacerateBearActive and (rotationData.lacerateBearDuration < 3 + 2 * rotationData.catLatency) and rotationData.lacerateBearDuration < self:estimatedFightLength()

        if(self:getWeavingType() ~= 2 or lacerateNow == false) then
            shiftNow = shiftNow or rotationData.omenOfClarityDown == false;
        end

        if(emergencyLacerate) then
            return L["Lacerate"];
        elseif(shiftNow) then
            return L["Cat Form"];
        elseif(lacerateNow) then
            return L["Lacerate"];
        elseif(rotationData.mangleBearReady) then
            return L["Mangle (Bear)"];
        elseif(self:checkQueueMaul(rotationData)) then
            return L["Maul"];
        end
    elseif (rotationData.emergencyBearweave) then
        return L["Dire Bear Form"];
    elseif (rotationData.berserkNow) then
        return L["Berserk"];
    elseif (rotationData.savageRoarNow) then
        return L["Savage Roar"];
    elseif (rotationData.ripNow) then
        return L["Rip"];
    elseif (rotationData.biteNow) then
        return L["Ferocious Bite"];
    elseif (rotationData.rakeNow) then
        return L["Rake"];
    elseif (rotationData.mangleNow) then
        return L["Mangle (Cat)"];
    elseif (rotationData.bearweaveNow) then
        return L["Dire Bear Form"];
    else
        return L["Shred"];
    end

    return nil;
end

function FeralByNerdDruids:clipSavageRoar(rotationData)
    if(rotationData.ripActive == false or (
            (rotationData.ripDuration <= rotationData.savageRoarDuration or
                rotationData.encounterTimeRemaining - rotationData.ripDuration < 10)
        )) then
        return false;
    end

    -- Max Rip Duration skipped for now

    local availableTime = rotationData.ripDuration - rotationData.savageRoarDuration;
    local expectedEnergyGain = 10 * availableTime;

    if(rotationData.tigersFuryCooldown < rotationData.ripDuration) then
        expectedEnergyGain = expectedEnergyGain + rotationData.kingOfTheJungleEnergy
    end

    if(rotationData.omenOfClaritySkilled) then
        expectedEnergyGain = (expectedEnergyGain + availableTime / rotationData.attackSpeed) * (3.5 / 60 * (1.0 - rotationData.missChance) * rotationData.shredEnergy)
    end

    if(rotationData.omenOfClarity > 0) then
        expectedEnergyGain = expectedEnergyGain + rotationData.shredEnergy
    end

    local availableEnergy = rotationData.catEnergy - rotationData.savageRoarEnergy + expectedEnergyGain;
    local cpPerBuilder = 1 + (GetCritChance() / 100);
    local costPerBuilder = (rotationData.shredEnergy + rotationData.shredEnergy + rotationData.rakeEnergy) / 3 * (1 + 0.2 * rotationData.missChance);
    local ripRefreshCost = 5 / cpPerBuilder * costPerBuilder + rotationData.ripEnergy;

    if(ripRefreshCost <= availableEnergy) then
        return false
    end

    return rotationData.savageRoarDuration <= rotationData.strategyMaxRoarClip
end

function FeralByNerdDruids:decideOnSpellInRotation()
    local guid = UnitGUID("target")
    if guid == nil or UnitCanAttack("player", "target") == false then
        FeralByNerdDruids.textureList["last"]:SetTexture(nil)
        FeralByNerdDruids.textureList["current"]:SetTexture(nil)
        FeralByNerdDruids.textureList["next"]:SetTexture(nil)
        FeralByNerdDruids.textureList["misc"]:SetTexture(nil)
        FeralByNerdDruids.textureList["int"]:SetTexture(nil)
        return
    end

    local rotationData = { };
    rotationData.catEnergy = UnitPower("player", 3)
    rotationData.comboPoints = GetComboPoints("player", "target");
    rotationData.bearRage = UnitPower("player", 1);
    rotationData.encounterTimeRemaining = self:estimatedFightLength();
    local catform, _, _, _, _, _, _, _, _ = AuraUtil.FindAuraByName(L["Cat Form"], "player", "HELPFUL")
    local bearform, _, _, _, _, _, _, _, _ = AuraUtil.FindAuraByName(L["Dire Bear Form"], "player", "HELPFUL")

    if(catform ~= nil) then
        rotationData.catForm = true;
    else
        rotationData.catForm = false;
    end

    if(bearform ~= nil) then
        rotationData.bearForm = true;
    else
        rotationData.bearForm = false;
    end



    local currentTime = GetTime()

    local spell = ""

    start, duration, _, _ = GetSpellCooldown(L["Rake"]);
    rotationData.globalCooldown = math.max(start - currentTime + duration, 0);

    local omenOfClarity = 0


    local mangleCatActive = false;
    local mangleBearActive = false;
    local traumaWarriorActive = false;

    local mangleCatDuration = nil;
    local mangleBearDuration = nil;
    local traumaWarriorDuration = nil;


    -- King of the Jungle
    _, _, _, _, currRank, _ = GetTalentInfo(2, 26);
    rotationData.kingOfTheJungleEnergy = 20 * currRank;

    rotationData.attackSpeed = UnitAttackSpeed("player");

    local strategyMinCombosForRip = 5;
    local strategyUseRake = true;
    local strategyUseBite = false;
    local strategyBiteTime = 10.0;
    local strategyMinCombosForBite = 5;
    local strategyMangleSpam = false;
    local strategyBearMangle = true;
    local strategyUseBerserk = true;
    local strategyPrePopBerserk = false;
    local strategyPreProcOmen = true;
    local strategyBearWeave = true;
    local strategyBerserkBiteThreshold = 30;
    local strategyLaceratePrio = false;
    local strategyLacerateTime = 10.0;
    local strategyPowerBear = false;
    local strategyMaxRoarClip = 10.0;
    local strategyEncounterEndThreshold = 10.0;
    local rakeMaxDuration = 9;
    local maxBerserkDuration = 15;
    local catLatency = 1.1;
    rotationData.catLatency = catLatency;
    rotationData.strategyLacerateTime = strategyLacerateTime;

    rotationData.strategyMaxRoarClip = strategyMaxRoarClip;

    local mangleEnergy = 1;
    local shredEnergy = 1;
    local rakeEnergy = 1;
    local ripEnergy = 1;
    local savageRoarEnergy = 1;
    local ferociousBiteEnergy = 1;

    local mangleBearRage = 1;
    local lacerateRage = 1;
    local maulRage = 1;

    _, _, _, _, currRank, _ = GetTalentInfo(3, 2);
    local furorEnergyCap = math.min(20 * currRank, 85);

    rotationData.furorEnergyCap = furorEnergyCap;

    _, _, _, _, currRank, _ = GetTalentInfo(3, 7);
    if(currRank == 1) then
        rotationData.omenOfClaritySkilled = true;
    else
        rotationData.omenOfClaritySkilled = false;
    end

    local lacerate = 0;
    local lacerateStack = 0;
    if(UnitLevel("target") == -1) then
        rotationData.missChance = math.max((2 + (83 - UnitLevel("player")) * 2) - GetCombatRatingBonus(CR_HIT_MELEE) + GetHitModifier(), 0);
    else
        rotationData.missChance = math.max((5 + (UnitLevel("target") - UnitLevel("player")) * 0.5) - GetCombatRatingBonus(CR_HIT_MELEE) + GetHitModifier(), 0);
    end

    if(rotationData.missChance ~= 0) then
        rotationData.missChance = rotationData.missChance / 100
    end


    name, _, _, _, _, expirationTime, _, _ = AuraUtil.FindAuraByName(L["Clearcasting"], "player", "HELPFUL");
    if name ~= nil then
        rotationData.omenOfClarity = expirationTime - currentTime
    else
        rotationData.omenOfClarity = 0;
    end
    local omenOfClarityDown = true;
    if rotationData.omenOfClarity > 0 then
        omenOfClarityDown = false;
    else
        omenOfClarityDown = true;
    end

    rotationData.mangleEnergy = GetSpellPowerCost(L["Mangle (Cat)"])[1].cost
    rotationData.shredEnergy = GetSpellPowerCost(L["Shred"])[1].cost
    rotationData.rakeEnergy = GetSpellPowerCost(L["Rake"])[1].cost
    rotationData.ripEnergy = GetSpellPowerCost(L["Rip"])[1].cost
    rotationData.savageRoarEnergy = GetSpellPowerCost(L["Savage Roar"])[1].cost
    rotationData.ferociousBiteEnergy = GetSpellPowerCost(L["Ferocious Bite"])[1].cost
    rotationData.mangleBearRage = GetSpellPowerCost(L["Mangle (Bear)"])[1].cost
    rotationData.lacerateRage = GetSpellPowerCost(L["Lacerate"])[1].cost
    rotationData.maulRage = GetSpellPowerCost(L["Maul"])

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(L["Rake Debuff"], "target", "PLAYER|HARMFUL");
    if name ~= nil then
        rotationData.rakeDuration = expirationTime - currentTime
        rotationData.rakeActive = true;
    else
        rotationData.rakeDuration = nil;
        rotationData.rakeActive = false;
    end

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(L["Rip Debuff"], "target", "PLAYER|HARMFUL");
    if name ~= nil then
        rotationData.ripDuration = expirationTime - currentTime
        rotationData.ripActive = true;
    else
        rotationData.ripDuration = nil;
        rotationData.ripActive = false;
    end

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(L["Mangle (Cat) Debuff"], "target", "HARMFUL");
    if name ~= nil then
        mangleCatDuration = expirationTime - currentTime
        mangleCatActive = true;
    else
        mangleCatDuration = nil
        mangleCatActive = false;
    end

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(L["Mangle (Bear) Debuff"], "target", "HARMFUL");
    if name ~= nil then
        mangleBearDuration = expirationTime - currentTime
        mangleBearActive = true;
    else
        mangleBearDuration = nil
        mangleBearActive = false;
    end

    name, _, count, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(L["Lacerate"], "target", "HARMFUL");

    if name ~= nil then
        rotationData.lacerateBearDuration = expirationTime - currentTime
        rotationData.lacerateBearActive = true;
        rotationData.lacerateBearStacks = count;
    else
        rotationData.lacerateBearDuration = nil
        rotationData.lacerateBearActive = false;
        rotationData.lacerateBearStacks = 0;
    end

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(L["Trauma"], "target", "HARMFUL");
    if name ~= nil then
        traumaWarriorDuration = expirationTime - currentTime
        traumaWarriorActive = true;
    else
        traumaWarriorDuration = nil
        traumaWarriorActive = false;
    end

    if(mangleCatActive) then
        rotationData.bleedDebuffActive = true;
        rotationData.bleedDebuffDuration = mangleCatDuration;
    elseif(mangleBearActive) then
        rotationData.bleedDebuffActive = true;
        rotationData.bleedDebuffDuration = mangleBearDuration;
    elseif(traumaWarriorActive) then
        rotationData.bleedDebuffActive = true;
        rotationData.bleedDebuffDuration = traumaWarriorActive;
    else
        rotationData.bleedDebuffActive = false;
        rotationData.bleedDebuffDuration = nil;
    end

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(L["Faerie Fire (Feral)"], "target", "HARMFUL");
    if name ~= nil then
        rotationData.fairyFireFeralDuration = expirationTime - currentTime
    else
        rotationData.fairyFireFeralDuration = nil;
    end

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(L["Faerie Fire"], "target", "HARMFUL");
    if name ~= nil then
        rotationData.fairyFireDuration = expirationTime - currentTime
    else
        rotationData.fairyFireDuration = nil;
    end

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(L["Savage Roar"], "player", "HELPFUL");
    if name ~= nil then
        rotationData.savageRoarActive = true;
        rotationData.savageRoarDuration = expirationTime - currentTime;
    else
        rotationData.savageRoarActive = false;
        rotationData.savageRoarDuration = nil;
    end

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(L["Berserk"], "player", "HELPFUL");
    if name ~= nil then
        rotationData.berserkActive = true;
        rotationData.berserkDuration = expirationTime - currentTime;
    else
        rotationData.berserkActive = false;
        rotationData.berserkDuration = nil;
    end

    startTime, duration, _ = GetSpellCooldown(L["Berserk"]);
    if(startTime == 0) then
        rotationData.berserkReady = true;
        rotationData.berserkCooldown = 0;
    else
        rotationData.berserkReady = false;
        rotationData.berserkCooldown = startTime - currentTime + duration;
    end

    startTime, duration, _ = GetSpellCooldown(L["Mangle (Bear)"]);
    if(startTime == 0) then
        rotationData.mangleBearReady = true;
        rotationData.mangleBearCooldown = 0;
    else
        rotationData.mangleBearReady = false;
        rotationData.mangleBearCooldown = startTime - currentTime + duration;
    end

    startTime, duration, _ = GetSpellCooldown(L["Faerie Fire (Feral)"]);
    if(startTime == 0) then
        rotationData.faerieFireFeralReady = true;
        rotationData.faerieFireFeralCooldown = 0;
    else
        rotationData.faerieFireFeralReady = false;
        rotationData.faerieFireFeralCooldown = startTime - currentTime + duration;
    end

    startTime, duration, _ = GetSpellCooldown(L["Tiger's Fury"]);
    if(startTime == 0) then
        rotationData.tigersFuryReady = true;
        rotationData.tigersFuryCooldown = 0;
    else
        rotationData.tigersFuryReady = false;
        rotationData.tigersFuryCooldown = startTime - currentTime + duration;
    end

    rotationData.ripNow = rotationData.comboPoints >= strategyMinCombosForRip and
            rotationData.ripActive == false and
            rotationData.encounterTimeRemaining >= strategyEncounterEndThreshold and
            omenOfClarityDown;

    rotationData.biteAtEnd = rotationData.comboPoints >= strategyMinCombosForBite and (
            rotationData.encounterTimeRemaining < strategyEncounterEndThreshold
                    or (
                    rotationData.ripActive and
                            self:estimatedFightLength() - rotationData.ripDuration < strategyEncounterEndThreshold
            )
    );

    rotationData.mangleNow = (rotationData.ripNow == false and rotationData.bleedDebuffActive == false);

    rotationData.biteBeforeRip = (rotationData.comboPoints >= strategyMinCombosForBite) and
            rotationData.ripActive and
            rotationData.savageRoarActive and
            strategyUseBite == true and (
            rotationData.ripDuration >= strategyBiteTime and
                    rotationData.savageRoarDuration >= strategyBiteTime
    );

    rotationData.biteNow = (rotationData.biteBeforeRip or rotationData.biteAtEnd) and omenOfClarityDown;

    if(rotationData.biteNow and rotationData.berserkActive) then
        rotationData.biteNow = rotationData.catEnergy <= strategyBerserkBiteThreshold;
    end

    rotationData.rakeNow = strategyUseRake and
            rotationData.rakeActive == false and
            rotationData.encounterTimeRemaining > rakeMaxDuration and
            omenOfClarityDown;

    rotationData.berserkNow = rotationData.berserkReady and (rotationData.tigersFuryCooldown  > maxBerserkDuration);

    rotationData.savageRoarNow = rotationData.comboPoints >= 1 and (
            rotationData.savageRoarActive == false or
                    self:clipSavageRoar(rotationData)
    )

    local ripRefreshPending = false;
    local pendingActions = { };
    local ripCost = 0;
    local rakeCost = 0;
    local mangleCost = 0;
    local savageRoarCost = 0;


    if(rotationData.ripActive and (rotationData.ripDuration < rotationData.encounterTimeRemaining - strategyEncounterEndThreshold)) then
        if(rotationData.berserkCooldown < rotationData.ripDuration) then
            ripCost = rotationData.ripEnergy * 0.5;
        else
            ripCost = rotationData.ripEnergy;
        end
        pendingActions[tostring(rotationData.ripDuration)] = ripCost;
        ripRefreshPending = true;
    end

    if(rotationData.rakeActive and (rotationData.rakeDuration < rotationData.encounterTimeRemaining - 9)) then
        if(rotationData.berserkCooldown < rotationData.rakeDuration) then
            rakeCost = rotationData.rakeEnergy * 0.5;
        else
            rakeCost = rotationData.rakeEnergy;
        end
        pendingActions[tostring(rotationData.rakeDuration)] = rakeCost;
    end

    if(rotationData.bleedDebuffActive and (rotationData.bleedDebuffDuration < rotationData.encounterTimeRemaining - 1)) then
        if(rotationData.berserkCooldown < rotationData.bleedDebuffDuration) then
            mangleCost = rotationData.mangleEnergy * 0.5;
        else
            mangleCost = rotationData.mangleEnergy;
        end
        pendingActions[tostring(rotationData.bleedDebuffDuration)] = mangleCost;
    end

    if(rotationData.savageRoarActive) then
        if(rotationData.berserkCooldown < rotationData.savageRoarDuration) then
            savageRoarCost = rotationData.savageRoarEnergy * 0.5;
        else
            savageRoarCost = rotationData.savageRoarEnergy;
        end
        pendingActions[tostring(rotationData.savageRoarDuration)] = savageRoarCost;
    end
    table.sort(pendingActions)

    local weaveEnergy = furorEnergyCap - 30 - 20 * catLatency;

    if(furorEnergyCap > 60) then
        weaveEnergy = weaveEnergy - 15;
    end

    local weaveEnd = (4.5 + 2) * catLatency;

    local bearweaveNow = self:getWeavingType() ~= 0 and rotationData.catEnergy <= weaveEnergy and omenOfClarityDown and
            (ripRefreshPending == false or rotationData.ripDuration >= weaveEnd) and rotationData.berserkActive == false;

    if(bearweaveNow and self:getWeavingType() ~= 2) then
        bearweaveNow = rotationData.tigersFuryCooldown >= weaveEnd;
    end

    local emergencyBearweave = self:getWeavingType() == 2 and rotationData.lacerateBearActive and rotationData.lacerateBearDuration < 2.5 + catLatency and (rotationData.lacerateBearDuration < rotationData.encounterTimeRemaining);

    floatingEnergy = 0;

    for key, value in pairs(pendingActions) do
        local delta = tonumber(key) / 0.1;
        if(delta < value) then
            floatingEnergy = floatingEnergy + value - delta;
        end
    end

    local excessEnergy = rotationData.catEnergy - floatingEnergy;
    rotationData.bearweaveNow = bearweaveNow;
    rotationData.emergencyBearweave = emergencyBearweave;
    rotationData.excessEnergy = excessEnergy;
    rotationData.ripRefreshPending = ripRefreshPending;

    spell = FeralByNerdDruids:nextSpell(rotationData)
    FeralByNerdDruids.textureList["current"]:SetTexture(GetSpellTexture(spell));
end

--GUID Parser
function parseGUID(guid)
    if guid == nil then
        FeralByNerdDruids.currentTarget.id = 0000;
        --print("No target, ID #",FeralByNerdDruids.currentTarget.id)
        return
    end
    if guid then
        local unit_type = strsplit("-", guid)
        if unit_type == "Player" then
            local _, _, _ = strsplit("-", guid)
            FeralByNerdDruids.currentTarget.unitType = 0x000
        elseif unit_type == "Creature" then
            local _, _, _, _, _, _, spawn_uid = strsplit("-", guid)
            FeralByNerdDruids.currentTarget.unitType = 0x003
            FeralByNerdDruids.currentTarget.id = spawn_uid
        elseif unit_type == "Pet" then
            FeralByNerdDruids.currentTarget.unitType = 0x004
        elseif unit_type == "Vehicle" then
            FeralByNerdDruids.currentTarget.unitType = 0x005
        end
    end
end

function FeralByNerdDruids:OnUpdate(elapsed)
    FeralByNerdDruids.timeSinceLastUpdate = FeralByNerdDruids.timeSinceLastUpdate + elapsed;

    local start, duration = GetSpellCooldown(L["Rake"])
    FeralByNerdDruids.globalCooldownFrame:SetCooldown(start, duration)

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