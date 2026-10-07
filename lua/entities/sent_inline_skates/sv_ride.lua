-- The skating itself, simulated every physics tick while someone wears the skates.

-- A skater leaning further than this has no wheels on the ground at all.
local ON_SIDE_LEAN = 70

-- Caps on the leg springs, so a skater landing hard or stuck in the ground isn't launched.
local MAX_SUSPENSION_GRAVITIES = 10
local MAX_COMPRESSION_FRACTION = 0.5

-- Steering recentres faster than it turns in.
local STEER_RECENTER_SCALE = 1.6

-- Pushing power fades out over this last fraction of the top speed.
local PUSH_FADE_FRACTION = 0.3
-- Slower than this (u/s), forwards or backwards, the skater counts as standing: S then skates backwards instead of
-- braking, and W skates forwards instead of braking a backwards roll.
local STANDSTILL_SPEED = 15

-- Below this speed the heading follows the steering directly, instead of waiting for the lean.
local LEAN_LIMITED_TURN_MIN_SPEED = 30
local MAX_SUPPORTING_LEAN = 60
-- Turning on the spot fades out by this speed (u/s), where carving takes over.
local PIVOT_FADE_SPEED = 80

-- On the ground the body is kept square to it, at this gain (1/s), max speed (deg/s) and response (1/s). On top of
-- that it turns along as fast as the ground turns under it, up to the max (deg/s), such as through the curve at the
-- bottom of a quarter pipe, where it would otherwise fall behind and tip over its toes.
local GROUND_PITCH_GAIN = 8
local GROUND_PITCH_MAX_SPEED = 180
local GROUND_PITCH_RESPONSE = 12
local GROUND_TURN_MAX_SPEED = 720

-- Keys whose double-taps tricks can read, and how quickly the second press must follow the first (s).
local DOUBLE_TAP_KEYS = { [IN_FORWARD] = true, [IN_BACK] = true, [IN_MOVELEFT] = true, [IN_MOVERIGHT] = true }
local DOUBLE_TAP_WINDOW = 0.3

-- Jumping still works this long after rolling off an edge (s), so a jump off the lip of a ramp isn't lost.
local JUMP_GRACE_TIME = 0.15

-- Arcade-feel: in the air the skater is turned to land on their skates. Their path is followed ahead, at most this
-- far (s) in steps this long (s), to the ground they'll come down on, and they're stood square to it this long (s)
-- before they touch down: turning at least at the gain (1/s), at most at the max speed (deg/s), with the response
-- (1/s).
local LANDING_PREDICT_TIME = 2.4
local LANDING_PREDICT_STEP = 0.08
local LANDING_LEAD_TIME = 0.1
local LANDING_TILT_GAIN = 4
local LANDING_TILT_MAX_SPEED = 400
local LANDING_RESPONSE = 10
-- Ground steeper than this (deg) is a wall, which the skater isn't turned to land on: except back down the ramp of a
-- vert air, or ground they already face within this much, such as further up a quarter pipe they briefly left.
local MAX_LANDING_SLOPE = 70
local MIN_LANDING_NORMAL_UP = math.cos(math.rad(MAX_LANDING_SLOPE))
-- Not spinning, the skater also turns to face along their path, forwards or backwards, while facing within this (deg)
-- of it: at the gain (1/s) and max speed (deg/s). Slower than the min speed (u/s) they may face any way.
local LANDING_FACING_MAX_ANGLE = 60
local LANDING_FACING_GAIN = 4
local LANDING_FACING_MAX_SPEED = 180
local LANDING_FACING_MIN_SPEED = 60
-- Touching down after at least this long in the air (s), the skater stops tumbling and rolls the way they face.
local TOUCHDOWN_MIN_AIR_TIME = 0.2
-- How quickly the skater's pitch follows W / S in the air (1/s).
local AIR_CONTROL_RESPONSE = 10
-- Leaving ground at least this steep (deg) on the way up is a vert air, whichever way the skater heads up it: they
-- can't drift away from the ramp, so they come back down onto it.
local VERT_AIR_MIN_SLOPE = 60
-- A spine transfer is steered as if it lands at least this soon (s), so pressing late doesn't throw the skater across.
local MIN_TRANSFER_TIME = 0.1
-- How fast a spine transfer may tip the skater over the top (deg/s).
local MAX_TRANSFER_PITCH_SPEED = 720
-- A spine transfer sets the soles down this far (units) out from the ramp behind, and only starts once the skates can
-- move at least this far (units) over the top without hitting anything, so they're above it.
local TRANSFER_LANDING_GAP = 4
local TRANSFER_MIN_CLEARANCE = 16

-- The skater's path turns with the ground by at most this much per tick (deg), larger jumps aren't the same surface.
local MAX_GROUND_FOLLOW_ANGLE = 45
local MIN_GROUND_FOLLOW_COS = math.cos(math.rad(MAX_GROUND_FOLLOW_ANGLE))
-- Skates touching ground sloped this differently (deg) are on uneven ground, such as the foot of a ramp.
local UNEVEN_GROUND_ANGLE = 5
local UNEVEN_GROUND_COS = math.cos(math.rad(UNEVEN_GROUND_ANGLE))

