-- Speed per unit/s for each inline_skates_hud_speed_unit, 1 unit is 1.905 cm. Any other unit hides the speedometer.
local SPEED_UNIT_SCALES = {
  ["km/h"] = 0.06858,
  ["kmh"] = 0.06858,
  ["mp/h"] = 0.042613,
  ["mph"] = 0.042613,
  ["units"] = 1,
}

-- The skater's own sequence would twist the upper body towards where they look, which the pose does itself.
local ZEROED_POSE_PARAMETERS = { "aim_yaw", "aim_pitch", "body_yaw", "spine_yaw", "move_x", "move_y" }

local CAMERA_HULL_MINS = Vector(-4, -4, -4)
local CAMERA_HULL_MAXS = Vector(4, 4, 4)
-- The on-foot view is only blended from when it was seen this recently.
local MAX_FOOT_VIEW_AGE = 0.5
-- With inline_skates_cam_follow_travel, the camera looks the way the skater goes from this speed (u/s).
local CAMERA_FOLLOW_TRAVEL_SPEED = 60
-- How far (deg) a skater that sees their own body can look away from straight ahead. Looking down goes further, to see
-- the skates. Positive pitch looks down.
local BODY_LOOK_MAX_YAW = 120
local BODY_LOOK_MIN_PITCH = -60
local BODY_LOOK_MAX_PITCH = 80

-- Landed tricks stay on screen this long (s), fading out over the last part.
local LANDED_TRICKS_DURATION = 2.5
local LANDED_TRICKS_FADE = 0.6
local LANDED_TRICKS_COLOR = Color(255, 220, 90)

local LEAN_GAUGE_LENGTH = 60
local LEAN_GAUGE_MARKERS = { -45, 0, 45 }
local DEBUG_PANEL_LINE_HEIGHT = 14
local DEBUG_PANEL_BACKGROUND = Color(0, 0, 0, 170)
local CONTROL_HINTS = {
  "W: push",
  "S: brake, skate backwards from a standstill",
  "W rolling backwards: brake, then skate forwards",
  "A/D: steer (turn on the spot when standing)",
  "R: turn round (forwards <-> backwards)",
  "SHIFT: sprint",
  "CTRL: tuck down (less drag downhill)",
  "SPACE: hold to crouch, let go to jump",
  "E: take the skates off",
  "",
  "Tricks (in the air): ",
  "• W/S tip forward/back",
  "• W above a quarter pipe: spine transfer",
  "• A/D spin (180, 360, ...)",
  "• double-tap S/W backflip/front flip",
  "• MOUSE2 grab",
  "• MOUSE1 mute grab",
  "• CTRL christ air",
}

local function getLocalPlayerSkates()
  return inlineSkates.getFromSeat(LocalPlayer():GetVehicle())
end

--- @return Entity? # The skates the local player wears, or else the ones they look at
function inlineSkates.findLocalSkates()
  local skates = getLocalPlayerSkates() or LocalPlayer():GetEyeTrace().Entity

  return (IsValid(skates) and skates.IsInlineSkates) and skates or nil
end

local function formatVector(vector)
  return string.format("(%6.2f %6.2f %6.2f)", vector.x, vector.y, vector.z)
end

