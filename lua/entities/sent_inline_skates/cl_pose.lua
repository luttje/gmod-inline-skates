-- The skater's animation. The skates are placed first, then the skater's body is stood over them inside its own bone
-- setup.

local FULL_TURN = math.pi * 2
local HALF_TURN = math.pi

local RIDER_BONE_NAMES = {
  spine = "ValveBiped.Bip01_Spine",
  spine1 = "ValveBiped.Bip01_Spine1",
  spine2 = "ValveBiped.Bip01_Spine2",
  neck = "ValveBiped.Bip01_Neck1",
  leftThigh = "ValveBiped.Bip01_L_Thigh",
  leftCalf = "ValveBiped.Bip01_L_Calf",
  leftFoot = "ValveBiped.Bip01_L_Foot",
  leftToe = "ValveBiped.Bip01_L_Toe0",
  rightThigh = "ValveBiped.Bip01_R_Thigh",
  rightCalf = "ValveBiped.Bip01_R_Calf",
  rightFoot = "ValveBiped.Bip01_R_Foot",
  rightToe = "ValveBiped.Bip01_R_Toe0",
  leftClavicle = "ValveBiped.Bip01_L_Clavicle",
  leftUpperArm = "ValveBiped.Bip01_L_UpperArm",
  leftForearm = "ValveBiped.Bip01_L_Forearm",
  leftHand = "ValveBiped.Bip01_L_Hand",
  rightClavicle = "ValveBiped.Bip01_R_Clavicle",
  rightUpperArm = "ValveBiped.Bip01_R_UpperArm",
  rightForearm = "ValveBiped.Bip01_R_Forearm",
  rightHand = "ValveBiped.Bip01_R_Hand",
}
-- Without these the skater can't be stood over the skates, and keeps their plain standing sequence.
local REQUIRED_RIDER_BONES = { "leftThigh", "leftCalf", "leftFoot", "rightThigh", "rightCalf", "rightFoot", "neck" }

-- `side` is 1 on the skater's left, -1 on their right. The legs push in turn, half a stride apart.
local SKATER_LEGS = {
  { side = 1, thigh = "leftThigh", calf = "leftCalf", foot = "leftFoot", toe = "leftToe", phaseOffset = 0 },
  {
    side = -1,
    thigh = "rightThigh",
    calf = "rightCalf",
    foot = "rightFoot",
    toe = "rightToe",
    phaseOffset = HALF_TURN,
  },
}
local SKATER_ARMS = {
  {
    side = 1,
    clavicle = "leftClavicle",
    upperArm = "leftUpperArm",
    forearm = "leftForearm",
    hand = "leftHand",
    phaseOffset = 0,
  },
  {
    side = -1,
    clavicle = "rightClavicle",
    upperArm = "rightUpperArm",
    forearm = "rightForearm",
    hand = "rightHand",
    phaseOffset = HALF_TURN,
  },
}
-- Leaning forward bends through the whole spine, this share at each joint from the bottom up.
local SPINE_BENDS = {
  { bone = "spine", share = 0.4 },
  { bone = "spine1", share = 0.3 },
  { bone = "spine2", share = 0.3 },
}

-- A stride. Each leg pushes out to the side and back with its toe turned out and the skate on its inside edge, then
-- lifts and comes back in under the skater. Units and degrees.
local PUSH_BACK = 6
local PUSH_TOE_OUT = 26
local PUSH_EDGE = 14
local RECOVERY_LIFT = 3.5
local RECOVERY_FORWARD = 2.5
local SPRINT_STRIDE_SCALE = 1.35
-- Stepping round on the spot only lifts the feet in turn.
local STEP_LIFT = 2.5
-- The hips sway over the gliding leg and the shoulders twist with the arms.
local HIPS_SWAY = 2
local TORSO_TWIST = 9
local SPRINT_ARM_SWING_SCALE = 1.4

-- Turning, the inside skate leads and both turn into the turn.
local TURN_SCISSOR = 5
local TURN_TOE_IN = 6

-- Braking. A heel brake puts the right skate forward with its toe up, pivoting on its back wheel. A T-stop drags the
-- left skate crosswise behind the right one.
local HEEL_BRAKE_FORWARD = 9
local HEEL_BRAKE_TOE_UP = 16
local HEEL_BRAKE_BACK = 3
local REAR_WHEEL_PIVOT = 7
local T_STOP_BACK = 9
local T_STOP_INWARD = 1
local T_STOP_TURN = 80
local T_STOP_EDGE = 10
-- Braking while rolling backwards is a plow: the skates spread, heels pushed out and toes in, on their inside edges.
local PLOW_WIDTH = 4
local PLOW_TOE_IN = 20
local PLOW_EDGE = 12

