include("shared.lua")
include("cl_pose.lua")

-- The skater reaches well beyond the small entity, so it's drawn whenever any of this is in view.
local RENDER_MINS = Vector(-60, -60, -20)
local RENDER_MAXS = Vector(60, 60, 100)

-- In first person the camera sits in the skater's head, so the neck and everything above it is shrunk to almost
-- nothing. Not quite zero, as a degenerate bone matrix can break lighting.
local RIDER_NECK_BONE = "ValveBiped.Bip01_Neck1"
local SHRUNK_HEAD_SCALE = Vector(0.0001, 0.0001, 0.0001)

local cl_interp = GetConVar("cl_interp")
local cl_interp_ratio = GetConVar("cl_interp_ratio")
local cl_updaterate = GetConVar("cl_updaterate")

local DEBUG_DISTANCE = 1500
local DEBUG_CONTACT_SEGMENTS = 24
local DEBUG_LINE_LENGTH = 40
local DEBUG_VELOCITY_SCALE = 0.1
local EDITOR_MARKER_RADIUS = 1

local SOUNDS = {
  push = "inline_skates/push.wav",
  land = "inline_skates/land.wav",
}

-- Looping sounds fade towards their volume at this rate (1/s), and stop once quieter than the silent volume.
local LOOP_VOLUME_RESPONSE = 8
local LOOP_SILENT_VOLUME = 0.01
-- The wheels hum louder and higher the faster they roll. Speeds in u/s.
local ROLL_MIN_SPEED = 15
local ROLL_FULL_SPEED = 500
local ROLL_PITCH_MIN = 70
local ROLL_PITCH_MAX = 135
local ROLL_VOLUME_MIN = 0.15
local ROLL_VOLUME_MAX = 0.8
local BRAKE_PITCH_MIN = 90
local BRAKE_PITCH_MAX = 115
local BRAKE_FULL_PITCH_SPEED = 400
-- Only the skater hears the wind, from the min speed up to its loudest at the full speed.
local WIND_MIN_SPEED = 150
local WIND_FULL_SPEED = 650
local WIND_PITCH_MIN = 80
local WIND_PITCH_MAX = 130
local WIND_VOLUME_MAX = 1

local SOUND_LOOPS = {
  roll = { path = "inline_skates/roll_loop.wav", soundLevel = 65 },
  brake = { path = "inline_skates/brake_loop.wav", soundLevel = 72 },
  wind = { path = "inline_skates/wind_loop.wav", soundLevel = 0 },
}

function ENT:Initialize()
  self.soundLoops = {}
  self.soundLoopVolumes = {}
  self.trickAngles = {}
  self.trickSnapshots = {}
  self:InitPose()
  self:SetRenderBounds(RENDER_MINS, RENDER_MAXS)
end

function ENT:Draw()
  for index, skate in ipairs(self:GetFramePose().skates) do
    inlineSkates.skateParts.draw(
      self,
      skate.position,
      skate.angles,
      skate.side,
      self.pose.rolledDistance,
      self:GetCuffAngle(index)
    )
  end
end

--- @return boolean # Whether any trick is drawn turned
function ENT:IsDoingTrick()
  return next(self.trickAngles) ~= nil
end

--- @return boolean # Whether a trick that turns the skater over, such as a flip, is in progress
function ENT:IsRotatingTrick()
  for id in pairs(self.trickAngles) do
    local trick = inlineSkates.trick.get(id)

    if (trick and trick.rotatesSkater) then
      return true
    end
  end

  return false
end

--- Moves a bone to `position` and scales it there. Its children are left where they are.
local function shrinkBone(entity, bone, position, scale)
  local matrix = bone and entity:GetBoneMatrix(bone)

  if (matrix) then
    matrix:SetTranslation(position)
    matrix:Scale(scale)
    entity:SetBoneMatrix(bone, matrix)
  end
end

