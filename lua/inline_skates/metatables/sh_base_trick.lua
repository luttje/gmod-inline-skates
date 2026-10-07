--- Defaults for every registered trick, which a trick table overrides by setting the same key. A trick's `state.angle`
--- is signed and keeps counting past whole turns until it lands.
local BASE_TRICK = {}

BASE_TRICK.__index = BASE_TRICK

--- Shown to players, defaults to the id.
BASE_TRICK.name = nil

--- Where the skates may be while the trick is done: "none" in the air, "ground" rolling on the ground.
BASE_TRICK.contact = { none = true, ground = nil }

--- Shown in the guide binder: the keys that do the trick. Bracketed text is drawn as a key, and a bracketed bind is
--- drawn as whichever key the player has bound to it, such as "Double-tap [+back]" for double-tapping S.
BASE_TRICK.keys = nil

--- Shown in the guide binder: what the trick does. Where it can be done is taken from `contact`.
BASE_TRICK.description = nil

--- Whether the trick turns the skater's whole body over, which skips the crash check and the balance, and holds the
--- camera still.
BASE_TRICK.rotatesSkater = false

--- Whether the trick turns the skater over their toes or heels, like a flip. The landing assist leaves that pitch to
--- the trick while it turns.
BASE_TRICK.flipsSkater = false

--- Whether input already driving the trick when it becomes possible is ignored until pressed again. For tricks on keys
--- that also skate, such as steering into a jump.
BASE_TRICK.needsFreshInput = false

--- Server, every tick while the contact allows the trick.
--- @param input table
--- @param rider Player
--- @param state table `{ angle, speed, direction, data }`, `data` is the trick's own and cleared on landing
--- @return number direction 1 or -1 to drive the trick, 0 to let it finish
--- @return boolean? takesSteering Whether steering drives the trick instead of turning
function BASE_TRICK:ReadInput(input, rider, state)
  return 0, false
end

--- Server, moves `state.angle` and `state.speed` on, such as with `inlineSkates.trick.spin` or
--- `inlineSkates.trick.hold`.
--- @param state table
--- @param isDriven boolean
--- @param direction number 1 or -1 while driven
--- @param deltaTime number
function BASE_TRICK:Spin(state, isDriven, direction, deltaTime)
end

--- Server, applies forces to the skater after `Spin`.
--- @param skates Entity
--- @param physics PhysObj
--- @param ride table
--- @param state table
--- @param deltaTime number
function BASE_TRICK:Simulate(skates, physics, ride, state, deltaTime)
end

--- Server, when the skater touches down in a way the contact doesn't allow.
--- @param skates Entity
--- @param ride table
--- @param state table
--- @return number? # Whole turns landed, nil to knock the skater over
function BASE_TRICK:Land(skates, ride, state)
  local fullTurn = inlineSkates.trick.getNearestFullTurn(state.angle)
  local offset = state.angle - fullTurn

  state.angle, state.speed = offset, 0

  if (math.abs(offset) > inlineSkates.getTuning("trick_land_tolerance")) then
    return nil
  end

  return math.abs(fullTurn / 360)
end

--- Server, once landed cleanly with at least one whole turn.
--- @param skates Entity
--- @param rider Player
--- @param turns number
function BASE_TRICK:OnLanded(skates, rider, turns)
end

--- Shown to the skater when they land the trick.
--- @param turns number As returned by `Land`
--- @return string
function BASE_TRICK:GetLandedName(turns)
  if (turns > 1) then
    return string.format("%s x%s", self.name, turns)
  end

  return self.name
end

--- Client, changes how the body is held, before the skates and limbs are placed. `pose` holds:
--- `kneeFraction` (how far the hips are above the ankles, as a fraction of the leg length), `hipsDrop`, `hipsForward`
--- and `hipsSide` (units), `torsoPitch`, `torsoTwist` and `headYaw` (deg, positive leans forward and turns left),
--- `tuck` (0-1, how far the knees are pulled up in the air) and `legsTogether` (0-1).
--- @param skates Entity
--- @param pose table
--- @param angle number The drawn `state.angle`
function BASE_TRICK:AdjustPose(skates, pose, angle)
end

--- Client, moves a skate.
--- @param skates Entity
--- @param leg table `leg.side` is 1 for the left skate, -1 for the right one
--- @param skate table `{ position, angles }` in world space, change them in place. `position` is on the ground under
--- the middle of the frame.
--- @param angle number
--- @param frame table `{ origin, forward, left, up }` of the skater's body, in world space
function BASE_TRICK:AdjustSkate(skates, leg, skate, angle, frame)
end

--- Client, moves where a hand goes.
--- @param skates Entity
--- @param arm table `{ side, shoulder, reach }`: `side` is 1 for the left arm, -1 for the right one, `shoulder` is
--- where the arm starts and `reach` how far the hand comes from it with the elbow slightly bent
--- @param target Vector Where the wrist goes, world space
--- @param angle number
--- @param frame table `{ origin, forward, left, up }` of the skater's body, in world space
--- @param skateFrames table[] The two skates' `{ position, angles }`, left first
--- @return Vector
function BASE_TRICK:AdjustHandTarget(skates, arm, target, angle, frame, skateFrames)
  return target
end

RegisterMetaTable("inline_skates.trick", BASE_TRICK)
