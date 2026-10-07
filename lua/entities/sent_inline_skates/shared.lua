ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Inline Skates"
-- Not spawnable itself: every registered model is its own class derived from this one.
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.IsInlineSkates = true

-- The engine needs a model, but it's never drawn: each skate is drawn from its skate model and the physics are hulls.
ENT.Model = "models/inline_skates/rollerblade.mdl"

-- Geometry is entity-local with forward as +X and up as +Z, and the origin on the ground between the skates.
-- Parked, the pair stands side by side in a small box.
ENT.ParkedMins = Vector(-10, -6.5, 0)
ENT.ParkedMaxs = Vector(10, 6.5, 15.5)
-- How far each parked skate stands from the middle.
ENT.ParkedSkateOffset = 3.6
-- Worn, the hull is the skater's body. It starts above the skates, so the legs carry them and only the body bumps into
-- things. Each ring is no wider than BODY_HULL_MAX_LEAN allows at its height, so leaning into a turn doesn't put the
-- hull's lower edge on the ground before the skater would fall anyway.
local BODY_HULL_MAX_LEAN = 75
local BODY_HULL_MAX_WIDTH_PER_HEIGHT = 1 / math.tan(math.rad(BODY_HULL_MAX_LEAN))

ENT.BodyHullRings = {
  { height = 8, halfLength = 6, halfWidth = 2 },
  { height = 26, halfLength = 8, halfWidth = 6 },
  { height = 64, halfLength = 9, halfWidth = 9 },
}

for _, ring in ipairs(ENT.BodyHullRings) do
  ring.halfWidth = math.min(ring.halfWidth, ring.height * BODY_HULL_MAX_WIDTH_PER_HEIGHT)
end