-- Skating backwards, each push is a backwards C-cut: the skate pushes out to the side and forwards, its heel turned
-- out. The skater looks back over a shoulder, turning the head and twisting the shoulders that way (deg). Rolling
-- backwards faster than this (u/s) counts as skating backwards.
local BACKWARDS_LOOK_HEAD = 55
local BACKWARDS_LOOK_TWIST = 15
local BACKWARDS_MIN_SPEED = 30
-- Steering this far turns the head to look over the shoulder on that side.
local LOOK_SIDE_STEER = 0.2
local LOOK_SIDE_RESPONSE = 3

-- How far the knees come up, at full tuck: in the air a little, for a grab or flip all the way.
local TUCK_LIFT = 14
local TUCK_FORWARD = 3
local AIR_TUCK = 0.35
-- Legs together (tucked down or posing in the air) close the stance to this fraction.
local LEGS_TOGETHER_STANCE = 0.45

-- The body. How far the hips drop (fraction of the leg length) and the upper body leans forward (deg) for each of
-- what the skater does.
local SPRINT_KNEE = 0.05
local TUCK_KNEE = 0.16
local CROUCH_KNEE = 0.26
local BRAKE_KNEE = 0.05
local SPRINT_TORSO = 12
local TUCK_TORSO = 30
local CROUCH_TORSO = 16
local BRAKE_TORSO = -8
local AIR_TORSO = 4
local LAND_TORSO = 12
local BRAKE_HIPS_BACK = 3
-- The head turns back up by this much of the forward lean, to keep looking ahead.
local HEAD_COUNTER = 0.85
-- The hips follow this much of the skates stepping up or down onto uneven ground.
local HIPS_FOLLOW_GROUND = 0.5

-- Landing dips the hips this far, fully from this fall speed (u/s), easing back up at this rate (1/s).
local LAND_DIP_DEPTH = 9
local LAND_DIP_FULL_SPEED = 600
local LAND_DIP_MIN = 0.25
local LAND_DIP_DECAY = 5
-- Jumps are heard from this upward speed (u/s).
local JUMP_SOUND_MIN_SPEED = 60

-- The arms swing from the shoulder like a pendulum, this far forward and back (deg) at full swing. Swinging forward
-- folds the elbow up further, like running, and the shoulder itself moves forward and back with the arm.
local ARM_SWING_FORWARD = 50
local ARM_SWING_BACK = 40
local ARM_SWING_ELBOW = 45
local SHOULDER_SWING = 8
-- How far the elbows are bent (deg) hanging relaxed.
local RELAXED_ELBOW = 25
-- Tricks that move a hand within this distance of where the arm swings it leave the arm swinging.
local HAND_TARGET_EPSILON = 0.1
-- How far tricks may reach a hand from the shoulder, as a fraction of the arm's length, so the elbows stay bent.
local ARM_REACH = 0.88
-- The feet are shrunk into the boots, so the playermodel's shoes don't poke through them.
local FOOT_SCALE = Vector(0.8, 0.8, 0.8)
-- How far a skate model's cuff may turn from how it was modelled to follow the shin (deg, positive is forward). Cuff
-- angles older than this many frames are dropped, such as while the skater isn't drawn.
local CUFF_MIN_ANGLE = -15
local CUFF_MAX_ANGLE = 35
local CUFF_STALE_FRAMES = 2

-- Each skate is put on the ground found this far above and below it.
local GROUND_TRACE_UP = 12
local GROUND_TRACE_DOWN = 10
local MAX_GROUND_OFFSET = 8
local GROUND_OFFSET_RESPONSE = 25

-- How fast what the skater does blends in and out (1/s).
local POSE_RESPONSE = 6
local AIR_RESPONSE = 10
local CROUCH_RESPONSE = 12
local STEER_RESPONSE = 10

--- @type table<string, table|false> Bone indices by name key, per model. False for models missing required bones.
local riderBonesByModel = {}

