-- Clients carry each trick on at its last sent speed, so it's only resent once it's this far off that (deg).
local TRICK_SEND_TOLERANCE = 1
-- Active tricks are resent this often (s) for players who come into view of the skater.
local TRICK_STATES_RESEND_INTERVAL = 0.25
local LANDED_TRICKS_MAX = 16

--- @param trick table
--- @return table # `{ angle, speed, direction, data, canSpin, isHeldSinceStart, sent }`, `sent` is
--- `{ angle, speed, tick }` as last sent, nil once sent straight
function ENT:GetTrickState(trick)
  local state = self.trickStates[trick.id]

  if (not state) then
    state = { angle = 0, speed = 0, data = {}, canSpin = false }
    self.trickStates[trick.id] = state
  end

  return state
end

local function clearTrickMemory(state)
  state.direction = nil
  state.data = {}
end

--- @return boolean # Whether the trick is turned away from straight or still moving
local function isTrickActive(state)
  return state.angle ~= 0 or state.speed ~= 0
end

--- @param sent table? `state.sent`
--- @param tick number
--- @return number # Where clients have carried the trick on to by `tick`
local function getSentAngle(sent, tick)
  if (not sent) then
    return 0
  end

  return sent.angle + sent.speed * (tick - sent.tick) * engine.TickInterval()
end

--- Sends every trick that isn't straight, so each message replaces the last whole. Clients carry tricks on at their sent
--- speed, so a message only goes out when one drifts from that, one stops, or the resend interval passes. Messages go
--- unreliably to players who can see the skater, except when a trick stops. Once all are straight again, that goes
--- reliably to everyone.
function ENT:SendTrickStates()
  local tick = engine.TickCount()
  local activeCount = 0
  local isDrifting = false
  local isStopping = false

  for _, trick in ipairs(inlineSkates.trick.getAll()) do
    local state = self:GetTrickState(trick)
    local sent = state.sent

    if (isTrickActive(state)) then
      activeCount = activeCount + 1
    end

    isDrifting = isDrifting or math.abs(state.angle - getSentAngle(sent, tick)) > TRICK_SEND_TOLERANCE
    isStopping = isStopping or (sent ~= nil and sent.speed ~= 0 and state.speed == 0)
  end

  local isActive = activeCount > 0
  local isEnding = not isActive and self.hasSentActiveTricks
  local isResendDue = CurTime() >= (self.nextTrickStatesSendAt or 0)

  if (not isEnding and not (isActive and (isDrifting or isStopping or isResendDue))) then
    return
  end

  self.hasSentActiveTricks = isActive
  self.nextTrickStatesSendAt = CurTime() + TRICK_STATES_RESEND_INTERVAL

  net.Start("inline_skates.TrickStates", isActive and not isStopping)
  net.WriteEntity(self)
  net.WriteUInt(tick, 32)
  net.WriteUInt(activeCount, 8)

  for _, trick in ipairs(inlineSkates.trick.getAll()) do
    local state = self.trickStates[trick.id]

    if (isTrickActive(state)) then
      inlineSkates.trick.write(trick)
      net.WriteFloat(state.angle)
      net.WriteFloat(state.speed)

      state.sent = { angle = state.angle, speed = state.speed, tick = tick }
    else
      state.sent = nil
    end
  end

  if (isActive) then
    net.SendPVS(self:GetPos())
  else
    net.Broadcast()
  end
end

function ENT:ResetTricks()
  for _, trick in ipairs(inlineSkates.trick.getAll()) do
    local state = self:GetTrickState(trick)

    state.angle, state.speed, state.canSpin = 0, 0, false
    clearTrickMemory(state)
  end

  self.isRotatingSkater = false
  self.isSpinningSkater = false
  self.isFlippingSkater = false
  self:SendTrickStates()
end

