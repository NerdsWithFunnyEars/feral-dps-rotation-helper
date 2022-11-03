------------------------------------------------------------------------------------------------------------------------
--- FeralByNerdDruids - an addon by a collaborative work of many druids found in https://discord.com/invite/classicdruid

-- Core File - builds up the main addon
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------

-- Local Variables
------------------------------------------------------------------------------------------------------------------------

-- Main Array
FeralByNerdDruids = {}

FeralByNerdDruids.playerName = nil;
FeralByNerdDruids.playerClass = nil;
FeralByNerdDruids.playerLevel = nil;
FeralByNerdDruids.globalCooldownFrame = nil;
FeralByNerdDruids.timeSinceLastUpdate = 0;
FeralByNerdDruids.currentTarget = {};
FeralByNerdDruids.currentTarget.guid = "A";
FeralByNerdDruids.currentTarget.id = 0000;
FeralByNerdDruids.sTime = 0;
FeralByNerdDruids.pHealth = 0;
FeralByNerdDruids.pTime = 0;
FeralByNerdDruids.damage = 0;
FeralByNerdDruids.tTillZero = 999999;
FeralByNerdDruids.lastSwingTimer = 0;
FeralByNerdDruids.timeToNextSwing = 0;
FeralByNerdDruids.weavingType = "Mangleweave";

FeralByNerdDruidsAPI = {};
FeralByNerdDruidsAPI.currentSpell = nil;
------------------------------------------------------------------------------------------------------------------------
-- Local Variables end

function FeralByNerdDruids:estimatedFightLength()
    local cHealth = UnitHealth("target")
    local hSegment = FeralByNerdDruids.pHealth - cHealth
    if hSegment ~= 0 then -- target has been healed or damaged
        local cTime = GetTime()
        local tTime = cTime - FeralByNerdDruids.sTime
        local tSegment = cTime - FeralByNerdDruids.pTime
        FeralByNerdDruids.damage = FeralByNerdDruids.damage + hSegment
        if tSegment >= 1 then -- one or more seconds has passed; update time till zero
            local rate = FeralByNerdDruids.damage / tTime
            FeralByNerdDruids.tTillZero = cHealth / rate
            FeralByNerdDruids.pTime = cTime
        end
        FeralByNerdDruids.pHealth = cHealth
    end
    if(FeralByNerdDruids.tTillZero == 0 or string.find(UnitName("target"), "Training Dummy")) then
        return 999999;
    else
        return FeralByNerdDruids.tTillZero;
    end
end

-- Get default setting or boss/npc specific setting
-- 0 = None
-- 1 = Mangle
-- 2 = Lacerate
-- 3 = Flower
function FeralByNerdDruids:getWeavingType()
    if(FeralByNerdDruids.weavingType == "Monocat") then
        return 0;
    elseif(FeralByNerdDruids.weavingType == "Mangleweave") then
        return 1;
    else
        return 2;
    end
end

function FeralByNerdDruids:isMaulQueued()
    for lActionSlot = 1, 120 do
        if(IsCurrentAction(lActionSlot) and GetActionTexture(lActionSlot) == GetSpellTexture(FeralByNerdDruidsLocalization.L["Maul"])) then
            return true;
        end
    end
    return false;
end