--- @return table? # Bone indices by the keys of RIDER_BONE_NAMES, nil when the model can't be posed
local function getRiderBones(rider)
  local model = rider:GetModel()
  local bones = riderBonesByModel[model]

  if (bones == nil) then
    bones = {}

    for key, name in pairs(RIDER_BONE_NAMES) do
      bones[key] = rider:LookupBone(name)
    end

    for _, key in ipairs(REQUIRED_RIDER_BONES) do
      if (not bones[key]) then
        bones = false
        break
      end
    end

    riderBonesByModel[model] = bones
  end

  return bones or nil
end

local function blend(from, to, rate, deltaTime)
  return Lerp(1 - math.exp(-rate * deltaTime), from, to)
end

local function boolToNumber(value)
  return value and 1 or 0
end

function ENT:InitPose()
  self.pose = {
    -- Where each leg is in its stride, radians.
    phase = 0,
    push = 0,
    step = 0,
    sprint = 0,
    brake = 0,
    tuck = 0,
    air = 0,
    crouch = 0,
    steer = 0,
    -- How far the skater rolls and pushes backwards, 0-1.
    backwards = 0,
    backwardsPush = 0,
    -- Which shoulder the skater looks back over skating backwards, 1 the left and -1 the right.
    lookSide = 1,
    landDip = 0,
    -- How far the wheels have rolled forward (units), which turns each by its own radius.
    rolledDistance = 0,
    wasGrounded = true,
    lastVerticalSpeed = 0,
    groundOffsets = { 0, 0 },
    -- How far each cuff is turned forward to follow the shin (deg), left first, and the frame that worked it out.
    cuffAngles = { 0, 0 },
    cuffAnglesFrame = -1,
  }
end

--- Blends what the skater does in and out and moves the stride on. Plays the pushes, jumps and landings.
function ENT:UpdatePose(deltaTime)
  local pose = self.pose
  local isRidden = IsValid(self:GetRider())
  local isGrounded = not isRidden or self:HasPoseFlag("grounded")
  local isPushing = self:HasPoseFlag("pushing")
  local verticalSpeed = self:GetVelocity().z

  if (isRidden and isGrounded and not pose.wasGrounded) then
    local fallSpeed = -pose.lastVerticalSpeed

    pose.landDip = math.max(pose.landDip, math.Clamp(fallSpeed / LAND_DIP_FULL_SPEED, LAND_DIP_MIN, 1))
    self:PlaySkateSound("land", math.Clamp(fallSpeed / LAND_DIP_FULL_SPEED, 0.3, 1), math.random(95, 105))
  elseif (isRidden and not isGrounded and pose.wasGrounded and verticalSpeed > JUMP_SOUND_MIN_SPEED) then
    self:PlaySkateSound("land", 0.4, math.random(125, 135))
  end

  pose.wasGrounded = isGrounded
  pose.lastVerticalSpeed = verticalSpeed
  pose.landDip = pose.landDip * math.exp(-LAND_DIP_DECAY * deltaTime)

  local isPushingBackwards = self:HasPoseFlag("pushingBackwards")

  pose.push = blend(pose.push, boolToNumber(isPushing or isPushingBackwards), POSE_RESPONSE, deltaTime)
  pose.backwardsPush = blend(pose.backwardsPush, boolToNumber(isPushingBackwards), POSE_RESPONSE, deltaTime)
  pose.backwards = blend(
    pose.backwards,
    boolToNumber(isRidden and self:GetForwardSpeed() < -BACKWARDS_MIN_SPEED),
    POSE_RESPONSE,
    deltaTime
  )
  pose.step = blend(pose.step, boolToNumber(self:HasPoseFlag("stepping")), POSE_RESPONSE, deltaTime)
  pose.sprint = blend(pose.sprint, boolToNumber(self:HasPoseFlag("sprinting")), POSE_RESPONSE, deltaTime)
  pose.brake = blend(pose.brake, boolToNumber(self:HasPoseFlag("braking")), POSE_RESPONSE, deltaTime)
  pose.tuck = blend(pose.tuck, boolToNumber(self:HasPoseFlag("tucking")), POSE_RESPONSE, deltaTime)
  pose.air = blend(pose.air, boolToNumber(not isGrounded), AIR_RESPONSE, deltaTime)
  pose.crouch = blend(pose.crouch, self:GetCrouch(), CROUCH_RESPONSE, deltaTime)
  pose.steer = blend(pose.steer, self:GetSteer(), STEER_RESPONSE, deltaTime)

  -- Skating backwards, D curves the path round past the skater's left shoulder, so they look back over that one.
  if (math.abs(pose.steer) > LOOK_SIDE_STEER) then
    pose.lookSide = blend(pose.lookSide, pose.steer > 0 and 1 or -1, LOOK_SIDE_RESPONSE, deltaTime)
  end

  -- Each time a leg starts its push, which is every half a stride.
  local previousHalf = math.floor(pose.phase / HALF_TURN)

  pose.phase = (pose.phase + self:GetCadence() / 60 * FULL_TURN * deltaTime) % FULL_TURN

  if (isPushing and isGrounded and math.floor(pose.phase / HALF_TURN) ~= previousHalf) then
    self:PlaySkateSound("push", Lerp(pose.sprint, 0.5, 0.8), math.random(92, 108))
  end

  pose.rolledDistance = pose.rolledDistance + self:GetForwardSpeed() * deltaTime
