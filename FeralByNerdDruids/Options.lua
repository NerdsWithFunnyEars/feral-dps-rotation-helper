
FeralByNerdDruidsOptions = { };

function FeralByNerdDruidsOptions:GetLocked()
    return FeralByNerdDruidsDB.locked
end

function FeralByNerdDruidsOptions:ToggleLocked()
    if(FeralByNerdDruidsOptions:GetLocked()) then
        FeralByNerdDruidsDB.locked = false;
        FeralByNerdDruidsFrames.mainFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
        FeralByNerdDruidsFrames.mainFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
        FeralByNerdDruidsFrames.mainFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        FeralByNerdDruidsFrames.mainFrame:SetBackdropColor(0, 0, 0, .4)
        FeralByNerdDruidsFrames.mainFrame:EnableMouse(true)
    else
        FeralByNerdDruidsDB.locked = true;
        FeralByNerdDruidsFrames.mainFrame:SetScript("OnMouseDown", nil)
        FeralByNerdDruidsFrames.mainFrame:SetScript("OnMouseUp", nil)
        FeralByNerdDruidsFrames.mainFrame:SetScript("OnDragStop", nil)
        FeralByNerdDruidsFrames.mainFrame:SetBackdropColor(0, 0, 0, 0)
        FeralByNerdDruidsFrames.mainFrame:EnableMouse(false)
    end
end

function FeralByNerdDruidsOptions:SetScale(num)
    FeralByNerdDruidsDB.scale = num
    FeralByNerdDruidsFrames.mainFrame:SetScale(FeralByNerdDruidsDB.scale)
end

function FeralByNerdDruidsOptions:GetScale()
    return FeralByNerdDruidsDB.scale
end


local panel = CreateFrame("Frame");
panel.name = "FeralByNerdDruids";
InterfaceOptions_AddCategory(panel);  -- see InterfaceOptions API
local title = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge");
title:SetPoint("TOP");
title:SetText("FeralByNerdDruids Configuration window");

local feralByNerdDruidsSetting1 = panel:CreateFontString("FeralByNerdDruidsOptions_string1","OVERLAY","GameFontNormal")
feralByNerdDruidsSetting1:SetText("Lock")
feralByNerdDruidsSetting1:SetPoint("TOPLEFT", 10, -10)
local checkbox1 = CreateFrame("CheckButton", "$parent_cb1", panel, "OptionsCheckButtonTemplate")
checkbox1:SetWidth(18)
checkbox1:SetHeight(18)
checkbox1:SetScript("OnClick", function() FeralByNerdDruidsOptions:ToggleLocked() end)
checkbox1:SetPoint("TOPRIGHT", -10, -10)
checkbox1:SetChecked(FeralByNerdDruidsOptions:GetLocked())

local feralByNerdDruidsSetting2 = panel:CreateFontString("FeralByNerdDruidsOptions_string2","OVERLAY","GameFontNormal")
feralByNerdDruidsSetting2:SetText("Suggestion Monitor Scale")
feralByNerdDruidsSetting2:SetPoint("TOPLEFT", 10, -20)
local slider1 = CreateFrame("Slider", "$parent_sl1", panel, "OptionsSliderTemplate")
slider1:SetMinMaxValues(.25, 2.0)
slider1:SetValue(FeralByNerdDruidsOptions:GetScale())
slider1:SetValueStep(.05)
slider1:SetScript("OnValueChanged", function(self) FeralByNerdDruidsOptions:SetScale(self:GetValue()); _G[self:GetName() .. "Text"]:SetText(self:GetValue())  end)
_G[slider1:GetName() .. "Low"]:SetText("0.25")
_G[slider1:GetName() .. "High"]:SetText("2.0")
_G[slider1:GetName() .. "Text"]:SetText(FeralByNerdDruidsOptions:GetScale())
slider1:SetPoint("TOPRIGHT", -10, -20)