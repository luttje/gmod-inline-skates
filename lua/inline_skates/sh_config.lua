-- Tuning is server authoritative and replicated, so every value can be changed live while skating. The server saves
-- it, so a server's tuning survives restarts.
local TUNING_FLAGS = { FCVAR_ARCHIVE, FCVAR_REPLICATED }

-- The sequence the skater's body starts from before it's posed over the skates.
inlineSkates.DEFAULT_SKATER_SEQUENCE = "idle_all_01"

-- Each setting becomes a "inline_skates_<name>" convar. `min`, `max` and `decimals` are for its slider, `type` is
-- "bool" or "string" for settings that aren't numbers.
inlineSkates.tuningSections = {
  {
    name = "Speed and pushing",
    settings = {
      {
        name = "top_speed",
        label = "Top speed",
        default = 360,
        min = 0,
        max = 1500,
        description = "Top skating speed (u/s). 360 u/s ~ 25 km/h",
      },
      {
        name = "sprint_speed",
        label = "Sprint speed",
        default = 500,
        min = 0,
        max = 2000,
        description = "Top speed while sprinting (u/s). 500 u/s ~ 34 km/h",
      },
      {
        name = "push_accel",
        label = "Push acceleration",
        default = 170,
        min = 0,
        max = 1000,
        description = "Acceleration while pushing off (u/s^2)",
      },
      {
        name = "sprint_accel",
        label = "Sprint acceleration",
        default = 1.35,
        min = 1,
        max = 3,
        decimals = 2,
        description = "Push acceleration multiplier while sprinting",
      },
      {
        name = "brake_accel",
        label = "Brake deceleration",
        default = 420,
        min = 0,
        max = 2000,
        description = "Braking deceleration, with the heel brake or W while rolling backwards (u/s^2)",
      },
      {
        name = "backwards_speed",
        label = "Backwards top speed",
        default = 260,
        min = 0,
        max = 1500,
        description = "Top speed skating backwards, holding S (u/s). 260 u/s ~ 18 km/h",
      },
      {
        name = "backwards_accel",
        label = "Backwards acceleration",
        default = 130,
        min = 0,
        max = 1000,
        description = "Acceleration while pushing off skating backwards (u/s^2)",
      },
      {
        name = "rolling",
        label = "Rolling resistance",
        default = 6,
        min = 0,
        max = 100,
        description = "Rolling resistance while gliding (u/s^2)",
      },
      {
        name = "drag",
        label = "Air drag",
        default = 0.0003,
        min = 0,
        max = 0.002,
        decimals = 4,
        description = "Air drag while gliding (per u/s^2)",
      },
      {
        name = "tuck_drag",
        label = "Tucked drag",
        default = 0.45,
        min = 0,
        max = 1,
        decimals = 2,
        description = "Air drag multiplier while tucked down (Ctrl), to pick up speed downhill",
      },
    },
  },
  {
    name = "Legs and wheels",
    settings = {
      {
        name = "spring",
        label = "Leg spring",
        default = 400,
        min = 0,
        max = 2000,
        description = "How stiff the skater's legs carry them (mass-normalised)",
      },
      { name = "damper", label = "Leg damping", default = 20, min = 0, max = 100, description = "Leg damping" },
      {
        name = "grip",
        label = "Sideways grip",
        default = 25,
        min = 0,
        max = 100,
        description = "How fast sideways slip is removed (1/s)",
      },
      {
        name = "mu",
        label = "Wheel friction",
        default = 1.0,
        min = 0,
        max = 3,
        decimals = 2,
        description = "Wheel friction coefficient (caps carving and braking)",
      },
    },
  },
  {
    name = "Lean and steering",
    settings = {
      { name = "lean_max", label = "Max lean", default = 50, min = 0, max = 80, description = "Max lean angle (deg)" },
      {
        name = "lean_p",
        label = "Lean gain",
        default = 6,
        min = 0,
        max = 20,
        decimals = 1,
        description = "Lean controller gain (deg/s per deg of error)",
      },
      {
        name = "lean_rate",
        label = "Lean rate",
        default = 180,
        min = 0,
        max = 500,
        description = "Max lean rate (deg/s)",
      },
      {
        name = "lean_response",
        label = "Lean response",
        default = 25,
        min = 0,
        max = 100,
        description = "How hard the lean controller corrects (1/s)",
      },
      {
        name = "lean_slack",
        label = "Lean slack",
        default = 250,
        min = 0,
        max = 1000,
        description = "Carving allowed before the skater has leaned in (u/s^2)",
      },
      {
        name = "yaw_response",
        label = "Yaw response",
        default = 30,
        min = 0,
        max = 100,
        description = "How fast the heading follows the steering (1/s)",
      },
      {
        name = "landing_assist",
        label = "Landing assist",
        type = "bool",
        default = 1,
        description = "Turn skaters in the air to land square on their skates, facing along their path",
      },
      {
        name = "air_pitch_speed",
        label = "Air pitch speed",
        default = 170,
        min = 0,
        max = 1000,
        description = "How fast W / S tip the skater forward / back in the air (deg/s), 0 turns it off",
      },
      {
        name = "turn_radius_slow",
        label = "Turn radius (slow)",
        default = 40,
        min = 1,
        max = 500,
        description = "Tightest turn at low speed (units)",
      },
      {
        name = "turn_radius_fast",
        label = "Turn radius (fast)",
        default = 260,
        min = 1,
        max = 2000,
        description = "Tightest turn at high speed (units)",
      },
      {
        name = "turn_slow_speed",
        label = "Slow turning below",
        default = 60,
        min = 0,
        max = 1000,
        description = "Below this speed the slow turn radius is allowed (u/s)",
      },
      {
        name = "turn_fast_speed",
        label = "Fast turning above",
        default = 420,
        min = 0,
        max = 2000,
        description = "Above this speed turns are widened to the fast turn radius (u/s)",
      },
      {
        name = "steer_rate",
        label = "Steer rate",
        default = 3.5,
        min = 0,
        max = 10,
        decimals = 1,
        description = "How fast steering builds up (full turns per second)",
      },
      {
        name = "pivot_turn_speed",
        label = "Turn on the spot",
        default = 120,
        min = 0,
        max = 720,
        description = "How fast A / D turn a skater standing still, stepping round (deg/s)",
      },
    },
  },
  {
    name = "Jumping and tricks",
    settings = {
      {
        name = "jump_min",
        label = "Jump (tap)",
        default = 170,
        min = 0,
        max = 800,
        description = "Upward velocity of a tapped jump (u/s)",
      },
      {
        name = "jump_max",
        label = "Jump (charged)",
        default = 290,
        min = 0,
        max = 800,
        description = "Upward velocity of a fully charged jump, holding Space (u/s)",
      },
      {
        name = "jump_charge_time",
        label = "Jump charge time",
        default = 0.45,
        min = 0.05,
        max = 2,
        decimals = 2,
        description = "Seconds of holding Space for a fully charged jump",
      },
      {
        name = "jump_cooldown",
        label = "Jump cooldown",
        default = 0.3,
        min = 0,
        max = 2,
        decimals = 2,
        description = "Seconds between jumps",
      },
      {
        name = "tricks",
        label = "Allow tricks",
        type = "bool",
        default = 1,
        description = "Let skaters grab, flip and spin in the air",
      },
      {
        name = "spin_speed",
        label = "Spin speed",
        default = 540,
        min = 0,
        max = 2000,
        description = "How fast a skater spins round in the air (deg/s)",
      },
      {
        name = "flip_speed",
        label = "Flip speed",
        default = 560,
        min = 0,
        max = 2000,
        description = "How fast a skater turns over during a backflip or front flip (deg/s)",
      },
      {
        name = "trick_land_tolerance",
        label = "Trick landing tolerance",
        default = 60,
        min = 0,
        max = 180,
        description = "Landing a flip or spin further off straight than this throws you off (deg)",
      },
    },
  },
  {
    name = "Crashes",
    settings = {
      {
        name = "crash_speed",
        label = "Crash speed",
        default = 360,
        min = 0,
        max = 1500,
        description = "Frontal impact speed that knocks you over (u/s)",
      },
      {
        name = "trip_speed",
        label = "Trip speed",
        default = 260,
        min = 0,
        max = 1500,
        description = "Speed into a curb or step too tall to roll over that trips you (u/s)",
      },
      {
        name = "land_crash_speed",
        label = "Landing crash speed",
        default = 900,
        min = 0,
        max = 3000,
        description = "Landing faster than this (u/s into the ground) knocks you over",
      },
      {
        name = "crash_lean",
        label = "Crash lean",
        default = 75,
        min = 0,
        max = 90,
        description = "Lean angle that counts as a fall (deg)",
      },
      {
        name = "crash_pitch",
        label = "Crash pitch",
        default = 70,
        min = 0,
        max = 90,
        description = "Forward or backward tilt against the ground that counts as a fall (deg)",
      },
      {
        name = "forward_damage",
        label = "Skaters can be hurt",
        type = "bool",
        default = 1,
        description = "Damage dealt to the skater's body, such as bullets and explosions, hurts the skater",
      },
    },
  },
  {
    name = "Water",
    settings = {
      {
        name = "water_level",
        label = "Knock over at water level",
        default = 2,
        min = 0,
        max = 3,
        description = "Water this deep knocks the skater over: 1 touching, 2 half under, 3 fully under, 0 never",
      },
      {
        name = "water_drag",
        label = "Water drag",
        default = 2,
        min = 0,
        max = 10,
        decimals = 2,
        description = "How hard water slows the skater once the skates are under (1/s)",
      },
    },
  },
  {
    name = "Sounds",
    settings = {
      {
        name = "sounds",
        label = "Enable sounds",
        type = "bool",
        default = 1,
        description = "Play the skates' sounds: rolling, pushing, braking, wind, landings and falls",
      },
    },
  },
  {
    name = "Mass and the skater",
    settings = {
      {
        name = "mass_ridden",
        label = "Skating mass",
        default = 75,
        min = 1,
        max = 300,
        description = "Physics mass while skating (skates + skater)",
      },
      {
        name = "take_off_anywhere",
        label = "Always let skaters take them off",
        type = "bool",
        default = 0,
        description = "Skaters with no room to stand get off above the skates instead of keeping them on, "
            .. "which could put them past a player clip the skater went through",
      },
      {
        name = "ragmod_crash",
        label = "Ragdoll falling skaters (RagMod)",
        type = "bool",
        default = 1,
        description = "When RagMod is installed and enabled, skaters that fall become a RagMod ragdoll",
      },
      {
        name = "skater_seq",
        label = "Skater sequence",
        type = "string",
        default = inlineSkates.DEFAULT_SKATER_SEQUENCE,
        choices = { "idle_all_01", "idle_all_02", "idle_passive" },
        description = "Player sequence the skater's pose starts from",
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
      definition.description
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
