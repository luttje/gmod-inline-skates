# Integrating with Gmod Inline Skates

This guide is for addon and gamemode developers. It covers adding your own skates and tricks, and the hooks that let
your code react to skaters. For skating, settings and installing, see the [README](README.md).

## Adding your own skates
Other addons can add their own skates. Each pair gets its own entry in the spawn menu. Register it from a shared
`lua/autorun/` file:

```lua
AddCSLuaFile()

hook.Add("InlineSkatesRegisterModels", "myaddon.skates", function()
  inlineSkates.registerModel("myskates", {
    name = "My Skates",
    model = "models/myname/skate.mdl",  -- one rigged skate, drawn on both feet
    rightBodygroups = { brake = 1 },    -- the heel brake, only on the right skate
  })
end)
```

- [📚 `MODELING_GUIDE.md`](MODELING_GUIDE.md) explains how to build and rig a skate model that works with the addon:
  its wheel bones spin as the skates roll, in any layout, and its attachments mark where the skater's foot goes.
- Every setting a model can have is listed in [`lua/inline_skates/sh_models.lua`](lua/inline_skates/sh_models.lua),
  along with the built-in skates as an example.
- To line up the skater's feet in the boots by eye, wear or look at your skates and run `inline_skates_editor`
  (admins). It gives you the matching `inlineSkates.registerModel` call to copy. `inline_skates_print_bones` shows what
  the addon read from your model.
- With `developer 1`, a debug overlay shows the skater's legs as they're simulated and their body hull.

## Adding your own tricks
Every trick is a file in `lua/inline_skates/tricks/`. The addon loads every file in that folder on the server and the
client, so another addon can add a trick by putting a file there too. A trick is an angle the server moves on from the
skater's input. Spins and flips have to land near a whole turn, while poses like grabs go half a turn in while held:

```lua
-- lua/inline_skates/tricks/myaddon_stalefish.lua
local TRICK = {}

TRICK.id = "myaddon_stalefish"
TRICK.name = "Stalefish"
-- Where the skates may be during the trick: "none" in the air and/or "ground"
TRICK.contact = { none = true }

-- Server: which way to drive the trick (1, -1, or 0 to let it finish), and whether it takes the steering
function TRICK:ReadInput(input, rider, state)
  return (input.isGrabHeld and input.isBrakeHeld) and 1 or 0, false
end

-- Server: hold the pose half a turn in while driven, see also inlineSkates.trick.spin for whole turns
function TRICK:Spin(state, isDriven, direction, deltaTime)
  inlineSkates.trick.hold(state, isDriven, direction, 900, deltaTime)
end

if (CLIENT) then
  -- Pulls the knees up, as far as the pose is in
  function TRICK:AdjustPose(skates, pose, angle)
    pose.tuck = math.max(pose.tuck, inlineSkates.trick.getPoseFraction(angle))
  end

  -- The left hand reaches behind to the left skate's heel
  function TRICK:AdjustHandTarget(skates, arm, target, angle, frame, skateFrames)
    if (arm.side ~= 1) then
      return target
    end

    local skate = skateFrames[1]
    local heel = skate.position + skate.angles:Up() * 8 - skate.angles:Forward() * 6

    return LerpVector(inlineSkates.trick.getPoseFraction(angle), target, heel)
  end
end

inlineSkates.trick.register(TRICK)
```

A trick can also apply forces to the skater (`Simulate`), judge its own landing (`Land`), turn the skater over
(`rotatesSkater`), move the skates (`AdjustSkate`) and name itself when landed (`GetLandedName`). All of it is
documented in [`lua/inline_skates/metatables/sh_base_trick.lua`](lua/inline_skates/metatables/sh_base_trick.lua). The
built-in tricks are complete examples, such as the [spin](lua/inline_skates/tricks/spin.lua), the
[backflip](lua/inline_skates/tricks/backflip.lua) and the [safety grab](lua/inline_skates/tricks/safety_grab.lua).

To give tricks more controls, add fields to the skater's input with the [`InlineSkatesReadInput`](#tricks) hook.

## Hooks
These hooks let gamemodes and other addons react to skaters. They run on the server, except for the HUD ones.

### Putting skates on and taking them off
`InlineSkatesCanPutOn` runs when a player presses **E** on a pair of skates. Return `false` to keep them from putting
them on:

```lua
--- @param player Player The player trying to put the skates on
--- @param skates Entity The skates
--- @return boolean? Return false to keep the player from putting them on
hook.Add("InlineSkatesCanPutOn", "myaddon.putOn", function(player, skates)
end)
```

