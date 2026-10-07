-- Skate models are registered from the "InlineSkatesRegisterModels" hook, which runs once the gamemode has loaded. Each
-- becomes its own spawnable entity class derived from sent_inline_skates.
--
-- A skate is drawn from its `model`: one rigged skate in its own space, where the origin is on the ground under the
-- middle of the skate, forward is +X, left is +Y and up is +Z. The same model is drawn on both feet, unless
-- `leftModel` or `rightModel` replaces it on one of them. Every bone whose name starts with "wheel" spins as the skate
-- rolls. Every bone whose name starts with "cuff" turns around its hinge to lean with the skater's shin. The "ankle"
-- and "toe" attachments mark where the skater's foot goes. See MODELING_GUIDE.md.
--
-- From another addon, in a shared lua/autorun/ file:
--
--   hook.Add("InlineSkatesRegisterModels", "myaddon.skates", function()
--     inlineSkates.registerModel("myskates", {
--       name = "My Skates",
--       model = "models/myname/skate.mdl",
--       -- The heel brake, only on the right skate.
--       rightBodygroups = { brake = 1 },
--     })
--   end)

-- Definition keys that are copied as-is onto the entity class. Left out keys fall back to the defaults.
local DEFINITION_FIELDS = {
  -- Spawn menu icon material, e.g. "entities/myskates.png". Defaults to "entities/<class>.png".
  icon = "IconOverride",
  -- Whether the skates spawn with a random color, which tints the skate model unless `paint` is false.
  randomColor = "RandomColor",
  -- Physics mass of the pair, while nobody wears them.
  mass = "EmptyMass",
  -- Multiplies the server's top speeds, so faster skates (such as speed skates) can be made.
  speedScale = "SpeedScale",
  -- Distance between the middle of the two skates while gliding.
  stanceWidth = "StanceWidth",
  -- How far the skater's ankle and toes are moved from where the model's "ankle" and "toe" attachments put them:
  -- forward, inward (mirrored for each side) and up. The foot is aimed from the ankle to the toes.
  ankleOffset = "AnkleOffset",
  toeOffset = "ToeOffset",
  -- Where the ankle and toes are, in the skate's own space, for skate models without those attachments.
  anklePosition = "AnklePosition",
  toePosition = "ToePosition",
  -- How far the shin leans forward from the skate's up (deg) when the model's cuff, as modelled, fits around it. The
  -- cuff turns by how much further the shin leans.
  cuffLean = "CuffLean",
  -- How the skater brakes: "heel" puts the right skate forward onto its heel brake, "tstop" drags the left skate
  -- crosswise behind, for skates without a brake.
  brakeStyle = "BrakeStyle",
  -- The rigged skate model, drawn on both feet unless replaced on one of them.
  model = "SkateModel",
  leftModel = "SkateModelLeft",
  rightModel = "SkateModelRight",
  -- Bodygroups of the skate model, as { [bodygroup name] = submodel index }, for both skates or only one of them.
  bodygroups = "SkateBodygroups",
  leftBodygroups = "SkateBodygroupsLeft",
  rightBodygroups = "SkateBodygroupsRight",
  -- Whether the skate model is tinted with the skates' color. Which parts take the tint is up to its material.
  paint = "SkatePaint",
}

--- @type table<string, string> The entity class field each definition key sets
inlineSkates.modelDefinitionFields = DEFINITION_FIELDS

--- @type table<string, table> Definitions by id, as passed to `inlineSkates.registerModel`
inlineSkates.models = inlineSkates.models or {}

--- Pastes skates from a dupe. The default duplicator merges the whole saved entity table onto the new entity, and dupe
--- files come from clients, so that would let them set any field. Only generic entity data is restored here.
local function pasteSkates(player, data)
  local className = data.Class

  local isAdminOnly = not scripted_ents.GetMember(className, "Spawnable")
      or scripted_ents.GetMember(className, "AdminOnly")

  if (IsValid(player) and not player:IsAdmin() and isAdminOnly) then
    return
  end

  local entity = ents.Create(className)

  if (not IsValid(entity)) then
    return
  end

  duplicator.DoGeneric(entity, data)
  entity:Spawn()
  entity:Activate()
  duplicator.DoGenericPhysics(entity, player, data)

  return entity
end

--- @param id string
--- @return string # The entity class a model is registered as
function inlineSkates.getModelClass(id)
  return inlineSkates.ENTITY_CLASS .. "_" .. id
end

--- Registers a pair of skates as the spawnable entity class "sent_inline_skates_<id>". Call it from the
--- "InlineSkatesRegisterModels" hook, on both the server and the client.
--- @param id string Unique, used in the class name
--- @param definition table
--- @return string? # The entity class, nil when the definition is invalid
function inlineSkates.registerModel(id, definition)
  if (not isstring(id) or not istable(definition)) then
    ErrorNoHaltWithStack("[inline_skates] registerModel needs a string id and a definition table.\n")
    return nil
  end

  local className = inlineSkates.getModelClass(id)
  local entityTable = {
    Type = "anim",
    Base = inlineSkates.ENTITY_CLASS,
    PrintName = definition.name or id,
    Category = definition.category or inlineSkates.SPAWN_CATEGORY,
    Spawnable = true,
    InlineSkatesModelId = id,
  }

  for key, field in pairs(DEFINITION_FIELDS) do
    entityTable[field] = definition[key]
  end

  inlineSkates.models[id] = definition
  scripted_ents.Register(entityTable, className)

  if (SERVER) then
    duplicator.RegisterEntityClass(className, pasteSkates, "Data")
  end

  return className
end

--- Changes one setting of a registered model live: on its definition, on its entity class for skates spawned later and
--- on every pair of it that is already spawned.
--- @param id string
--- @param key string A key of `DEFINITION_FIELDS`
--- @param value any
--- @return boolean # False when the model or key is unknown
function inlineSkates.setModelSetting(id, key, value)
  local definition, field = inlineSkates.models[id], DEFINITION_FIELDS[key]

  if (not definition or not field) then
    return false
  end

  local className = inlineSkates.getModelClass(id)
  local stored = scripted_ents.GetStored(className)

  definition[key] = value

  if (stored) then
    stored.t[field] = value
  end

  for _, skates in ipairs(ents.FindByClass(className)) do
    skates[field] = value

    if (skates.OnModelSettingChanged) then
      skates:OnModelSettingChanged(key)
    end
  end

  hook.Run("InlineSkatesModelSettingChanged", id, key, value)

  return true
end

hook.Add("OnGamemodeLoaded", "inlineSkates.registerModels", function()
  hook.Run("InlineSkatesRegisterModels")
end)

hook.Add("InlineSkatesRegisterModels", "inlineSkates.defaultModels", function()
  inlineSkates.registerModel("default", {
    name = "Inline Skates",
    icon = "entities/inline_skates.png",
    model = "models/inline_skates/rollerblade.mdl",
    randomColor = true,
    mass = 4,
    speedScale = 1,
    stanceWidth = 10,
    brakeStyle = "tstop",
  })
end)