--- Collapses the neck and head, with everything attached to them, while the local skater sees their body in first
--- person. Runs inside the skater's "BuildBonePositions".
function ENT:ShrinkRiderHead(rider)
  -- Skipped while the camera measures where the skater's eyes are, and while it still eases in from the on-foot view
  -- and is outside the head.
  if (
        self:GetRider() ~= rider
        or rider.inlineSkatesKeepHead
        or not inlineSkates.isShowingFirstPersonBody(rider)
        or inlineSkates.isBlendingFromFootView()
      ) then
    return
  end

  local neck = rider:LookupBone(RIDER_NECK_BONE)
  local neckPosition = inlineSkates.ik.getBonePosition(rider, neck)

  if (not neckPosition) then
    return
  end

  shrinkBone(rider, neck, neckPosition, SHRUNK_HEAD_SCALE)

  for _, descendant in ipairs(inlineSkates.ik.getDescendants(rider, neck)) do
    shrinkBone(rider, descendant, neckPosition, SHRUNK_HEAD_SCALE)
  end
end

function ENT:StopPosingRider()
  if (IsValid(self.posedRider) and self.riderPoseCallback) then
    self.posedRider:RemoveCallback("BuildBonePositions", self.riderPoseCallback)
    self.posedRider:SetLOD(-1)
  end

  self.posedRider = nil
  self.riderPoseCallback = nil
end

--- Hooks the skater's bone setup whenever someone else puts the skates on.
function ENT:UpdateRiderPose()
  local rider = self:GetRider()

  if (self.posedRider == rider) then
    return
  end

  self:StopPosingRider()

  if (not IsValid(rider)) then
    return
  end

  self.posedRider = rider
  -- Lower detail levels leave bones like the toes and fingers out of the bone setup, which the limbs can't be solved
  -- without.
  rider:SetLOD(0)
  self.riderPoseCallback = rider:AddCallback("BuildBonePositions", function(player)
    -- Dormant skates' Think doesn't run, so they can't unhook themselves.
    if (IsValid(self) and not self:IsDormant()) then
      inlineSkates.ik.beginPass(player)
      self:PoseRider(player)
      self:ShrinkRiderHead(player)
    end
  end)
end

function ENT:IsWithinDebugDistance()
  return self:GetPos():DistToSqr(EyePos()) < DEBUG_DISTANCE * DEBUG_DISTANCE
end

--- The client traces the legs itself for the debug overlay, as the server's contacts aren't networked.
function ENT:UpdateDebugContacts()
  if (not inlineSkates.isDebugEnabled() or not IsValid(self:GetRider()) or not self:IsWithinDebugDistance()) then
    self.debugContacts = nil
    return
  end

  self.debugContacts = self.debugContacts or {}

  for index = 1, #self.Contacts do
    self.debugContacts[index] = self:TraceContact(index)
  end
end

--- Plays a one-off skating sound, heard by this client only: every client plays it from their own animation.
--- @param name string A key of SOUNDS
function ENT:PlaySkateSound(name, volume, pitch)
  local scaledVolume = volume * inlineSkates.getClientSetting("sound_volume")

  if (scaledVolume <= 0 or not inlineSkates.getTuningBool("sounds")) then
    return
  end

  self:EmitSound(SOUNDS[name], 70, pitch, scaledVolume)
end

function ENT:UpdateSoundLoop(name, volume, pitch, deltaTime)
  local currentVolume = Lerp(
    1 - math.exp(-LOOP_VOLUME_RESPONSE * deltaTime),
    self.soundLoopVolumes[name] or 0,
    volume
  )
  local loop = self.soundLoops[name]

  self.soundLoopVolumes[name] = currentVolume

  if (currentVolume < LOOP_SILENT_VOLUME) then
    if (loop and loop:IsPlaying()) then
      loop:Stop()
    end

    return
  end

  if (not loop) then
    local settings = SOUND_LOOPS[name]

    loop = CreateSound(self, settings.path)
    loop:SetSoundLevel(settings.soundLevel)
    self.soundLoops[name] = loop
  end

  if (loop:IsPlaying()) then
    loop:ChangeVolume(currentVolume)
    loop:ChangePitch(pitch)
  else
    loop:PlayEx(currentVolume, pitch)
  end
end

