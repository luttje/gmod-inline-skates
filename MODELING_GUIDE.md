# Making your own skates for Gmod Inline Skates

This guide walks you through turning a skate model into one that works with the addon: wheels that spin as you roll, a
cuff that leans with the skater's shins, and the skater's feet sitting in the boots. It works for any wheel layout, such
as inline skates with four wheels in a row or quad roller skates with two pairs. The addon finds everything by **bone
and attachment name**, so as long as you follow the names and rules below, your skates just work. The only code you need
is a few lines that register your model with the addon (step 9).

You only model **one skate**. The addon draws it on both feet.

## What you need

- **Blender** with [the **Blender Source Tools** add-on](https://developer.valvesoftware.com/wiki/Blender_Source_Tools) (exports `.smd` files)
- [**Crowbar**](https://developer.valvesoftware.com/wiki/Crowbar) (compiles your model into a `.mdl` for Garry's Mod)
- [**VTFEdit**](https://github.com/NeilJed/VTFLib) (converts your textures to Source's `.vtf` format)
- A skate model. If you download one (for example from Sketchfab), **check the license**: CC-BY means you must credit
  the author, and "NC" (non-commercial) licenses may limit where you can use it.

---

## 1. Clean up and orient the model

1. Delete everything that isn't a single skate: ground planes, lights, the other skate of the pair. If your left and
   right skates really differ, keep both and make two models (see `leftModel` and `rightModel` in step 9).
2. Keep it light: about **2,000–8,000 triangles**. Every skater shows two of them. The wheels and bearings are usually
   the heaviest part: 16 to 24 sides per wheel is plenty.
3. Keep the model at **real-world size, in meters**. Don't scale it up; the compile step does that for you. An adult
   inline skate is about 0.30 m long and 0.30 m tall.
4. Rotate the skate so it faces the right way:
   - **The toe points to +X** (the way the red X dot points in Blender's 3D View)
   - **Up is +Z**
   - That makes **left +Y** and right −Y.
5. Put the **origin (0,0,0) on the ground, under the middle of the skate**:
   - **Inline skates:** halfway between the front and back wheels, centered on the frame.
   - **Quad skates:** in the middle of the four wheels.
   - Either way, the **bottom of every wheel touches Z = 0**. The addon reads each wheel's radius from how high its
     axle is above the ground, so a wheel floating above or sunk below it spins at the wrong speed.
6. Select everything and press **Ctrl+A → All Transforms**.

## 2. Split the skate into parts

Every part that moves needs to be its own object. Select its faces in Edit mode and press **P → Selection**.

| Object | Contains |
|---|---|
| Boot | the foot of the boot, the frame or plate, the axle bolts: everything that never moves |
| Cuff | the top of the boot that wraps around the shin, with its buckle or strap |
| Wheel 1, Wheel 2, ... | one object per wheel, with its hub and bearings |
| Brake | the heel brake or toe stop, *only* if it should be on one skate but not the other |

**The cuff** leans forward and back with the skater's shin, like on a real skate, where it's riveted to the boot at the
ankle. The skater skates with bent knees, so their shins lean forward a lot: a cuff that can't move has the shins poking
through it. If your cuff is a separate hard shell, split it off. If it's one piece with the boot, such as a soft boot
with lacing up the front, keep it in the Boot: you'll let it bend with skinning in step 4. Low skates without a cuff
(such as quad skates with a low boot) can leave it out.

A brake that belongs on both skates (or a toe stop on a quad skate) can stay part of the Boot. A heel brake usually
only goes on the right skate: keep it as its own object, and it becomes a bodygroup in step 8.

## 3. Build the skeleton (armature)

Bones tell the game **where each wheel turns and around which line**, and where the cuff hinges.

### Add the root bone
In Object mode, press **Shift+A → Armature**. Keep the armature object at location 0, rotation 0, scale 1. Go into Edit
mode (Tab) and rename the bone to **`skate`**. Leave it at 0,0,0, pointing straight up. How far up the tail goes
doesn't matter.

### Add the other bones
For each wheel bone, find its pivot point first:
1. Select the wheel's mesh and enter Edit mode.
2. Select a ring of vertices around the axle.
3. Press **Shift+S → Cursor to Selected**. The 3D cursor is now exactly on the hub.
4. Go back to object mode and select the armature.
5. Go into the armature's Edit mode and press **Shift+A** to add a bone at the cursor.
6. Fine-tune its **Head** and **Tail** in the **N panel → Item** to point it in the direction listed in the tables
   below.

**The one rule that matters:** a bone's **head sits on the hub**, and the line from **head to tail is the axle it
spins around**. For every wheel, that line goes **sideways, pointing to the left** (+Y): set the tail to the head's
position plus a little Y. A wheel whose tail points right (−Y) spins backwards in game.

**Every bone whose name starts with `wheel` spins.** Name them however you like after that, as long as each name is
unique. The cuff works the same way: its bone's **head sits on the hinge** and its **tail points left**. For inline
skates, numbering the wheels from the front works well:

| Bone | Head goes at | Tail points | Parent |
|---|---|---|---|
| `skate` | 0,0,0 | up | – |
| `wheel_1` | front wheel's hub | left (+Y) | skate |
| `wheel_2` | second wheel's hub | left (+Y) | skate |
| `wheel_3` | third wheel's hub | left (+Y) | skate |
| `wheel_4` | back wheel's hub | left (+Y) | skate |
| `cuff` | the cuff's hinge, at the ankle | left (+Y) | skate |
| `att_ankle` | where the skater's ankle joint goes | anywhere | skate |
| `att_toe` | where the skater's toes go | anywhere | skate |

For quad skates, naming them after their corners keeps them apart:

| Bone | Head goes at | Tail points | Parent |
|---|---|---|---|
| `skate` | 0,0,0 | up | – |
| `wheel_FL` | front left wheel's hub (+Y) | left (+Y) | skate |
| `wheel_FR` | front right wheel's hub (−Y) | left (+Y) | skate |
| `wheel_RL` | rear left wheel's hub (+Y) | left (+Y) | skate |
| `wheel_RR` | rear right wheel's hub (−Y) | left (+Y) | skate |
| `cuff` | the cuff's hinge, at the ankle | left (+Y) | skate |
| `att_ankle` | where the skater's ankle joint goes | anywhere | skate |
| `att_toe` | where the skater's toes go | anywhere | skate |

Note that the right wheels' tails point left too, through the wheel: the direction is what counts, not the side the
wheel is on.

**Use `skate`, `cuff`, `att_ankle` and `att_toe` exactly, with no spaces.** The addon looks them up by name.

**The `cuff` bone** turns the cuff around the line from its head to its tail, so put the head on the hinge:
- On a skate with a riveted cuff, that's the rivet on the side of the boot, moved to the middle (Y = 0).
- Otherwise, put it at the ankle joint, the same spot as `att_ankle` below. The shin turns around the ankle, so a cuff
  hinged there stays wrapped around it.

The addon measures how far each shin leans forward and turns the cuff to match, from about 15° back to 35° forward of
how you modelled it. Every bone whose name starts with `cuff` turns that way, but one is all a skate needs.

The `att_` bones don't move anything. They only mark where the skater's foot goes:
- **`att_ankle`**: the ankle joint of a foot standing in the boot. That's above the heel, about a third of the way
  from the back of the boot, and about 8–10 cm above the insole. The addon puts the playermodel's ankle here, and
  bends the leg so the foot's ankle bone lands on it. It's **not** the top of the boot: the cuff reaches well above
  the ankle, and an `att_ankle` up there lifts the whole foot out of the boot.
- **`att_toe`**: the ball of the foot, near the front of the boot and just above the insole. The addon points the foot
  from the ankle towards here.

The feet are shrunk a little and hidden inside the boot, so it only has to be roomy around these two points. You can
fine-tune both in game afterwards (step 9).

The skater's physics don't use your wheels, so quads skate just like inline skates.

### Parent the bones
Parenting happens in the **armature's Edit mode**. Click a bone, then in the **Properties editor → Bone tab (green bone
icon) → Relations**, set its **Parent** to `skate`. Leave **Connected** unchecked, or the bone jumps to its parent.

> Can't click a bone? It's hidden inside the mesh. Press **Alt+Z** (X-ray), or select it in the Outliner.

## 4. Attach the parts to the bones (skinning)

With skinning you tell the game **which bone moves which part of the 3D mesh**. Each part must be skinned to exactly
one bone, with **weight 1.0** (full influence). The only exception is a cuff that bends with the boot (below). The
addon uses the bone names to find the wheels and the cuff.

Do this for each part:
1. In Object mode, click the mesh, Shift-click the armature, then press **Ctrl+P → With Empty Groups**.
2. Go into the mesh's Edit mode and select all (**A**).
3. In **Object Data → Vertex Groups**, pick the matching bone name and click **Assign** (weight 1.0).

| Object | Vertex group |
|---|---|
| Boot | `skate` |
| Cuff | `cuff` |
| Brake | `skate` |
| Wheel 1, Wheel 2, ... | its own `wheel_` bone |

*Note that the `att_` bones don't have any mesh assigned to them.*

### A cuff that bends with the boot
If the cuff is one piece with the boot, skinning it all to one bone would tear the mesh open at the ankle when the cuff
turns. Instead, blend the two bones across the ankle, so the boot bends there like soft material:
- Above the ankle: `cuff` 1.0.
- A band of about **2–4 cm around the ankle and the instep**: blending from `cuff` 1.0 at the top to `skate` 1.0 at
  the bottom, about half and half in the middle.
- Below: `skate` 1.0, for the foot of the boot, the sole and the frame.

The easiest way is **Weight Paint mode**: select the `cuff` vertex group and drag the **Gradient** tool from just above
the ankle to just below it, then paint `skate` the opposite way. Two bones per vertex is plenty; Source allows up to
three.

Painting easily misses spots, such as inside the boot or under the cuff's edge. To give every vertex without a weight
to `skate`:
1. In Weight Paint mode, **Weights → Clean** with **Subset: All Groups**. That takes vertices painted to 0 out of the
   groups, so they count as having no weight.
2. In Edit mode, switch to **vertex select** (press **1**), deselect all, then **Select → Select All by Trait →
   Ungrouped Vertices**.
3. In **Object Data → Vertex Groups**, pick `skate`, set Weight to 1.0 and click **Assign**.

Finish with **Weights → Normalize All** in Weight Paint mode, so the weights of every vertex add up to 1. To check for
gaps, turn on **Viewport Overlays → Zero Weights → All**: any vertex without a weight shows black.

### Test it
Go to **Pose mode**, select a wheel bone, press **R, then Y twice**, and move the mouse. That rotates the bone around
its own axis.
- Each wheel should spin **without wobbling** and without moving any other part. If it wobbles, the head isn't
  exactly on the hub.
- With the bone's tail pointing left, rotating it the positive way should roll the top of the wheel forward (+X).

Do the same with the `cuff` bone: rotating it the positive way should tip the top of the cuff forward, around the
ankle. Try about 30°: the cuff shouldn't come loose from the boot, and a cuff that bends with the boot should fold
smoothly at the ankle without tearing or crumpling.

Press **Alt+R** to reset the pose afterwards.

## 5. Make the collision (physics) mesh

The skate model gets a collision mesh of its own, so it also works as an ordinary physics prop: spawned from the spawn
menu or picked up with the physgun. The addon itself
ignores it: it only draws your model, and builds its own physics for the skates, both for a pair standing on the ground
and for the skater's body while they're worn.

The game uses a separate, very simple shape for collisions. Make **one object** out of **2 to 4 simple pieces**:

| Piece | Shape | Size |
|---|---|---|
| Boot | stretched box | from the heel to the toe, and from the sole to the top of the cuff; about as wide as the boot |
| Wheels | stretched box | **inline:** around the whole row of wheels and the frame, from the ground up to the sole, about as wide as the frame |
| | | **quads:** around both pairs of wheels and the plate, as wide as the outside of the wheels |

A high-top boot can be two boxes instead of one: a low one around the foot and a narrower, taller one around the
ankle. A more detailed collision mesh doesn't make the prop any better, only more expensive for the physics.

How to build it:
- **Boxes:** Shift+A → Cube, then scale it around the part in Edit mode. A rough fit is fine.
- Join the pieces with **Ctrl+J**, name the object `skate_phys`, and skin all of it to the **`skate`** bone (the same
  way as in step 4).
- The joined object keeps the location, rotation and scale of whichever piece was active, so press
  **Ctrl+A → All Transforms** on it again. Otherwise the collision model ends up in the wrong spot.
- Right-click → **Shade Smooth**. Otherwise the compiler can split the pieces into lots of little ones.

Rules:
- Every piece must be **convex**: no dents, holes or inward bevels. Plain boxes always are.
- Pieces **may overlap** in space, but must **not be connected**, meaning they share no vertices. Ctrl+J is safe;
  **Merge by Distance** and **Boolean union** are not. To check, hover over a piece in Edit mode and press **L**: only
  that one piece should light up.
- The bottom of the wheel box sits on the ground (Z = 0), like the wheels, so the prop stands on its wheels.
- Leave out the brake if it's a bodygroup, the buckles and other small details.

## 6. Collections (how the export is grouped)

Blender Source Tools exports **each collection as one file**. Parenting doesn't change that.
- Put the Boot, the Cuff and all the Wheels in a collection called **`skate_ref`**.
- If you have a separate Brake, put it in a collection called **`skate_brake`**.
- Put the physics object in a collection called **`skate_phys`**.

Select objects and press **M → + New Collection** to move them. The Source Engine Export panel should now list those
collections, and you export them as **SMD**.

## 7. Textures

Convert your textures to `.vtf` with VTFEdit and write a `.vmt` for each material. Put them in
`materials/models/<yourname>/skate/`. The **material names in Blender** must match the `.vmt` file names.

Skates can be colored: they spawn in a random color (with `randomColor` in step 9) and can be repainted with the Color
tool. To choose which parts take that color, such as the boot shell but not the wheels or buckles, paint a mask into
the **alpha channel of the base texture**: white where the color shows, black where the texture keeps its own colors.
Then turn it on in the `.vmt`:

```
"VertexLitGeneric"
{
	"$basetexture" "models/<yourname>/skate/skate"
	"$blendtintbybasealpha" 1
}
```

Without the mask the whole skate is tinted. Set `paint = false` in step 9 to keep your textures' own colors instead.

## 8. The QC file and compiling

Save this next to your SMDs as `skate.qc`:

```
$modelname "<yourname>/skate.mdl"
$cdmaterials "models/<yourname>/skate/"
$scale 39.37
$origin 0 0 0 -90

$body "skate" "skate_ref.smd"

// Only with a separate brake: off by default, turned on per skate in the registration.
$bodygroup "brake"
{
	blank
	studio "skate_brake.smd"
}

$sequence "idle" "skate_ref.smd" fps 1

$attachment "ankle" "att_ankle" 0 0 0
$attachment "toe"   "att_toe"   0 0 0

$surfaceprop "plastic"

$collisionmodel "skate_phys.smd" {
    $concave
    $mass 2
}
```

- **`$scale 39.37`** converts meters to Source units at the scale the playermodels are built (1 unit is an inch), so
  the boot fits the skater's foot. If the playermodels' shoes poke through your boot, go a little larger rather than
  making the boot bulkier.
- **`$origin 0 0 0 -90`** cancels the 90° turn that studiomdl gives every model. Without it the mesh faces sideways in
  game while the bones still face forward, and the wheels spin around the wrong axis.
- The attachment offsets are all zero on purpose, because the `att_` bones already mark the exact spots.
- The `brake` bodygroup's first entry, `blank`, is no brake. The registration in step 9 turns it on for the right
  skate only.
- **`$surfaceprop`** and **`$mass`** (kg, one skate) are for when the model is used as a prop. The addon sets its own
  mass for a pair (`mass` in step 9).

Compile with **Crowbar** (game: Garry's Mod) and open the result in **HLMV** to check it:
- the skate's toe points forward and its wheels stand on the ground
- the wheel bones rotate around their axles
- the cuff bone tips forward around the ankle
- the attachments show up at the ankle and the toes
- the `brake` bodygroup switches the brake on and off
- the collision view (Physics Model) shows your simple pieces, around the skate and down to the ground

## 9. Register your skates

Tell the addon about your model with a small Lua file in your own addon, for example `lua/autorun/sh_myskates.lua`:

```lua
AddCSLuaFile()

hook.Add("InlineSkatesRegisterModels", "myskates", function()
  inlineSkates.registerModel("myskates", {
    name = "My Skates",
    model = "models/<yourname>/skate.mdl",
    rightBodygroups = { brake = 1 },
    brakeStyle = "heel",
    randomColor = true,
  })
end)
```

- `name` is what the spawn menu shows. Your skates appear under **Entities** next to the included ones.
- `model` is drawn on both feet. If your left and right skates differ, set `leftModel` and `rightModel` as well, each
  replacing it on that side.
- `bodygroups` sets bodygroups on both skates, `leftBodygroups` and `rightBodygroups` on one of them, as
  `{ [bodygroup name] = submodel index }`.
- `brakeStyle` is how the skater brakes: `"heel"` puts the right skate forward onto its heel brake, `"tstop"` drags the
  left skate crosswise behind, for skates without a heel brake.
- `randomColor` spawns the skates in a random color, and `paint = false` keeps your textures' own colors instead (see
  step 7).
- `ankleOffset` and `toeOffset` move the skater's ankle and toes from your `att_ankle`/`att_toe` bones (forward, inward
  mirrored for each side, up), in case the feet don't sit right in the boot.
- `cuffLean` is how far the shin leans forward (degrees, 12 by default) when your cuff fits around it the way you
  modelled it. The cuff turns by how much further the shin leans. Raise it if the shins poke through the front of the
  cuff, lower it if they poke through the back.
- `stanceWidth` (how far apart the skates are while gliding), `mass` and `speedScale` (multiplies the server's top
  speeds, such as for speed skates) are optional. `lua/inline_skates/sh_models.lua` in this addon lists every setting.

The wheels and their sizes, the cuff, and where the ankle and toes go are read from your bones and attachments, so you
don't need to enter them.

### Check it in game

Spawn your skates, wear or look at them, and run **`inline_skates_print_bones`** in the console. It lists every bone of
your model with its position and axes, marks the ones that spin as wheels with the radius read for them and the cuff,
and says whether it found the ankle and toe attachments. A wheel missing from the list either has a name that doesn't
start with `wheel`, or its bone sits on the ground instead of on the hub.

### Tune it in game

Wear or look at your skates and run **`inline_skates_editor`** in the console (admins only). Its sliders change the
settings above live, and markers show where the ankles (green) and toes (orange) end up. Put the skates on to see the
skater's feet follow. When it looks right, click **Copy registration** and paste the result over the
`inlineSkates.registerModel` call in your file. Edits made in the editor only last until the map changes.
