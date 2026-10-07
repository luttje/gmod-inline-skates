local TRICK = {}

TRICK.id = "safety_grab"
TRICK.name = "Safety grab"
TRICK.contact = { none = true }

local POSE_SPEED = 900
-- How far the upper body curls down to the skate (deg), and how far the grabbed skate comes out to the side.
local CURL_TORSO = 18
local SKATE_OUT = 2
-- Where the hand holds the skate's boot: up from the ground and outward of its middle.
local GRAB_HEIGHT = 9
local GRAB_OUTWARD = 3

--- Hold right mouse in the air: the knees come up and the right hand grabs the outside of the right skate, while the
--- left arm goes out for balance.
function TRICK:ReadInput(input)
  return input.isGrabHeld and 1 or 0
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
      skate.position = skate.position - frame.left * (SKATE_OUT * inlineSkates.trick.getPoseFraction(angle))
    end
  end

  function TRICK:AdjustHandTarget(skates, arm, target, angle, frame, skateFrames)
    local fraction = inlineSkates.trick.getPoseFraction(angle)

    if (arm.side == -1) then
      local skate = skateFrames[2]
      local grabPoint = skate.position + skate.angles:Up() * GRAB_HEIGHT + skate.angles:Right() * GRAB_OUTWARD

      return LerpVector(fraction, target, grabPoint)
    end

    local outward = (frame.left * 0.85 + frame.up * 0.15 + frame.forward * 0.25):GetNormalized()

    return LerpVector(fraction, target, arm.shoulder + outward * arm.reach)
  end
end

inlineSkates.trick.register(TRICK)
