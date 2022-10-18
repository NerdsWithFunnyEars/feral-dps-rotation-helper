------------------------------------------------------------------------------------------------------------------------
--- FeralByNerdDruids - an addon by a collaborative work of many druids found in https://discord.com/invite/classicdruid

-- Language file - used to parse all spells
------------------------------------------------------------------------------------------------------------------------

--- Returns the name of a given spell id
--- @param spellID number
--- @return string
function GetSpellName(spellID)
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
    ["Mangle (Cat)"] = GetSpellName(48566),
    -- Bad bleed
    ["Rake"] = GetSpellName(48574),
    -- Good bleed
    ["Rip"] = GetSpellName(49800),
    -- Damage #1
    ["Shred"] = GetSpellName(48572),
    -- Big bite
    ["Ferocious Bite"] = GetSpellName(48577),
    --
    --- Damage Abilities Bear
    --

    -- Filler
    ["Mangle (Bear)"] = GetSpellName(48564),
    -- Okayish bleed
    ["Lacerate"] = GetSpellName(48568),
    -- Ragedump
    ["Maul"] = GetSpellName(48480),

    --
    --- Buffs
    --

    -- Aaah yes, 30% more dmg
    ["Savage Roar"] = GetSpellName(52610),
    -- Aaah yes, free shred
    ["Clearcasting"] = GetSpellName(16870),

    --
    --- Cooldowns
    --

    -- Aaah yes, energy
    ["Tiger's Fury"] = GetSpellName(50213),
    -- Time to kill smth
    ["Berserk"] = GetSpellName(50334),
    -- I'm in danger
    ["Barkskin"] = GetSpellName(22812),
    -- Enemy is in danger
    ["Enrage"] = GetSpellName(5229),

    --
    --- External/Long Term Debuffs
    --

    -- Yay, warrior did a crit
    ["Trauma"] = GetSpellName(46855),
    -- Yay, there is a boomie in the group
    ["Faerie Fire"] = GetSpellName(770),
    -- Nay, no boomie here
    ["Faerie Fire (Feral)"] = GetSpellName(16857),

    --
    --- Shapeshifts
    --

    -- Swift kitten
    ["Cat Form"] = GetSpellName(768),
    -- Stronk bear
    ["Dire Bear Form"] = GetSpellName(9634)
}