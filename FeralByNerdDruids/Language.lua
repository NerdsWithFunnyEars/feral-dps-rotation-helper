------------------------------------------------------------------------------------------------------------------------
--- FeralByNerdDruids - an addon by a collaborative work of many druids found in https://discord.com/invite/classicdruid

-- Language file - used to parse all spells
------------------------------------------------------------------------------------------------------------------------

--- Returns the name of a given spell id
--- @param spellID number
--- @return string
function getSpellName(spellID)
    local name = GetSpellInfo(spellID);
    return name;
end

--- Contains all spell names we use in this addon
--- @type table

L = {
    --
    --- Damage Abilities Cat
    --

    -- The thing we need but don't want to use
    ["Mangle (Cat)"] = getSpellName(48566),
    -- Bad bleed
    ["Rake"] = getSpellName(48574),
    -- Good bleed
    ["Rip"] = getSpellName(49800),
    -- Damage #1
    ["Shred"] = getSpellName(48572),
    -- Big bite
    ["Ferocious Bite"] = getSpellName(48577),
    --
    --- Damage Abilities Bear
    --

    -- Filler
    ["Mangle (Bear)"] = getSpellName(48564),
    -- Okayish bleed
    ["Lacerate"] = getSpellName(48568),
    -- Ragedump
    ["Maul"] = getSpellName(48480),

    --
    --- Buffs
    --

    -- Aaah yes, 30% more dmg
    ["Savage Roar"] = getSpellName(52610),
    -- Aaah yes, free shred
    ["Clearcasting"] = getSpellName(16870),

    --
    --- Cooldowns
    --

    -- Aaah yes, energy
    ["Tiger's Fury"] = getSpellName(50213),
    -- Time to kill smth
    ["Berserk"] = getSpellName(50334),
    -- I'm in danger
    ["Barkskin"] = getSpellName(22812),
    -- Enemy is in danger
    ["Enrage"] = getSpellName(5229),

    --
    --- External/Long Term Debuffs
    --

    -- Yay, warrior did a crit
    ["Trauma"] = getSpellName(46855),
    -- Yay, there is a boomie in the group
    ["Faerie Fire"] = getSpellName(770),
    -- Nay, no boomie here
    ["Faerie Fire (Feral)"] = getSpellName(16857),

    --
    --- Shapeshifts
    --

    -- Swift kitten
    ["Cat Form"] = getSpellName(768),
    -- Stronk bear
    ["Dire Bear Form"] = getSpellName(9634)
}