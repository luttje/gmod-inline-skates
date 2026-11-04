-- Tuning is server authoritative and replicated, so every value can be changed live while skating. The server saves
-- it, so a server's tuning survives restarts.
local TUNING_FLAGS = { FCVAR_ARCHIVE, FCVAR_REPLICATED }

-- The sequence the skater's body starts from before it's posed over the skates.
inlineSkates.DEFAULT_SKATER_SEQUENCE = "idle_all_01"

-- Each setting becomes a "inline_skates_<name>" convar. `min`, `max` and `decimals` are for its slider, `type` is
-- "bool" or "string" for settings that aren't numbers.
inlineSkates.tuningSections = {
  {
    id = "speed",
    settings = {
      {
        name = "top_speed",
        default = 360,
        min = 0,
        max = 1500,
      },
      {
        name = "sprint_speed",
        default = 500,
        min = 0,
        max = 2000,
      },
      {
        name = "push_accel",
        default = 170,
        min = 0,
        max = 1000,
      },
      {
        name = "sprint_accel",
        default = 1.35,
        min = 1,
        max = 3,
        decimals = 2,
      },
      {
        name = "brake_accel",
        default = 420,
        min = 0,
        max = 2000,
      },
      {
        name = "backwards_speed",
        default = 260,
        min = 0,
        max = 1500,
      },
      {
        name = "backwards_accel",
        default = 130,
        min = 0,
        max = 1000,
      },
      {
        name = "rolling",
        default = 6,
        min = 0,
        max = 100,
      },
      {
        name = "drag",
        default = 0.0003,
        min = 0,
        max = 0.002,
        decimals = 4,
      },
      {
        name = "tuck_drag",
        default = 0.45,
        min = 0,
        max = 1,
        decimals = 2,
      },
    },
  },
  {
    id = "legs",
    settings = {
      {
        name = "spring",
        default = 400,
        min = 0,
        max = 2000,
      },
      { name = "damper", default = 20, min = 0, max = 100 },
      {
        name = "grip",
        default = 25,
        min = 0,
        max = 100,
      },
      {
        name = "mu",
        default = 1.0,
        min = 0,
        max = 3,
        decimals = 2,
      },
    },
  },
  {
    id = "steering",
    settings = {
      { name = "lean_max", default = 50, min = 0, max = 80 },
      {
        name = "lean_p",
        default = 6,
        min = 0,
        max = 20,
        decimals = 1,
      },
      {
        name = "lean_rate",
        default = 180,
        min = 0,
        max = 500,
      },
      {
        name = "lean_response",
        default = 25,
        min = 0,
        max = 100,
      },
      {
        name = "lean_slack",
        default = 250,
        min = 0,
        max = 1000,
      },
      {
        name = "yaw_response",
        default = 30,
        min = 0,
        max = 100,
      },
      {
        name = "landing_assist",
        type = "bool",
        default = 1,
      },
      {
        name = "air_pitch_speed",
        default = 170,
        min = 0,
        max = 1000,
      },
      {
        name = "turn_radius_slow",
        default = 40,
        min = 1,
        max = 500,
      },
      {
        name = "turn_radius_fast",
        default = 260,
        min = 1,
        max = 2000,
      },
      {
        name = "turn_slow_speed",
        default = 60,
        min = 0,
        max = 1000,
      },
      {
        name = "turn_fast_speed",
        default = 420,
        min = 0,
        max = 2000,
      },
      {
        name = "steer_rate",
        default = 3.5,
        min = 0,
        max = 10,
        decimals = 1,
      },
      {
        name = "pivot_turn_speed",
        default = 120,
        min = 0,
        max = 720,
      },
    },
  },
  {
    id = "tricks",
    settings = {
      {
        name = "jump_min",
        default = 170,
        min = 0,
        max = 800,
      },
      {
        name = "jump_max",
        default = 290,
        min = 0,
        max = 800,
      },
      {
        name = "jump_charge_time",
        default = 0.45,
        min = 0.05,
        max = 2,
        decimals = 2,
      },
      {
        name = "jump_cooldown",
        default = 0.3,
        min = 0,
        max = 2,
        decimals = 2,
      },
      {
        name = "tricks",
        type = "bool",
        default = 1,
      },
      {
        name = "spin_speed",
        default = 540,
        min = 0,
        max = 2000,
      },
      {
        name = "flip_speed",
        default = 560,
        min = 0,
        max = 2000,
      },
      {
        name = "trick_land_tolerance",
        default = 60,
        min = 0,
        max = 180,
      },
    },
  },
  {
    id = "crashes",
    settings = {
      {
        name = "crash_speed",
        default = 360,
        min = 0,
        max = 1500,
      },
      {
        name = "trip_speed",
        default = 260,
        min = 0,
        max = 1500,
      },
      {
        name = "land_crash_speed",
        default = 900,
        min = 0,
        max = 3000,
      },
      {
        name = "crash_lean",
        default = 75,
        min = 0,
        max = 90,
      },
      {
        name = "crash_pitch",
        default = 70,
        min = 0,
        max = 90,
      },
      {
        name = "forward_damage",
        type = "bool",
        default = 1,
      },
    },
  },
  {
    id = "water",
    settings = {
      {
        name = "water_level",
        default = 2,
        min = 0,
        max = 3,
      },
      {
        name = "water_drag",
        default = 2,
        min = 0,
        max = 10,
        decimals = 2,
      },
    },
  },
  {
    id = "sounds",
    settings = {
      {
        name = "sounds",
        type = "bool",
        default = 1,
      },
    },
  },
  {
    id = "mass",
    settings = {
      {
        name = "mass_ridden",
        default = 75,
        min = 1,
        max = 300,
      },
      {
        name = "take_off_anywhere",
        type = "bool",
        default = 0,
      },
      {
        name = "ragmod_crash",
        type = "bool",
        default = 1,
      },
      {
        name = "skater_seq",
        type = "string",
        default = inlineSkates.DEFAULT_SKATER_SEQUENCE,
        choices = { "idle_all_01", "idle_all_02", "idle_passive" },
      },
    },
  },
}

--- @type table[] Every setting of `inlineSkates.tuningSections`, in order
inlineSkates.tuningDefinitions = {}
inlineSkates.tuningConVars = inlineSkates.tuningConVars or {}

for _, section in ipairs(inlineSkates.tuningSections) do
  for _, definition in ipairs(section.settings) do
    inlineSkates.tuningDefinitions[#inlineSkates.tuningDefinitions + 1] = definition
    inlineSkates.tuningConVars[definition.name] = CreateConVar(
      "inline_skates_" .. definition.name,
      tostring(definition.default),
      TUNING_FLAGS,
      inlineSkates.lang.get("setting_" .. definition.name .. "_help")
    )
  end
end

--- @param name string A name from `inlineSkates.tuningSections`
--- @return number
function inlineSkates.getTuning(name)
  return inlineSkates.tuningConVars[name]:GetFloat()
end

--- @param name string A name from `inlineSkates.tuningSections`
--- @return boolean
function inlineSkates.getTuningBool(name)
  return inlineSkates.tuningConVars[name]:GetBool()
end

--- @param name string A name from `inlineSkates.tuningSections`
--- @return string
function inlineSkates.getTuningString(name)
  return inlineSkates.tuningConVars[name]:GetString()
end
