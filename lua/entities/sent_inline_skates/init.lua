AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_pose.lua")

include("shared.lua")
include("sv_ride.lua")
include("sv_tricks.lua")

local SPAWN_HEIGHT = 4

local RIDER_SEAT_MODEL = "models/nova/airboat_seat.mdl"
-- Players in a vehicle stand at this attachment of the seat's model, so it's moved onto the skates.
local SEAT_FEET_ATTACHMENT = "vehicle_feet_passenger0"

-- Random spawn colors pick any hue, but stay saturated and bright enough to not look muddy.
local RANDOM_COLOR_SATURATION = 0.7
local RANDOM_COLOR_VALUE = 0.9

-- Stops the same key press that put the skates on or took them off from immediately undoing it.
local USE_COOLDOWN_AFTER_ENTERING = 0.5
local USE_COOLDOWN_AFTER_LEAVING = 0.6
-- Pressing E with no room to take the skates off says so at most this often (s).
local NO_ROOM_MESSAGE_INTERVAL = 1

local PUT_ON_GROUND_REACH = 48

-- Where a skater may stand after taking the skates off, relative to their heading, tried in order.
local TAKE_OFF_OFFSETS = {
  { forward = 0,   right = 0,   up = 4 },
  { forward = 0,   right = -24, up = 16 },
  { forward = 0,   right = 24,  up = 16 },
  { forward = -40, right = 0,   up = 16 },
  { forward = 0,   right = 0,   up = 40 },
}
-- Falling only places the skater on the spot or to a side, the throw itself comes from CRASH_EJECT_VELOCITY_SCALE.
local CRASH_TAKE_OFF_OFFSETS = {
  { forward = 0, right = 0,   up = 8 },
  { forward = 0, right = -24, up = 16 },
  { forward = 0, right = 24,  up = 16 },
}
-- The fallback when no offset fits: straight up from the skates, as far as there is room.
local FALLBACK_TAKE_OFF_HEIGHT = 40
-- Anything further than this from the skates after leaving was moved by something else, such as an admin teleport.
local MAX_TAKE_OFF_CORRECTION_DISTANCE = 128
local CRASH_EJECT_VELOCITY_SCALE = 0.8
local CRASH_EJECT_UPWARD_SPEED = 140
-- After a fall the skates carry on tumbling with this much of the skater's speed.
local CRASH_SKATES_VELOCITY_SCALE = 0.5
local CRASH_SKATES_SPIN = 360
-- How long a fallen skater's RagMod ragdoll passes through the skates they were put down overlapping.
local RAGMOD_NO_COLLIDE_TIME = 0.2

local IMPACT_SOUND_MIN_SPEED = 150
local IMPACT_SOUND_INTERVAL = 0.2
-- Impacts closer to head-on than this (dot product with the heading) count as frontal.
local FRONTAL_IMPACT_DOT = 0.6
-- Any impact this many times inline_skates_crash_speed knocks the skater over, frontal or not.
local ANY_IMPACT_CRASH_SCALE = 2

function ENT:SpawnFunction(player, trace, className)
  if (not trace.Hit) then
    return
  end

  local entity = ents.Create(className)
  entity:SetPos(trace.HitPos + trace.HitNormal * SPAWN_HEIGHT)
  entity:SetAngles(Angle(0, player:EyeAngles().y, 0))

  if (entity.RandomColor) then
    entity:SetColor(HSVToColor(math.random(0, 359), RANDOM_COLOR_SATURATION, RANDOM_COLOR_VALUE))
  end

  entity:Spawn()
  entity:Activate()

  return entity
end

function ENT:Initialize()
  self:SetModel(self.Model)
  self:SetUseType(SIMPLE_USE)

  self.isRiddenPhysics = nil
  self:SetRiddenPhysics(false)

  self.steerFraction = 0
  self.wasJumpHeld = false
  self.isJumpBlocked = false
  self.jumpCharge = 0
  self.lastGroundedAt = 0
  self.jumpNormal = vector_up
  self.nextJumpAt = 0
  self.tapPressedAt = {}
  self.pendingDoubleTaps = {}
  self.nextImpactSoundAt = 0
  self.restingOffGroundTime = 0
  self.bodyOnGroundTime = 0
  self.wasGrounded = false
  self.lastAirVelocity = Vector(0, 0, 0)
  self.turnAround = nil
  self.trickStates = {}
  self.takeoffSlope = 0
  self.airKeysHeldSinceTakeoff = {}
  self.airTime = 0

  self:CreateSeat()
