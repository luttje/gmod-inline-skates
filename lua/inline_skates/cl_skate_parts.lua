-- Draws a skate from its registered rigged skate model, spinning its wheel bones and turning its cuff with the shin.
-- Every model is loaded once as a hidden clientside model, drawn as often as needed.

inlineSkates.skateParts = inlineSkates.skateParts or {}

-- Every bone of a skate model whose name starts with this spins as a wheel, around its own axle.
local WHEEL_BONE_PREFIX = "wheel"
-- Wheel bones closer to the ground than this (units) aren't on an axle, and don't spin.
local MIN_WHEEL_RADIUS = 0.1
-- Every bone whose name starts with this is a cuff, hinged around its own Y axis to lean with the skater's shin.
local CUFF_BONE_PREFIX = "cuff"
-- The skate model's attachments marking where the skater's ankle and toes go.
local ANKLE_ATTACHMENT = "ankle"
local TOE_ATTACHMENT = "toe"

--- @type table<string, Entity> Clientside models by model path
local skateModels = {}
--- @type table<string, table> What was read from each skate model, by model path
local modelInfos = {}

--- @return Entity?
local function getSkateModel(path)
  local model = skateModels[path]

  if (IsValid(model)) then
    return model
  end

  model = ClientsideModel(path, RENDERGROUP_OPAQUE)

  if (not IsValid(model)) then
    return nil
  end

  model:SetNoDraw(true)
  model:DrawShadow(false)
  skateModels[path] = model

  return model
end

--- @return string? # The model drawn for this side's skate
function inlineSkates.skateParts.getModelPath(skates, side)
  return (side == 1 and skates.SkateModelLeft) or (side == -1 and skates.SkateModelRight) or skates.SkateModel
end

--- @return Vector? # Where the attachment is in the model's own space, nil when it has none by that name
local function getAttachmentPosition(model, name)
  local index = model:LookupAttachment(name)
  local attachment = index and index > 0 and model:GetAttachment(index)

  return attachment and attachment.Pos
end

--- @return boolean # Whether the bone's name starts with `prefix`, ignoring case
local function hasPrefix(name, prefix)
  return name:lower():sub(1, #prefix) == prefix
end

--- Reads a skate model once: its wheel bones, each with its radius from how high its axle is above the ground, its
--- cuff bones and where its ankle and toe attachments are.
--- @return table # `{ wheels = { { bone, name, radius } }, cuffs = { { bone, name } }, ankle?, toe? }`, positions in
--- the model's own space
function inlineSkates.skateParts.getModelInfo(path)
  local info = modelInfos[path]

  if (info) then
    return info
  end

  info = { wheels = {}, cuffs = {} }
  modelInfos[path] = info

  local model = getSkateModel(path)

  if (not model) then
    return info
  end

  -- Placed at the origin, the model's world space is its own.
  model:SetPos(vector_origin)
  model:SetAngles(angle_zero)
  model:InvalidateBoneCache()
  model:SetupBones()

  for bone = 0, model:GetBoneCount() - 1 do
    local name = model:GetBoneName(bone) or ""
    local matrix = hasPrefix(name, WHEEL_BONE_PREFIX) and model:GetBoneMatrix(bone)
    local radius = matrix and matrix:GetTranslation().z

    if (radius and radius > MIN_WHEEL_RADIUS) then
      info.wheels[#info.wheels + 1] = { bone = bone, name = name, radius = radius }
    elseif (hasPrefix(name, CUFF_BONE_PREFIX)) then
      info.cuffs[#info.cuffs + 1] = { bone = bone, name = name }
    end
  end

  info.ankle = getAttachmentPosition(model, ANKLE_ATTACHMENT)
  info.toe = getAttachmentPosition(model, TOE_ATTACHMENT)

  return info
end

--- @return Vector, Vector # Where the skater's ankle and toes go in this side's skate, in the skate's own space: the
--- model's attachments, or else the registered positions
function inlineSkates.skateParts.getFootPositions(skates, side)
  local path = inlineSkates.skateParts.getModelPath(skates, side)
  local info = path and inlineSkates.skateParts.getModelInfo(path)

  return (info and info.ankle) or skates.AnklePosition, (info and info.toe) or skates.ToePosition
end

--- Sets every bodygroup of `model` to its first submodel, then to the ones in `bodygroups` and `sideBodygroups`.
local function applyBodygroups(model, bodygroups, sideBodygroups)
  for index = 0, model:GetNumBodyGroups() - 1 do
    model:SetBodygroup(index, 0)
  end

  for _, groups in ipairs({ bodygroups or {}, sideBodygroups or {} }) do
    for name, submodel in pairs(groups) do
      local index = model:FindBodygroupByName(name)

      if (index >= 0) then
        model:SetBodygroup(index, submodel)
      end
    end
  end
end

--- Draws one skate.
--- @param skates Entity
--- @param position Vector World space, on the ground under the middle of the skate
--- @param angles Angle World space
--- @param side number 1 for the left skate, -1 for the right one
--- @param rolledDistance number How far the wheels have rolled forward (units)
--- @param cuffAngle number? How far the cuff is turned forward from how it was modelled (deg)
function inlineSkates.skateParts.draw(skates, position, angles, side, rolledDistance, cuffAngle)
  local path = inlineSkates.skateParts.getModelPath(skates, side)
  local model = path and getSkateModel(path)

  if (not model) then
    return
  end

  local info = inlineSkates.skateParts.getModelInfo(path)
  local sideBodygroups = side == 1 and skates.SkateBodygroupsLeft or skates.SkateBodygroupsRight

  applyBodygroups(model, skates.SkateBodygroups, sideBodygroups)

  -- Each wheel's axle is its bone's Y axis, which is what ManipulateBoneAngles calls pitch. Positive rolls it forward.
  for _, wheel in ipairs(info.wheels) do
    model:ManipulateBoneAngles(wheel.bone, Angle(math.deg(rolledDistance / wheel.radius) % 360, 0, 0))
  end

  -- A cuff's hinge is its bone's Y axis too, and positive pitch tips its top forward.
  for _, cuff in ipairs(info.cuffs) do
    model:ManipulateBoneAngles(cuff.bone, Angle(cuffAngle or 0, 0, 0))
  end

  model:SetPos(position)
  model:SetAngles(angles)
  model:InvalidateBoneCache()

  if (skates.SkatePaint ~= false) then
    local color = skates:GetColor()
    render.SetColorModulation(color.r / 255, color.g / 255, color.b / 255)
  end

  model:DrawModel()
  render.SetColorModulation(1, 1, 1)
end