-- Ported from https://github.com/wowsims/wotlk/
function FeralByNerdDruids:checkQueueMaul(rotationData)
    local furorCap = rotationData.furorEnergyCap;
    local ripRefreshPending = rotationData.ripRefreshPending;
    local playerInputDelay = rotationData.catLatency;
    local energyLeeway = furorCap - 15 - 10 * (rotationData.globalCooldown + playerInputDelay - 1);
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
        return FeralByNerdDruidsLocalization.L["Faerie Fire (Feral)"]
    end

    if not rotationData.emergencyBearweave and rotationData.berserkNow and rotationData.catForm then
        FeralByNerdDruidsAPI.berserkNow = rotationData.berserkNow;
    else
        FeralByNerdDruidsAPI.berserkNow = false;
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

        local powerBearNow = false;

        if(rotationData.strategyPowerBear) then
            powerBearNow = shiftNow == false and rotationData.bearRage < 10;
        else
            powerBearNow = false;
            shiftNow = shiftNow or rotationData.bearRage < 10;
        end

        if(emergencyLacerate) then
            return FeralByNerdDruidsLocalization.L["Lacerate"];
        elseif(shiftNow) then
            return FeralByNerdDruidsLocalization.L["Cat Form"];
        elseif(lacerateNow) then
            return FeralByNerdDruidsLocalization.L["Lacerate"];
        elseif(powerBearNow) then
            return FeralByNerdDruidsLocalization.L["Dire Bear Form"];
        elseif(rotationData.mangleBearReady and rotationData.bearRage > rotationData.mangleBearRage) then
            return FeralByNerdDruidsLocalization.L["Mangle (Bear)"];
        elseif (rotationData.bearRage > rotationData.lacerateRage) then
            return FeralByNerdDruidsLocalization.L["Lacerate"];
        else
            return nil;
        end
    elseif (rotationData.emergencyBearweave) then
        return FeralByNerdDruidsLocalization.L["Dire Bear Form"];
    elseif (rotationData.savageRoarNow) then
        return FeralByNerdDruidsLocalization.L["Savage Roar"];
    elseif (rotationData.ripNow) then
        return FeralByNerdDruidsLocalization.L["Rip"];
    elseif (rotationData.biteNow) then
        return FeralByNerdDruidsLocalization.L["Ferocious Bite"];
    elseif (rotationData.rakeNow) then
        return FeralByNerdDruidsLocalization.L["Rake"];
    elseif (rotationData.mangleNow) then
        return FeralByNerdDruidsLocalization.L["Mangle (Cat)"];
    elseif (rotationData.bearweaveNow) then
        return FeralByNerdDruidsLocalization.L["Dire Bear Form"];
    elseif(rotationData.excessEnergy >= rotationData.shredEnergy or rotationData.omenOfClarityDown == false) then
        return FeralByNerdDruidsLocalization.L["Shred"];
    end
    return nil;
end

function FeralByNerdDruids:clipSavageRoar(rotationData)
    if(rotationData.ripActive == false or rotationData.encounterTimeRemaining - rotationData.ripDuration < 10) then
        return false;
    end

    local ripEnd = FeralByNerdDruids.ripStartTime - GetTime() + rotationData.maximumRipLength;

    if(rotationData.savageRoarDuration >= ripEnd + rotationData.strategyMaxRoarClip) then
        return false;
    end

    return (rotationData.maximumSavageRoarLength >= ripEnd + rotationData.strategyMaxRoarClip);
end

function isMaulQueued()
    for lActionSlot = 1, 120 do
        if(IsCurrentAction(lActionSlot) and GetActionTexture(lActionSlot) == GetSpellTexture(FeralByNerdDruidsLocalization.L["Maul"])) then
            return true;
        end
    end
end

function FeralByNerdDruids:hasSetBonus(setItemId, neededItemCount)
    local SetSlots = { "Head", "Shoulder", "Chest", "Hands", "Legs" }
    local setItemCount = 0;
    for i = 1, #SetSlots do
        local invSlotId, _, _ = GetInventorySlotInfo(SetSlots[i].."Slot");
        local itemId, _ = GetInventoryItemID("player", invSlotId);
        local _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, setID, _ = GetItemInfo(itemId);
        if(setItemId == setID) then
            setItemCount = setItemCount + 1;
        end
    end
    return setItemCount >= neededItemCount;
end

function FeralByNerdDruids:hasGlyph(id)
    for i = 1, 6 do
        local _, _, glyphSpell = GetGlyphSocketInfo(i)
        if glyphSpell == id then
            return true
        end
    end
    return false;
end

