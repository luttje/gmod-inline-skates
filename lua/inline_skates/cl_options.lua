local function isChangedFromDefault(definition)
  local conVar = inlineSkates.tuningConVars[definition.name]

  if (isnumber(definition.default)) then
    return conVar:GetFloat() ~= definition.default
  end

  return conVar:GetString() ~= definition.default
end

-- Prints every tuning value, so a tuning session can be pasted back as-is. The tuning convars are replicated, so this
-- runs on the client and costs the server nothing.
concommand.Add("inline_skates_dump_tuning", function()
  print("===== SKATE TUNING =====")

  for _, definition in ipairs(inlineSkates.tuningDefinitions) do
    local conVar = inlineSkates.tuningConVars[definition.name]
    local changedMarker = isChangedFromDefault(definition) and "   (changed)" or ""

    print(string.format("%s %s%s", conVar:GetName(), conVar:GetString(), changedMarker))
  end
end)

local L = inlineSkates.lang.get

local function addSettingControl(form, definition)
  local conVarName = "inline_skates_" .. definition.name
  local label = L("setting_" .. definition.name)
  local control

  if (definition.type == "bool") then
    control = form:CheckBox(label, conVarName)
  elseif (definition.type == "string") then
    control = form:ComboBox(label, conVarName)

    for _, choice in ipairs(definition.choices or {}) do
      local choiceLabel = definition.choiceLabels and definition.choiceLabels[choice]

      control:AddChoice(choiceLabel and L(choiceLabel) or choice, choice)
    end
  else
    control = form:NumSlider(label, conVarName, definition.min, definition.max, definition.decimals or 0)
  end

  control:SetTooltip(L("options_tooltip", {
    description = L("setting_" .. definition.name .. "_help"),
    convar = conVarName,
    default = definition.default,
  }))
end

local function addSections(form, sections)
  for _, section in ipairs(sections) do
    local sectionForm = vgui.Create("DForm")
    sectionForm:SetLabel(L("section_" .. section.id))
    form:AddItem(sectionForm)

    for _, definition in ipairs(section.settings) do
      addSettingControl(sectionForm, definition)
    end
  end
end

local function buildClientPanel(form)
  form:Help(L("options_client_help"))
  form:Button(L("options_open_guide"), "inline_skates_guide")
  form:Button(L("options_reset"), "inline_skates_reset_client")
  addSections(form, inlineSkates.clientSettingSections)

  form:Help(L("options_skate_tools"))
  form:Button(L("options_open_editor"), "inline_skates_editor")
  form:Button(L("options_print_bones"), "inline_skates_print_bones")

  form:DockPadding(0, 0, 0, 16)
end

local function buildServerPanel(form)
  form:Help(L("options_server_help"))
  form:Button(L("options_reset"), "inline_skates_reset_tuning")
  form:Button(L("options_print_tuning"), "inline_skates_dump_tuning")
  addSections(form, inlineSkates.tuningSections)

  form:DockPadding(0, 0, 0, 16)
end

hook.Add("PopulateToolMenu", "inlineSkates.options", function()
  local category = L("options_category")

  spawnmenu.AddToolMenuOption(
    "Options", category, "inline_skates_client", L("options_client"), "", "", buildClientPanel
  )
  spawnmenu.AddToolMenuOption(
    "Options", category, "inline_skates_server", L("options_server"), "", "", buildServerPanel
  )
end)