end

--- @return table # `{ origin, forward, left, up, angles }` of the skates, in world space
function ENT:GetBodyFrame()
  local angles = self:GetAngles()

  return {
    origin = self:GetPos(),
    forward = angles:Forward(),
    left = -angles:Right(),
    up = angles:Up(),
    angles = angles,
  }
end

--- How the body is held this frame.
--- @return table
function ENT:BuildBodyPose()
  local pose = self.pose
  local pushAmount = pose.push * (1 - pose.air) * (1 - pose.brake) * (1 - pose.tuck)
  local body = {
    pushAmount = pushAmount,
    stepAmount = pose.step * (1 - pose.air),
    kneeFraction = 1 - inlineSkates.getClientSetting("skater_knee_bend")
        - SPRINT_KNEE * pose.sprint
        - TUCK_KNEE * pose.tuck
        - CROUCH_KNEE * pose.crouch
        - BRAKE_KNEE * pose.brake,
    hipsDrop = LAND_DIP_DEPTH * pose.landDip,
    hipsForward = -BRAKE_HIPS_BACK * pose.brake,
    hipsSide = -HIPS_SWAY * math.sin(pose.phase) * pushAmount,
    torsoPitch = inlineSkates.getClientSetting("skater_torso_lean")
        + SPRINT_TORSO * pose.sprint
        + TUCK_TORSO * pose.tuck
        + CROUCH_TORSO * pose.crouch
        + BRAKE_TORSO * pose.brake
        + AIR_TORSO * pose.air
        + LAND_TORSO * pose.landDip,
    torsoTwist = TORSO_TWIST * math.sin(pose.phase) * pushAmount
        + BACKWARDS_LOOK_TWIST * pose.lookSide * pose.backwards,
    -- Degrees the head turns left from looking ahead.
    headYaw = BACKWARDS_LOOK_HEAD * pose.lookSide * pose.backwards,
    tuck = AIR_TUCK * pose.air,
    legsTogether = pose.tuck,
  }

  for _, trick in ipairs(inlineSkates.trick.getAll()) do
    local angle = self.trickAngles[trick.id]

    if (angle) then
      trick:AdjustPose(self, body, angle)
    end
  end

  return body
end

--- @return number # How far the ground under `solePoint` is above it along `up`, 0 when there's none in reach
function ENT:TraceSkateGround(solePoint, up)
  local trace = util.TraceLine({
    start = solePoint + up * GROUND_TRACE_UP,
    endpos = solePoint - up * GROUND_TRACE_DOWN,
    filter = self:GetContactTraceFilter(),
    mask = MASK_SOLID,
  })

  if (not trace.Hit or trace.StartSolid) then
    return 0
  end

  return math.Clamp((trace.HitPos - solePoint):Dot(up), -MAX_GROUND_OFFSET, MAX_GROUND_OFFSET)
end

