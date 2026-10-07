local TRICK = {}

TRICK.id = "mute_grab"
TRICK.name = "Mute grab"
TRICK.keys = "[+attack]"
TRICK.description = "Your right skate crosses in front and your left hand reaches across to grab its toe."
TRICK.contact = { none = true }

local POSE_SPEED = 900
-- How far the upper body curls down to the skate (deg), and how far the grabbed skate crosses in and comes forward.
local CURL_TORSO = 22
local SKATE_CROSS = 4
local SKATE_FORWARD = 3
-- Where the hand holds the skate: up from the ground, forward to the toe and on its inner side.
local GRAB_HEIGHT = 7
local GRAB_FORWARD = 5
local GRAB_INWARD = 2.5

--- Hold left mouse in the air: the knees come up, the right skate crosses in front and the left hand reaches across to
--- grab its toe, while the right arm goes out for balance.
function TRICK:ReadInput(input)
  return input.isAltGrabHeld and 1 or 0
end

function TRICK:Spin(state, isDriven, direction, deltaTime)
  inlineSkates.trick.hold(state, isDriven, direction, POSE_SPEED, deltaTime)

  if (state.angle % 360 == 180) then
    state.data.wasPosed = true
  end
end

--- Forgiving: landing still holding the grab is fine, it counts once the grab was reached.
function TRICK:Land(skates, ride, state)
  state.angle, state.speed = 0, 0

  return state.data.wasPosed and 1 or 0
end

if (CLIENT) then
  function TRICK:AdjustPose(skates, pose, angle)
    local fraction = inlineSkates.trick.getPoseFraction(angle)

    pose.tuck = math.max(pose.tuck, fraction)
    pose.torsoPitch = pose.torsoPitch + CURL_TORSO * fraction
  end

  function TRICK:AdjustSkate(skates, leg, skate, angle, frame)
    if (leg.side == -1) then
      local fraction = inlineSkates.trick.getPoseFraction(angle)

      skate.position = skate.position
          + frame.left * (SKATE_CROSS * fraction)
          + frame.forward * (SKATE_FORWARD * fraction)
    end
  end

  function TRICK:AdjustHandTarget(skates, arm, target, angle, frame, skateFrames)
    local fraction = inlineSkates.trick.getPoseFraction(angle)

    if (arm.side == 1) then
      local skate = skateFrames[2]
      local grabPoint = skate.position + skate.angles:Up() * GRAB_HEIGHT + skate.angles:Forward() * GRAB_FORWARD
          - skate.angles:Right() * GRAB_INWARD

      return LerpVector(fraction, target, grabPoint)
    end

    local outward = (-frame.left * 0.85 + frame.up * 0.15 + frame.forward * 0.25):GetNormalized()

    return LerpVector(fraction, target, arm.shoulder + outward * arm.reach)
  end
end

inlineSkates.trick.register(TRICK)