end

--- Swaps the physics between the parked skates and the skater's body, keeping the motion.
--- @param isRidden boolean
--- @param velocity? Vector Replaces the current velocity
--- @param angularVelocity? Vector Replaces the current angular velocity, local deg/s
function ENT:SetRiddenPhysics(isRidden, velocity, angularVelocity)
  if (self.isRiddenPhysics == isRidden and not velocity) then
    return
  end

  local physics = self:GetPhysicsObject()

  if (IsValid(physics)) then
    velocity = velocity or physics:GetVelocity()
    angularVelocity = angularVelocity or physics:GetAngleVelocity()
  end

  if (self.isRiddenPhysics ~= isRidden) then
    if (self.hasMotionController) then
      self:StopMotionController()
      self.hasMotionController = false
    end

    local mins, maxs = self.ParkedMins, self.ParkedMaxs

    if (isRidden) then
      mins, maxs = self.BodyMins, self.BodyMaxs

      if (not self:PhysicsInitConvex(self:GetBodyHullVertices())) then
        self:PhysicsInitBox(mins, maxs)
      end
    else
      self:PhysicsInitBox(mins, maxs)
    end

    -- Traces then hit the physics hull itself, not the stand-in model's.
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:EnableCustomCollisions()
    self:SetCollisionBounds(mins, maxs)
    -- Parked skates don't block players, who would trip over them putting them on or taking them off.
    self:SetCollisionGroup(isRidden and COLLISION_GROUP_NONE or COLLISION_GROUP_WEAPON)
    self.isRiddenPhysics = isRidden

    physics = self:GetPhysicsObject()

    if (IsValid(physics)) then
      physics:SetMaterial(isRidden and "flesh" or "plastic")
      physics:SetDamping(0, isRidden and 0.5 or 0.2)
      physics:EnableDrag(false)
      self.inertiaPerMass = physics:GetInertia() / physics:GetMass()
    end

    if (isRidden) then
      self:StartMotionController()
      self.hasMotionController = true
    end

    self:UpdateMass()
  end

  if (IsValid(physics)) then
    physics:SetVelocity(velocity or vector_origin)
    physics:AddAngleVelocity((angularVelocity or vector_origin) - physics:GetAngleVelocity())
    physics:Wake()
  end
end

--- The skater's weight is put on the body box, so skating feels like moving a person.
function ENT:UpdateMass()
  local physics = self:GetPhysicsObject()

  if (not IsValid(physics)) then
    return
  end

  local mass = self.isRiddenPhysics and inlineSkates.getTuning("mass_ridden") or self.EmptyMass
  physics:SetMass(mass)

  if (self.inertiaPerMass) then
    physics:SetInertia(self.inertiaPerMass * mass)
  end

  physics:Wake()
end

--- Creates an invisible seat parented to the skates, with no collisions or motion of its own.
function ENT:CreateSeat()
  local seat = ents.Create("prop_vehicle_prisoner_pod")

  if (not IsValid(seat)) then
    return
  end

  seat:SetModel(RIDER_SEAT_MODEL)
  seat:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
  seat:SetKeyValue("limitview", "0")
  seat:SetPos(self:GetPos())
  seat:SetAngles(self:LocalToWorldAngles(self.SeatAngles))
  seat:Spawn()
  seat:Activate()

  local feet = seat:GetAttachment(seat:LookupAttachment(SEAT_FEET_ATTACHMENT))

  if (feet) then
    seat:SetPos(seat:GetPos() + (self:GetPos() - feet.Pos))
  end

  seat:SetMoveType(MOVETYPE_NONE)
  seat:SetParent(self)
  seat:SetNotSolid(true)
  seat:SetNoDraw(true)
  seat:DrawShadow(false)

  local seatPhysics = seat:GetPhysicsObject()

  if (IsValid(seatPhysics)) then
    seatPhysics:EnableMotion(false)
    seatPhysics:EnableCollisions(false)
  end

  seat.PhysgunDisabled = true
  seat.DoNotDuplicate = true
  seat:SetNW2Bool("inline_skates_Seat", true)

  self:DeleteOnRemove(seat)
  self:SetSeat(seat)