--- @return table[] # Each skate's `{ position, angles, side }` in world space, left first
function ENT:ComputeSkateFrames(frame, body)
  local pose = self.pose
  local strideScale = Lerp(pose.sprint, 1, SPRINT_STRIDE_SCALE)
  local pushOut = inlineSkates.getClientSetting("skater_stride_width") * strideScale
  local stanceHalf = self.StanceWidth * 0.5 * Lerp(body.legsTogether, 1, LEGS_TOGETHER_STANCE)
  local isHeelBrake = self.BrakeStyle ~= "tstop"
  -- Strides push back skating forwards and forwards skating backwards.
  local strokeDirection = Lerp(pose.backwardsPush, 1, -1)
  -- Rolling backwards, braking is a plow instead of the heel brake or T-stop.
  local plow = pose.brake * pose.backwards
  local forwardsBrake = pose.brake - plow
  local groundBlend = 1 - math.exp(-GROUND_OFFSET_RESPONSE * FrameTime())
  local skates = {}

  for index, leg in ipairs(SKATER_LEGS) do
    local side = leg.side
    local legPhase = (pose.phase + leg.phaseOffset) % FULL_TURN
    local extension, lift = 0, 0

    if (legPhase < HALF_TURN) then
      extension = (1 - math.cos(legPhase)) * 0.5
    else
      extension = (1 + math.cos(legPhase - HALF_TURN)) * 0.5
      lift = math.sin(legPhase - HALF_TURN)
    end

    local push = body.pushAmount
    local lateral = stanceHalf + pushOut * extension * push + PLOW_WIDTH * plow
    local along = (-PUSH_BACK * strideScale * extension * push + RECOVERY_FORWARD * lift * push) * strokeDirection
        - side * pose.steer * TURN_SCISSOR
    local height = RECOVERY_LIFT * lift * push + STEP_LIFT * lift * body.stepAmount
    -- Positive yaw turns the toe left, positive pitch lifts it and positive roll tips the skate to the right.
    local yaw = side * PUSH_TOE_OUT * extension * push * strokeDirection - pose.steer * TURN_TOE_IN
        - side * PLOW_TOE_IN * plow
    local pitch = 0
    local roll = side * (PUSH_EDGE * extension * push + PLOW_EDGE * plow)

    if (isHeelBrake) then
      if (side == -1) then
        along = along + HEEL_BRAKE_FORWARD * forwardsBrake
        pitch = pitch + HEEL_BRAKE_TOE_UP * forwardsBrake
      else
        along = along - HEEL_BRAKE_BACK * forwardsBrake
      end
    elseif (side == 1) then
      along = along - T_STOP_BACK * forwardsBrake
      lateral = Lerp(forwardsBrake, lateral, T_STOP_INWARD)
      yaw = yaw + T_STOP_TURN * forwardsBrake
      roll = roll + T_STOP_EDGE * forwardsBrake
    end

    -- Tipping the toe up pivots on the back wheel, which stays on the ground.
    height = height + math.sin(math.rad(pitch)) * REAR_WHEEL_PIVOT
        + TUCK_LIFT * body.tuck
    along = along + TUCK_FORWARD * body.tuck

    local solePoint = frame.origin + frame.forward * along + frame.left * (side * lateral)
    local groundOffset = 0

    if (pose.air < 0.99) then
      groundOffset = self:TraceSkateGround(solePoint, frame.up)
    end

    pose.groundOffsets[index] = Lerp(groundBlend, pose.groundOffsets[index], groundOffset)

    local angles = Angle(frame.angles)
    angles:RotateAroundAxis(angles:Up(), yaw)
    angles:RotateAroundAxis(angles:Right(), pitch)
    angles:RotateAroundAxis(angles:Forward(), roll)

    local skate = {
      position = solePoint + frame.up * (pose.groundOffsets[index] * (1 - pose.air) + height),
      angles = angles,
      side = side,
    }

    for _, trick in ipairs(inlineSkates.trick.getAll()) do
      local angle = self.trickAngles[trick.id]

      if (angle) then
        trick:AdjustSkate(self, leg, skate, angle, frame)
      end
    end

    skates[index] = skate
  end

  return skates
end

--- @return table[] # Each parked skate's `{ position, angles, side }`, standing side by side
function ENT:GetParkedSkateFrames()
  local angles = self:GetAngles()
  local skates = {}

  for index, leg in ipairs(SKATER_LEGS) do
    skates[index] = {
      position = self:LocalToWorld(Vector(0, leg.side * self.ParkedSkateOffset, 0)),
      angles = angles,
      side = leg.side,
    }
  end

  return skates
end

--- Everything drawing the skates and posing the skater needs this frame, worked out once per frame.
--- @return table # `{ frame, body, skates }`, `body` is nil for parked skates
function ENT:GetFramePose()
  if (self.framePoseNumber == FrameNumber() and self.framePose) then
    return self.framePose
  end

  self.framePoseNumber = FrameNumber()

  local frame = self:GetBodyFrame()

  if (not IsValid(self:GetRider())) then
    self.framePose = { frame = frame, skates = self:GetParkedSkateFrames() }
    return self.framePose
  end

  local body = self:BuildBodyPose()

  self.framePose = { frame = frame, body = body, skates = self:ComputeSkateFrames(frame, body) }

  return self.framePose
