local TRICK = {}

TRICK.id = "frontflip"
TRICK.name = "Front flip"
TRICK.contact = { none = true }
TRICK.rotatesSkater = true
TRICK.flipsSkater = true

-- How quickly the skater's pitch follows the flip (1/s), and how hard it catches up on rotation it's behind (1/s).
local FLIP_RESPONSE = 20
local FLIP_ANGLE_GAIN = 8
-- A double-tap keeps driving the flip at least this far round, so a quick second tap still commits to it (deg).
local FLIP_COMMIT_ANGLE = 60
-- How far the upper body curls over the tucked knees (deg).
local TUCK_TORSO = 20

--- Double-tap forward in the air to flip, keep holding it for more flips.
function TRICK:ReadInput(input, rider, state)
  local data = state.data

  if (input.doubleTaps[IN_FORWARD]) then
    data.isTriggered = true
    data.isFlipping = true
  elseif (not input.isPushHeld and math.abs(state.angle) >= FLIP_COMMIT_ANGLE) then
    data.isTriggered = false
  end

  return data.isTriggered and -1 or 0
end

function TRICK:Spin(state, isDriven, spinDirection, deltaTime)
  inlineSkates.trick.spin(state, isDriven, spinDirection, inlineSkates.getTuning("flip_speed"), deltaTime)
end

-- Turns the skater's pitch to follow the flip, positive tips the toes up, a front flip turns the other way.
function TRICK:Simulate(skates, physics, ride, state, deltaTime)
  local data = state.data

  if (not data.isFlipping) then
    return
  end

  local pitchSpeed = ride.angularVelocity:Dot(ride.right)

  -- A finished flip hands the skater back to the air controls and stops its last spin.
  if (state.speed == 0) then
    if (not data.isReleased) then
      data.isReleased = true
      physics:AddAngleVelocity(physics:WorldToLocalVector(ride.right * -pitchSpeed))
    end

    return
  end

  data.isReleased = false
  data.rotated = (data.rotated or 0) + pitchSpeed * deltaTime

  local wantedPitchSpeed = state.speed + (state.angle - data.rotated) * FLIP_ANGLE_GAIN
  local blend = 1 - math.exp(-FLIP_RESPONSE * deltaTime)

  physics:AddAngleVelocity(physics:WorldToLocalVector(ride.right * ((wantedPitchSpeed - pitchSpeed) * blend)))
end

-- Judged by how the skater really lands, not by the flip.
function TRICK:Land(skates, ride, state)
  local turns = math.abs(inlineSkates.trick.getNearestFullTurn(state.angle) / 360)

  state.angle, state.speed = 0, 0

  if (state.data.isFlipping and inlineSkates.trick.getTilt(ride) > inlineSkates.getTuning("trick_land_tolerance")) then
    return nil
  end

  return turns
end

if (CLIENT) then
  -- Tucks into a ball: knees to the chest and hands on the shins.
  function TRICK:AdjustPose(skates, pose, angle)
    local fraction = inlineSkates.trick.getTurnFraction(angle)

    pose.tuck = math.max(pose.tuck, fraction)
    pose.legsTogether = math.max(pose.legsTogether, fraction)
    pose.torsoPitch = pose.torsoPitch + TUCK_TORSO * fraction
  end

  function TRICK:AdjustHandTarget(skates, arm, target, angle, frame, skateFrames)
    local skate = skateFrames[arm.side == 1 and 1 or 2]
    local shin = skate.position + skate.angles:Up() * 14 + skate.angles:Forward() * 2

    return LerpVector(inlineSkates.trick.getTurnFraction(angle), target, shin)
  end
end

inlineSkates.trick.register(TRICK)