end

--- Moves the skates onto `player`'s feet, facing where they look and keeping their walking speed.
--- @param player Player
--- @return boolean # False when there is no room for the skater there
function ENT:PutOn(player)
  local filter = { self, player, self:GetSeat() }
  local feet = player:GetPos()
  local groundTrace = util.TraceLine({
    start = feet + vector_up * 8,
    endpos = feet - vector_up * PUT_ON_GROUND_REACH,
    filter = filter,
    mask = MASK_PLAYERSOLID,
  })
  local position = groundTrace.Hit and groundTrace.HitPos or feet
  local roomTrace = util.TraceHull({
    start = position,
    endpos = position,
    mins = self.BodyMins,
    maxs = self.BodyMaxs,
    filter = filter,
    mask = MASK_SOLID,
  })

  if (roomTrace.StartSolid) then
    player:PrintMessage(HUD_PRINTCENTER, "There's no room to put the skates on here")
    return false
  end

  local walkingVelocity = player:GetVelocity()
  walkingVelocity.z = 0

  self:SetPos(position)
  self:SetAngles(Angle(0, player:EyeAngles().y, 0))
  self:SetRiddenPhysics(true, walkingVelocity, vector_origin)

  -- The skater would be knocked straight back over.
  if (self:IsTooDeepToRide()) then
    self:SetRiddenPhysics(false, vector_origin, vector_origin)
    return false
  end

  return true
end

function ENT:Use(activator)
  if (not IsValid(activator) or not activator:IsPlayer() or activator:InVehicle()) then
    return
  end

  if (self.isPhysgunHeld or (activator._InlineSkatesNextUseAt or 0) > CurTime() or IsValid(self:GetRider())) then
    return
  end

  if (hook.Run("InlineSkatesCanPutOn", activator, self) == false) then
    return
  end

  if (not IsValid(self:GetSeat())) then
    self:CreateSeat()
  end

  if (not IsValid(self:GetSeat()) or not self:PutOn(activator)) then
    return
  end

  activator:EnterVehicle(self:GetSeat())

  -- Another addon kept them out of the seat.
  if (activator:GetVehicle() ~= self:GetSeat()) then
    self:SetRiddenPhysics(false, vector_origin, vector_origin)
  end
end

--- @param key string
function ENT:OnModelSettingChanged(key)
  if (key == "mass") then
    self:UpdateMass()
  end
end

function ENT:OnRiderEnter(player)
  self:SetRider(player)
  self:SetCrashed(false)
  self:SetRiddenPhysics(true)
  self:UpdateMass()

  -- The Use or Jump press that put the skates on shouldn't also jump.
  self.isJumpBlocked = true
  self.jumpCharge = 0
  self.turnAround = nil
  player._InlineSkatesNextUseAt = CurTime() + USE_COOLDOWN_AFTER_ENTERING

  player:SetEyeAngles(self.SeatForwardEyeAngles)

  hook.Run("InlineSkatesPutOn", player, self)
end