end

--- @param position Vector In the skate's own space
--- @param offset Vector Added to `position`, with its `y` inward: mirrored for each side
--- @return Vector # The point in world space
local function getSkatePoint(skate, position, offset)
  local angles = skate.angles

  return skate.position
      + angles:Forward() * (position.x + offset.x)
      - angles:Right() * (position.y - skate.side * offset.y)
      + angles:Up() * (position.z + offset.z)
end

--- @return Vector # Where the skater's ankle goes in this skate
function ENT:GetAnkleTarget(skate)
  local ankle = inlineSkates.skateParts.getFootPositions(self, skate.side)

  return getSkatePoint(skate, ankle, self.AnkleOffset)
end

--- @return Vector # Where the skater's toes go in this skate
function ENT:GetToeTarget(skate)
  local _, toe = inlineSkates.skateParts.getFootPositions(self, skate.side)

  return getSkatePoint(skate, toe, self.ToeOffset)
end

--- @return number # How far the cuff of the skate at this index turns forward to follow the shin (deg)
function ENT:GetCuffAngle(index)
  if (not IsValid(self:GetRider()) or FrameNumber() - self.pose.cuffAnglesFrame > CUFF_STALE_FRAMES) then
    return 0
  end

  return self.pose.cuffAngles[index]
end

--- How an arm is held, before tricks move the hand.
--- @return table # `{ upperDirection, elbowBend, foldDirection, shoulderSwing }`: where the upper arm points, the
--- elbow's bend (deg), which way the forearm folds from the upper arm and the shoulder's turn (deg, positive is back)
function ENT:GetArmPose(arm, frame, body, torsoForward, torsoUp)
  local pose = self.pose
  local side = arm.side
  local forward, left, up = torsoForward, frame.left, torsoUp
  local armPhase = (pose.phase + arm.phaseOffset) % FULL_TURN
  -- Positive while this side's leg pushes, which swings this arm back and the other one forward across the body.
  local swing = math.sin(armPhase) * body.pushAmount * inlineSkates.getClientSetting("skater_arm_swing")
      * Lerp(pose.sprint, 1, SPRINT_ARM_SWING_SCALE)
  local back, front = math.max(swing, 0), math.max(-swing, 0)
  local swingAngle = math.rad(ARM_SWING_FORWARD * front - ARM_SWING_BACK * back)

  -- Hanging down, swung forward (slightly across the body) or back (slightly out) around the shoulder.
  local upperDirection = -up * math.cos(swingAngle) + forward * math.sin(swingAngle)
      + forward * 0.15 + left * (side * (0.12 + 0.15 * back - 0.3 * front))
  local elbowBend = RELAXED_ELBOW + ARM_SWING_ELBOW * front
  local foldDirection = forward - left * (side * 0.2)

  local function blendTowards(fraction, direction, bend, fold)
    if (fraction <= 0) then
      return
    end

    upperDirection = LerpVector(fraction, upperDirection:GetNormalized(), direction:GetNormalized())
    elbowBend = Lerp(fraction, elbowBend, bend)
    foldDirection = LerpVector(fraction, foldDirection:GetNormalized(), fold:GetNormalized())
  end

  blendTowards(pose.brake, forward * 0.75 - up * 0.65 + left * (side * 0.35), 20, forward)
  blendTowards(pose.air, left * (side * 0.85) - up * 0.35 + forward * 0.3, 25, forward + up * 0.3)
  blendTowards(pose.crouch, -forward * 0.7 - up * 0.7 + left * (side * 0.15), 15, forward)
  -- Behind the back, the forearms fold in towards the spine.
  blendTowards(pose.tuck * (1 - pose.air), -up * 0.75 - forward * 0.55 + left * (side * 0.1), 95, -left * side)

  return {
    upperDirection = upperDirection:GetNormalized(),
    elbowBend = elbowBend,
    foldDirection = foldDirection,
    shoulderSwing = side * SHOULDER_SWING * swing,
  }
end