--- @param physics PhysObj
--- @param ride table
--- @param input table
--- @param rider Player
--- @param deltaTime number
--- @return boolean # Whether a trick takes the steering
function ENT:UpdateTricks(physics, ride, input, rider, deltaTime)
  if (ride.isCrashed or self.isPhysgunHeld or not inlineSkates.getTuningBool("tricks")) then
    self:ResetTricks()

    return false
  end

  local contact = inlineSkates.trick.getContact(ride.groundedCount > 0)
  local isSteeringTrick = false
  local isRotatingSkater = false
  local isSpinningSkater = false
  local isFlippingSkater = false
  local landedTricks = {}
  local isBailing = false

  for _, trick in ipairs(inlineSkates.trick.getAll()) do
    local state = self:GetTrickState(trick)
    local canSpin = trick.contact[contact] == true

    if (canSpin) then
      local direction, takesSteering = trick:ReadInput(input, rider, state)
      local isDriven = direction ~= 0

      -- Input already held when the trick became possible, such as steering into a jump, is still skating and only
      -- does the trick once pressed again.
      if (not state.canSpin) then
        state.isHeldSinceStart = isDriven and trick.needsFreshInput
      elseif (not isDriven) then
        state.isHeldSinceStart = false
      end

      if (state.isHeldSinceStart) then
        isDriven, takesSteering = false, false
      end

      isSteeringTrick = isSteeringTrick or takesSteering == true
      trick:Spin(state, isDriven, direction, deltaTime)
      trick:Simulate(self, physics, ride, state, deltaTime)
    else
      if (state.canSpin) then
        local turns = trick:Land(self, ride, state)

        if (not turns) then
          isBailing = true
        elseif (turns > 0) then
          landedTricks[trick.id] = turns
        end

        clearTrickMemory(state)
      end

      inlineSkates.trick.straighten(state, deltaTime)
    end

    state.canSpin = canSpin
    isRotatingSkater = isRotatingSkater or (trick.rotatesSkater and isTrickActive(state))
    isSpinningSkater = isSpinningSkater or (trick.rotatesSkater and state.speed ~= 0)
    isFlippingSkater = isFlippingSkater or (trick.flipsSkater and state.speed ~= 0)
  end

  self.isRotatingSkater = isRotatingSkater
  -- Unlike `isRotatingSkater`, ends once the skater stops turning over rather than on landing.
  self.isSpinningSkater = isSpinningSkater
  -- Whether a flip is turning the skater over its toes or heels, which the landing assist leaves to it.
  self.isFlippingSkater = isFlippingSkater
  self:SendTrickStates()

  if (isBailing) then
    self.hasPendingCrash = true
  elseif (next(landedTricks)) then
    self:QueueLandedTricks(landedTricks)
  end

  return isSteeringTrick
end

--- Landed tricks are handled in Think, outside the physics step.
--- @param landedTricks table<string, number> Turns by trick id
function ENT:QueueLandedTricks(landedTricks)
  local pending = self.pendingLandedTricks or {}

  for id, turns in pairs(landedTricks) do
    pending[id] = (pending[id] or 0) + turns
  end

  self.pendingLandedTricks = pending
end

--- Shows the skater the tricks they landed.
--- @param rider Player
--- @param landedTricks table<string, number>
local function sendLandedTricks(rider, landedTricks)
  local landed = {}

  -- In the order the tricks were registered, so a combo always reads the same way.
  for _, trick in ipairs(inlineSkates.trick.getAll()) do
    if (landedTricks[trick.id] and #landed < LANDED_TRICKS_MAX) then
      landed[#landed + 1] = trick
    end
  end

  net.Start("inline_skates.TricksLanded")
  net.WriteUInt(#landed, 5)

  for _, trick in ipairs(landed) do
    inlineSkates.trick.write(trick)
    net.WriteFloat(landedTricks[trick.id])
  end

  net.Send(rider)
end

function ENT:HandleLandedTricks()
  local landedTricks = self.pendingLandedTricks

  if (not landedTricks) then
    return
  end

  self.pendingLandedTricks = nil

  local rider = self:GetRider()

  -- Knocked over since, such as by an impact in the same tick.
  if (not IsValid(rider) or self:GetCrashed()) then
    return
  end

  for id, turns in pairs(landedTricks) do
    local trick = inlineSkates.trick.get(id)

    if (trick) then
      trick:OnLanded(self, rider, turns)
    end
  end

  sendLandedTricks(rider, landedTricks)

  -- `landedTricks` holds the turns of each trick landed cleanly, by trick id, such as `{ backflip = 1, spin = 1.5 }`.
  hook.Run("InlineSkatesTrickLanded", rider, self, landedTricks)
end