function FeralByNerdDruids:decideOnSpellInRotation()
    local guid = UnitGUID("target")
    if guid == nil or UnitCanAttack("player", "target") == false then
        FeralByNerdDruidsAPI.currentSpell = nil;
        FeralByNerdDruidsAPI.lockedIn = true;
        FeralByNerdDruidsAPI.globalCooldownStart = nil;
        FeralByNerdDruidsAPI.tigersFuryNow = false;
        FeralByNerdDruidsAPI.berserkNow = false;
        FeralByNerdDruidsAPI.queueMaul = false;
        FeralByNerdDruidsAPI.emergencyBearweave = false;
        FeralByNerdDruidsAPI.weavingType = nil;
        return
    end

    local rotationData = { };
    rotationData.catEnergy = UnitPower("player", 3)
    rotationData.comboPoints = GetComboPoints("player", "target");
    rotationData.bearRage = UnitPower("player", 1);
    rotationData.encounterTimeRemaining = self:estimatedFightLength();
    local catform, _, _, _, _, _, _, _, _ = AuraUtil.FindAuraByName(FeralByNerdDruidsLocalization.L["Cat Form"], "player", "HELPFUL")
    local bearform, _, _, _, _, _, _, _, _ = AuraUtil.FindAuraByName(FeralByNerdDruidsLocalization.L["Dire Bear Form"], "player", "HELPFUL")

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

    start, duration, _, _ = GetSpellCooldown(FeralByNerdDruidsLocalization.L["Rake"]);
    rotationData.globalCooldown = math.max(start - currentTime + duration, 0);


    local mangleCatActive = false;
    local mangleBearActive = false;
    local traumaWarriorActive = false;

    local mangleCatDuration;
    local mangleBearDuration;
    local traumaWarriorDuration;


    -- King of the Jungle
    _, _, _, _, currRank, _ = GetTalentInfo(2, 26);
    rotationData.kingOfTheJungleEnergy = 20 * currRank;

    rotationData.attackSpeed = UnitAttackSpeed("player");

    local strategyMinCombosForRip = 5;
    local strategyUseRake = true;
    local strategyUseBite = FeralByNerdDruidsDB.useBite;
    local strategyBiteTime = 10.0;
    local strategyMinCombosForBite = 5;
    local strategyBerserkBiteThreshold = 30;
    local strategyLacerateTime = 10.0;
    local strategyPowerBear = false;
    if(self:getWeavingType() == 1) then
        strategyPowerBear = true;
    end
    rotationData.strategyPowerBear = strategyPowerBear;
    local strategyMaxRoarClip = 14.0;
    local strategyEncounterEndThreshold = 10.0;

    local dreamWalkerSet = 798;
    local dreamWalkerSetBonusRip = 2;

    local nightSongSet = 827;
    local nightSongSetBonusRoar = 4;

    local extraRipSecondsFromSet = 0;
    local extraRoarSecondsFromSet = 0;

    if(FeralByNerdDruids:hasSetBonus(dreamWalkerSet, dreamWalkerSetBonusRip)) then
        extraRipSecondsFromSet = 4;
    end

    if(FeralByNerdDruids:hasSetBonus(nightSongSet, nightSongSetBonusRoar)) then
        extraRoarSecondsFromSet = 8;
    end

    local extraRipSecondsFromShredGlyph = 0;
    local extraRipSecondsFromRipGlyph = 0;

    if(FeralByNerdDruids:hasGlyph(54815)) then
        extraRipSecondsFromShredGlyph = 6;
    end

    if(FeralByNerdDruids:hasGlyph(54818)) then
        extraRipSecondsFromRipGlyph = 4;
    end

    local savageRoarTimes = {
        [0] = 0,
        [1] = 14 + extraRoarSecondsFromSet,
        [2] = 19 + extraRoarSecondsFromSet,
        [3] = 24 + extraRoarSecondsFromSet,
        [4] = 29 + extraRoarSecondsFromSet,
        [5] = 34 + extraRoarSecondsFromSet
    };

    rotationData.maximumRipLength = 12 + extraRipSecondsFromSet + extraRipSecondsFromRipGlyph + extraRipSecondsFromShredGlyph;
    rotationData.maximumSavageRoarLength = savageRoarTimes[rotationData.comboPoints];

    local rakeMaxDuration = 9;
    local maxBerserkDuration = 15;
    local catLatency = 1.1;
    rotationData.catLatency = catLatency;
    rotationData.strategyLacerateTime = strategyLacerateTime;

    rotationData.strategyMaxRoarClip = strategyMaxRoarClip;

    _, _, _, _, currRank, _ = GetTalentInfo(3, 2);
    local furorEnergyCap = math.min(20 * currRank, 85);

    rotationData.furorEnergyCap = furorEnergyCap;

    _, _, _, _, currRank, _ = GetTalentInfo(3, 7);
    if(currRank == 1) then
        rotationData.omenOfClaritySkilled = true;
    else
        rotationData.omenOfClaritySkilled = false;
    end

    if(UnitLevel("target") == -1) then
        rotationData.missChance = math.max((2 + (83 - UnitLevel("player")) * 2) - GetCombatRatingBonus(CR_HIT_MELEE) + GetHitModifier(), 0);
    else
        rotationData.missChance = math.max((5 + (UnitLevel("target") - UnitLevel("player")) * 0.5) - GetCombatRatingBonus(CR_HIT_MELEE) + GetHitModifier(), 0);
    end

    if(rotationData.missChance ~= 0) then
        rotationData.missChance = rotationData.missChance / 100
    end


    name, _, _, _, _, expirationTime, _, _ = AuraUtil.FindAuraByName(FeralByNerdDruidsLocalization.L["Clearcasting"], "player", "HELPFUL");
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

    rotationData.omenOfClarityDown = omenOfClarityDown;

    rotationData.mangleEnergy = GetSpellPowerCost(FeralByNerdDruidsLocalization.L["Mangle (Cat)"])[1].cost
    rotationData.shredEnergy = GetSpellPowerCost(FeralByNerdDruidsLocalization.L["Shred"])[1].cost
    rotationData.rakeEnergy = GetSpellPowerCost(FeralByNerdDruidsLocalization.L["Rake"])[1].cost
    rotationData.ripEnergy = GetSpellPowerCost(FeralByNerdDruidsLocalization.L["Rip"])[1].cost
    rotationData.savageRoarEnergy = GetSpellPowerCost(FeralByNerdDruidsLocalization.L["Savage Roar"])[1].cost
    rotationData.ferociousBiteEnergy = GetSpellPowerCost(FeralByNerdDruidsLocalization.L["Ferocious Bite"])[1].cost
    rotationData.mangleBearRage = GetSpellPowerCost(FeralByNerdDruidsLocalization.L["Mangle (Bear)"])[1].cost
    rotationData.lacerateRage = GetSpellPowerCost(FeralByNerdDruidsLocalization.L["Lacerate"])[1].cost
    rotationData.maulRage = GetSpellPowerCost(FeralByNerdDruidsLocalization.L["Maul"])

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(FeralByNerdDruidsLocalization.L["Rake"], "target", "PLAYER|HARMFUL");
    if name ~= nil then
        rotationData.rakeDuration = expirationTime - currentTime
        rotationData.rakeActive = true;
    else
        rotationData.rakeDuration = nil;
        rotationData.rakeActive = false;
    end

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(FeralByNerdDruidsLocalization.L["Rip"], "target", "PLAYER|HARMFUL");
    if name ~= nil then
        rotationData.ripDuration = expirationTime - currentTime
        rotationData.ripActive = true;
    else
        rotationData.ripDuration = nil;
        rotationData.ripActive = false;
    end

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(FeralByNerdDruidsLocalization.L["Mangle (Cat)"], "target", "HARMFUL");
    if name ~= nil then
        mangleCatDuration = expirationTime - currentTime
        mangleCatActive = true;
    else
        mangleCatDuration = nil
        mangleCatActive = false;
    end

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(FeralByNerdDruidsLocalization.L["Mangle (Bear)"], "target", "HARMFUL");
    if name ~= nil then
        mangleBearDuration = expirationTime - currentTime
        mangleBearActive = true;
    else
        mangleBearDuration = nil
        mangleBearActive = false;
    end

    name, _, count, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(FeralByNerdDruidsLocalization.L["Lacerate"], "target", "HARMFUL");

    if name ~= nil then
        rotationData.lacerateBearDuration = expirationTime - currentTime
        rotationData.lacerateBearActive = true;
        rotationData.lacerateBearStacks = count;
    else
        rotationData.lacerateBearDuration = nil
        rotationData.lacerateBearActive = false;
        rotationData.lacerateBearStacks = 0;
    end

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(FeralByNerdDruidsLocalization.L["Trauma"], "target", "HARMFUL");
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
        rotationData.bleedDebuffDuration = traumaWarriorDuration;
    else
        rotationData.bleedDebuffActive = false;
        rotationData.bleedDebuffDuration = nil;
    end

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(FeralByNerdDruidsLocalization.L["Faerie Fire (Feral)"], "target", "HARMFUL");
    if name ~= nil then
        rotationData.fairyFireFeralDuration = expirationTime - currentTime
    else
        rotationData.fairyFireFeralDuration = nil;
    end

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(FeralByNerdDruidsLocalization.L["Faerie Fire"], "target", "HARMFUL");
    if name ~= nil then
        rotationData.fairyFireDuration = expirationTime - currentTime
    else
        rotationData.fairyFireDuration = nil;
    end

    name, _, _, _, duration, expirationTime, _, _ = AuraUtil.FindAuraByName(FeralByNerdDruidsLocalization.L["Savage Roar"], "player", "HELPFUL");
    if name ~= nil then
        rotationData.savageRoarActive = true;
        rotationData.savageRoarDuration = expirationTime - currentTime;
    else
        rotationData.savageRoarActive = false;
        rotationData.savageRoarDuration = nil;
    end

    name, _, _, _, duration, expirationTime, _, _, _, spellID = AuraUtil.FindAuraByName(FeralByNerdDruidsLocalization.L["Berserk"], "player", "HELPFUL");
    if name ~= nil and spellID ~= 59620 then
        rotationData.berserkActive = true;
        rotationData.berserkDuration = expirationTime - currentTime;
    else
        rotationData.berserkActive = false;
        rotationData.berserkDuration = nil;
    end

    startTime, duration, _ = GetSpellCooldown(FeralByNerdDruidsLocalization.L["Berserk"]);
    if(startTime == 0 or ((startTime - currentTime + duration - rotationData.globalCooldown) <= 0)) then
        rotationData.berserkReady = true;
        rotationData.berserkCooldown = 0;
    else
        rotationData.berserkReady = false;
        rotationData.berserkCooldown = startTime - currentTime + duration;
    end

    startTime, duration, _ = GetSpellCooldown(FeralByNerdDruidsLocalization.L["Enrage"]);
    if(startTime == 0 or ((startTime - currentTime + duration - rotationData.globalCooldown) <= 0)) then
        rotationData.enrageReady = true;
        rotationData.enrageCooldown = 0;
    else
        rotationData.enrageReady = false;
        rotationData.enrageCooldown = startTime - currentTime + duration;
    end

    startTime, duration, _ = GetSpellCooldown(FeralByNerdDruidsLocalization.L["Mangle (Bear)"]);
    if(startTime == 0 or (startTime - currentTime + duration - rotationData.globalCooldown <= 0)) then
        rotationData.mangleBearReady = true;
        rotationData.mangleBearCooldown = 0;
    else
        rotationData.mangleBearReady = false;
        rotationData.mangleBearCooldown = startTime - currentTime + duration;
    end

    startTime, duration, _ = GetSpellCooldown(FeralByNerdDruidsLocalization.L["Faerie Fire (Feral)"]);
    if(startTime == 0 or (startTime - currentTime + duration - rotationData.globalCooldown <= 0)) then
        rotationData.faerieFireFeralReady = true;
        rotationData.faerieFireFeralCooldown = 0;
    else
        rotationData.faerieFireFeralReady = false;
        rotationData.faerieFireFeralCooldown = startTime - currentTime + duration;
    end

    startTime, duration, _ = GetSpellCooldown(FeralByNerdDruidsLocalization.L["Tiger's Fury"]);
    if(startTime == 0 or (startTime - currentTime + duration - rotationData.globalCooldown <= 0)) then
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

    rotationData.berserkNow = rotationData.berserkReady and (rotationData.tigersFuryCooldown  > maxBerserkDuration) and (rotationData.catEnergy > 80);

    rotationData.savageRoarNow = rotationData.comboPoints >= 1 and (
            rotationData.savageRoarActive == false or
                    self:clipSavageRoar(rotationData)
    )

    if(rotationData.catForm == true and rotationData.tigersFuryReady and rotationData.berserkActive == false and rotationData.kingOfTheJungleEnergy < 100 - rotationData.catEnergy) then
        rotationData.tigersFuryNow = true;
    else
        rotationData.tigersFuryNow = false;
    end

    local ripRefreshPending = false;
    local pendingActions = { };
    local pendingActionIcons = { };
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
        pendingActionIcons[tostring(rotationData.ripDuration)] = FeralByNerdDruidsLocalization.L["Rip"];
        ripRefreshPending = true;
    end

    if(rotationData.rakeActive and (rotationData.rakeDuration < rotationData.encounterTimeRemaining - 9)) then
        if(rotationData.berserkCooldown < rotationData.rakeDuration) then
            rakeCost = rotationData.rakeEnergy * 0.5;
        else
            rakeCost = rotationData.rakeEnergy;
        end
        pendingActions[tostring(rotationData.rakeDuration)] = rakeCost;
        pendingActionIcons[tostring(rotationData.rakeDuration)] = FeralByNerdDruidsLocalization.L["Rake"];
    end

    if(rotationData.bleedDebuffActive and (rotationData.bleedDebuffDuration < rotationData.encounterTimeRemaining - 1)) then
        if(rotationData.berserkCooldown < rotationData.bleedDebuffDuration) then
            mangleCost = rotationData.mangleEnergy * 0.5;
        else
            mangleCost = rotationData.mangleEnergy;
        end
        pendingActions[tostring(rotationData.bleedDebuffDuration)] = mangleCost;
        pendingActionIcons[tostring(rotationData.bleedDebuffDuration)] = FeralByNerdDruidsLocalization.L["Mangle"];
    end

    if(rotationData.savageRoarActive) then
        if(rotationData.berserkCooldown < rotationData.savageRoarDuration) then
            savageRoarCost = rotationData.savageRoarEnergy * 0.5;
        else
            savageRoarCost = rotationData.savageRoarEnergy;
        end
        pendingActions[tostring(rotationData.savageRoarDuration)] = savageRoarCost;
        pendingActionIcons[tostring(rotationData.bleedDebuffDuration)] = FeralByNerdDruidsLocalization.L["Savage Roar"];
    end

    local pendingActionKeys = {}
    local pendingActionIconKeys = {}
    for k in pairs(pendingActions) do table.insert(pendingActionKeys, k) end
    table.sort(pendingActionKeys);

    for k in pairs(pendingActionIcons) do table.insert(pendingActionIconKeys, k) end
    table.sort(pendingActionIconKeys);

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

    local emergencyBearweave = self:getWeavingType() == 2 and rotationData.lacerateBearActive and rotationData.lacerateBearDuration < 2.5 * rotationData.catLatency and (rotationData.lacerateBearDuration < rotationData.encounterTimeRemaining);

    local floatingEnergy = 0;

    for _, key in ipairs(pendingActionKeys) do
        local delta = tonumber(key) / 0.1;
        if(delta < pendingActions[key]) then
            floatingEnergy = floatingEnergy + pendingActions[key] - delta;
        end
    end

    local nextActionIcon;
    local nextActionTime;

    for _, key in ipairs(pendingActionIconKeys) do
        nextActionIcon = pendingActionIcons[key];
        nextActionTime = tonumber(key);
    end


    local excessEnergy = rotationData.catEnergy - floatingEnergy;
    rotationData.bearweaveNow = bearweaveNow;
    rotationData.emergencyBearweave = emergencyBearweave;
    rotationData.excessEnergy = excessEnergy;
    rotationData.ripRefreshPending = ripRefreshPending;

    local nextSpell = FeralByNerdDruids:nextSpell(rotationData)
    local _, _, _, _, _, _, spellID = GetSpellInfo(nextSpell);
    FeralByNerdDruidsAPI.currentSpell = spellID;
    FeralByNerdDruidsAPI.lockedIn = rotationData.globalCooldown <= FeralByNerdDruids.timeToNextSwing;
    FeralByNerdDruidsAPI.globalCooldownStart = start;
    FeralByNerdDruidsAPI.tigersFuryNow = rotationData.tigersFuryNow;
    FeralByNerdDruidsAPI.queueMaul = FeralByNerdDruids:checkQueueMaul(rotationData);
    FeralByNerdDruidsAPI.maulQueued = FeralByNerdDruids:isMaulQueued();
    FeralByNerdDruidsAPI.emergencyBearweave = emergencyBearweave;
    FeralByNerdDruidsAPI.weavingType = FeralByNerdDruids:getWeavingType();
end