--- Poses an arm from the shoulder down: turns the shoulder, points the upper arm and bends the elbow.
function ENT:SwingArm(rider, arm, bones, armPose, torsoUp)
  local ik = inlineSkates.ik
  local getPosition = ik.getBonePosition
  local clavicle, upperArm, forearm = bones[arm.clavicle], bones[arm.upperArm], bones[arm.forearm]
  local clavicleRoot = getPosition(rider, clavicle)

  if (clavicleRoot) then
    ik.rotateAround(rider, ik.getBranch(rider, clavicle), clavicleRoot, torsoUp, armPose.shoulderSwing)
  end

  local shoulder, elbow = getPosition(rider, upperArm), getPosition(rider, forearm)

  if (not shoulder or not elbow) then
    return
  end

  local upperDirection = armPose.upperDirection

  ik.aimBone(rider, upperArm, elbow - shoulder, upperDirection)

  elbow = getPosition(rider, forearm)

  local wrist = getPosition(rider, bones[arm.hand])

  if (not elbow or not wrist) then
    return
  end

  -- The forearm turns from along the upper arm towards the fold direction by the elbow's bend.
  local fold = armPose.foldDirection - upperDirection * armPose.foldDirection:Dot(upperDirection)

  if (fold:LengthSqr() < 1e-4) then
    return
  end

  fold:Normalize()

  local bend = math.rad(armPose.elbowBend)

  ik.aimBone(rider, forearm, wrist - elbow, upperDirection * math.cos(bend) + fold * math.sin(bend))
end

