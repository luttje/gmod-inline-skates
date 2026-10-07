inlineSkates.editor = inlineSkates.editor or {}

-- `axes` marks a vector setting with a slider per axis. The slider range is also what the server accepts.
inlineSkates.editor.SETTINGS = {
  {
    key = "stanceWidth",
    section = "Stance and feet",
    label = "Stance width",
    min = 4,
    max = 24,
    decimals = 2,
    help = "Distance between the middle of the two skates while gliding.",
  },
  {
    key = "ankleOffset",
    section = "Stance and feet",
    label = "Ankle offset",
    axes = { "forward", "inward", "up" },
    min = -10,
    max = 10,
    decimals = 2,
    help = "How far the skater's ankle is moved from the model's \"ankle\" attachment. Inward is mirrored for each "
        .. "side.",
  },
  {
    key = "toeOffset",
    section = "Stance and feet",
    label = "Toe offset",
    axes = { "forward", "inward", "up" },
    min = -10,
    max = 10,
    decimals = 2,
    help = "How far the skater's toes are moved from the model's \"toe\" attachment. The foot points from the "
        .. "ankle to the toes.",
  },
  {
    key = "cuffLean",
    section = "Stance and feet",
    label = "Cuff lean",
    min = -10,
    max = 45,
    decimals = 1,
    help = "How far the shin leans forward (deg) when the model's cuff fits it as modelled. Only for skate models "
        .. "with a cuff bone.",
  },
  {
    key = "mass",
    section = "Physics",
    label = "Mass",
    min = 0.5,
    max = 50,
    decimals = 1,
    help = "Physics mass of the pair while nobody wears them.",
  },
  {
    key = "speedScale",
    section = "Physics",
    label = "Speed scale",
    min = 0.25,
    max = 3,
    decimals = 2,
    help = "Multiplies the server's top speeds for these skates.",
  },
}

inlineSkates.editor.settingsByKey = {}

for _, setting in ipairs(inlineSkates.editor.SETTINGS) do
  inlineSkates.editor.settingsByKey[setting.key] = setting
end

local function clampNumber(setting, value)
  -- NaN fails every comparison, so math.Clamp would let it through.
  if (value ~= value) then
    return setting.min
  end

  value = math.Clamp(value, setting.min, setting.max)

  if (setting.decimals == 0) then
    value = math.Round(value)
  end

  return value
end

--- Keeps a value inside the setting's slider range.
--- @return number|Vector
function inlineSkates.editor.clampValue(setting, value)
  if (setting.axes) then
    return Vector(clampNumber(setting, value.x), clampNumber(setting, value.y), clampNumber(setting, value.z))
  end

  return clampNumber(setting, value)
end

-- Floats rather than net.WriteVector, which rounds to 1/32 of a unit and would show up in the copied registration.
function inlineSkates.editor.writeValue(setting, value)
  if (setting.axes) then
    net.WriteFloat(value.x)
    net.WriteFloat(value.y)
    net.WriteFloat(value.z)
  else
    net.WriteFloat(value)
  end
end

--- @return number|Vector
function inlineSkates.editor.readValue(setting)
  if (setting.axes) then
    return Vector(net.ReadFloat(), net.ReadFloat(), net.ReadFloat())
  end

  return net.ReadFloat()
end