function ENT:UpdateSoundLoops(deltaTime)
  local rider = self:GetRider()
  local isRolling = IsValid(rider) and self:HasPoseFlag("grounded")
  local isEnabled = inlineSkates.getTuningBool("sounds")
  local skatingVolume = isEnabled and inlineSkates.getClientSetting("sound_volume") or 0
  local windVolume = isEnabled and inlineSkates.getClientSetting("sound_wind") or 0
  local absoluteSpeed = math.abs(self:GetForwardSpeed())
  local rollFraction = math.Clamp((absoluteSpeed - ROLL_MIN_SPEED) / (ROLL_FULL_SPEED - ROLL_MIN_SPEED), 0, 1)

  self:UpdateSoundLoop(
    "roll",
    (isRolling and absoluteSpeed > ROLL_MIN_SPEED) and Lerp(rollFraction, ROLL_VOLUME_MIN, ROLL_VOLUME_MAX)
        * skatingVolume or 0,
    Lerp(rollFraction, ROLL_PITCH_MIN, ROLL_PITCH_MAX),
    deltaTime
  )

  self:UpdateSoundLoop(
    "brake",
    IsValid(rider) and self:GetSkid() * skatingVolume or 0,
    Lerp(math.Clamp(absoluteSpeed / BRAKE_FULL_PITCH_SPEED, 0, 1), BRAKE_PITCH_MIN, BRAKE_PITCH_MAX),
    deltaTime
  )

  local windFraction = 0

  if (IsValid(rider) and rider == LocalPlayer()) then
    windFraction = math.Clamp(
      (self:GetVelocity():Length() - WIND_MIN_SPEED) / (WIND_FULL_SPEED - WIND_MIN_SPEED),
      0,
      1
    )
  end

  self:UpdateSoundLoop(
    "wind",
    windFraction * WIND_VOLUME_MAX * windVolume,
    Lerp(windFraction, WIND_PITCH_MIN, WIND_PITCH_MAX),
    deltaTime
  )
end

--- Also called when the skates leave the player's view, since Think stops running and would leave the loops playing.
function ENT:StopSoundLoops()
  for name, loop in pairs(self.soundLoops) do
    loop:Stop()
    self.soundLoopVolumes[name] = 0
  end
end

--- @return number # How far behind the server entities are drawn (s), as the engine works it out
local function getInterpolationDelay()
  return math.max(cl_interp:GetFloat(), cl_interp_ratio:GetFloat() / math.max(cl_updaterate:GetFloat(), 1))
end