--- Stands the skater over the skates. Runs inside the skater's "BuildBonePositions", after their sequence posed them.
function ENT:PoseRider(rider)
  if (self:GetRider() ~= rider or not inlineSkates.getClientSettingBool("skater_ik")) then
    return
  end

  local bones = getRiderBones(rider)
  local framePose = self:GetFramePose()

  if (not bones or not framePose.body) then
    return
  end

  local ik = inlineSkates.ik
  local getPosition = ik.getBonePosition
  local frame, body, skates = framePose.frame, framePose.body, framePose.skates
  local leftThigh, rightThigh = getPosition(rider, bones.leftThigh), getPosition(rider, bones.rightThigh)
  local leftCalf, leftFoot = getPosition(rider, bones.leftCalf), getPosition(rider, bones.leftFoot)
  local neck = getPosition(rider, bones.neck)

  -- Bones the engine skips in this setup pass have no matrix.
  if (not leftThigh or not rightThigh or not leftCalf or not leftFoot or not neck) then
    return
  end

  -- The hips and spine as the sequence posed them.
  local hips = (leftThigh + rightThigh) * 0.5
  local currentLeft = leftThigh - rightThigh
  local spineUp = neck - hips
  local currentUp = spineUp - currentLeft:GetNormalized() * spineUp:Dot(currentLeft:GetNormalized())

  if (currentLeft:LengthSqr() < 1e-4 or currentUp:LengthSqr() < 1e-4) then
    return
  end

  currentLeft:Normalize()
  currentUp:Normalize()

  -- 1. The whole body upright over the skates, the hips as high as the bent knees put them.
  local legLength = leftThigh:Distance(leftCalf) + leftCalf:Distance(leftFoot)
  local groundOffset = (self.pose.groundOffsets[1] + self.pose.groundOffsets[2]) * 0.5
      * (1 - self.pose.air) * HIPS_FOLLOW_GROUND
  -- The legs stand on the ankles, which are this high above the ground in the boots.
  local leftAnkle = inlineSkates.skateParts.getFootPositions(self, 1)
  local rightAnkle = inlineSkates.skateParts.getFootPositions(self, -1)
  local ankleHeight = (leftAnkle.z + rightAnkle.z) * 0.5 + self.AnkleOffset.z
  local hipsHeight = ankleHeight + legLength * body.kneeFraction - body.hipsDrop + groundOffset

  ik.moveSkeleton(rider, {
    origin = hips,
    forward = currentLeft:Cross(currentUp),
    left = currentLeft,
    up = currentUp,
  }, {
    origin = frame.origin + frame.up * hipsHeight + frame.forward * body.hipsForward + frame.left * body.hipsSide,
    forward = frame.forward,
    left = frame.left,
    up = frame.up,
  })

  -- 2. The upper body leaned forward, bending through the spine, and twisted with the arm swing.
  local torsoPitch = body.torsoPitch

  for _, spineBend in ipairs(SPINE_BENDS) do
    local bone = bones[spineBend.bone]
    local position = getPosition(rider, bone)

    if (position) then
      ik.rotateAround(rider, ik.getBranch(rider, bone), position, frame.left, torsoPitch * spineBend.share)
    end
  end

  local pitchRadians = math.rad(torsoPitch)
  local torsoForward = frame.forward * math.cos(pitchRadians) - frame.up * math.sin(pitchRadians)
  local torsoUp = frame.up * math.cos(pitchRadians) + frame.forward * math.sin(pitchRadians)
  local chestPosition = getPosition(rider, bones.spine2)

  if (chestPosition) then
    ik.rotateAround(rider, ik.getBranch(rider, bones.spine2), chestPosition, torsoUp, body.torsoTwist)
  end

  -- 3. The head turned back up to look ahead, or back over a shoulder skating backwards.
  local neckPosition = getPosition(rider, bones.neck)

  if (neckPosition) then
    local neckBranch = ik.getBranch(rider, bones.neck)

    ik.rotateAround(rider, neckBranch, neckPosition, frame.left, -torsoPitch * HEAD_COUNTER)
    ik.rotateAround(rider, neckBranch, neckPosition, frame.up, body.headYaw)
  end

  -- 4. The legs reaching into the boots, the knees over the toes.
  local kneeOut = inlineSkates.getClientSetting("skater_knee_out")

  for index, leg in ipairs(SKATER_LEGS) do
    local skate = skates[index]
    local thigh, calf, foot, toe = bones[leg.thigh], bones[leg.calf], bones[leg.foot], bones[leg.toe]
    local ankleTarget = self:GetAnkleTarget(skate)
    local toeTarget = self:GetToeTarget(skate)
    local kneePole = frame.forward + skate.angles:Forward() + frame.left * (leg.side * kneeOut) + frame.up * body.tuck

    ik.solveLimb(rider, thigh, calf, foot, ankleTarget, kneePole)

    local kneePosition, footPosition, toePosition = getPosition(rider, calf), getPosition(rider, foot),
        getPosition(rider, toe)

    -- The cuff leans with the shin, seen from the side of the skate.
    if (kneePosition and footPosition) then
      local shin = kneePosition - footPosition
      local lean = math.deg(math.atan2(shin:Dot(skate.angles:Forward()), shin:Dot(skate.angles:Up())))

      self.pose.cuffAngles[index] = math.Clamp(lean - self.CuffLean, CUFF_MIN_ANGLE, CUFF_MAX_ANGLE)
      self.pose.cuffAnglesFrame = FrameNumber()
    end

    if (footPosition and toePosition) then
      ik.aimBone(rider, foot, toePosition - footPosition, toeTarget - ankleTarget)

      local toeMatrix = rider:GetBoneMatrix(toe)

      if (toeMatrix) then
        footPosition = getPosition(rider, foot)
        toeMatrix:SetTranslation(footPosition + (toeMatrix:GetTranslation() - footPosition) * FOOT_SCALE.x)
        toeMatrix:Scale(FOOT_SCALE)
        rider:SetBoneMatrix(toe, toeMatrix)
      end
    end

    ik.scaleBone(rider, foot, FOOT_SCALE)
  end

  -- 5. The arms, swinging from the shoulders with the stride, unless a trick puts a hand somewhere: then the arm
  -- reaches there.
  for _, arm in ipairs(SKATER_ARMS) do
    local upperArm, forearm, hand = bones[arm.upperArm], bones[arm.forearm], bones[arm.hand]

    self:SwingArm(rider, arm, bones, self:GetArmPose(arm, frame, body, torsoForward, torsoUp), torsoUp)

    local shoulder, elbow, wrist = getPosition(rider, upperArm), getPosition(rider, forearm), getPosition(rider, hand)

    if (shoulder and elbow and wrist) then
      local armState = {
        side = arm.side,
        phaseOffset = arm.phaseOffset,
        shoulder = shoulder,
        reach = (shoulder:Distance(elbow) + elbow:Distance(wrist)) * ARM_REACH,
      }
      local target = wrist

      for _, trick in ipairs(inlineSkates.trick.getAll()) do
        local angle = self.trickAngles[trick.id]

        if (angle) then
          target = trick:AdjustHandTarget(self, armState, target, angle, frame, skates)
        end
      end

      if (target:DistToSqr(wrist) > HAND_TARGET_EPSILON * HAND_TARGET_EPSILON) then
        local elbowPole = -torsoForward * 0.5 + frame.left * (arm.side * 0.8) - torsoUp * 0.4

        ik.solveLimb(rider, upperArm, forearm, hand, target, elbowPole)
      end
    end
  end
end
