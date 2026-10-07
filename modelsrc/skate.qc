$modelname "inline_skates/rollerblade.mdl"
$cdmaterials "models/inline_skates/"
$scale 39.37
$origin 0 0 0 -90

$body "rollerblade" "rollerblade_ref.smd"

$sequence "idle" "rollerblade_ref.smd" fps 1

$attachment "ankle" "att_ankle" 0 0 0
$attachment "toe"   "att_toe"   0 0 0

$surfaceprop "plastic"

$collisionmodel "rollerblade_phys.smd" {
    $concave
    $mass 2
}