--- Keeps the trick states the server sent, until the skates are drawn as of when they were sent.
--- @param time number Server time they were sent at
--- @param states table<string, table> `{ angle, speed }` of every trick that isn't straight, by trick id
function ENT:AddTrickSnapshot(time, states)
  self.trickSnapshots[#self.trickSnapshots + 1] = { time = time, states = states }
end

--- Draws tricks as of the moment the skates themselves are drawn, so they're in step with their movement. The server
--- sends a trick again once it drifts from its last sent speed, so carrying it on at that speed stays close.
function ENT:UpdateTrickAngles()
  local snapshots = self.trickSnapshots
  local drawTime = CurTime() - getInterpolationDelay()

  -- Only the newest snapshot the skates are drawn past is needed.
  while (snapshots[2] and snapshots[2].time <= drawTime) do
    table.remove(snapshots, 1)
  end

  table.Empty(self.trickAngles)

  local snapshot = snapshots[1]

  if (not snapshot or snapshot.time > drawTime) then
    return
  end

  for id, state in pairs(snapshot.states) do
    local angle = state.angle + state.speed * (drawTime - snapshot.time)

    self.trickAngles[id] = angle ~= 0 and angle or nil
  end
end

function ENT:Think()
  local deltaTime = FrameTime()

  self:UpdateTrickAngles()
  self:UpdatePose(deltaTime)
  self:UpdateRiderPose()
  self:UpdateDebugContacts()
  self:UpdateSoundLoops(deltaTime)

  self:SetNextClientThink(CurTime())
  return true
end

function ENT:OnRemove()
  self:StopPosingRider()
  self:StopSoundLoops()
end

--- Draws each leg's contact as the ride simulates it: a circle of the contact radius, with where it touches the
--- ground or a wall.
function ENT:DrawDebugContact(index, contactDefinition)
  local colors = inlineSkates.debugColors
  local radius = self.ContactRadius
  local topPosition = self:LocalToWorld(contactDefinition.position)
  local forward, up = self:GetForward(), self:GetUp()
  local contact = self.debugContacts and self.debugContacts[index]
  local color = (contact and contact.isGrounded) and colors.grounded or colors.airborne

  local function getRimPoint(angle)
    return topPosition + forward * (math.cos(angle) * radius) + up * (math.sin(angle) * radius)
  end

  local previousPoint = getRimPoint(0)

  for segment = 1, DEBUG_CONTACT_SEGMENTS do
    local point = getRimPoint(segment / DEBUG_CONTACT_SEGMENTS * math.pi * 2)

    render.DrawLine(previousPoint, point, color, false)
    previousPoint = point
  end

  if (contact and contact.isHit) then
    render.DrawLine(topPosition, contact.contactPosition, colors.contactTrace, false)
    render.DrawWireframeSphere(contact.contactPosition, 1.2, 6, 6, color, false)
  end

  if (contact and contact.wall) then
    render.DrawLine(topPosition, contact.wall.contactPosition, colors.contactTrace, false)
    render.DrawWireframeSphere(contact.wall.contactPosition, 1.2, 6, 6, color, false)
  end
end

--- Draws the body hull's rings and the edges between them.
function ENT:DrawDebugBodyHull(color)
  local vertices = self:GetBodyHullVertices()
  local cornersPerRing = 4

  for index, vertex in ipairs(vertices) do
    local ringStart = math.floor((index - 1) / cornersPerRing) * cornersPerRing
    local nextInRing = ringStart + (index - ringStart) % cornersPerRing + 1
    local position = self:LocalToWorld(vertex)

    render.DrawLine(position, self:LocalToWorld(vertices[nextInRing]), color, false)

    if (vertices[index + cornersPerRing]) then
      render.DrawLine(position, self:LocalToWorld(vertices[index + cornersPerRing]), color, false)
    end
  end
end

function ENT:DrawDebug()
  local colors = inlineSkates.debugColors
  local position = self:GetPos()

  if (not IsValid(self:GetRider())) then
    render.DrawWireframeBox(position, self:GetAngles(), self.ParkedMins, self.ParkedMaxs, colors.body, false)
    return
  end

  for index, contactDefinition in ipairs(self.Contacts) do
    self:DrawDebugContact(index, contactDefinition)
  end

  self:DrawDebugBodyHull(colors.body)

  local flatRight = self:GetRight()
  flatRight.z = 0
  flatRight:Normalize()

  local targetLeanRadians = math.rad(self:GetTargetLean())
  local targetUp = vector_up * math.cos(targetLeanRadians) + flatRight * math.sin(targetLeanRadians)

  render.DrawLine(position, position + self:GetUp() * DEBUG_LINE_LENGTH, colors.actualLean, false)
  render.DrawLine(position, position + targetUp * DEBUG_LINE_LENGTH, colors.targetLean, false)
  render.DrawLine(position, position + self:GetVelocity() * DEBUG_VELOCITY_SCALE, colors.velocity, false)
end

--- Marks where the model's settings put the skater's ankles (green) and toes (orange) in the skates.
function ENT:DrawEditorOverlay()
  local colors = inlineSkates.debugColors

  for _, skate in ipairs(self:GetFramePose().skates) do
    local ankle, toe = self:GetAnkleTarget(skate), self:GetToeTarget(skate)

    render.DrawWireframeSphere(ankle, EDITOR_MARKER_RADIUS, 8, 8, colors.editorAnkle, false)
    render.DrawWireframeSphere(toe, EDITOR_MARKER_RADIUS, 8, 8, colors.editorToe, false)
    render.DrawLine(ankle, toe, colors.editorToe, false)
  end
end
