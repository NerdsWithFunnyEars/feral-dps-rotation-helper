
FeralByNerdDruidsOptions = { };

function FeralByNerdDruidsOptions:GetLocked()
    return FeralByNerdDruidsDB.locked
end

function FeralByNerdDruidsOptions:GetUseBite()
    return FeralByNerdDruidsDB.useBite;
end

function FeralByNerdDruidsOptions:GetWeavingType()
    return FeralByNerdDruidsDB.weaveType;
end

function FeralByNerdDruidsOptions:ToggleUseBite()
    if(FeralByNerdDruidsDB.useBite) then
        FeralByNerdDruidsDB.useBite = false;
    else
        FeralByNerdDruidsDB.useBite = true;
    end
end

function FeralByNerdDruidsOptions:changeWeavingType(type, default)
    print("FeralByNightDruids: Set weaving type to: ", type);
    if(default) then
        FeralByNerdDruidsDB.weaveType = type;
    end
    FeralByNerdDruids.weavingType = type;
end

function FeralByNerdDruidsOptions:openOptionsFrame()
    InterfaceOptionsFrame_Show();
    InterfaceOptionsFrame_OpenToCategory("FeralByNerdDruids");
end

--- Opts:
---     name (string): Name of the dropdown (lowercase)
---     parent (Frame): Parent frame of the dropdown.
---     items (Table): String table of the dropdown options.
---     defaultVal (String): String value for the dropdown to default to (empty otherwise).
---     changeFunc (Function): A custom function to be called, after selecting a dropdown option.
function FeralByNerdDruidsOptions:createDropdown(opts)
    local dropdown_name = '$parent_' .. opts['name'] .. '_dropdown'
    local menu_items = opts['items'] or {}
    local title_text = opts['title'] or ''
    local dropdown_width = 0
    local default_val = opts['defaultVal'] or ''
    local change_func = opts['changeFunc'] or function (dropdown_val) end
    local dropdownParent = opts['parent'];

    local dropdown = CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')
    local dd_title = dropdownParent:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOPLEFT", 10, -50)

    for _, item in pairs(menu_items) do -- Sets the dropdown width to the largest item string width.
        dd_title:SetText(item)
        local text_width = dd_title:GetStringWidth() + 20
        if text_width > dropdown_width then
            dropdown_width = text_width
        end
    end

    UIDropDownMenu_SetWidth(dropdown, dropdown_width)
    UIDropDownMenu_SetText(dropdown, default_val)
    dd_title:SetText(title_text)

    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
        local info = UIDropDownMenu_CreateInfo()
        for key, val in pairs(menu_items) do
            info.text = val;
            info.checked = false
            info.menuList= key
            info.hasArrow = false
            info.func = function(b)
                UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
                UIDropDownMenu_SetText(dropdown, b.value)
                b.checked = true
                change_func(dropdown, b.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    return dropdown
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


function FeralByNerdDruidsOptions:initializeOptionFrames()
    local panel = CreateFrame("Frame");
    panel.name = "FeralByNerdDruids";
    InterfaceOptions_AddCategory(panel);
    local title = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge");
    title:SetPoint("TOP");
    title:SetText("FeralByNerdDruids Configuration window");

    local feralByNerdDruidsSetting3 = panel:CreateFontString("FeralByNerdDruidsOptions_string3","OVERLAY","GameFontNormal")
    feralByNerdDruidsSetting3:SetText("Use Ferocious Bite")
    feralByNerdDruidsSetting3:SetPoint("TOPLEFT", 10, -20)
    local checkbox2 = CreateFrame("CheckButton", "$parent_cb2", panel, "OptionsCheckButtonTemplate")
    checkbox2:SetWidth(18)
    checkbox2:SetHeight(18)
    checkbox2:SetScript("OnClick", function() FeralByNerdDruidsOptions:ToggleUseBite() end)
    checkbox2:SetPoint("TOPRIGHT", -10, -20)
    checkbox2:SetChecked(FeralByNerdDruidsOptions:GetUseBite())

    local weaveOptions = {
        ['name'] = 'dd1',
        ['parent'] = panel,
        ['title'] = 'Weaving Type',
        ['items'] = { 'Monocat', 'Mangleweave', 'Lacerateweave' },
        ['defaultVal'] = FeralByNerdDruidsOptions:GetWeavingType(),
        ['changeFunc'] = function(_, dropdown_val)
            FeralByNerdDruidsOptions:changeWeavingType(dropdown_val, true);
        end
    }

    local feralByNerdDruidsSetting5 = FeralByNerdDruidsOptions:createDropdown(weaveOptions);
    feralByNerdDruidsSetting5:SetPoint("TOPRIGHT", 0, -50);
end