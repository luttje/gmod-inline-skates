local TRICK = {}

TRICK.id = "spin"
TRICK.name = "Spin"
TRICK.contact = { none = true }
TRICK.rotatesSkater = true
-- Steering into a jump keeps carving, a spin needs a fresh press in the air.
TRICK.needsFreshInput = true

local HALF_TURN = 180

-- How quickly the skater's spin follows the trick (1/s), and how hard it catches up on rotation it's behind (1/s).
local SPIN_RESPONSE = 20
local SPIN_ANGLE_GAIN = 8
-- Landing slower than this (u/s), the skater can face any way.
local FACING_MIN_SPEED = 60

--- A / D in the air spin round, in half turns: a 180 lands skating backwards.
function TRICK:ReadInput(input)
  -- Positive spins left.
  return -input.steerDirection, true
end

function TRICK:Spin(state, isDriven, direction, deltaTime)
  if (isDriven) then
    state.data.isSpinning = true
  end

  inlineSkates.trick.spin(state, isDriven, direction, inlineSkates.getTuning("spin_speed"), deltaTime, HALF_TURN)
end

-- Turns the skater around their own up to follow the spin.
function TRICK:Simulate(skates, physics, ride, state, deltaTime)
  local data = state.data

  if (not data.isSpinning) then
    return
  end

  local up = ride.angles:Up()
  local spinSpeed = ride.angularVelocity:Dot(up)

  -- Finished, the spin is stopped so the skater doesn't carry on turning.
  if (state.speed == 0) then
    if (not data.isReleased) then
      data.isReleased = true
      physics:AddAngleVelocity(physics:WorldToLocalVector(up * -spinSpeed))
    end

    return
  end

  data.isReleased = false
  data.rotated = (data.rotated or 0) + spinSpeed * deltaTime

  local wantedSpinSpeed = state.speed + (state.angle - data.rotated) * SPIN_ANGLE_GAIN
  local blend = 1 - math.exp(-SPIN_RESPONSE * deltaTime)

  physics:AddAngleVelocity(physics:WorldToLocalVector(up * ((wantedSpinSpeed - spinSpeed) * blend)))
end

--- Judged by how the skater really lands: facing along their path, forwards or backwards. Turns count in halves, so a
--- 180 is 0.5 and a 540 is 1.5.
function TRICK:Land(skates, ride, state)
  local halfTurns = math.abs(inlineSkates.trick.getNearestFullTurn(state.angle, HALF_TURN) / HALF_TURN)

  state.angle, state.speed = 0, 0

  if (not state.data.isSpinning) then
    return 0
  end

  local velocityAlongGround = ride.velocity - ride.groundNormal * ride.velocity:Dot(ride.groundNormal)
  local speed = velocityAlongGround:Length()

  if (speed > FACING_MIN_SPEED) then
    local facing = math.abs(ride.forwardAlongGround:Dot(velocityAlongGround / speed))

    if (facing < math.cos(math.rad(inlineSkates.getTuning("trick_land_tolerance")))) then
      return nil
    end
  end

  return halfTurns * 0.5
end

function TRICK:GetLandedName(turns)
  return string.format("%d", math.Round(turns * 360))
end

if (CLIENT) then
  -- The arms come in over this much of the start of each half turn, and go back out over this much of its end (deg).
  local ARMS_IN_ANGLE = 30

  --- @return number # 0 at whole half turns, easing up to 1 in between
  local function getSpinFraction(angle)
    local offset = math.abs(angle - inlineSkates.trick.getNearestFullTurn(angle, HALF_TURN))

    return math.sin(math.min(offset / ARMS_IN_ANGLE, 1) * math.pi * 0.5)
  end

  -- Pulls the legs together and the arms in to spin.
  function TRICK:AdjustPose(skates, pose, angle)
    pose.legsTogether = math.max(pose.legsTogether, getSpinFraction(angle))
  end

  function TRICK:AdjustHandTarget(skates, arm, target, angle, frame)
    local chest = arm.shoulder - frame.up * 6 + frame.forward * 5 - frame.left * (arm.side * 5)

    return LerpVector(getSpinFraction(angle) * 0.7, target, chest)
  end
end

inlineSkates.trick.register(TRICK)
