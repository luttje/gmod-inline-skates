-- To translate the addon, copy this file to one named after the language's `gmod_language` code, such as "de.lua" or
-- "zh-CN.lua", and translate the text on the right of each `=`. Leave the keys on the left as they are.
--
-- - `{name}` is filled in by the addon, such as a number or a trick's name. Keep it, but move it wherever it reads best.
-- - `[+use]`, `[+forward]` and other bracketed binds are drawn as the key the player has bound to them. Keep them as
--   they are.
-- - Use `\n` for a line break, and `\"` for a double quote.
-- - Leave out any phrase you haven't translated yet, and the English one shows instead.
return {
  -- Spawn menu
  spawn_category = "Rides",
  entity_inline_skates = "Inline Skates",
  entity_guide = "Skate Guide",
  entity_guide_instructions = "Use it to read how to skate and do tricks",
  model_default = "Inline Skates",
  no_room_put_on = "There's no room to put the skates on here",
  no_room_take_off = "There's no room to take the skates off here",

  -- Options → Inline Skates
  options_category = "Inline Skates",
  options_client = "Client",
  options_server = "Server",
  options_client_help = "Your own camera, skater and debug settings. They are saved between sessions.",
  options_server_help =
  "How everyone skates. Only the server host can change these (in singleplayer, that's you), and the server saves them. On a dedicated server, set the inline_skates_* ConVars from the server console or server.cfg instead.",
  options_open_guide = "Open the skate guide",
  options_reset = "Reset to defaults",
  options_reset_client_done = "Client settings reset to defaults.",
  options_reset_tuning_done = "Server settings reset to defaults.",
  options_reset_tuning_denied = "You don't have access to reset the server settings.",
  options_skate_tools = "Wear or look at skates first:",
  options_open_editor = "Open the skate editor (admins)",
  options_print_bones = "Print the skate model's bones to the console",
  options_print_tuning = "Print all values to the console",
  options_tooltip = "{description}\n{convar} (default {default})",

  -- Server settings
  section_speed = "Speed and pushing",
  setting_top_speed = "Top speed",
  setting_top_speed_help = "Top skating speed (u/s). 360 u/s ~ 25 km/h",
  setting_sprint_speed = "Sprint speed",
  setting_sprint_speed_help = "Top speed while sprinting (u/s). 500 u/s ~ 34 km/h",
  setting_push_accel = "Push acceleration",
  setting_push_accel_help = "Acceleration while pushing off (u/s^2)",
  setting_sprint_accel = "Sprint acceleration",
  setting_sprint_accel_help = "Push acceleration multiplier while sprinting",
  setting_brake_accel = "Brake deceleration",
  setting_brake_accel_help = "Braking deceleration, with the heel brake or W while rolling backwards (u/s^2)",
  setting_backwards_speed = "Backwards top speed",
  setting_backwards_speed_help = "Top speed skating backwards, holding S (u/s). 260 u/s ~ 18 km/h",
  setting_backwards_accel = "Backwards acceleration",
  setting_backwards_accel_help = "Acceleration while pushing off skating backwards (u/s^2)",
  setting_rolling = "Rolling resistance",
  setting_rolling_help = "Rolling resistance while gliding (u/s^2)",
  setting_drag = "Air drag",
  setting_drag_help = "Air drag while gliding (per u/s^2)",
  setting_tuck_drag = "Tucked drag",
  setting_tuck_drag_help = "Air drag multiplier while tucked down (Ctrl), to pick up speed downhill",

  section_legs = "Legs and wheels",
  setting_spring = "Leg spring",
  setting_spring_help = "How stiff the skater's legs carry them (mass-normalised)",
  setting_damper = "Leg damping",
  setting_damper_help = "Leg damping",
  setting_grip = "Sideways grip",
  setting_grip_help = "How fast sideways slip is removed (1/s)",
  setting_mu = "Wheel friction",
  setting_mu_help = "Wheel friction coefficient (caps carving and braking)",

  section_steering = "Lean and steering",
  setting_lean_max = "Max lean",
  setting_lean_max_help = "Max lean angle (deg)",
  setting_lean_p = "Lean gain",
  setting_lean_p_help = "Lean controller gain (deg/s per deg of error)",
  setting_lean_rate = "Lean rate",
  setting_lean_rate_help = "Max lean rate (deg/s)",
  setting_lean_response = "Lean response",
  setting_lean_response_help = "How hard the lean controller corrects (1/s)",
  setting_lean_slack = "Lean slack",
  setting_lean_slack_help = "Carving allowed before the skater has leaned in (u/s^2)",
  setting_yaw_response = "Yaw response",
  setting_yaw_response_help = "How fast the heading follows the steering (1/s)",
  setting_landing_assist = "Landing assist",
  setting_landing_assist_help = "Turn skaters in the air to land square on their skates, facing along their path",
  setting_air_pitch_speed = "Air pitch speed",
  setting_air_pitch_speed_help = "How fast W / S tip the skater forward / back in the air (deg/s), 0 turns it off",
  setting_turn_radius_slow = "Turn radius (slow)",
  setting_turn_radius_slow_help = "Tightest turn at low speed (units)",
  setting_turn_radius_fast = "Turn radius (fast)",
  setting_turn_radius_fast_help = "Tightest turn at high speed (units)",
  setting_turn_slow_speed = "Slow turning below",
  setting_turn_slow_speed_help = "Below this speed the slow turn radius is allowed (u/s)",
  setting_turn_fast_speed = "Fast turning above",
  setting_turn_fast_speed_help = "Above this speed turns are widened to the fast turn radius (u/s)",
  setting_steer_rate = "Steer rate",
  setting_steer_rate_help = "How fast steering builds up (full turns per second)",
  setting_pivot_turn_speed = "Turn on the spot",
  setting_pivot_turn_speed_help = "How fast A / D turn a skater standing still, stepping round (deg/s)",

  section_tricks = "Jumping and tricks",
  setting_jump_min = "Jump (tap)",
  setting_jump_min_help = "Upward velocity of a tapped jump (u/s)",
  setting_jump_max = "Jump (charged)",
  setting_jump_max_help = "Upward velocity of a fully charged jump, holding Space (u/s)",
  setting_jump_charge_time = "Jump charge time",
  setting_jump_charge_time_help = "Seconds of holding Space for a fully charged jump",
  setting_jump_cooldown = "Jump cooldown",
  setting_jump_cooldown_help = "Seconds between jumps",
  setting_tricks = "Allow tricks",
  setting_tricks_help = "Let skaters grab, flip and spin in the air",
  setting_spin_speed = "Spin speed",
  setting_spin_speed_help = "How fast a skater spins round in the air (deg/s)",
  setting_flip_speed = "Flip speed",
  setting_flip_speed_help = "How fast a skater turns over during a backflip or front flip (deg/s)",
  setting_trick_land_tolerance = "Trick landing tolerance",
  setting_trick_land_tolerance_help = "Landing a flip or spin further off straight than this throws you off (deg)",

  section_crashes = "Crashes",
  setting_crash_speed = "Crash speed",
  setting_crash_speed_help = "Frontal impact speed that knocks you over (u/s)",
  setting_trip_speed = "Trip speed",
  setting_trip_speed_help = "Speed into a curb or step too tall to roll over that trips you (u/s)",
  setting_land_crash_speed = "Landing crash speed",
  setting_land_crash_speed_help = "Landing faster than this (u/s into the ground) knocks you over",
  setting_crash_lean = "Crash lean",
  setting_crash_lean_help = "Lean angle that counts as a fall (deg)",
  setting_crash_pitch = "Crash pitch",
  setting_crash_pitch_help = "Forward or backward tilt against the ground that counts as a fall (deg)",
  setting_forward_damage = "Skaters can be hurt",
  setting_forward_damage_help = "Damage dealt to the skater's body, such as bullets and explosions, hurts the skater",

  section_water = "Water",
  setting_water_level = "Knock over at water level",
  setting_water_level_help = "Water this deep knocks the skater over: 1 touching, 2 half under, 3 fully under, 0 never",
  setting_water_drag = "Water drag",
  setting_water_drag_help = "How hard water slows the skater once the skates are under (1/s)",

  section_sounds = "Sounds",
  setting_sounds = "Enable sounds",
  setting_sounds_help = "Play the skates' sounds: rolling, pushing, braking, wind, landings and falls",

  section_mass = "Mass and the skater",
  setting_mass_ridden = "Skating mass",
  setting_mass_ridden_help = "Physics mass while skating (skates + skater)",
  setting_take_off_anywhere = "Always let skaters take them off",
  setting_take_off_anywhere_help =
  "Skaters with no room to stand get off above the skates instead of keeping them on, which could put them past a player clip the skater went through",
  setting_ragmod_crash = "Ragdoll falling skaters (RagMod)",
  setting_ragmod_crash_help = "When RagMod is installed and enabled, skaters that fall become a RagMod ragdoll",
  setting_skater_seq = "Skater sequence",
  setting_skater_seq_help = "Player sequence the skater's pose starts from",

  -- Client settings
  section_camera = "Camera",
  setting_cam_third_person = "Third person view",
  setting_cam_third_person_help = "Skate in third person instead of first person",
  setting_cam_roll = "Camera roll",
  setting_cam_roll_help = "How much of the skater's lean the camera follows (0-1)",
  setting_cam_level = "Keep camera level",
  setting_cam_level_help =
  "Keep the horizon level: the camera only turns with the skater, never pitches or rolls with them",
  setting_cam_follow_travel = "Camera looks where you go",
  setting_cam_follow_travel_help =
  "In third person, look the way you're going: skating backwards, the camera looks past your back",
  setting_cam_smooth = "Camera smoothing",
  setting_cam_smooth_help =
  "Seconds the camera lags behind the skater turning and leaning, 0 is off. Mouse look stays instant",
  setting_cam_dist = "Camera distance",
  setting_cam_dist_help = "Third-person camera distance",
  setting_cam_height = "Camera height",
  setting_cam_height_help = "Third-person camera pivot height above the skates",
  setting_cam_fov_boost = "Sprint FOV boost",
  setting_cam_fov_boost_help = "Extra FOV at sprint speed",
  setting_cam_put_on_blend = "Camera blend when putting skates on",
  setting_cam_put_on_blend_help =
  "Seconds the camera takes to move from your on-foot view to the skating view, 0 is off",
  setting_cam_body = "Show your body in first person",
  setting_cam_body_help =
  "Draw your own playermodel in first person, without its head, so you see your arms and skates",

  section_skater = "Skater",
  setting_skater_ik = "Animate skaters",
  setting_skater_ik_help = "Pose skaters over their skates: striding, swinging their arms, crouching and tucking",
  setting_skater_knee_bend = "Knee bend",
  setting_skater_knee_bend_help = "How far skaters crouch while gliding, as a fraction of their leg length",
  setting_skater_torso_lean = "Forward lean",
  setting_skater_torso_lean_help = "How far skaters lean their upper body forward (deg)",
  setting_skater_stride_width = "Stride width",
  setting_skater_stride_width_help = "How far out to the side each push takes the skate",
  setting_skater_arm_swing = "Arm swing",
  setting_skater_arm_swing_help = "How far skaters swing their arms while pushing (0 keeps them still)",
  setting_skater_knee_out = "Knees outward",
  setting_skater_knee_out_help = "How far the knees point outward (0 = straight ahead)",

  section_hud = "HUD",
  setting_hud_speed_unit = "Speedometer",
  setting_hud_speed_unit_help = "Unit the speedometer shows while skating, or off to hide it",
  setting_hud_tricks = "Show landed tricks",
  setting_hud_tricks_help = "Show the names of the tricks you land",
  unit_kmh = "km/h",
  unit_mph = "mph",
  unit_units = "units",
  unit_off = "off",

  section_volume = "Sound",
  setting_sound_volume = "Skating sounds volume",
  setting_sound_volume_help = "Volume of every skater's rolling wheels, pushes, braking and landings (0-1)",
  setting_sound_wind = "Wind volume",
  setting_sound_wind_help = "Volume of the wind you hear while skating fast (0-1), 0 is off",

  section_debug = "Debug",
  setting_debug = "Debug overlay and HUD (needs developer 1)",
  setting_debug_help = "Draw the legs, lean and body box debug overlay and HUD (needs developer 1)",

  -- Keys, as drawn on keycaps
  key_mouse1 = "Left mouse",
  key_mouse2 = "Right mouse",
  key_mouse3 = "Middle mouse",
  key_mouse4 = "Mouse 4",
  key_mouse5 = "Mouse 5",
  key_mwheelup = "Wheel up",
  key_mwheeldown = "Wheel down",
  key_ctrl = "Ctrl",
  key_rctrl = "Right Ctrl",
  key_rshift = "Right Shift",
  key_ralt = "Right Alt",
  key_unbound = "{bind} (unbound)",

  -- Skate guide
  guide_title = "SKATE GUIDE",
  guide_subtitle = "EVERYTHING YOU NEED TO ROLL",
  guide_read_hint = "Press [+use] to read",
  guide_tip = "Tip",
  guide_previous = "< PREVIOUS",
  guide_next = "NEXT >",
  guide_chapter = "Chapter {number}",
  guide_page = "CHAPTER {number} / {total}",

  chapter_getting_started = "Getting started",
  getting_started_intro =
  "Grab a pair of skates from the spawn menu, under Entities → {category}. Put them on and you're standing on them right where you stood, facing where you looked.",
  getting_started_put_on = "Put the skates on, and take them off again",
  getting_started_push = "Push off",
  getting_started_steer = "Steer",
  getting_started_tip_take_off = "Take them off and they're left standing where you were, ready to put back on.",
  getting_started_tip_first_person =
  "Prefer skating in first person? Turn off Third person view under Options → Inline Skates → Client, or run inline_skates_cam_third_person 0 in the console.",
  getting_started_tip_lost = "Lost this binder? Run inline_skates_guide in the console to open the guide anywhere.",

  chapter_skating = "Skating",
  skating_intro =
  "Push off stride by stride, carve into corners and jump up curbs. Everything here works with your skates on the ground.",
  skating_push = "Push off. Rolling backwards, brake first",
  skating_brake = "Brake. Standing still, skate backwards",
  skating_steer = "Steer, leaning into the turn. Standing still, step round on the spot",
  skating_turn_round = "Turn round, from skating forwards to backwards or back, keeping your speed",
  skating_sprint = "Sprint: longer, faster strides",
  skating_tuck = "Tuck down low: no pushing, but less drag, so you pick up speed downhill",
  skating_jump_keys = "Hold [+jump]",
  skating_jump = "Crouch, charging the jump. Let go to jump: the longer you hold it, the higher you go",
  skating_take_off = "Take the skates off",
  skating_tip_backwards =
  "Skating backwards, the camera looks the way you're going and steering still turns you the way you'd expect from it. Prefer the camera to stay behind your back? Turn off Camera looks where you go under Options → Inline Skates → Client.",
  skating_falling = "Falling",
  skating_tip_fall =
  "Hitting a wall hard, or rolling fast into a curb you can't roll over, knocks you over. Jump up curbs instead.",
  skating_tip_water =
  "Water slows you down, and skating in until you're half under knocks you over. Server admins can change both, or turn the falling off, under Water in the server settings.",

  chapter_in_the_air = "In the air",
  in_the_air_intro = "Once your skates leave the ground, the keys turn you in the air instead.",
  in_the_air_disabled =
  "This server has turned tricks and tipping in the air off, so you fly wherever the jump takes you.",
  in_the_air_spin = "Spin round in half turns, see Tricks",
  in_the_air_pitch = "Tip forward / back",
  in_the_air_spine_transfer =
  "Above the top of a quarter pipe: spine transfer over the top and into the quarter pipe behind it",
  in_the_air_tip_landing_assist =
  "You're turned to come down square on your skates, onto whatever you're about to land on, such as the slope of a ramp or back down a quarter pipe. Coming down tilted anyway? Tip forward or back before you land.",
  in_the_air_tip_landing_assist_off =
  "This server has turned the landing assist off, so it's up to you to come down square on your skates.",
  in_the_air_tip_held_keys =
  "Keys you were already holding as you took off, such as steering or tucking into a jump, only turn you in the air once you press them again.",

  chapter_tricks = "Tricks",
  tricks_disabled =
  "This server has turned tricks off. You can still jump, tip forward and back and spine transfer, see In the air.",
  tricks_intro =
  "Get some air and throw down. Grabs last as long as you hold their keys, while spins and flips keep going, so let go in time to land them.",
  -- Where a trick can be done, shown on its card. A trick that can be done in more than one place lists each, joined
  -- by `tricks_place_separator`.
  tricks_place_none = "in the air",
  tricks_place_ground = "on the ground",
  tricks_place_separator = " or ",
  tricks_combos = "Combos",
  tricks_combos_intro = "Tricks combine. Try these to get started:",
  tricks_combo_backflip_safety_grab_keys = "Double-tap [+back], then [+attack2]",
  tricks_combo_backflip_safety_grab = "Backflip safety grab",
  tricks_combo_mute_grab_360 = "Mute grab 360",
  tricks_tip_landing =
  "Land your flips upright and your spins facing along the way you're going: forwards or backwards both work, but more than {degrees}° off knocks you over. Let go of the keys early and the trick finishes its turn by itself.",
  tricks_tip_180 = "Landed a 180? You carry on skating backwards, until you turn round to face forwards again.",

  chapter_settings = "Settings",
  settings_intro =
  "Open the spawn menu and go to Options → Inline Skates. Changes apply straight away, so you can tweak things while skating.",
  settings_client = "Client",
  settings_client_text =
  "Just for you, and saved between sessions: first or third person, camera distance and height, camera roll, how your character skates (knee bend, forward lean, stride width, arm swing), speedometer units, showing the tricks you land and the volume of the skating sounds and wind.",
  settings_server = "Server",
  settings_server_text =
  "How everyone skates: top speed, acceleration, braking, steering, jumping, tricks, falling and more. In singleplayer and on a server you host from the menu, you change them right there. On a dedicated server, the menu only shows them: set the inline_skates_* ConVars from the server console, rcon or cfg/server.cfg instead.",
  settings_tip_reset =
  "Changed too much? Run inline_skates_reset_client in the console to restore your own settings, or inline_skates_reset_tuning (admins) to restore the server settings.",

  -- Tricks
  trick_spin = "Spin",
  trick_spin_help =
  "Spins you round in half turns: 180, 360, 540... Keep holding for more. Land a 180 and you carry on skating backwards.",
  trick_backflip = "Backflip",
  trick_backflip_keys = "Double-tap [+back]",
  trick_backflip_help = "Tucks up and turns you over backwards. Keep holding the second press for more flips.",
  trick_frontflip = "Front flip",
  trick_frontflip_keys = "Double-tap [+forward]",
  trick_frontflip_help = "Tucks up and turns you over forwards. Keep holding the second press for more flips.",
  trick_safety_grab = "Safety grab",
  trick_safety_grab_help =
  "Knees up, and your right hand grabs the outside of your right skate. Lasts as long as you hold it.",
  trick_mute_grab = "Mute grab",
  trick_mute_grab_help = "Your right skate crosses in front and your left hand reaches across to grab its toe.",
  trick_christ_air = "Christ air",
  trick_christ_air_help = "Legs straight and together, back arched and arms spread wide.",

  -- Landed tricks, shown on the HUD
  hud_landed = "Landed",
  hud_combo = "{count}-trick combo",
  -- A trick landed with more than one whole turn, such as a double backflip.
  hud_turns = "{trick} x{turns}",
}