--- Prints every bone of a skate model, with its position and axes in the skate's own space, and what the addon read
--- from it: the wheels that spin with their radius, the cuffs, and the ankle and toe attachments.
local function printSkateModel(path)
  local info = inlineSkates.skateParts.getModelInfo(path)
  local model = ClientsideModel(path, RENDERGROUP_OPAQUE)

  if (not IsValid(model)) then
    print(string.format("[inline_skates] Couldn't load %s.", path))
    return
  end

  model:SetPos(vector_origin)
  model:SetAngles(angle_zero)
  model:SetupBones()

  local wheelRadii = {}

  for _, wheel in ipairs(info.wheels) do
    wheelRadii[wheel.bone] = wheel.radius
  end

  local isCuff = {}

  for _, cuff in ipairs(info.cuffs) do
    isCuff[cuff.bone] = true
  end

  print(string.format("[inline_skates] %s, %d spinning wheels, %d cuffs", path, #info.wheels, #info.cuffs))

  for bone = 0, model:GetBoneCount() - 1 do
    local matrix = model:GetBoneMatrix(bone)

    if (matrix) then
      local wheelNote = wheelRadii[bone] and string.format("  wheel, radius %.2f", wheelRadii[bone])
          or isCuff[bone] and "  cuff"
          or ""

      print(string.format(
        "%2d %-16s pos %s  X %s  Y %s  Z %s%s",
        bone,
        model:GetBoneName(bone),
        formatVector(matrix:GetTranslation()),
        formatVector(matrix:GetForward()),
        -- A matrix's "right" is its negated Y axis, which is the axle a wheel spins around.
        formatVector(-matrix:GetRight()),
        formatVector(matrix:GetUp()),
        wheelNote
      ))
    end
  end

  print(string.format(
    "ankle attachment %s, toe attachment %s",
    info.ankle and formatVector(info.ankle) or "missing",
    info.toe and formatVector(info.toe) or "missing"
  ))

  model:Remove()
end

concommand.Add("inline_skates_print_bones", function()
  local skates = inlineSkates.findLocalSkates()

  if (not skates) then
    print("[inline_skates] Wear or look at skates first.")
    return
  end

  local printed = {}

  for _, side in ipairs({ 1, -1 }) do
    local path = inlineSkates.skateParts.getModelPath(skates, side)

    if (path and not printed[path]) then
      printed[path] = true
      printSkateModel(path)
    end
  end

  if (not next(printed)) then
    print("[inline_skates] These skates have no skate model.")
  end
end)

-- The last frame the skates' camera made the view. Another addon's hook can take over the view before ours runs, which
-- would show the skater without a head.
local cameraFrame = -1

--- @return boolean # Whether `player` is the local player, skating with the settings for first person with their body
local function wantsFirstPersonBody(player)
  if (player ~= LocalPlayer() or GetViewEntity() ~= player or not inlineSkates.getClientSettingBool("cam_body")) then
    return false
  end

  return inlineSkates.getFromSeat(player:GetVehicle()) ~= nil
      and not inlineSkates.getClientSettingBool("cam_third_person")
end

--- @return boolean # Whether `player` is the local player, skating in first person with inline_skates_cam_body on,
--- seen through the skates' own camera
function inlineSkates.isShowingFirstPersonBody(player)
  return wantsFirstPersonBody(player) and cameraFrame >= FrameNumber() - 1
end

--- Where the skater's playermodel has its eyes this frame, as the seat's own eye position doesn't follow the skater's
--- pose. The bones are set up once with the head kept to measure this, then again with the head shrunk away.
--- @return Vector?
function inlineSkates.getRiderEyePosition(player)
  local eyesAttachment = player:LookupAttachment("eyes")

  if (not eyesAttachment or eyesAttachment <= 0) then
    return nil
  end

  player.inlineSkatesKeepHead = true
  player:InvalidateBoneCache()
  player:SetupBones()

  local eyes = player:GetAttachment(eyesAttachment)

  player.inlineSkatesKeepHead = nil
  player:InvalidateBoneCache()

  return eyes and eyes.Pos
end

hook.Add("PrePlayerDraw", "inlineSkates.riderPoseParameters", function(player)
  if (not inlineSkates.getFromSeat(player:GetVehicle())) then
    return
  end

  for _, name in ipairs(ZEROED_POSE_PARAMETERS) do
    player:SetPoseParameter(name, 0)
  end
end)

-- Where the local player looked from while on foot, and when they put on the skates they now wear.
local footView = nil
local putOnSeat = nil
local putOnAt = 0
local isBlendingFromFootView = false

-- The heading, slope and lean the camera follows, trailing the skater's by inline_skates_cam_smooth.
local smoothedSkates = nil
local smoothedHeading = { pitch = 0, yaw = 0, lean = 0 }
local smoothedFrame = -1
-- The skater's look from before a flip, held until it lands.
local heldRiderLook = nil

-- Tricks landed last, shown on the HUD: `{ text, at }`.
local landedTricks = nil

hook.Add("Think", "inlineSkates.trackFootView", function()
  local player = LocalPlayer()

  if (not IsValid(player) or player:InVehicle()) then
    return
  end

  putOnSeat = nil
  isBlendingFromFootView = false
  smoothedSkates = nil
  heldRiderLook = nil
  footView = {
    origin = player:EyePos(),
    angles = player:EyeAngles(),
    seenAt = RealTime(),
  }
end)

-- Skates' Think stops once they leave the player's view, so their looping sounds would keep playing.
hook.Add("NotifyShouldTransmit", "inlineSkates.stopSoundLoops", function(entity, shouldTransmit)
  if (not shouldTransmit and entity.IsInlineSkates and entity.soundLoops) then
    entity:StopSoundLoops()
  end
end)

net.Receive("inline_skates.TricksLanded", function()
  local names = {}

  for _ = 1, net.ReadUInt(5) do
    local trick = inlineSkates.trick.read()
    local turns = net.ReadFloat()

    if (trick) then
      names[#names + 1] = trick:GetLandedName(turns)
    end
  end

  if (#names > 0) then
    landedTricks = { text = table.concat(names, " + "), at = RealTime() }
  end
end)

local function lerpAngleShortest(fraction, from, to)
  return Angle(
    from.p + math.AngleDifference(to.p, from.p) * fraction,
    from.y + math.AngleDifference(to.y, from.y) * fraction,
    from.r + math.AngleDifference(to.r, from.r) * fraction
  )
end

--- Eases the camera from the on-foot view into `cameraView` right after putting the skates on.
local function blendFromFootView(vehicle, cameraView)
  if (putOnSeat ~= vehicle) then
    putOnSeat = vehicle
    putOnAt = RealTime()
  end

  isBlendingFromFootView = false

  local blendTime = inlineSkates.getClientSetting("cam_put_on_blend")

  if (blendTime <= 0 or not footView or putOnAt - footView.seenAt > MAX_FOOT_VIEW_AGE) then
    return
  end

  local fraction = (RealTime() - putOnAt) / blendTime

  if (fraction >= 1) then
    return
  end

  isBlendingFromFootView = true
  fraction = math.ease.InOutSine(fraction)
  cameraView.origin = LerpVector(fraction, footView.origin, cameraView.origin)
  cameraView.angles = lerpAngleShortest(fraction, footView.angles, cameraView.angles)
end

--- @return boolean # Whether the local player's camera is still easing into the skating view after putting them on
function inlineSkates.isBlendingFromFootView()
  return isBlendingFromFootView
end

--- @return number # The yaw the camera looks along: the skater's heading, or with inline_skates_cam_follow_travel in
--- third person the way they go, so skating backwards it looks past their back
local function getFollowedYaw(skates, headingYaw)
  if (not inlineSkates.getClientSettingBool("cam_follow_travel")
        or not inlineSkates.getClientSettingBool("cam_third_person")) then
    return headingYaw
  end

  local velocity = skates:GetVelocity()
  velocity.z = 0

  if (velocity:Length() > CAMERA_FOLLOW_TRAVEL_SPEED) then
    return velocity:Angle().y
  end

  -- Slower, such as standing still, the camera stays on whichever side of the skater it was, so it doesn't swing round
  -- each time they stop.
  local backwardsYaw = headingYaw + 180

  if (math.abs(math.AngleDifference(backwardsYaw, smoothedHeading.yaw))
        < math.abs(math.AngleDifference(headingYaw, smoothedHeading.yaw))) then
    return backwardsYaw
  end

  return headingYaw
end

--- Heading, slope pitch and lean are smoothed apart from each other: averaging the skater's angles as a whole mixes
--- the lean into pitch and yaw while leaned over, which makes the camera wobble through a turn.
local function updateSmoothedHeading(skates)
  -- A flip or spin turns the skater over, which would swing the heading round, so the camera holds still until it lands.
  if (smoothedSkates == skates and skates:IsRotatingTrick()) then
    return
  end

  local forwardAngles = skates:GetForward():Angle()

  if (smoothedSkates ~= skates) then
    smoothedSkates = skates
    -- Starts out behind the skater, unless they already skate backwards.
    smoothedHeading.yaw = forwardAngles.y
    smoothedHeading.yaw = getFollowedYaw(skates, forwardAngles.y)
    smoothedHeading.pitch, smoothedHeading.lean = 0, 0
  end

  -- The view can be calculated more than once per frame, but should only move on once.
  if (smoothedFrame == FrameNumber()) then
    return
  end

  smoothedFrame = FrameNumber()

  local yaw = getFollowedYaw(skates, forwardAngles.y)
  -- Looking past the skater's back, their slope and lean are seen the other way round.
  local facing = math.abs(math.AngleDifference(yaw, forwardAngles.y)) > 90 and -1 or 1
  local smoothTime = inlineSkates.getClientSetting("cam_smooth")
  local fraction = smoothTime > 0 and 1 - math.exp(-FrameTime() / smoothTime) or 1

  smoothedHeading.pitch = smoothedHeading.pitch
      + math.AngleDifference(forwardAngles.p * facing, smoothedHeading.pitch) * fraction
  smoothedHeading.yaw = smoothedHeading.yaw + math.AngleDifference(yaw, smoothedHeading.yaw) * fraction
  smoothedHeading.lean = Lerp(fraction, smoothedHeading.lean, skates:GetLean() * facing)
end

--- The skater's mouse look as pitch and yaw away from straight ahead, read from the seat without its own tilt, which
--- would roll the horizon while looking around.
--- @return Angle
local function getRiderLook(skates, vehicle, viewAngles)
  local _, eyeAngles = WorldToLocal(vector_origin, viewAngles, vector_origin, vehicle:GetAngles())
  local forward = skates.SeatForwardEyeAngles

  return Angle(eyeAngles.p - forward.p, math.AngleDifference(eyeAngles.y, forward.y), 0)
end

--- Keeps a look, as pitch and yaw away from straight ahead, within what a neck can turn.
--- @return Angle
local function clampBodyLook(look)
  return Angle(
    math.Clamp(look.p, BODY_LOOK_MIN_PITCH, BODY_LOOK_MAX_PITCH),
    math.Clamp(look.y, -BODY_LOOK_MAX_YAW, BODY_LOOK_MAX_YAW),
    0
  )
end

-- A skater that sees their own body can't look behind them, where they'd see their shrunken head. The input itself is
-- clamped, rather than just the view, so there's no dead zone to turn back through.
hook.Add("CreateMove", "inlineSkates.limitBodyLook", function(cmd)
  local player = LocalPlayer()

  if (not inlineSkates.isShowingFirstPersonBody(player)) then
    return
  end

  local forward = inlineSkates.getFromSeat(player:GetVehicle()).SeatForwardEyeAngles
  local viewAngles = cmd:GetViewAngles()
  local look = Angle(viewAngles.p - forward.p, math.AngleDifference(viewAngles.y, forward.y), 0)
  local clampedLook = clampBodyLook(look)

  if (clampedLook ~= look) then
    cmd:SetViewAngles(Angle(forward.p + clampedLook.p, forward.y + clampedLook.y, viewAngles.r))
  end
end)

--- The view follows the seat, so it turns, pitches and rolls as abruptly as the skater does. This puts the skater's
--- look onto a calmer frame: the smoothed heading and slope, with only inline_skates_cam_roll of the smoothed lean.
--- With inline_skates_cam_level only the heading is left.
--- @return Angle
local function getSmoothedViewAngles(skates, vehicle, viewAngles)
  updateSmoothedHeading(skates)

  local frame = Angle(0, smoothedHeading.yaw, 0)

  if (not inlineSkates.getClientSettingBool("cam_level")) then
    frame.p = smoothedHeading.pitch
    frame.r = smoothedHeading.lean * inlineSkates.getClientSetting("cam_roll")
  end

  -- Mid-flip the look read back from the seat jumps between equivalent angles, so the look from before is held.
  local look = heldRiderLook

  if (not look or not skates:IsRotatingTrick()) then
    look = getRiderLook(skates, vehicle, viewAngles)
    heldRiderLook = look
  end

  -- The input is already limited, this only covers the view being calculated before it.
  if (wantsFirstPersonBody(LocalPlayer())) then
    look = clampBodyLook(look)
  end

  local _, smoothedViewAngles = LocalToWorld(vector_origin, look, vector_origin, frame)

  return smoothedViewAngles
end

hook.Add("CalcVehicleView", "inlineSkates.camera", function(vehicle, player, view)
  local skates = inlineSkates.getFromSeat(vehicle)

  -- Looking through something else, like a camera.
  if (not skates or GetViewEntity() ~= player) then
    return
  end

  local angles = getSmoothedViewAngles(skates, vehicle, view.angles)
  local fullFovBoostSpeed = math.max(inlineSkates.getTuning("sprint_speed") * skates.SpeedScale, 1)
  local fovBoostFraction = math.Clamp(math.abs(skates:GetForwardSpeed()) / fullFovBoostSpeed, 0, 1)
  local cameraView = {
    origin = view.origin,
    angles = angles,
    fov = view.fov + fovBoostFraction * inlineSkates.getClientSetting("cam_fov_boost"),
    drawviewer = wantsFirstPersonBody(player),
  }

  -- Not the vehicle's own third person mode, which GMod toggles with Ctrl: that tucks down here.
  if (inlineSkates.getClientSettingBool("cam_third_person")) then
    local pivot = skates:GetPos() + vector_up * inlineSkates.getClientSetting("cam_height")
    local distance = inlineSkates.getClientSetting("cam_dist") * (1 + vehicle:GetCameraDistance())
    local trace = util.TraceHull({
      start = pivot,
      endpos = pivot - angles:Forward() * distance,
      mins = CAMERA_HULL_MINS,
      maxs = CAMERA_HULL_MAXS,
      filter = { skates, vehicle, player },
      mask = MASK_SOLID_BRUSHONLY,
    })

    cameraView.origin = trace.HitPos
    cameraView.drawviewer = true
  else
    -- The seat's eyes are where a seated player's would be, the skater's own eyes follow their pose.
    cameraView.origin = inlineSkates.getRiderEyePosition(player) or cameraView.origin
  end

  blendFromFootView(vehicle, cameraView)
  cameraFrame = FrameNumber()

  return cameraView
end)

local function drawLeanGaugeSpoke(x, y, lean, color)
  local radians = math.rad(lean)

  surface.SetDrawColor(color)
  surface.DrawLine(x, y, x + math.sin(radians) * LEAN_GAUGE_LENGTH, y - math.cos(radians) * LEAN_GAUGE_LENGTH)
end

local function drawLeanGauge(skates, x, y)
  local colors = inlineSkates.debugColors

  for _, markerLean in ipairs(LEAN_GAUGE_MARKERS) do
    drawLeanGaugeSpoke(x, y, markerLean, colors.marker)
  end

  drawLeanGaugeSpoke(x, y, skates:GetTargetLean(), colors.targetLean)
  drawLeanGaugeSpoke(x, y, skates:GetLean(), colors.actualLean)
end

local function describeContact(contact)
  if (not contact) then
    return "?"
  end

  return contact.isGrounded and string.format("down %4.1f", contact.compression) or "air      "
end

local function describePoseFlags(skates)
  local active = {}

  for name in SortedPairsByValue(skates.POSE_FLAGS) do
    if (skates:HasPoseFlag(name)) then
      active[#active + 1] = name
    end
  end

  return table.concat(active, " ")
end

local function drawDebugPanel(skates, speed)
  local contacts = skates.debugContacts or {}
  local lines = {
    string.format("%-8s %5.0f u/s", "speed", speed),
    string.format(
      "%-12s %5.1f    %-6s %5.1f",
      "lean", skates:GetLean(),
      "target", skates:GetTargetLean()
    ),
    string.format("%-8s %5.2f", "steer", skates:GetSteer()),
    string.format("%-8s %5.0f /min", "strides", skates:GetCadence()),
    string.format("%-8s %5.2f", "crouch", skates:GetCrouch()),
    string.format(
      "%-8s %-12s %-6s %s",
      "heels", describeContact(contacts[1]),
      "toes", describeContact(contacts[2])
    ),
    string.format("%-8s %s", "doing", describePoseFlags(skates)),
    "",
  }

  local longestLineLength = 0
  local longestLineText = ""

  for _, line in ipairs(lines) do
    if (#line > longestLineLength) then
      longestLineLength = #line
      longestLineText = line
    end
  end

  for _, hint in ipairs(CONTROL_HINTS) do
    lines[#lines + 1] = hint

    if (#hint > longestLineLength) then
      longestLineLength = #hint
      longestLineText = hint
    end
  end

  local x, y = 24, ScrH() * 0.4

  surface.SetFont("BudgetLabel")
  local width = surface.GetTextSize(longestLineText) + 20

  draw.RoundedBox(4, x - 10, y - 10, width, #lines * DEBUG_PANEL_LINE_HEIGHT + 20, DEBUG_PANEL_BACKGROUND)

  for index, line in ipairs(lines) do
    draw.SimpleText(line, "BudgetLabel", x, y + (index - 1) * DEBUG_PANEL_LINE_HEIGHT, color_white)
  end
end

local function drawLandedTricks(x, y)
  if (not landedTricks or not inlineSkates.getClientSettingBool("hud_tricks")) then
    return
  end

  local age = RealTime() - landedTricks.at

  if (age > LANDED_TRICKS_DURATION) then
    landedTricks = nil
    return
  end

  if (hook.Run("HUDShouldDraw", "InlineSkatesTricks") == false) then
    return
  end

  local alpha = math.Clamp((LANDED_TRICKS_DURATION - age) / LANDED_TRICKS_FADE, 0, 1) * 255
  local color = ColorAlpha(LANDED_TRICKS_COLOR, alpha)

  draw.SimpleTextOutlined(
    landedTricks.text,
    "DermaLarge",
    x,
    y,
    color,
    TEXT_ALIGN_CENTER,
    TEXT_ALIGN_CENTER,
    2,
    ColorAlpha(color_black, alpha)
  )
end

hook.Add("HUDPaint", "inlineSkates.hud", function()
  local skates = getLocalPlayerSkates()

  if (not skates) then
    return
  end

  local speed = skates:GetForwardSpeed()
  local centerX, speedometerY = ScrW() * 0.5, ScrH() - 90

  local speedUnit = inlineSkates.getClientSettingString("hud_speed_unit")
  local speedUnitScale = SPEED_UNIT_SCALES[speedUnit]

  if (speedUnitScale and hook.Run("HUDShouldDraw", "InlineSkatesSpeedometer") ~= false) then
    draw.SimpleTextOutlined(
      string.format("%d %s", math.Round(math.abs(speed) * speedUnitScale), speedUnit),
      "DermaLarge",
      centerX,
      speedometerY,
      color_white,
      TEXT_ALIGN_CENTER,
      TEXT_ALIGN_CENTER,
      2,
      color_black
    )
  end

  drawLandedTricks(centerX, speedometerY - 70)

  if (not inlineSkates.isDebugEnabled()) then
    return
  end

  drawLeanGauge(skates, centerX, speedometerY - 30)
  drawDebugPanel(skates, speed)
end)

hook.Add("PostDrawTranslucentRenderables", "inlineSkates.debugOverlay", function(_, isDrawingSkybox)
  if (isDrawingSkybox or not inlineSkates.isDebugEnabled()) then
    return
  end

  -- Every registered model is its own class derived from the skates entity.
  for _, skates in ipairs(ents.FindByClass(inlineSkates.ENTITY_CLASS .. "_*")) do
    if (skates:IsWithinDebugDistance()) then
      skates:DrawDebug()
    end
  end
end)