-- Touchdowns are looked for along the skater's path, for ground they fall into at least this steeply (cosine of the
-- angle from its normal).
local MIN_TOUCHDOWN_APPROACH_COS = 0.3
-- Steeper surfaces (deg from the skater's up) are walls, which the skates don't land on.
local MAX_TOUCHDOWN_GROUND_ANGLE = 60
local MIN_TOUCHDOWN_GROUND_UP = math.cos(math.rad(MAX_TOUCHDOWN_GROUND_ANGLE))

-- In the air gravity won't let a skater stay slower than this (u/s) for long, so one that does is lying on their body.
-- They fall over once that's lasted this many times as long as falling takes to pass through that speed.
local RESTING_OFF_GROUND_SPEED = 50
local RESTING_OFF_GROUND_FALL_TIMES = 3
-- A body hull corner this close (units) above ground, with the skater tipped further from square to it than
-- inline_skates_crash_lean, which no turn leans them, means they lie on their body, such as on their face or after
-- landing a flip on their back. They fall over once that's lasted this long (s).
local BODY_ON_GROUND_CLEARANCE = 2
local BODY_ON_GROUND_TIME = 0.1
-- Ground under the body flatter than this (deg) counts, so a body brushing past a wall doesn't.
local BODY_ON_GROUND_MAX_SLOPE = 60
local BODY_ON_GROUND_MIN_NORMAL_UP = math.cos(math.rad(BODY_ON_GROUND_MAX_SLOPE))

-- Turning round on the ground with R: at this spin speed (deg/s), until half a turn round within this angle (deg),
-- giving up after the max time (s).
local TURN_AROUND_SPEED = 540
local TURN_AROUND_DONE_ANGLE = 8
local TURN_AROUND_DONE_COS = math.cos(math.rad(TURN_AROUND_DONE_ANGLE))
local TURN_AROUND_MAX_TIME = 1

-- Strides per minute: a base rate rising with speed, faster sprinting. Purely visual.
local BASE_CADENCE = 40
local CADENCE_PER_SPEED = 0.08
local SPRINT_CADENCE_SCALE = 1.3
local STEPPING_CADENCE = 70
local CADENCE_CHANGE_RATE = 200
-- Stepping round on the spot shows from this much steering, below this fraction of PIVOT_FADE_SPEED.
local STEPPING_MIN_STEER = 0.1
local STEPPING_MAX_SPEED_FRACTION = 0.5

local WATER_LEVEL_SUBMERGED = 3

-- Braking scrapes from this speed and is at its loudest from the full speed (u/s).
local BRAKE_SKID_MIN_SPEED = 40
local BRAKE_SKID_FULL_SPEED = 360
-- Sliding sideways scrapes from this side speed and is at its loudest from the full side speed (u/s).
local SLIDE_SKID_MIN_SPEED = 40
local SLIDE_SKID_FULL_SPEED = 250
-- These are networked in steps of this size, so they don't send a new value every tick.
local SKID_NETWORK_STEP = 0.05
local CROUCH_NETWORK_STEP = 0.05
local STEER_NETWORK_STEP = 0.02
local LEAN_NETWORK_STEP = 0.5

local function getGravity()
  local gravity = physenv.GetGravity():Length()

  return gravity > 1 and gravity or 600
end

--- How far to blend towards a target this tick, independent of the tick rate.
local function getBlendFraction(rate, deltaTime)
  return 1 - math.exp(-rate * deltaTime)
end

local function projectOntoPlane(direction, normal)
  local projected = direction - normal * direction:Dot(normal)
  projected:Normalize()

  return projected
end

local function roundToStep(value, step)
  return math.Round(value / step) * step
end

--- The contact traces go straight through water, so without this a skater would skate along the bottom as if it were
--- dry.
--- @return boolean
function ENT:IsTooDeepToRide()
  local maxWaterLevel = inlineSkates.getTuning("water_level")

  return maxWaterLevel > 0 and self:WaterLevel() >= maxWaterLevel
end

--- Called for each key the skater presses, as their command is run. `CurTime` is then the skater's own time, so lag
--- doesn't change the double-tap window. A triple tap counts once.
--- @param key number IN_ key
function ENT:OnRiderKeyPress(key)
  if (not DOUBLE_TAP_KEYS[key]) then
    return
  end

  local now = CurTime()
  local pressedAt = self.tapPressedAt[key]

  if (pressedAt and now - pressedAt <= DOUBLE_TAP_WINDOW) then
    self.pendingDoubleTaps[key] = true
    self.tapPressedAt[key] = nil
  else
    self.tapPressedAt[key] = now
  end
end

--- @return table<number, boolean> # The DOUBLE_TAP_KEYS double-tapped since the last call
function ENT:ReadDoubleTaps()
  local doubleTaps = self.pendingDoubleTaps

  self.pendingDoubleTaps = {}

  return doubleTaps
end

--- The "InlineSkatesReadInput" hook can add or change fields, which tricks then read.
--- @param rider Player
--- @return table
function ENT:ReadRiderInput(rider)
  local isJumpHeld = rider:KeyDown(IN_JUMP)
  local isJumpReleased = self.wasJumpHeld and not isJumpHeld
  self.wasJumpHeld = isJumpHeld

  local isTurnHeld = rider:KeyDown(IN_RELOAD)
  local isTurnPressed = isTurnHeld and not self.wasTurnHeld
  self.wasTurnHeld = isTurnHeld

  -- The key that put the skates on doesn't jump until it's been let go of.
  if (self.isJumpBlocked) then
    self.isJumpBlocked = isJumpHeld
    isJumpHeld, isJumpReleased = false, false
  end

  local input = {
    isPushHeld = rider:KeyDown(IN_FORWARD),
    isBrakeHeld = rider:KeyDown(IN_BACK),
    steerDirection = (rider:KeyDown(IN_MOVERIGHT) and 1 or 0) - (rider:KeyDown(IN_MOVELEFT) and 1 or 0),
    isSprintHeld = rider:KeyDown(IN_SPEED),
    -- Holding Space charges a jump, letting go jumps.
    isJumpHeld = isJumpHeld,
    isJumpReleased = isJumpReleased,
    isTuckHeld = rider:KeyDown(IN_DUCK),
    isGrabHeld = rider:KeyDown(IN_ATTACK2),
    isAltGrabHeld = rider:KeyDown(IN_ATTACK),
    -- Turns round on the ground, from forwards to backwards or back.
    isTurnPressed = isTurnPressed,
    -- IN_ keys double-tapped this tick.
    doubleTaps = self:ReadDoubleTaps(),
  }

  hook.Run("InlineSkatesReadInput", rider, self, input)

  return input
end

--- Clears what the input remembers between ticks while nobody wears the skates.
function ENT:ResetRiderInput()
  self.wasJumpHeld = false
  self.wasTurnHeld = false
  self.jumpCharge = 0
  self.tapPressedAt = {}
  self.pendingDoubleTaps = {}
end

--- Everything the ride needs to know about the skater this tick, before any forces are applied.
--- @return table
function ENT:MeasureRide(physics)
  local angles = physics:GetAngles()
  local forward, right = angles:Forward(), angles:Right()
  -- Against the ground skated on last, or the ramp of a vert air, so skating up a quarter pipe at an angle doesn't read
  -- as leaning over.
  local groundUp = self.lastGroundNormal or (self.vertAir and self.vertAir.away) or vector_up
  local lean = -math.deg(math.asin(math.Clamp(right:Dot(groundUp), -1, 1)))
  local isCrashed = self:GetCrashed()
  local isOnSide = math.abs(lean) > ON_SIDE_LEAN

  return {
    position = physics:GetPos(),
    angles = angles,
    forward = forward,
    right = right,
    -- Degrees from square to the ground, positive is leaning right
    lean = lean,
    -- Degrees, positive is leaning back (toes up)
    pitch = inlineSkates.getElevation(forward),
    velocity = physics:GetVelocity(),
    -- World space, deg/s
    angularVelocity = physics:LocalToWorldVector(physics:GetAngleVelocity()),
    mass = physics:GetMass(),
    massCenter = physics:GetMassCenter(),
    massCenterPosition = physics:LocalToWorld(physics:GetMassCenter()),
    gravity = getGravity(),
    gravityVector = physenv.GetGravity(),
    -- How far the skates are under water, 0-1
    waterFraction = self:WaterLevel() / WATER_LEVEL_SUBMERGED,
    isCrashed = isCrashed,
    isOnSide = isOnSide,
    -- A trick turning the skater over, such as a spin up a quarter pipe, may lie them on their side for a moment.
    isControlled = not isCrashed and not self.isPhysgunHeld and (not isOnSide or self.isRotatingSkater == true),
  }
end

--- While balanced, the legs push on the line through the centre of mass (pitch only, no roll torque), so the lean
--- controller never fights gravity. Uncontrolled, they push at the contact point and the skater falls naturally.
--- @param isWall boolean Whether `contact` is a wall the skates press against, rather than ground
function ENT:ApplyLegSpring(physics, ride, leg, contact, deltaTime, isWall)
  local normal = contact.normal
  local compression = math.min(contact.compression, self.ContactRadius * MAX_COMPRESSION_FRACTION)
  local compressionSpeed = -physics:GetVelocityAtPoint(contact.topPosition):Dot(normal)
  local acceleration = inlineSkates.getTuning("spring") * compression
      + inlineSkates.getTuning("damper") * compressionSpeed

  -- Legs can only push the skater away from the ground, never pull them down.
  if (acceleration <= 0) then
    return
  end

  acceleration = math.min(acceleration, ride.gravity * MAX_SUSPENSION_GRAVITIES)

  local forcePosition = contact.contactPosition
  local force = normal * (acceleration * ride.mass * deltaTime)

  -- Arcade-feel: ground never holds the skater back along their heading, such as at the foot of a ramp.
  if (ride.isControlled and not isWall) then
    force:Sub(ride.forwardAlongGround * force:Dot(ride.forwardAlongGround))
  end

  if (ride.isControlled) then
    forcePosition = physics:LocalToWorld(Vector(leg.position.x, ride.massCenter.y, ride.massCenter.z))

    -- Only the part along the shared ground normal pushes there. Where the skates touch differently sloped ground the
    -- rest would slowly turn the skater, so it pushes through the centre of mass instead.
    local support = ride.groundNormal * force:Dot(ride.groundNormal)

    physics:ApplyForceCenter(force - support)
    force = support
  end

  physics:ApplyForceOffset(force, forcePosition)
end

--- Springs each grounded contact and adds what the skates touch to `ride`: the ground normal, which contacts are down
--- and the skater's heading and speed along the ground. All contacts are traced before any is sprung, since the
--- springs need the shared ground normal. Rolling fast into a wall too tall to roll over trips the skater.
function ENT:ApplyLegSuspension(physics, ride, deltaTime)
  local groundNormalSum = Vector(0, 0, 0)
  local groundedContacts = {}
  local wallContacts = {}

  ride.groundedCount = 0

  if (not ride.isOnSide or ride.isControlled) then
    local filter = self:GetContactTraceFilter()

    for index in ipairs(self.Contacts) do
      local contact = self:TraceContact(index, filter, ride.position, ride.angles)

      if (contact.isGrounded) then
        ride.groundedCount = ride.groundedCount + 1

        -- On a step's edge the skater rolls onto the step's top instead of being steered up the edge like a ramp.
        groundNormalSum:Add(contact.groundNormal)
        groundedContacts[index] = contact
      end

      wallContacts[index] = contact.wall
    end
  end

  ride.groundNormal = ride.groundedCount > 0 and groundNormalSum:GetNormalized() or vector_up
  ride.groundContactPosition = nil

  if (ride.groundedCount > 0) then
    local contactPositionSum = Vector(0, 0, 0)

    for _, contact in pairs(groundedContacts) do
      contactPositionSum:Add(contact.contactPosition)
    end

    ride.groundContactPosition = contactPositionSum / ride.groundedCount
  end

  ride.forwardAlongGround = projectOntoPlane(ride.forward, ride.groundNormal)
  ride.sideAlongGround = projectOntoPlane(ride.right, ride.groundNormal)
  ride.isGroundUneven = false

  for _, contact in pairs(groundedContacts) do
    if (contact.normal:Dot(ride.groundNormal) < UNEVEN_GROUND_COS) then
      ride.isGroundUneven = true
    end
  end

  self:FollowGround(physics, ride, deltaTime)
  self:CushionTouchdown(physics, ride, deltaTime)

  for index, contact in pairs(groundedContacts) do
    self:ApplyLegSpring(physics, ride, self.Contacts[index], contact, deltaTime, false)
  end

  local tripSpeed = inlineSkates.getTuning("trip_speed")

  for index, contact in pairs(wallContacts) do
    if (not ride.isCrashed and not self.isPhysgunHeld and -ride.velocity:Dot(contact.normal) > tripSpeed) then
      self.hasPendingCrash = true
    end

    self:ApplyLegSpring(physics, ride, self.Contacts[index], contact, deltaTime, true)
  end

  ride.groundedFraction = ride.groundedCount / #self.Contacts
  ride.speed = ride.velocity:Dot(ride.forwardAlongGround)
  ride.absoluteSpeed = math.abs(ride.speed)
end

--- Arcade-feel: while grounded, the skater's path turns as the ground does, so they roll into a ramp or quarter pipe
--- instead of losing their speed against it. Only into the ground, so they can still fly off a crest.
function ENT:FollowGround(physics, ride, deltaTime)
  local previousNormal = self.lastGroundNormal
  local normal = ride.groundNormal

  self.lastGroundNormal = (ride.isControlled and ride.groundedCount > 0) and normal or nil
  -- How fast the ground turns under the skater, as an angular velocity in world space (deg/s).
  ride.groundTurnVelocity = Vector(0, 0, 0)

  if (previousNormal and self.lastGroundNormal) then
    local turnAxis = previousNormal:Cross(normal)
    local turnSine = turnAxis:Length()

    if (turnSine > 1e-4) then
      local turnAngle = math.deg(math.atan2(turnSine, previousNormal:Dot(normal)))

      ride.groundTurnVelocity = turnAxis * (turnAngle / turnSine / deltaTime)
    end
  end

  if (not previousNormal or not self.lastGroundNormal or ride.velocity:Dot(normal) >= 0) then
    return
  end

  local axis = previousNormal:Cross(normal)
  local sine = axis:Length()
  local cosine = previousNormal:Dot(normal)

  if (sine < 1e-4 or cosine < MIN_GROUND_FOLLOW_COS) then
    return
  end

  axis:Div(sine)

  -- Rodrigues' rotation by the same turn as the ground's.
  local velocity = ride.velocity
  local turned = velocity * cosine + axis:Cross(velocity) * sine + axis * (axis:Dot(velocity) * (1 - cosine))

  physics:AddVelocity(turned - velocity)
  ride.velocity = turned
end

--- @return Vector?, number? # The normal of the ground `leg` lands on along `direction`, and how far its contact is
--- from touching it. Nil when there is no ground within `reach`.
function ENT:TraceTouchdown(ride, leg, filter, direction, reach)
  local topPosition = LocalToWorld(leg.position, angle_zero, ride.position, ride.angles)
  local trace = util.TraceLine({
    start = topPosition,
    endpos = topPosition + direction * reach,
    filter = filter,
    mask = MASK_SOLID,
  })

  if (not trace.Hit or trace.StartSolid or trace.HitNormal:Dot(ride.angles:Up()) < MIN_TOUCHDOWN_GROUND_UP) then
    return nil
  end

  return trace.HitNormal, (topPosition - trace.HitPos):Dot(trace.HitNormal) - self.ContactRadius
end

--- Slows a skater falling onto the ground to what the legs can absorb, the tick before they touch down. Landings too
--- hard for that are left alone, and knock the skater over once they land.
function ENT:CushionTouchdown(physics, ride, deltaTime)
  local speed = ride.velocity:Length()

  if (ride.groundedCount > 0 or not ride.isControlled or speed < 1) then
    return
  end

  local direction = ride.velocity / speed
  local reach = (self.ContactRadius + speed * deltaTime) / MIN_TOUCHDOWN_APPROACH_COS
  local filter = self:GetContactTraceFilter()
  -- Damping alone stops a leg within speed / damping, so this is the fastest it stops before the body touches down.
  local maxTouchdownSpeed = inlineSkates.getTuning("damper") * self.BodyMins.z
  local landCrashSpeed = inlineSkates.getTuning("land_crash_speed")
  local cushionNormal, cushionSpeed = nil, 0

  for _, leg in ipairs(self.Contacts) do
    local normal, gap = self:TraceTouchdown(ride, leg, filter, direction, reach)

    if (normal) then
      local approachSpeed = -ride.velocity:Dot(normal)
      -- Only slowed once it would otherwise reach the ground this tick, so it doesn't stop short in mid-air.
      local wantedSpeed = math.max(maxTouchdownSpeed, (gap - maxTouchdownSpeed * deltaTime) / deltaTime)

      if (approachSpeed - wantedSpeed > cushionSpeed and approachSpeed <= landCrashSpeed) then
        cushionNormal, cushionSpeed = normal, approachSpeed - wantedSpeed
      end
    end
  end

  if (cushionNormal) then
    local speedChange = cushionNormal * cushionSpeed

    physics:AddVelocity(speedChange)
    ride.velocity = ride.velocity + speedChange
  end
end

--- @return number # How far steered, -1 to 1, positive is right
function ENT:UpdateSteering(steerDirection, deltaTime)
  local steerRate = inlineSkates.getTuning("steer_rate")

  if (steerDirection == 0) then
    steerRate = steerRate * STEER_RECENTER_SCALE
  end

  self.steerFraction = math.Approach(self.steerFraction, steerDirection, steerRate * deltaTime)

  return self.steerFraction
end

--- The faster the skater goes, the wider a full steer turns, from turn_radius_slow to turn_radius_fast between
--- turn_slow_speed and turn_fast_speed. Standing still, they step round on the spot instead. D always turns the skater
--- right, whether skating forwards or backwards.
--- @return number yawRate Radians per second, positive is right
--- @return boolean isPivoting Whether turning on the spot turns faster than carving would
function ENT:GetSteeredYawRate(ride)
  local slowSpeed = inlineSkates.getTuning("turn_slow_speed")
  -- The speeds can be set equal or the wrong way around.
  local narrowingRange = math.max(inlineSkates.getTuning("turn_fast_speed") - slowSpeed, 1)
  local narrowingFraction = math.Clamp((ride.absoluteSpeed - slowSpeed) / narrowingRange, 0, 1)
  local radius = math.max(
    Lerp(narrowingFraction, inlineSkates.getTuning("turn_radius_slow"), inlineSkates.getTuning("turn_radius_fast")),
    1
  )
  local yawRate = ride.absoluteSpeed * self.steerFraction / radius
  local pivotFraction = 1 - math.Clamp(ride.absoluteSpeed / PIVOT_FADE_SPEED, 0, 1)
  local pivotRate = math.rad(inlineSkates.getTuning("pivot_turn_speed")) * self.steerFraction * pivotFraction

  if (math.abs(pivotRate) > math.abs(yawRate)) then
    return pivotRate, true
  end

  return yawRate, false
end

--- Like static friction: brings `speed` to a standstill this tick and holds it there against `slopeAcceleration` (the
--- gravity pulling along that direction), but never pushes harder than `maxAcceleration` or past a standstill.
--- @return number # Acceleration to apply (u/s^2)
local function getHoldingAcceleration(speed, slopeAcceleration, maxAcceleration, deltaTime)
  return math.Clamp(-speed / deltaTime - slopeAcceleration, -maxAcceleration, maxAcceleration)
end

--- @param state table What the skater does
function ENT:ApplyPushAndBrake(physics, ride, input, state, deltaTime)
  local speed = ride.speed
  -- Without holding against this, gravity would creep the skater down even a slight slope while braking.
  local slopeAcceleration = ride.gravityVector:Dot(ride.forwardAlongGround)
  local acceleration = 0

  if (state.isPushing) then
    local topSpeedName = input.isSprintHeld and "sprint_speed" or "top_speed"
    local topSpeed = inlineSkates.getTuning(topSpeedName) * self.SpeedScale
    local pushAcceleration = inlineSkates.getTuning("push_accel")
        * (input.isSprintHeld and inlineSkates.getTuning("sprint_accel") or 1)

    acceleration = acceleration
        + pushAcceleration * math.Clamp((topSpeed - speed) / math.max(topSpeed * PUSH_FADE_FRACTION, 1), 0, 1)
  elseif (state.isPushingBackwards) then
    local topSpeed = inlineSkates.getTuning("backwards_speed") * self.SpeedScale

    acceleration = acceleration - inlineSkates.getTuning("backwards_accel")
        * math.Clamp((topSpeed + speed) / math.max(topSpeed * PUSH_FADE_FRACTION, 1), 0, 1)
  end

  if (state.isBraking) then
    acceleration = acceleration + getHoldingAcceleration(
      speed,
      slopeAcceleration,
      inlineSkates.getTuning("brake_accel") * ride.groundedFraction,
      deltaTime
    )
  elseif (not state.isPushing and not state.isPushingBackwards) then
    local drag = inlineSkates.getTuning("drag") * (state.isTucking and inlineSkates.getTuning("tuck_drag") or 1)

    -- Rolling resistance holds the skater on slopes too gentle to overcome it, steeper ones roll them down.
    acceleration = acceleration + getHoldingAcceleration(
      speed,
      slopeAcceleration,
      inlineSkates.getTuning("rolling") * ride.groundedFraction + drag * speed * speed,
      deltaTime
    )
  end

  -- Wading slows the skater whatever they do. Taking a fraction of the speed never turns them around.
  local newSpeed = speed + acceleration * deltaTime
  local waterSlowdown = newSpeed
      * getBlendFraction(inlineSkates.getTuning("water_drag") * ride.waterFraction, deltaTime)

  physics:AddVelocity(ride.forwardAlongGround * (newSpeed - waterSlowdown - speed))
end

--- Holding Space crouches, charging the jump, and letting go jumps: higher the longer it was held. Jumps off the ground
--- along its normal, so a jump off a ramp leaves square to the ramp.
function ENT:UpdateJump(physics, ride, input, deltaTime)
  if (ride.groundedCount > 0) then
    self.lastGroundedAt = CurTime()
    self.jumpNormal = ride.groundNormal
  end

  local canJump = CurTime() - self.lastGroundedAt <= JUMP_GRACE_TIME and CurTime() >= self.nextJumpAt

  if (input.isJumpHeld) then
    if (canJump) then
      self.jumpCharge = math.min(
        self.jumpCharge + deltaTime / math.max(inlineSkates.getTuning("jump_charge_time"), 0.01),
        1
      )
    end

    return
  end

  local charge = self.jumpCharge
  self.jumpCharge = 0

  if (not input.isJumpReleased or not canJump) then
    return
  end

  self.nextJumpAt = CurTime() + inlineSkates.getTuning("jump_cooldown")
  -- No more grace once jumped, or a jump off an edge could be followed by a second one.
  self.lastGroundedAt = 0

  local normal = self.jumpNormal
  local jumpSpeed = Lerp(charge, inlineSkates.getTuning("jump_min"), inlineSkates.getTuning("jump_max"))
  -- Any speed into the ground, such as rolling down a slope, is cancelled so every jump is as high.
  local intoGround = math.min(ride.velocity:Dot(normal), 0)

  physics:AddVelocity(normal * (jumpSpeed - intoGround))
end

--- Removes sideways slip and holds the skater against gravity pulling them sideways down a slope, but never harder
--- than the wheels' friction allows, so the skates can still slide.
function ENT:ApplyWheelGrip(physics, ride, deltaTime)
  local sideSpeed = ride.velocity:Dot(ride.sideAlongGround)

  ride.sideSpeed = sideSpeed

  -- Turning round, the skates pivot on their wheels and keep the skater's speed.
  if (self.turnAround) then
    return
  end

  local slopeSpeedChange = ride.gravityVector:Dot(ride.sideAlongGround) * deltaTime
  local maxSpeedChange = inlineSkates.getTuning("mu") * ride.gravity * ride.groundedFraction * deltaTime
  local speedChange = math.Clamp(
    -sideSpeed * getBlendFraction(inlineSkates.getTuning("grip"), deltaTime) - slopeSpeedChange,
    -maxSpeedChange,
    maxSpeedChange
  )

  physics:AddVelocity(ride.sideAlongGround * speedChange)
end

--- @return number # How hard the skates scrape, 0-1
function ENT:GetSkidAmount(ride, state)
  if (ride.groundedCount == 0 or self.turnAround) then
    return 0
  end

  local slideSkid = math.Clamp(
    (math.abs(ride.sideSpeed or 0) - SLIDE_SKID_MIN_SPEED) / (SLIDE_SKID_FULL_SPEED - SLIDE_SKID_MIN_SPEED),
    0,
    1
  )
  local brakeSkid = 0

  if (state.isBraking) then
    brakeSkid = math.Clamp(
      (ride.absoluteSpeed - BRAKE_SKID_MIN_SPEED) / (BRAKE_SKID_FULL_SPEED - BRAKE_SKID_MIN_SPEED),
      0,
      1
    )
  end

  return math.max(slideSkid, brakeSkid)
end

--- Turns the skater half a turn round on the ground when they press R, keeping their speed: from forwards to
--- backwards or back. Landing backwards, such as off a 180, keeps skating backwards until they do.
function ENT:UpdateTurnAround(ride, input)
  if (ride.groundedCount == 0 or not ride.isControlled) then
    self.turnAround = nil
    return
  end

  local turnAround = self.turnAround

  if (turnAround) then
    local isDone = ride.forwardAlongGround:Dot(turnAround.startForward) < -TURN_AROUND_DONE_COS

    if (isDone or CurTime() > turnAround.endsAt) then
      self.turnAround = nil
    end

    return
  end

  -- Turns the way the skater steers, or else to the left.
  if (input.isTurnPressed) then
    self.turnAround = {
      direction = input.steerDirection > 0 and -1 or 1,
      startForward = ride.forwardAlongGround,
      endsAt = CurTime() + TURN_AROUND_MAX_TIME,
    }
  end
end

--- Only turns as hard as the current lean supports (plus inline_skates_lean_slack), so the skater leans in first and
--- then carves.
--- @return Vector # Angular velocity correction in world space, deg/s
function ENT:GetHeadingCorrection(ride, steeredYawRate, lateralAcceleration, isPivoting, deltaTime)
  if (ride.groundedCount == 0) then
    return Vector(0, 0, 0)
  end

  -- Around the ground normal, where positive turns left.
  local currentYawSpeed = ride.angularVelocity:Dot(ride.groundNormal)
  local wantedYawSpeed

  if (self.turnAround) then
    wantedYawSpeed = self.turnAround.direction * TURN_AROUND_SPEED
  else
    local yawRate = steeredYawRate

    if (not isPivoting and ride.absoluteSpeed > LEAN_LIMITED_TURN_MIN_SPEED) then
      local turnDirection = lateralAcceleration >= 0 and 1 or -1
      local leanIntoTurn = math.Clamp(ride.lean * turnDirection, 0, MAX_SUPPORTING_LEAN)
      local supportedAcceleration = ride.gravity * math.tan(math.rad(leanIntoTurn))
          + inlineSkates.getTuning("lean_slack")

      yawRate = turnDirection * math.min(math.abs(lateralAcceleration), supportedAcceleration) / ride.speed
    end

    wantedYawSpeed = -math.deg(yawRate)
  end

  local blend = getBlendFraction(inlineSkates.getTuning("yaw_response"), deltaTime)

  return ride.groundNormal * ((wantedYawSpeed - currentYawSpeed) * blend)
end

--- A P controller on the lean angle picks a roll speed, which the skater's actual roll is then blended towards.
--- @return Vector # Angular velocity correction in world space, deg/s
function ENT:GetLeanCorrection(ride, targetLean, deltaTime)
  local maxRollSpeed = inlineSkates.getTuning("lean_rate")
  local wantedRollSpeed = math.Clamp(
    (targetLean - ride.lean) * inlineSkates.getTuning("lean_p"),
    -maxRollSpeed,
    maxRollSpeed
  )
  local currentRollSpeed = ride.angularVelocity:Dot(ride.forward)
  local blend = getBlendFraction(inlineSkates.getTuning("lean_response"), deltaTime)

  return ride.forward * ((wantedRollSpeed - currentRollSpeed) * blend)
end

--- Keeps the body square to the ground front to back: the skater's ankles and knees do that, the two contacts alone
--- are too close together to.
--- @return Vector # Angular velocity correction in world space, deg/s
function ENT:GetGroundPitchCorrection(ride, deltaTime)
  -- Positive while the body leans back from square to the ground, which pitching forward corrects.
  local pitchError = math.deg(math.asin(math.Clamp(ride.forward:Dot(ride.groundNormal), -1, 1)))
  -- Pitched around the right along the ground, not the skater's own right: leaned into a turn, that tilts towards the
  -- ground normal, so turning would read as pitching and be cancelled. Positive tips the toes up, leaning back.
  local pitchAxis = ride.sideAlongGround
  local groundTurnSpeed = math.Clamp(
    ride.groundTurnVelocity:Dot(pitchAxis),
    -GROUND_TURN_MAX_SPEED,
    GROUND_TURN_MAX_SPEED
  )
  local wantedPitchSpeed = groundTurnSpeed
      + math.Clamp(-pitchError * GROUND_PITCH_GAIN, -GROUND_PITCH_MAX_SPEED, GROUND_PITCH_MAX_SPEED)
  local currentPitchSpeed = ride.angularVelocity:Dot(pitchAxis)

  return pitchAxis * ((wantedPitchSpeed - currentPitchSpeed) * getBlendFraction(GROUND_PITCH_RESPONSE, deltaTime))
end

--- Keys already held when the skater leaves the ground, such as pushing off a jump, keep skating as before and only
--- tip the skater in the air once pressed again. Adds `airPitchDirection` to `ride`: 1 tips the toes up, leaning back,
--- -1 tips forward.
function ENT:ReadAirControls(ride, input)
  local heldSinceTakeoff = self.airKeysHeldSinceTakeoff

  if (ride.groundedCount > 0) then
    heldSinceTakeoff.isPushHeld = input.isPushHeld
    heldSinceTakeoff.isBrakeHeld = input.isBrakeHeld
    ride.airPitchDirection = 0

    return
  end

  heldSinceTakeoff.isPushHeld = heldSinceTakeoff.isPushHeld and input.isPushHeld
  heldSinceTakeoff.isBrakeHeld = heldSinceTakeoff.isBrakeHeld and input.isBrakeHeld

  if (inlineSkates.getTuning("air_pitch_speed") <= 0) then
    ride.airPitchDirection = 0
  else
    ride.airPitchDirection = ((input.isBrakeHeld and not heldSinceTakeoff.isBrakeHeld) and 1 or 0)
        - ((input.isPushHeld and not heldSinceTakeoff.isPushHeld) and 1 or 0)
  end
end

--- @return Vector # How fast the skater's soles move, which their spin adds to as the centre of mass is higher up
local function getSoleVelocity(ride)
  return ride.velocity + (ride.angularVelocity * math.rad(1)):Cross(ride.position - ride.massCenterPosition)
end

--- @return number # Seconds until the skater's soles fall back to `height`, at least MIN_TRANSFER_TIME
local function getTimeToFallTo(ride, height)
  local verticalSpeed = getSoleVelocity(ride).z
  local rise = ride.position.z - height
  local fallTime = (verticalSpeed + math.sqrt(math.max(verticalSpeed * verticalSpeed + 2 * ride.gravity * rise, 0)))
      / ride.gravity

  return math.max(fallTime, MIN_TRANSFER_TIME)
end

--- Follows the skater's path ahead to where they'll touch down. In a vert air that's back down the ramp they went up,
--- or down the one behind it in a spine transfer.
--- @return Vector, number # The normal of the ground they'll land on, straight up when there's none ahead or it's a
--- wall, and how long until they do (s)
function ENT:PredictLanding(ride)
  local vertAir = self.vertAir

  if (vertAir) then
    local timeLeft = getTimeToFallTo(ride, vertAir.takeoffHeight)

    if (vertAir.isTransferring) then
      -- As steep as the ramp they went up, facing the other way.
      return Vector(-vertAir.rampNormal.x, -vertAir.rampNormal.y, vertAir.rampNormal.z), timeLeft
    end

    return vertAir.away, timeLeft
  end

  local filter = self:GetContactTraceFilter()
  local gravity = ride.gravityVector
  local position = ride.position

  for step = 1, math.ceil(LANDING_PREDICT_TIME / LANDING_PREDICT_STEP) do
    local time = step * LANDING_PREDICT_STEP
    local nextPosition = ride.position + ride.velocity * time + gravity * (0.5 * time * time)
    local trace = util.TraceLine({ start = position, endpos = nextPosition, filter = filter, mask = MASK_SOLID })

    if (trace.Hit and not trace.StartSolid) then
      local landingTime = time - LANDING_PREDICT_STEP * (1 - trace.Fraction)

      local normal = trace.HitNormal

      if (normal.z < MIN_LANDING_NORMAL_UP and normal:Dot(ride.angles:Up()) < MIN_LANDING_NORMAL_UP) then
        return vector_up, landingTime
      end

      return normal, landingTime
    end

    position = nextPosition
  end

  return vector_up, LANDING_PREDICT_TIME
end

--- Turns the skater around their own up to face along their path over the ground they'll land on, forwards or
--- backwards, so they don't touch down sideways.
--- @return Vector # Angular velocity correction in world space, deg/s
function ENT:GetLandingFacingCorrection(ride, landingNormal, blend)
  local alongGround = ride.velocity - landingNormal * ride.velocity:Dot(landingNormal)
  local speed = alongGround:Length()
  local heading = ride.forward - landingNormal * ride.forward:Dot(landingNormal)

  if (speed < LANDING_FACING_MIN_SPEED or heading:LengthSqr() < 1e-4) then
    return Vector(0, 0, 0)
  end

  heading:Normalize()

  local path = alongGround / speed

  if (heading:Dot(path) < 0) then
    path = -path
  end

  -- Positive turns left.
  local angle = math.deg(math.atan2(heading:Cross(path):Dot(landingNormal), heading:Dot(path)))

  if (math.abs(angle) > LANDING_FACING_MAX_ANGLE) then
    return Vector(0, 0, 0)
  end

  local up = ride.angles:Up()
  local wantedTurnSpeed = math.Clamp(angle * LANDING_FACING_GAIN, -LANDING_FACING_MAX_SPEED, LANDING_FACING_MAX_SPEED)

  return up * ((wantedTurnSpeed - ride.angularVelocity:Dot(up)) * blend)
end

--- W / S tip the skater forward and back in the air.
--- @return Vector # Angular velocity correction in world space, deg/s
local function getAirPitchControlCorrection(ride, deltaTime)
  local wantedPitchSpeed = ride.airPitchDirection * inlineSkates.getTuning("air_pitch_speed")
  local currentPitchSpeed = ride.angularVelocity:Dot(ride.right)

  return ride.right * ((wantedPitchSpeed - currentPitchSpeed) * getBlendFraction(AIR_CONTROL_RESPONSE, deltaTime))
end

--- Arcade-feel, with inline_skates_landing_assist: turns the skater in the air so they come down square on their
--- skates on the ground ahead, facing along their path. A flip keeps its own pitch, and W / S tip the skater forward
--- and back instead, such as to straighten up after one. Without the assist, the air is left to physics and W / S.
--- @return Vector # Angular velocity correction in world space, deg/s
function ENT:GetLandingCorrection(ride, deltaTime)
  local isPitchControlled = not self.isFlippingSkater and ride.airPitchDirection ~= 0

  if (not inlineSkates.getTuningBool("landing_assist")) then
    return isPitchControlled and getAirPitchControlCorrection(ride, deltaTime) or Vector(0, 0, 0)
  end

  local landingNormal, landingTime = self:PredictLanding(ride)
  local blend = getBlendFraction(LANDING_RESPONSE, deltaTime)
  local up = ride.angles:Up()
  local angularVelocity = ride.angularVelocity
  local axis = up:Cross(landingNormal)
  local sine = axis:Length()
  local tilt = math.deg(math.atan2(sine, up:Dot(landingNormal)))

  if (sine > 1e-4) then
    axis:Div(sine)
  elseif (tilt > 90) then
    -- Upside down any way round is as good, over the toes or heels like a flip.
    axis = ride.right
  end

  local timeLeft = math.max(landingTime - LANDING_LEAD_TIME, deltaTime)
  local tiltSpeed = math.min(math.max(tilt * LANDING_TILT_GAIN, tilt / timeLeft), LANDING_TILT_MAX_SPEED)
  -- Only the tilt: turning around the skater's own up is left to spins and the facing.
  local currentTiltVelocity = angularVelocity - up * angularVelocity:Dot(up)
  local correction = (axis * tiltSpeed - currentTiltVelocity) * blend

  if (self.isFlippingSkater or isPitchControlled) then
    correction:Sub(ride.right * correction:Dot(ride.right))
  end

  if (isPitchControlled) then
    correction:Add(getAirPitchControlCorrection(ride, deltaTime))
  end

  if (not self.isSpinningSkater) then
    correction:Add(self:GetLandingFacingCorrection(ride, landingNormal, blend))
  end

  return correction
end

--- Tips the skater over the top of a spine, to come down the ramp behind it as steeply as they went up this one by the
--- time they land there.
--- @return Vector # Angular velocity correction in world space, deg/s
function ENT:GetTransferCorrection(ride, vertAir, deltaTime)
  local up = ride.angles:Up()
  -- Turning around this tips the skater's up from out of the ramp, through straight up, to out of the ramp behind.
  local axis = vertAir.transferAxis
  local landingNormal = self:PredictLanding(ride)
  local upAcross = up - axis * up:Dot(axis)
  local targetAcross = landingNormal - axis * landingNormal:Dot(axis)
  local remaining = math.deg(math.atan2(axis:Dot(upAcross:Cross(targetAcross)), upAcross:Dot(targetAcross)))

  -- Measured the long way round until well past straight up, as that's the way over the top.
  if (remaining < -90) then
    remaining = remaining + 360
  end

  local wantedSpeed = math.Clamp(
    remaining / vertAir.timeLeft,
    -MAX_TRANSFER_PITCH_SPEED,
    MAX_TRANSFER_PITCH_SPEED
  )
  local blend = getBlendFraction(LANDING_RESPONSE, deltaTime)

  return axis * ((wantedSpeed - ride.angularVelocity:Dot(axis)) * blend)
end

--- Arcade-feel: touching down, the skater stops tumbling, and rolls the way their skates face, forwards or backwards,
--- when their path is within inline_skates_trick_land_tolerance of it.
function ENT:SettleTouchdown(physics, ride)
  local normal = ride.groundNormal
  local tumble = ride.angularVelocity - normal * ride.angularVelocity:Dot(normal)

  physics:AddAngleVelocity(physics:WorldToLocalVector(-tumble))
  ride.angularVelocity = ride.angularVelocity - tumble

  local alongGround = ride.velocity - normal * ride.velocity:Dot(normal)
  local speed = alongGround:Length()

  if (speed < LANDING_FACING_MIN_SPEED) then
    return
  end

  local heading = ride.forwardAlongGround

  if (heading:Dot(alongGround) < 0) then
    heading = -heading
  end

  if (heading:Dot(alongGround / speed) < math.cos(math.rad(inlineSkates.getTuning("trick_land_tolerance")))) then
    return
  end

  local speedChange = heading * speed - alongGround

  physics:AddVelocity(speedChange)
  ride.velocity = ride.velocity + speedChange
  ride.speed = ride.velocity:Dot(ride.forwardAlongGround)
  ride.absoluteSpeed = math.abs(ride.speed)
end

--- Counts how long the skater has been in the air, and settles them once they touch down.
function ENT:UpdateTouchdown(physics, ride, deltaTime)
  if (ride.groundedCount == 0) then
    self.airTime = self.airTime + deltaTime
    return
  end

  local isSettled = self.airTime >= TOUCHDOWN_MIN_AIR_TIME and ride.isControlled
      and inlineSkates.getTuningBool("landing_assist")

  if (isSettled) then
    self:SettleTouchdown(physics, ride)
  end

  self.airTime = 0
end

--- Called every tick on the ground, so the last one holds the take-off.
function ENT:UpdateTakeoff(ride)
  if (ride.groundedCount == 0) then
    return
  end

  self.takeoffSlope = math.deg(math.acos(math.Clamp(ride.groundNormal.z, -1, 1)))
  self.vertAir = self:MeasureVertAirTakeoff(ride)
end

--- @return table? # `{ away, rampNormal, transferAxis, rampPoint, takeoffOffset, takeoffHeight, isTransferring,
--- timeLeft? }`, nil unless the skater goes up steep enough ground for a vert air. `away` is horizontal, out of the
--- ramp, and `takeoffOffset` and `takeoffHeight` are where the skater's soles were, out from the ramp at `rampPoint`.
function ENT:MeasureVertAirTakeoff(ride)
  if (self.takeoffSlope < VERT_AIR_MIN_SLOPE or ride.velocity.z <= 0 or not ride.groundContactPosition) then
    return nil
  end

  local away = Vector(ride.groundNormal.x, ride.groundNormal.y, 0)

  if (away:LengthSqr() < 1e-2) then
    return nil
  end

  away:Normalize()

  return {
    away = away,
    rampNormal = ride.groundNormal,
    -- Horizontal, along the ramp.
    transferAxis = away:Cross(vector_up):GetNormalized(),
    rampPoint = ride.groundContactPosition,
    takeoffOffset = (ride.position - ride.groundContactPosition):Dot(away),
    takeoffHeight = ride.position.z,
    isTransferring = false,
  }
end

--- Whether the skates can move by `crossing` without passing through anything, such as once they're above a spine.
--- Traced from the soles under the heels, the middle and the toes.
function ENT:IsClearToCross(ride, crossing)
  local filter = self:GetContactTraceFilter()
  local starts = { ride.position }

  for _, leg in ipairs(self.Contacts) do
    starts[#starts + 1] = LocalToWorld(Vector(leg.position.x, 0, 0), angle_zero, ride.position, ride.angles)
  end

  for _, start in ipairs(starts) do
    local trace = util.TraceLine({ start = start, endpos = start + crossing, filter = filter, mask = MASK_SOLID })

    if (trace.Hit) then
      return false
    end
  end

  return true
end

--- Arcade-feel: in a vert air, such as straight up a quarter pipe, the legs springing back off the ramp would carry
--- the skater away from it to land on the flat, so their horizontal speed away from the ramp is taken. Pressing W with
--- nothing over the top transfers: as if there were a quarter pipe right behind this one, such as on a spine, the
--- skater's soles are steered to land as far behind the ramp as they took off in front of it, at the same height, and
--- the skater turns over the top around them.
function ENT:UpdateVertAir(physics, ride, deltaTime)
  local vertAir = self.vertAir

  if (not vertAir or ride.groundedCount > 0 or ride.isCrashed) then
    return
  end

  local away = vertAir.away
  local offset = (ride.position - vertAir.rampPoint):Dot(away)

  -- Where the soles land, behind the ramp.
  local landingOffset = -vertAir.takeoffOffset - TRANSFER_LANDING_GAP
  local crossing = math.max(offset - landingOffset, TRANSFER_MIN_CLEARANCE)

  if (not vertAir.isTransferring and ride.airPitchDirection < 0 and self:IsClearToCross(ride, away * -crossing)) then
    vertAir.isTransferring = true
  end

  local awaySpeed = ride.velocity:Dot(away)
  local wantedAwaySpeed = math.min(awaySpeed, 0)
  local verticalSpeedChange = 0

  if (vertAir.isTransferring) then
    -- Steers the soles, which the skater turns around, rather than the centre of mass. Up and down they fly on as they
    -- would on their own, however the skater turns around them.
    local soleVelocity = getSoleVelocity(ride)

    if (vertAir.soleVerticalSpeed) then
      vertAir.soleVerticalSpeed = vertAir.soleVerticalSpeed - ride.gravity * deltaTime
    else
      vertAir.soleVerticalSpeed = soleVelocity.z
    end

    vertAir.timeLeft = getTimeToFallTo(ride, vertAir.takeoffHeight)
    awaySpeed = soleVelocity:Dot(away)
    wantedAwaySpeed = (landingOffset - offset) / vertAir.timeLeft
    verticalSpeedChange = vertAir.soleVerticalSpeed - soleVelocity.z
  end

  local speedChange = away * (wantedAwaySpeed - awaySpeed) + vector_up * verticalSpeedChange

  physics:AddVelocity(speedChange)
  ride.velocity = ride.velocity + speedChange
end

--- Keeps the skater balanced, leaning into the turn they steer and heading where that lean allows.
--- @return number # The lean the skater aims for in degrees, positive is right
function ENT:ApplyBalance(physics, ride, deltaTime)
  local gravity = ride.gravity
  local maxLateralAcceleration = inlineSkates.getTuning("mu") * gravity
  local steeredYawRate, isPivoting = self:GetSteeredYawRate(ride)
  local lateralAcceleration = math.Clamp(
    ride.speed * steeredYawRate,
    -maxLateralAcceleration,
    maxLateralAcceleration
  )
  local maxLean = inlineSkates.getTuning("lean_max")
  -- The lean a real skater needs for this turn: tan(lean) = lateral acceleration / gravity.
  local targetLean = math.Clamp(math.deg(math.atan(lateralAcceleration / gravity)), -maxLean, maxLean)
  local correction = self:GetHeadingCorrection(ride, steeredYawRate, lateralAcceleration, isPivoting, deltaTime)

  if (ride.groundedCount > 0) then
    -- A trick still turning the skater over as they land leaves the lean alone until it's judged.
    if (not self.isRotatingSkater) then
      correction:Add(self:GetLeanCorrection(ride, targetLean, deltaTime))
    end

    correction:Add(self:GetGroundPitchCorrection(ride, deltaTime))
  elseif (self.vertAir and self.vertAir.isTransferring and not self.isFlippingSkater) then
    local transferCorrection = self:GetTransferCorrection(ride, self.vertAir, deltaTime)

    correction:Add(transferCorrection)
    -- Turning around the centre of mass, high up the body, would swing the skates down into the top of the spine.
    -- Moving the centre of mass along keeps the soles where they were going, so the skater turns around them instead.
    physics:AddVelocity((transferCorrection * math.rad(1)):Cross(ride.massCenterPosition - ride.position))
  else
    correction:Add(self:GetLandingCorrection(ride, deltaTime))
  end

  physics:AddAngleVelocity(physics:WorldToLocalVector(correction))

  return targetLean
end

--- @param state table What the skater does
function ENT:UpdateNetworkedVisuals(ride, state, targetLean, deltaTime)
  local wantedCadence = 0

  if (state.isPushing or state.isPushingBackwards) then
    wantedCadence = (BASE_CADENCE + ride.absoluteSpeed * CADENCE_PER_SPEED)
        * (state.isSprinting and SPRINT_CADENCE_SCALE or 1)
  elseif (state.isStepping) then
    wantedCadence = STEPPING_CADENCE
  end

  local flags = self.POSE_FLAGS
  local poseFlags = 0

  if (state.isPushing) then poseFlags = bit.bor(poseFlags, flags.pushing) end
  if (state.isSprinting) then poseFlags = bit.bor(poseFlags, flags.sprinting) end
  if (state.isBraking) then poseFlags = bit.bor(poseFlags, flags.braking) end
  if (state.isTucking) then poseFlags = bit.bor(poseFlags, flags.tucking) end
  if (ride.groundedCount > 0) then poseFlags = bit.bor(poseFlags, flags.grounded) end
  if (state.isPushingBackwards) then poseFlags = bit.bor(poseFlags, flags.pushingBackwards) end
  if (state.isStepping) then poseFlags = bit.bor(poseFlags, flags.stepping) end

  self:SetCadence(math.Approach(self:GetCadence(), wantedCadence, CADENCE_CHANGE_RATE * deltaTime))
  self:SetPoseFlags(poseFlags)
  self:SetSteer(roundToStep(self.steerFraction, STEER_NETWORK_STEP))
  self:SetTargetLean(roundToStep(targetLean, LEAN_NETWORK_STEP))
  self:SetCrouch(roundToStep(self.jumpCharge, CROUCH_NETWORK_STEP))
end

--- Clears what the client animates by, for skates nobody wears.
function ENT:ClearNetworkedVisuals()
  if (self:GetPoseFlags() == 0 and self:GetCadence() == 0) then
    return
  end

  self:SetCadence(0)
  self:SetPoseFlags(0)
  self:SetSteer(0)
  self:SetTargetLean(0)
  self:SetCrouch(0)
  self:SetSkid(0)
end

--- @return boolean # Whether the skater lies on their body: its lowest corner rests on the ground, and they're tipped
--- well away from standing on it
function ENT:IsBodyOnGround(ride)
  self.bodyHullVertices = self.bodyHullVertices or self:GetBodyHullVertices()

  local lowest

  for _, vertex in ipairs(self.bodyHullVertices) do
    local position = LocalToWorld(vertex, angle_zero, ride.position, ride.angles)

    if (not lowest or position.z < lowest.z) then
      lowest = position
    end
  end

  local trace = util.TraceLine({
    start = lowest + vector_up * BODY_ON_GROUND_CLEARANCE,
    endpos = lowest - vector_up * BODY_ON_GROUND_CLEARANCE,
    filter = self:GetContactTraceFilter(),
    mask = MASK_SOLID,
  })

  if (not trace.Hit) then
    return false
  end

  local normal = trace.StartSolid and vector_up or trace.HitNormal

  local maxUp = math.cos(math.rad(inlineSkates.getTuning("crash_lean")))

  return normal.z >= BODY_ON_GROUND_MIN_NORMAL_UP and ride.angles:Up():Dot(normal) < maxUp
end

--- Crashes that can only be judged once the legs have been traced: a bad landing, leaning or tipping too far, or
--- lying on the ground.
function ENT:CheckFalls(ride, deltaTime)
  local isGrounded = ride.groundedCount > 0

  if (ride.isCrashed or self.isPhysgunHeld) then
    self.wasGrounded = isGrounded
    return
  end

  -- Measured in the air, as the legs have already slowed the skater once they touch down.
  if (isGrounded and not self.wasGrounded
        and -self.lastAirVelocity:Dot(ride.groundNormal) > inlineSkates.getTuning("land_crash_speed")) then
    self.hasPendingCrash = true
  end

  if (not isGrounded) then
    self.lastAirVelocity = ride.velocity
  end

  self.wasGrounded = isGrounded

  -- Pitch is against the ground so steep ramps aren't falls. A trick turning the skater over judges its own landing.
  local groundPitch = math.deg(math.asin(math.Clamp(ride.forward:Dot(ride.groundNormal), -1, 1)))

  if (not self.isRotatingSkater and isGrounded
        and (math.abs(ride.lean) > inlineSkates.getTuning("crash_lean")
          or math.abs(groundPitch) > inlineSkates.getTuning("crash_pitch"))) then
    self.hasPendingCrash = true
  end

  -- Lying on their body, such as on their face or after landing a flip on their back. Judged from the body alone, as a
  -- leg may still find something to stand on, and tricks and the landing assist would carry on as if in the air.
  if (self:IsBodyOnGround(ride)) then
    self.bodyOnGroundTime = self.bodyOnGroundTime + deltaTime

    if (self.bodyOnGroundTime >= BODY_ON_GROUND_TIME) then
      self.hasPendingCrash = true
    end
  else
    self.bodyOnGroundTime = 0
  end

  -- Catches what the checks above can't, such as a skater resting on something the body check misses.
  if (not isGrounded and ride.velocity:Length() < RESTING_OFF_GROUND_SPEED) then
    self.restingOffGroundTime = self.restingOffGroundTime + deltaTime

    local fallThroughTime = RESTING_OFF_GROUND_SPEED * 2 / ride.gravity

    if (self.restingOffGroundTime > fallThroughTime * RESTING_OFF_GROUND_FALL_TIMES) then
      self.hasPendingCrash = true
    end
  else
    self.restingOffGroundTime = 0
  end
end

--- Velocities are measured once into `ride` before any forces are applied, so every stage starts from the same state.
function ENT:PhysicsSimulate(physics, deltaTime)
  local rider = self:GetRider()

  -- Parked skates are a plain physics prop.
  if (not IsValid(rider) or not self.isRiddenPhysics) then
    self:ResetRiderInput()
    self:ClearNetworkedVisuals()

    return vector_origin, vector_origin, SIM_NOTHING
  end

  deltaTime = math.Clamp(deltaTime, 0.001, 0.05)

  local input = self:ReadRiderInput(rider)
  local ride = self:MeasureRide(physics)

  if (not ride.isCrashed and self:IsTooDeepToRide()) then
    self.hasPendingCrash = true
    self.isCrashingIntoWater = true
  end

  self:ApplyLegSuspension(physics, ride, deltaTime)
  self:UpdateTouchdown(physics, ride, deltaTime)
  self:CheckFalls(ride, deltaTime)
  self:ReadAirControls(ride, input)

  local isGrounded = ride.groundedCount > 0
  -- Steering spins a trick while it's driven, so the skater doesn't also turn.
  local isSteeringTrick = self:UpdateTricks(physics, ride, input, rider, deltaTime)

  self:UpdateSteering(isSteeringTrick and 0 or input.steerDirection, deltaTime)
  self:UpdateTakeoff(ride)
  self:UpdateVertAir(physics, ride, deltaTime)
  self:UpdateTurnAround(ride, input)

  -- W skates forwards and S backwards. Either one rolling the other way brakes first, until standing.
  local isRollingForwards = ride.speed > STANDSTILL_SPEED
  local isRollingBackwards = ride.speed < -STANDSTILL_SPEED
  local isPushHeld = input.isPushHeld and not input.isBrakeHeld
  local isBackwardsPushHeld = input.isBrakeHeld and not input.isPushHeld
  local isTurningAround = self.turnAround ~= nil
  local state = {
    isTucking = isGrounded and input.isTuckHeld and not input.isBrakeHeld,
    isBraking = isGrounded and not isTurningAround
        and ((isBackwardsPushHeld and isRollingForwards) or (isPushHeld and isRollingBackwards)),
  }
  local canPush = isGrounded and not state.isTucking and not isTurningAround

  state.isPushing = canPush and isPushHeld and not isRollingBackwards
  state.isPushingBackwards = canPush and isBackwardsPushHeld and not isRollingForwards
  state.isSprinting = state.isPushing and input.isSprintHeld
  -- Turning round steps the feet round too.
  state.isStepping = isGrounded and not state.isPushing and not state.isPushingBackwards
      and (isTurningAround or (math.abs(self.steerFraction) > STEPPING_MIN_STEER
        and ride.absoluteSpeed < PIVOT_FADE_SPEED * STEPPING_MAX_SPEED_FRACTION))

  self:UpdateJump(physics, ride, input, deltaTime)

  if (isGrounded) then
    self:ApplyPushAndBrake(physics, ride, input, state, deltaTime)
    self:ApplyWheelGrip(physics, ride, deltaTime)
  end

  local targetLean = 0

  if (ride.isControlled) then
    targetLean = self:ApplyBalance(physics, ride, deltaTime)
  end

  self:UpdateNetworkedVisuals(ride, state, targetLean, deltaTime)
  self:SetSkid(roundToStep(self:GetSkidAmount(ride, state), SKID_NETWORK_STEP))

  return vector_origin, vector_origin, SIM_NOTHING
end