--- The corners of every ring of the body hull, entity-local.
--- @return Vector[]
function ENT:GetBodyHullVertices()
  local vertices = {}

  for _, ring in ipairs(self.BodyHullRings) do
    for _, corner in ipairs({ { 1, 1 }, { 1, -1 }, { -1, -1 }, { -1, 1 } }) do
      vertices[#vertices + 1] = Vector(corner[1] * ring.halfLength, corner[2] * ring.halfWidth, ring.height)
    end
  end

  return vertices
end

-- The bounds around the hull, such as for checking there's room to put the skates on.
ENT.BodyMins = Vector(0, 0, math.huge)
ENT.BodyMaxs = Vector(0, 0, -math.huge)

for _, ring in ipairs(ENT.BodyHullRings) do
  ENT.BodyMins = Vector(
    math.min(ENT.BodyMins.x, -ring.halfLength),
    math.min(ENT.BodyMins.y, -ring.halfWidth),
    math.min(ENT.BodyMins.z, ring.height)
  )
  ENT.BodyMaxs = Vector(
    math.max(ENT.BodyMaxs.x, ring.halfLength),
    math.max(ENT.BodyMaxs.y, ring.halfWidth),
    math.max(ENT.BodyMaxs.z, ring.height)
  )
end
-- The skater's legs are the suspension: the ground is traced for from this high above the soles, at heel and toe.
ENT.ContactRadius = 12
ENT.Contacts = {
  { position = Vector(-7, 0, 12) },
  { position = Vector(7, 0, 12) },
}

-- Defaults for what registered models set.
ENT.EmptyMass = 4
ENT.SpeedScale = 1
ENT.StanceWidth = 10
ENT.AnkleOffset = Vector(0, 0, 0)
ENT.ToeOffset = Vector(0, 0, 0)
ENT.AnklePosition = Vector(-3.2, 0, 10.2)
ENT.ToePosition = Vector(5, 0, 7)
ENT.CuffLean = 12
ENT.SkateModel = nil
ENT.SkateModelLeft = nil
ENT.SkateModelRight = nil
ENT.SkateBodygroups = nil
ENT.SkateBodygroupsLeft = nil
ENT.SkateBodygroupsRight = nil
ENT.SkatePaint = true
ENT.BrakeStyle = "heel"

-- Prisoner pods face their own +Y.
ENT.SeatAngles = Angle(0, -90, 0)
-- The skater's eye angles, which are relative to the seat, that look straight ahead.
ENT.SeatForwardEyeAngles = Angle(0, 90, 0)

-- What the skater is doing, networked as bits of PoseFlags for the client's animation.
ENT.POSE_FLAGS = {
  pushing = 1,
  sprinting = 2,
  braking = 4,
  tucking = 8,
  grounded = 16,
  pushingBackwards = 32,
  stepping = 64,
}

-- Below this the contact's own "down" has almost no length, meaning the skater is lying on their side.
local MIN_CONTACT_DOWN_LENGTH = 0.35
-- Contact traces start this far behind the leg's top, so one resting on the ground still hits it.
local CONTACT_TRACE_BACKOFF = 6
local CONTACT_TRACE_REACH_PAST = 8
-- The contact traces fan this far (deg) either side of the skater's down, so slopes and ramps ahead are found.
local CONTACT_TRACE_FAN_ANGLE = 45
local CONTACT_TRACE_FAN_COUNT = 7
-- Steeper surfaces (deg from the skater's up) are walls: they push the skates back but aren't skated on.
local MAX_GROUND_ANGLE = 60
local MIN_GROUND_NORMAL_UP = math.cos(math.rad(MAX_GROUND_ANGLE))
-- Walls only push back once this close, as a fraction of the contact radius, roughly where the skate's toe or heel is.
local WALL_REACH_FRACTION = 0.4
-- A wall whose top is below the contact is a step. The skates roll over its edge if it pushes them at most this
-- steeply (deg from the skater's up), which allows steps of about a wheel's height.
local MAX_STEP_EDGE_ANGLE = 40
local MIN_STEP_EDGE_NORMAL_UP = math.cos(math.rad(MAX_STEP_EDGE_ANGLE))
-- How far past a wall's face the step's top is looked for.
local STEP_PROBE_DEPTH = 2

function ENT:SetupDataTables()
  self:NetworkVar("Entity", "Seat")
  self:NetworkVar("Entity", "Rider")
  -- How far A / D are steered, -1 to 1, positive is right.
  self:NetworkVar("Float", "Steer")
  -- Strides per minute (each a push with both legs), negative skating backwards. Purely visual.
  self:NetworkVar("Float", "Cadence")
  -- Degrees, positive is right.
  self:NetworkVar("Float", "TargetLean")
  -- How hard the skates scrape from braking or sliding sideways, 0-1. Only drives the scrape sound.
  self:NetworkVar("Float", "Skid")
  -- How far a jump is charged by holding Space, 0-1. The skater crouches deeper.
  self:NetworkVar("Float", "Crouch")
  -- Bits of ENT.POSE_FLAGS.
  self:NetworkVar("Int", "PoseFlags")
  self:NetworkVar("Bool", "Crashed")
end

--- @param name string A key of ENT.POSE_FLAGS
--- @return boolean
function ENT:HasPoseFlag(name)
  return bit.band(self:GetPoseFlags(), self.POSE_FLAGS[name]) ~= 0
end

--- @return number # Degrees, positive is leaning right
function ENT:GetLean()
  -- Leaning right dips the skater's right side below the horizon.
  return -inlineSkates.getElevation(self:GetRight())
end

--- @return number # Speed along the skater's heading, negative when rolling backwards
function ENT:GetForwardSpeed()
  return self:GetVelocity():Dot(self:GetForward())
end

--- @return Entity[] # The skates, their seat and whoever wears them
function ENT:GetContactTraceFilter()
  local filter = { self }
  local seat, rider = self:GetSeat(), self:GetRider()

  if (IsValid(seat)) then
    filter[#filter + 1] = seat
  end

  if (IsValid(rider)) then
    filter[#filter + 1] = rider
  end

  return filter
end

--- @return table? # { distance, contactPosition, normal }, nil when the trace reaches nothing
local function traceContactRay(topPosition, direction, radius, filter)
  local reach = radius + CONTACT_TRACE_REACH_PAST
  local trace = util.TraceLine({
    start = topPosition - direction * CONTACT_TRACE_BACKOFF,
    endpos = topPosition + direction * reach,
    filter = filter,
    mask = MASK_SOLID,
  })

  if (not trace.Hit) then
    return nil
  end

  if (trace.StartSolid) then
    -- A trace starting inside the ground has no usable fraction or normal, so push straight back along it instead.
    return { distance = radius * 0.5, contactPosition = trace.HitPos, normal = -direction }
  end

  return {
    distance = trace.Fraction * (CONTACT_TRACE_BACKOFF + reach) - CONTACT_TRACE_BACKOFF,
    contactPosition = trace.HitPos,
    normal = trace.HitNormal,
  }
end

--- Retraces along the hit surface's normal within the skater's forward plane, which is exact on flat surfaces.
--- @return table # The closer of `hit` and the retrace
local function refineContactHit(hit, topPosition, right, up, radius, filter)
  local direction = right * hit.normal:Dot(right) - hit.normal
  local directionLength = direction:Length()

  if (directionLength < MIN_CONTACT_DOWN_LENGTH) then
    return hit
  end

  direction:Div(directionLength)

  local refined = traceContactRay(topPosition, direction, radius, filter)
  local isGround = hit.normal:Dot(up) >= MIN_GROUND_NORMAL_UP

  if (refined and refined.distance < hit.distance and (refined.normal:Dot(up) >= MIN_GROUND_NORMAL_UP) == isGround) then
    return refined
  end

  return hit
end

--- Looks for the top of the step a wall hit belongs to. The fan never hits the edge between a step's top and face, so
--- without this the skates would be pushed back by the face and never roll over it.
--- @return table? # { distance, contactPosition, normal, groundNormal } for the edge, with `normal` from the edge to
--- the contact's top and `groundNormal` the step's top. Nil when the wall is no step, or too tall to roll over.
local function findStepEdge(wall, topPosition, right, up, filter)
  local probe = wall.contactPosition - wall.normal * STEP_PROBE_DEPTH
  local topTrace = util.TraceLine({
    start = probe + up * (topPosition - probe):Dot(up),
    endpos = probe,
    filter = filter,
    mask = MASK_SOLID,
  })

  -- Starting in solid, the wall reaches past the contact's top.
  if (not topTrace.Hit or topTrace.StartSolid or topTrace.HitNormal:Dot(up) < MIN_GROUND_NORMAL_UP) then
    return nil
  end

  local edge = topTrace.HitPos + wall.normal * STEP_PROBE_DEPTH
  local offset = topPosition - edge
  offset:Sub(right * offset:Dot(right))

  local distance = offset:Length()

  if (distance < 1e-3) then
    return nil
  end

  offset:Div(distance)

  if (offset:Dot(up) < MIN_STEP_EDGE_NORMAL_UP) then
    return nil
  end

  return { distance = distance, contactPosition = edge, normal = offset, groundNormal = topTrace.HitNormal }
end

--- Finds the nearest ground and wall below and around a contact, so it stays correct while leaning or on slopes.
--- @param contactIndex number
--- @param filter? table Defaults to `ENT:GetContactTraceFilter()`
--- @param position? Vector Defaults to the skates' position
--- @param angles? Angle Defaults to the skates' angles
--- @return table # { topPosition, isHit, isGrounded, compression, contactPosition?, normal?, groundNormal?, wall? },
--- where `normal` is the way the ground pushes the skater and `groundNormal` the surface they skate on, which differ on
--- the edge of a step. `wall` is { topPosition, compression, contactPosition, normal } while the skates press against
--- one
function ENT:TraceContact(contactIndex, filter, position, angles)
  position = position or self:GetPos()
  angles = angles or self:GetAngles()
  filter = filter or self:GetContactTraceFilter()

  local radius = self.ContactRadius
  local topPosition = LocalToWorld(self.Contacts[contactIndex].position, angle_zero, position, angles)
  local contact = { topPosition = topPosition, isHit = false, isGrounded = false, compression = 0 }

  local forward, right, up = angles:Forward(), angles:Right(), angles:Up()

  -- How much of world down lies within the skater's forward plane.
  if (math.sqrt(1 - right.z * right.z) < MIN_CONTACT_DOWN_LENGTH) then
    return contact
  end

  local nearestGround, nearestWall

  for ray = 0, CONTACT_TRACE_FAN_COUNT - 1 do
    local fanAngle = math.rad(CONTACT_TRACE_FAN_ANGLE * (ray * 2 / (CONTACT_TRACE_FAN_COUNT - 1) - 1))
    local hit = traceContactRay(topPosition, forward * math.sin(fanAngle) - up * math.cos(fanAngle), radius, filter)

    if (hit) then
      if (hit.normal:Dot(up) >= MIN_GROUND_NORMAL_UP) then
        if (not nearestGround or hit.distance < nearestGround.distance) then
          nearestGround = hit
        end
      elseif (not nearestWall or hit.distance < nearestWall.distance) then
        nearestWall = hit
      end
    end
  end

  if (nearestGround) then
    nearestGround = refineContactHit(nearestGround, topPosition, right, up, radius, filter)
  end

  if (nearestWall) then
    nearestWall = refineContactHit(nearestWall, topPosition, right, up, radius, filter)

    local stepEdge = findStepEdge(nearestWall, topPosition, right, up, filter)

    -- The edge stands in for the step's face, so the skates roll up over it instead of being pushed back.
    if (stepEdge) then
      nearestWall = nil

      if (not nearestGround or stepEdge.distance < nearestGround.distance) then
        nearestGround = stepEdge
      end
    end
  end

  if (nearestGround) then
    contact.isHit = true
    contact.contactPosition = nearestGround.contactPosition
    contact.normal = nearestGround.normal
    contact.groundNormal = nearestGround.groundNormal or nearestGround.normal
    contact.compression = radius - nearestGround.distance
    contact.isGrounded = contact.compression > 0
  end

  local wallReach = radius * WALL_REACH_FRACTION

  if (nearestWall and nearestWall.distance < wallReach) then
    contact.wall = {
      topPosition = topPosition,
      compression = wallReach - nearestWall.distance,
      contactPosition = nearestWall.contactPosition,
      normal = nearestWall.normal,
    }
  end

  return contact
end