--- Finds the first offset where the player fits and which is reachable from the skates without passing through a wall.
--- @param player Player
--- @param offsets table[] Relative to the skates' heading, see `TAKE_OFF_OFFSETS`
--- @return Vector? # Nil when none of the offsets fits
function ENT:FindTakeOffPosition(player, offsets)
  local mins, maxs = player:GetHull()
  local origin = self:GetPos()
  local forward, right = self:GetForward(), self:GetRight()
  local filter = self:GetContactTraceFilter()
  filter[#filter + 1] = player

  forward.z, right.z = 0, 0
  forward:Normalize()
  right:Normalize()

  for _, offset in ipairs(offsets) do
    local target = origin + forward * offset.forward + right * offset.right
    local raisedTarget = target + vector_up * offset.up
    local lineOfSight = util.TraceLine({
      start = origin + vector_up * 10,
      endpos = raisedTarget + vector_up * 10,
      filter = filter,
      mask = MASK_PLAYERSOLID,
    })

    if (not lineOfSight.Hit) then
      local groundTrace = util.TraceHull({
        start = raisedTarget,
        endpos = target - vector_up * 48,
        mins = mins,
        maxs = maxs,
        filter = filter,
        mask = MASK_PLAYERSOLID,
      })

      if (groundTrace.Hit and not groundTrace.StartSolid) then
        return groundTrace.HitPos
      end
    end
  end

  return nil
end

--- For skaters that have to get off although no offset fits: straight up from the skates as far as the player fits.
--- @param player Player
--- @return Vector
function ENT:FindFallbackTakeOffPosition(player)
  local mins, maxs = player:GetHull()
  local origin = self:GetPos()
  local filter = self:GetContactTraceFilter()
  filter[#filter + 1] = player

  local trace = util.TraceHull({
    start = origin,
    endpos = origin + vector_up * FALLBACK_TAKE_OFF_HEIGHT,
    mins = mins,
    maxs = maxs,
    filter = filter,
    mask = MASK_PLAYERSOLID,
  })

  if (not trace.StartSolid) then
    return trace.HitPos
  end

  return origin
end

--- Called when the skater asks to take the skates off. Unless take_off_anywhere is on they keep them on when there is
--- nowhere to stand, as the fallback position could be past a player clip.
--- @param player Player
--- @return boolean
function ENT:CanRiderLeave(player)
  local position = self:FindTakeOffPosition(player, TAKE_OFF_OFFSETS)

  if (not position) then
    if (not inlineSkates.getTuningBool("take_off_anywhere")) then
      if ((player._InlineSkatesNextNoRoomMessageAt or 0) <= CurTime()) then
        player._InlineSkatesNextNoRoomMessageAt = CurTime() + NO_ROOM_MESSAGE_INTERVAL
        player:PrintMessage(HUD_PRINTCENTER, "There's no room to take the skates off here")
      end

      return false
    end

    position = self:FindFallbackTakeOffPosition(player)
  end

  self.plannedTakeOff = { position = position, at = CurTime() }

  return true
end

--- Where a skater getting off now should stand.
--- @param player Player
--- @param isCrashing boolean
--- @return Vector
function ENT:GetTakeOffPosition(player, isCrashing)
  local plannedTakeOff = self.plannedTakeOff
  self.plannedTakeOff = nil

  -- Only when planned for this exit: another hook may have kept the skater on after it was planned.
  if (not isCrashing and plannedTakeOff and plannedTakeOff.at == CurTime()) then
    return plannedTakeOff.position
  end

  return self:FindTakeOffPosition(player, isCrashing and CRASH_TAKE_OFF_OFFSETS or TAKE_OFF_OFFSETS)
      or self:FindFallbackTakeOffPosition(player)
end

--- Throws a fallen skater as a RagMod ragdoll, when RagMod is installed and enabled.
--- @param player Player
--- @param ejectVelocity Vector
--- @return boolean # Whether the skater became a ragdoll
local function tryRagmodRagdoll(player, ejectVelocity)
  if (not inlineSkates.getTuningBool("ragmod_crash")) then
    return false
  end

  if (not ragmod or not ragmod.TryToRagdoll or not RagModOptions or not RagModOptions.Enabled()) then
    return false
  end

  local ragdoll = ragmod:TryToRagdoll(player)

  if (not IsValid(ragdoll)) then
    return false
  end

  ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)
  ragdoll:SetVelocity(ejectVelocity)
  ragdoll:PlayRagSound()

  timer.Simple(RAGMOD_NO_COLLIDE_TIME, function()
    if (IsValid(ragdoll) and ragdoll:GetCollisionGroup() == COLLISION_GROUP_WEAPON) then
      ragdoll:SetCollisionGroup(COLLISION_GROUP_NONE)
    end
  end)

  return true
end

--- The engine may still move a player after the leave hooks, so the take-off position is enforced again next tick.
--- @param player Player
--- @param position Vector
--- @param skatesPosition Vector
--- @param onHeld? function Called once the position is enforced again
local function holdTakeOffPosition(player, position, skatesPosition, onHeld)
  timer.Simple(0, function()
    if (not IsValid(player) or player:InVehicle() or not player:Alive()) then
      return
    end

    local maxDistanceSqr = MAX_TAKE_OFF_CORRECTION_DISTANCE * MAX_TAKE_OFF_CORRECTION_DISTANCE

    if (player:GetPos():DistToSqr(skatesPosition) > maxDistanceSqr) then
      return
    end

    player:SetPos(position)

    if (onHeld) then
      onHeld()
    end
  end)
end

function ENT:OnRiderLeave(player)
  if (self:GetRider() ~= player) then
    return
  end

  self:SetRider(NULL)
  self:ResetTricks()
  self:ResetRiderInput()
  self:ClearNetworkedVisuals()
  self.steerFraction = 0
  self.turnAround = nil
  player._InlineSkatesNextUseAt = CurTime() + USE_COOLDOWN_AFTER_LEAVING

  local isCrashing = self.isEjectingFromCrash
  self.isEjectingFromCrash = nil

  -- Capped, so skates thrown with the physgun don't fling their skater across the map.
  local velocity = self:GetVelocity()
  local maxEjectSpeed = inlineSkates.getTuning("sprint_speed") * self.SpeedScale

  if (velocity:Length() > maxEjectSpeed) then
    velocity:Normalize()
    velocity:Mul(maxEjectSpeed)
  end

  -- Taken off, the skates are put down upright where the skater stood. Fallen off, they tumble on.
  local yaw = self:GetAngles().y

  if (isCrashing) then
    self:SetRiddenPhysics(
      false,
      velocity * CRASH_SKATES_VELOCITY_SCALE,
      VectorRand() * CRASH_SKATES_SPIN
    )
  else
    self:SetAngles(Angle(0, yaw, 0))
    self:SetRiddenPhysics(false, vector_origin, vector_origin)
  end

  local position = self:GetTakeOffPosition(player, isCrashing)

  player:SetPos(position)
  player:SetEyeAngles(Angle(0, yaw, 0))

  hook.Run("InlineSkatesTakenOff", player, self, isCrashing == true)

  holdTakeOffPosition(player, position, self:GetPos(), isCrashing and function()
    local ejectVelocity = velocity * CRASH_EJECT_VELOCITY_SCALE + vector_up * CRASH_EJECT_UPWARD_SPEED

    -- Returning false from the hook keeps the skater from being thrown.
    if (hook.Run("InlineSkatesSkaterCrashed", player, self, ejectVelocity) ~= false
          and not tryRagmodRagdoll(player, ejectVelocity)) then
      player:SetVelocity(ejectVelocity)
    end
  end)
end

--- @param isIntoWater? boolean Whether the skater skated into water too deep to skate through
function ENT:Crash(isIntoWater)
  if (self:GetCrashed()) then
    return
  end

  local rider = self:GetRider()

  if (IsValid(rider) and hook.Run("InlineSkatesShouldCrash", self, rider) == false) then
    return
  end

  self:SetCrashed(true)

  if (isIntoWater) then
    self:EmitSkatesSound("ambient/water/water_splash" .. math.random(1, 3) .. ".wav", 75, math.random(95, 110))
  else
    self:EmitSkatesSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 75,
      math.random(95, 110))
  end

  if (IsValid(rider)) then
    self.isEjectingFromCrash = true
    rider:ExitVehicle()
  end
