-- Each setting becomes an archived "inline_skates_<name>" client convar.
inlineSkates.clientSettingSections = {
  {
    id = "camera",
    settings = {
      {
        name = "cam_third_person",
        type = "bool",
        default = 1,
      },
      {
        name = "cam_roll",
        default = 0.2,
        min = 0,
        max = 1,
        decimals = 2,
      },
      {
        name = "cam_level",
        type = "bool",
        default = 1,
      },
      {
        name = "cam_follow_travel",
        type = "bool",
        default = 1,
      },
      {
        name = "cam_smooth",
        default = 0.2,
        min = 0,
        max = 1,
        decimals = 2,
      },
      {
        name = "cam_dist",
        default = 110,
        min = 20,
        max = 400,
      },
      {
        name = "cam_height",
        default = 52,
        min = 0,
        max = 120,
      },
      {
        name = "cam_fov_boost",
        default = 8,
        min = 0,
        max = 30,
      },
      {
        name = "cam_put_on_blend",
        default = 0.6,
        min = 0,
        max = 3,
        decimals = 2,
      },
      {
        name = "cam_body",
        type = "bool",
        default = 1,
      },
    },
  },
  {
    id = "skater",
    settings = {
      {
        name = "skater_ik",
        type = "bool",
        default = 1,
      },
      {
        name = "skater_knee_bend",
        default = 0.12,
        min = 0,
        max = 0.4,
        decimals = 2,
      },
      {
        name = "skater_torso_lean",
        default = 18,
        min = 0,
        max = 45,
      },
      {
        name = "skater_stride_width",
        default = 10,
        min = 0,
        max = 24,
        decimals = 1,
      },
      {
        name = "skater_arm_swing",
        default = 1,
        min = 0,
        max = 2,
        decimals = 2,
      },
      {
        name = "skater_knee_out",
        default = 0.15,
        min = 0,
        max = 1,
        decimals = 2,
      },
    },
  },
  {
    id = "hud",
    settings = {
      {
        name = "hud_speed_unit",
        type = "string",
        default = "km/h",
        choices = { "km/h", "mph", "units", "off" },
        choiceLabels = { ["km/h"] = "unit_kmh", mph = "unit_mph", units = "unit_units", off = "unit_off" },
      },
      {
        name = "hud_tricks",
        type = "bool",
        default = 1,
      },
    },
  },
  {
    id = "volume",
    settings = {
      {
        name = "sound_volume",
        default = 1,
        min = 0,
        max = 1,
        decimals = 2,
      },
      {
        name = "sound_wind",
        default = 1,
        min = 0,
        max = 1,
        decimals = 2,
      },
    },
  },
  {
    id = "debug",
    settings = {
      {
        name = "debug",
        type = "bool",
        default = 1,
      },
    },
  },
}

inlineSkates.clientConVars = inlineSkates.clientConVars or {}

for _, section in ipairs(inlineSkates.clientSettingSections) do
  for _, definition in ipairs(section.settings) do
    inlineSkates.clientConVars[definition.name] = CreateClientConVar(
      "inline_skates_" .. definition.name,
      tostring(definition.default),
      true,
      false,
      inlineSkates.lang.get("setting_" .. definition.name .. "_help")
    )
  end
end

concommand.Add("inline_skates_reset_client", function()
  for _, conVar in pairs(inlineSkates.clientConVars) do
    conVar:Revert()
  end

  inlineSkates.lang.print("options_reset_client_done")
end)

--- @param name string A name from `inlineSkates.clientSettingSections`
--- @return number
function inlineSkates.getClientSetting(name)
  return inlineSkates.clientConVars[name]:GetFloat()
end

--- @param name string A name from `inlineSkates.clientSettingSections`
--- @return boolean
function inlineSkates.getClientSettingBool(name)
  return inlineSkates.clientConVars[name]:GetBool()
end

--- @param name string A name from `inlineSkates.clientSettingSections`
--- @return string
function inlineSkates.getClientSettingString(name)
  return inlineSkates.clientConVars[name]:GetString()
end

local developerConVar = GetConVar("developer")

--- The debug overlay and HUD panel only show with both `developer` and `inline_skates_debug` on.
function inlineSkates.isDebugEnabled()
  return developerConVar:GetBool() and inlineSkates.getClientSettingBool("debug")
end

inlineSkates.debugColors = {
  marker = Color(255, 255, 255, 40),
  targetLean = Color(255, 160, 40),
  actualLean = Color(80, 200, 255),
  grounded = Color(80, 255, 120),
  airborne = Color(255, 90, 90),
  contactTrace = Color(255, 230, 0),
  velocity = Color(255, 255, 255),
  body = Color(255, 80, 255),
  editorAnkle = Color(80, 255, 120),
  editorToe = Color(255, 160, 40),
}
