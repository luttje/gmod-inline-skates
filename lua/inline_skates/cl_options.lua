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

local function addSettingControl(form, definition)
  local conVarName = "inline_skates_" .. definition.name
  local control

  if (definition.type == "bool") then
    control = form:CheckBox(definition.label, conVarName)
  elseif (definition.type == "string") then
    control = form:ComboBox(definition.label, conVarName)

    for _, choice in ipairs(definition.choices or {}) do
      control:AddChoice(choice, choice)
    end
  else
    control = form:NumSlider(definition.label, conVarName, definition.min, definition.max, definition.decimals or 0)
  end

  control:SetTooltip(string.format("%s\n%s (default %s)", definition.description, conVarName, definition.default))
end

local function addSections(form, sections)
  for _, section in ipairs(sections) do
    local sectionForm = vgui.Create("DForm")
    sectionForm:SetLabel(section.name)
    form:AddItem(sectionForm)

    for _, definition in ipairs(section.settings) do
      addSettingControl(sectionForm, definition)
    end
  end
end

local function buildClientPanel(form)
  form:Help("Your own camera, skater and debug settings. They are saved between sessions.")
  form:Button("Reset to defaults", "inline_skates_reset_client")
  addSections(form, inlineSkates.clientSettingSections)

  form:Help("Wear or look at skates first:")
  form:Button("Open the skate editor (admins)", "inline_skates_editor")
  form:Button("Print the skate model's bones to the console", "inline_skates_print_bones")

  form:DockPadding(0, 0, 0, 16)
end

local function buildServerPanel(form)
  form:Help(
    "How everyone skates. Only the server host can change these (in singleplayer, that's you), and the server saves "
    .. "them. On a dedicated server, set the inline_skates_* ConVars from the server console or server.cfg instead."
  )
  form:Button("Reset to defaults", "inline_skates_reset_tuning")
  form:Button("Print all values to the console", "inline_skates_dump_tuning")
  addSections(form, inlineSkates.tuningSections)

  form:DockPadding(0, 0, 0, 16)
end

hook.Add("PopulateToolMenu", "inlineSkates.options", function()
  spawnmenu.AddToolMenuOption("Options", "Inline Skates", "inline_skates_client", "Client", "", "", buildClientPanel)
  spawnmenu.AddToolMenuOption("Options", "Inline Skates", "inline_skates_server", "Server", "", "", buildServerPanel)
end)