end

function ENT:EmitSkatesSound(...)
  if (inlineSkates.getTuningBool("sounds")) then
    self:EmitSound(...)
  end
end

--- @param impactSpeed number Speed into what was hit (u/s)
--- @param hitNormal Vector
--- @return boolean # Whether hitting something this hard knocks the skater over
function ENT:IsCrashImpact(impactSpeed, hitNormal)
  local crashSpeed = inlineSkates.getTuning("crash_speed")
  local isFrontal = math.abs(hitNormal:Dot(self:GetForward())) > FRONTAL_IMPACT_DOT

  return (isFrontal and impactSpeed > crashSpeed) or impactSpeed > crashSpeed * ANY_IMPACT_CRASH_SCALE
end

-- Changing entity state inside a physics callback is unsafe, so impacts are recorded here and handled in Think.
function ENT:PhysicsCollide(collision)
  local rider = self:GetRider()

  -- Parked skates make their own impact sounds from their physics material.
  if (not IsValid(rider)) then
    return
  end

  local impactSpeed = math.abs(collision.OurOldVelocity:Dot(collision.HitNormal))

  if (impactSpeed > IMPACT_SOUND_MIN_SPEED and self.nextImpactSoundAt < CurTime()) then
    self.nextImpactSoundAt = CurTime() + IMPACT_SOUND_INTERVAL
    self.pendingImpactSoundSpeed = impactSpeed
  end

  -- Skates held with the physgun are thrown around by someone else, so the skater shouldn't fall from it.
  if (self:GetCrashed() or self.isPhysgunHeld or collision.HitEntity == rider) then
    return
  end

  if (self:IsCrashImpact(impactSpeed, collision.HitNormal)) then
    self.hasPendingCrash = true
  end
