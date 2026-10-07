local TRICK = {}

TRICK.id = "christ_air"
TRICK.name = "Christ air"
TRICK.keys = "[+duck]"
TRICK.description = "Legs straight and together, back arched and arms spread wide."
TRICK.contact = { none = true }
-- Tucking down (Ctrl) into a jump keeps the tuck, the pose needs a fresh press in the air.
TRICK.needsFreshInput = true

local POSE_SPEED = 700
-- How far the back arches (deg).
local ARCH_TORSO = 15

--- Hold Ctrl in the air: legs straight and together, back arched and arms spread straight out to the sides.
function TRICK:ReadInput(input)
  return input.isTuckHeld and 1 or 0
end

function TRICK:Spin(state, isDriven, direction, deltaTime)
  inlineSkates.trick.hold(state, isDriven, direction, POSE_SPEED, deltaTime)

  if (state.angle % 360 == 180) then
    state.data.wasPosed = true
  end
end

--- Forgiving: landing still posed is fine, it counts once the pose was reached.
function TRICK:Land(skates, ride, state)
  state.angle, state.speed = 0, 0

  return state.data.wasPosed and 1 or 0
end

if (CLIENT) then
  function TRICK:AdjustPose(skates, pose, angle)
    local fraction = inlineSkates.trick.getPoseFraction(angle)

    pose.tuck = Lerp(fraction, pose.tuck, 0)
    pose.legsTogether = math.max(pose.legsTogether, fraction)
    pose.torsoPitch = Lerp(fraction, pose.torsoPitch, -ARCH_TORSO)
    pose.kneeFraction = Lerp(fraction, pose.kneeFraction, 0.97)
  end

  function TRICK:AdjustHandTarget(skates, arm, target, angle, frame)
    local outward = (frame.left * arm.side + frame.up * 0.2):GetNormalized()

    return LerpVector(inlineSkates.trick.getPoseFraction(angle), target, arm.shoulder + outward * (arm.reach / 0.88))
  end
end

inlineSkates.trick.register(TRICK)
