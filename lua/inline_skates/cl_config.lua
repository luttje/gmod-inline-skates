-- Each setting becomes an archived "inline_skates_<name>" client convar.
inlineSkates.clientSettingSections = {
  {
    name = "Camera",
    settings = {
      {
        name = "cam_third_person",
        label = "Third person",
        type = "bool",
        default = 1,
        description = "Skate in third person instead of first person",
      },
      {
        name = "cam_roll",
        label = "Camera roll",
        default = 0.2,
        min = 0,
        max = 1,
        decimals = 2,
        description = "How much of the skater's lean the camera follows (0-1)",
      },
      {
        name = "cam_level",
        label = "Keep camera level",
        type = "bool",
        default = 1,
        description = "Keep the horizon level: the camera only turns with the skater, never pitches or rolls with them",
      },
      {
        name = "cam_follow_travel",
        label = "Camera looks where you go",
        type = "bool",
        default = 1,
        description = "In third person, look the way you're going: skating backwards, the camera looks past your back",
      },
      {
        name = "cam_smooth",
        label = "Camera smoothing",
        default = 0.2,
        min = 0,
        max = 1,
        decimals = 2,
        description = "Seconds the camera lags behind the skater turning and leaning, 0 is off. Mouse look stays "
            .. "instant",
      },
      {
        name = "cam_dist",
        label = "Camera distance",
        default = 110,
        min = 20,
        max = 400,
        description = "Third-person camera distance",
      },
      {
        name = "cam_height",
        label = "Camera height",
        default = 52,
        min = 0,
        max = 120,
        description = "Third-person camera pivot height above the skates",
      },
      {
        name = "cam_fov_boost",
        label = "Sprint FOV boost",
        default = 8,
        min = 0,
        max = 30,
        description = "Extra FOV at sprint speed",
      },
      {
        name = "cam_put_on_blend",
        label = "Camera blend when putting skates on",
        default = 0.6,
        min = 0,
        max = 3,
        decimals = 2,
        description = "Seconds the camera takes to move from your on-foot view to the skating view, 0 is off",
      },
      {
        name = "cam_body",
        label = "Show your body in first person",
        type = "bool",
        default = 1,
        description = "Draw your own playermodel in first person, without its head, so you see your arms and skates",
      },
    },
  },
  {
    name = "Skater",
    settings = {
      {
        name = "skater_ik",
        label = "Animate skaters",
        type = "bool",
        default = 1,
        description = "Pose skaters over their skates: striding, swinging their arms, crouching and tucking",
      },
      {
        name = "skater_knee_bend",
        label = "Knee bend",
        default = 0.12,
        min = 0,
        max = 0.4,
        decimals = 2,
        description = "How far skaters crouch while gliding, as a fraction of their leg length",
      },
      {
        name = "skater_torso_lean",
        label = "Forward lean",
        default = 18,
        min = 0,
        max = 45,
        description = "How far skaters lean their upper body forward (deg)",
      },
      {
        name = "skater_stride_width",
        label = "Stride width",
        default = 10,
        min = 0,
        max = 24,
        decimals = 1,
        description = "How far out to the side each push takes the skate",
      },
      {
        name = "skater_arm_swing",
        label = "Arm swing",
        default = 1,
        min = 0,
        max = 2,
        decimals = 2,
        description = "How far skaters swing their arms while pushing (0 keeps them still)",
      },
      {
        name = "skater_knee_out",
        label = "Knees outward",
        default = 0.15,
        min = 0,
        max = 1,
        decimals = 2,
        description = "How far the knees point outward (0 = straight ahead)",
      },
    },
  },
  {
    name = "HUD",
    settings = {
      {
        name = "hud_speed_unit",
        label = "Speedometer",
        type = "string",
        default = "km/h",
        choices = { "km/h", "mph", "units", "off" },
        description = "Unit the speedometer shows while skating, or off to hide it",
      },
      {
        name = "hud_tricks",
        label = "Show landed tricks",
        type = "bool",
        default = 1,
        description = "Show the names of the tricks you land",
      },
    },
  },
  {
    name = "Sound",
    settings = {
      {
        name = "sound_volume",
        label = "Skating sounds volume",
        default = 1,
        min = 0,
        max = 1,
        decimals = 2,
        description = "Volume of every skater's rolling wheels, pushes, braking and landings (0-1)",
      },
      {
        name = "sound_wind",
        label = "Wind volume",
        default = 1,
        min = 0,
        max = 1,
        decimals = 2,
        description = "Volume of the wind you hear while skating fast (0-1), 0 is off",
      },
    },
  },
  {
    name = "Debug",
    settings = {
      {
        name = "debug",
        label = "Debug overlay and HUD (needs developer 1)",
        type = "bool",
        default = 1,
        description = "Draw the legs, lean and body box debug overlay and HUD (needs developer 1)",
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
      definition.description
    )
  end
end

concommand.Add("inline_skates_reset_client", function()
  for _, conVar in pairs(inlineSkates.clientConVars) do
    conVar:Revert()
  end

  print("[inline_skates] Client settings reset to defaults.")
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