Once a player has put them on or taken them off, `InlineSkatesPutOn` and `InlineSkatesTakenOff` run:

```lua
--- @param player Player The skater
--- @param skates Entity The skates
hook.Add("InlineSkatesPutOn", "myaddon.putOn", function(player, skates)
end)

--- @param player Player The skater
--- @param skates Entity The skates
--- @param isCrash boolean Whether they fell, see InlineSkatesSkaterCrashed
hook.Add("InlineSkatesTakenOff", "myaddon.takenOff", function(player, skates, isCrash)
end)
```

To keep a skater from taking them off, use GMod's own `CanExitVehicle` hook. `inlineSkates.getFromSeat(vehicle)` returns
the skates when the vehicle is a skates' seat, and `inlineSkates.getFromPlayer(player)` the skates a player wears:

```lua
hook.Add("CanExitVehicle", "myaddon.keepSkatesOn", function(vehicle, player)
  if (inlineSkates.getFromSeat(vehicle)) then
    return false
  end
end)
```

### Falling
`InlineSkatesShouldCrash` runs when a skater hits something hard enough, trips over a curb, lands too hard, leans or
tips too far, lands a trick badly, ends up lying on the ground or skates into water that's too deep. Return `false` to
keep them on their skates. While the skater stays tipped over, lying down or in deep water, this runs every tick, so
keep it cheap:

```lua
--- @param skates Entity The skates
--- @param skater Player The skater
--- @return boolean? Return false to stop the fall
hook.Add("InlineSkatesShouldCrash", "myaddon.noFalls", function(skates, skater)
  if (skater:HasGodMode()) then
    return false
  end
end)
```

When a skater falls, the server runs the `InlineSkatesSkaterCrashed` hook once their skates are off, just before
they're thrown. When RagMod is installed and enabled, and the `inline_skates_ragmod_crash` setting is on (the default),
they're thrown as a RagMod ragdoll. Return `false` to keep them from being thrown, for example to throw them your own
way:

```lua
--- @param player Player The skater that fell
--- @param skates Entity The skates they fell off
--- @param velocity Vector The velocity the skater is about to be thrown with
--- @return boolean? Return false to stop the default throw behaviour and handle it yourself
hook.Add("InlineSkatesSkaterCrashed", "myaddon.fall", function(player, skates, velocity)
  player:SetVelocity(velocity * 2)

  return false
end)
```

For example, to knock skaters out for 10 seconds in a [Helix](https://github.com/NebulousCloud/helix) schema, put this
in a server-side plugin or schema file:

```lua
hook.Add("InlineSkatesSkaterCrashed", "myschema.skatesKnockout", function(client, skates, velocity)
  client:SetRagdolled(true, 10)
end)
```

Damage dealt to a skater's body, such as bullets and explosions, hurts the skater. Servers can turn that off with
`inline_skates_forward_damage 0`.

### Tricks
`InlineSkatesReadInput` runs on the server every physics tick while someone skates. Add or change fields of `input` to
give tricks (`TRICK:ReadInput`) more controls. It runs often, so keep it cheap:

```lua
--- @param skater Player The skater
--- @param skates Entity The skates
--- @param input table The skater's input, see ENT:ReadRiderInput in lua/entities/sent_inline_skates/sv_ride.lua
hook.Add("InlineSkatesReadInput", "myaddon.walkKey", function(skater, skates, input)
  input.isWalkHeld = skater:KeyDown(IN_WALK)
end)
```

When a skater lands tricks cleanly, the server runs `InlineSkatesTrickLanded` with the turns of each trick by its id.
Spins count in half turns, so a 180 is `0.5`, and grabs and other poses count as `1`. Tricks landed without a turn
are left out:

```lua
--- @param skater Player The skater
--- @param skates Entity The skates
--- @param landedTricks table<string, number> Turns by trick id, such as { backflip = 1, safety_grab = 1, spin = 0.5 }
hook.Add("InlineSkatesTrickLanded", "myaddon.score", function(skater, skates, landedTricks)
  for id, turns in pairs(landedTricks) do
    local trick = inlineSkates.trick.get(id)

    skater:ChatPrint(trick:GetLandedName(turns))
  end
end)
```

### HUD
On the client, the speedometer and the names of landed tricks check GMod's own `HUDShouldDraw` hook with the names
`InlineSkatesSpeedometer` and `InlineSkatesTricks`, so a gamemode with its own HUD can hide them:

```lua
hook.Add("HUDShouldDraw", "myaddon.hideSkatesHud", function(name)
  if (name == "InlineSkatesSpeedometer" or name == "InlineSkatesTricks") then
    return false
  end
end)
```