end

function ENT:HandlePendingImpacts()
  if (self.hasPendingCrash) then
    local isIntoWater = self.isCrashingIntoWater == true

    self.hasPendingCrash = nil
    self.isCrashingIntoWater = nil
    self:Crash(isIntoWater)
  end

  local impactSpeed = self.pendingImpactSoundSpeed

  if (impactSpeed) then
    self.pendingImpactSoundSpeed = nil
    self:EmitSkatesSound(
      "physics/body/body_medium_impact_soft" .. math.random(1, 5) .. ".wav",
      70,
      100,
      math.Clamp(impactSpeed / 500, 0.2, 1)
    )
  end
end

--- Damage dealt to the skater's body box, such as bullets, reaches the skater.
function ENT:OnTakeDamage(damageInfo)
  local rider = self:GetRider()

  if (not IsValid(rider) or self.isForwardingDamage or not inlineSkates.getTuningBool("forward_damage")) then
    return
  end

  -- The body bumping into things is handled as falling over instead.
  if (damageInfo:IsDamageType(DMG_CRUSH)) then
    return
  end

  self.isForwardingDamage = true
  rider:TakeDamageInfo(damageInfo)
  self.isForwardingDamage = false
end

--- Catches skaters that left without PlayerLeaveVehicle, such as by dying.
function ENT:ValidateRider()
  local rider, seat = self:GetRider(), self:GetSeat()

  if (IsValid(rider) and (not IsValid(seat) or rider:GetVehicle() ~= seat or not rider:Alive())) then
    self:SetRider(NULL)
    self:ResetTricks()
    self:ResetRiderInput()
    self:ClearNetworkedVisuals()
    rider = NULL
  end

  if (not IsValid(rider)) then
    if (self.isRiddenPhysics) then
      self:SetRiddenPhysics(false)
    end

    return
  end

  -- PhysicsSimulate stops running once the body falls asleep, which a skater standing still would.
  local physics = self:GetPhysicsObject()

  if (IsValid(physics)) then
    physics:Wake()
  end
end

function ENT:Think()
  self:HandlePendingImpacts()
  self:HandleLandedTricks()
  self:ValidateRider()

  self:NextThink(CurTime())
  return true
end

-- The duplicator restores saved network vars after spawning, and dupe files come from clients.
function ENT:OnDuplicated()
  self:SetCrashed(false)
end

function ENT:OnRemove()
  local rider = self:GetRider()

  if (IsValid(rider) and rider:InVehicle()) then
    rider:ExitVehicle()
  end
end
