-- Dutch (Nederlands). See en.lua for how to translate the addon.
return {
  -- Spawn menu
  spawn_category = "Vervoer",
  entity_inline_skates = "Inlineskates",
  entity_guide = "Skategids",
  entity_guide_instructions = "Gebruik hem om te lezen hoe je skatet en tricks doet",
  model_default = "Inlineskates",
  no_room_put_on = "Er is hier geen ruimte om de skates aan te trekken",
  no_room_take_off = "Er is hier geen ruimte om de skates uit te trekken",

  -- Options → Inline Skates
  options_category = "Inlineskates",
  options_client = "Client",
  options_server = "Server",
  options_client_help = "Je eigen camera-, skater- en debuginstellingen. Ze worden tussen sessies bewaard.",
  options_server_help =
  "Hoe iedereen skatet. Alleen de host van de server kan deze aanpassen (in singleplayer ben jij dat), en de server bewaart ze. Stel op een dedicated server in plaats daarvan de inline_skates_*-ConVars in via de serverconsole of server.cfg.",
  options_open_guide = "Open de skategids",
  options_reset = "Standaardwaarden herstellen",
  options_reset_client_done = "Clientinstellingen teruggezet naar de standaardwaarden.",
  options_reset_tuning_done = "Serverinstellingen teruggezet naar de standaardwaarden.",
  options_reset_tuning_denied = "Je hebt geen toegang om de serverinstellingen terug te zetten.",
  options_skate_tools = "Draag eerst skates of kijk ernaar:",
  options_open_editor = "Open de skate-editor (admins)",
  options_print_bones = "Toon de botten van het skatemodel in de console",
  options_print_tuning = "Toon alle waarden in de console",
  options_tooltip = "{description}\n{convar} (standaard {default})",

  -- Server settings
  section_speed = "Snelheid en afzetten",
  setting_top_speed = "Topsnelheid",
  setting_top_speed_help = "Topsnelheid tijdens het skaten (u/s). 360 u/s ~ 25 km/h",
  setting_sprint_speed = "Sprintsnelheid",
  setting_sprint_speed_help = "Topsnelheid tijdens het sprinten (u/s). 500 u/s ~ 34 km/h",
  setting_push_accel = "Afzetacceleratie",
  setting_push_accel_help = "Acceleratie tijdens het afzetten (u/s^2)",
  setting_sprint_accel = "Sprintacceleratie",
  setting_sprint_accel_help = "Vermenigvuldiger van de afzetacceleratie tijdens het sprinten",
  setting_brake_accel = "Remvertraging",
  setting_brake_accel_help = "Remvertraging, met de hielrem of W terwijl je achteruit rolt (u/s^2)",
  setting_backwards_speed = "Topsnelheid achteruit",
  setting_backwards_speed_help = "Topsnelheid bij achteruit skaten, met S ingedrukt (u/s). 260 u/s ~ 18 km/h",
  setting_backwards_accel = "Acceleratie achteruit",
  setting_backwards_accel_help = "Acceleratie tijdens het afzetten bij achteruit skaten (u/s^2)",
  setting_rolling = "Rolweerstand",
  setting_rolling_help = "Rolweerstand tijdens het glijden (u/s^2)",
  setting_drag = "Luchtweerstand",
  setting_drag_help = "Luchtweerstand tijdens het glijden (per u/s^2)",
  setting_tuck_drag = "Luchtweerstand in hurkhouding",
  setting_tuck_drag_help = "Vermenigvuldiger van de luchtweerstand in hurkhouding (Ctrl), om bergaf snelheid te maken",

  section_legs = "Benen en wielen",
  setting_spring = "Beenvering",
  setting_spring_help = "Hoe stijf de benen de skater dragen (genormaliseerd naar massa)",
  setting_damper = "Beendemping",
  setting_damper_help = "Beendemping",
  setting_grip = "Zijwaartse grip",
  setting_grip_help = "Hoe snel zijwaarts slippen wordt opgeheven (1/s)",
  setting_mu = "Wielwrijving",
  setting_mu_help = "Wrijvingscoëfficiënt van de wielen (begrenst bochtenwerk en remmen)",

  section_steering = "Hellen en sturen",
  setting_lean_max = "Maximale helling",
  setting_lean_max_help = "Maximale hellingshoek (graden)",
  setting_lean_p = "Hellingsversterking",
  setting_lean_p_help = "Versterking van de hellingsregelaar (graden/s per graad afwijking)",
  setting_lean_rate = "Hellingssnelheid",
  setting_lean_rate_help = "Maximale hellingssnelheid (graden/s)",
  setting_lean_response = "Hellingsrespons",
  setting_lean_response_help = "Hoe hard de hellingsregelaar corrigeert (1/s)",
  setting_lean_slack = "Hellingsspeling",
  setting_lean_slack_help = "Bochtenwerk dat is toegestaan voordat de skater de bocht in helt (u/s^2)",
  setting_yaw_response = "Draairespons",
  setting_yaw_response_help = "Hoe snel de rijrichting het sturen volgt (1/s)",
  setting_landing_assist = "Landingshulp",
  setting_landing_assist_help =
  "Draait skaters in de lucht zodat ze recht op hun skates landen, in de richting van hun baan",
  setting_air_pitch_speed = "Kantelsnelheid in de lucht",
  setting_air_pitch_speed_help =
  "Hoe snel W / S de skater in de lucht voorover / achterover kantelen (graden/s), 0 zet het uit",
  setting_turn_radius_slow = "Draaicirkel (langzaam)",
  setting_turn_radius_slow_help = "Krapste bocht bij lage snelheid (units)",
  setting_turn_radius_fast = "Draaicirkel (snel)",
  setting_turn_radius_fast_help = "Krapste bocht bij hoge snelheid (units)",
  setting_turn_slow_speed = "Langzaam draaien onder",
  setting_turn_slow_speed_help = "Onder deze snelheid is de langzame draaicirkel toegestaan (u/s)",
  setting_turn_fast_speed = "Snel draaien boven",
  setting_turn_fast_speed_help = "Boven deze snelheid worden bochten verbreed tot de snelle draaicirkel (u/s)",
  setting_steer_rate = "Stuursnelheid",
  setting_steer_rate_help = "Hoe snel het sturen opbouwt (volledige uitslagen per seconde)",
  setting_pivot_turn_speed = "Draaien op de plaats",
  setting_pivot_turn_speed_help = "Hoe snel A / D een stilstaande skater met kleine stapjes ronddraaien (graden/s)",

  section_tricks = "Springen en tricks",
  setting_jump_min = "Sprong (tik)",
  setting_jump_min_help = "Opwaartse snelheid van een getikte sprong (u/s)",
  setting_jump_max = "Sprong (opgeladen)",
  setting_jump_max_help = "Opwaartse snelheid van een volledig opgeladen sprong, met de spatiebalk ingedrukt (u/s)",
  setting_jump_charge_time = "Oplaadtijd van de sprong",
  setting_jump_charge_time_help = "Seconden dat je de spatiebalk ingedrukt houdt voor een volledig opgeladen sprong",
  setting_jump_cooldown = "Wachttijd tussen sprongen",
  setting_jump_cooldown_help = "Seconden tussen sprongen",
  setting_tricks = "Tricks toestaan",
  setting_tricks_help = "Laat skaters in de lucht grabben, flippen en spinnen",
  setting_spin_speed = "Spinsnelheid",
  setting_spin_speed_help = "Hoe snel een skater in de lucht ronddraait (graden/s)",
  setting_flip_speed = "Flipsnelheid",
  setting_flip_speed_help = "Hoe snel een skater omdraait tijdens een backflip of frontflip (graden/s)",
  setting_trick_land_tolerance = "Landingstolerantie voor tricks",
  setting_trick_land_tolerance_help = "Land je een flip of spin schever dan dit, dan val je (graden)",

  section_crashes = "Valpartijen",
  setting_crash_speed = "Botssnelheid",
  setting_crash_speed_help = "Snelheid van een frontale botsing waarbij je omvalt (u/s)",
  setting_trip_speed = "Struikelsnelheid",
  setting_trip_speed_help =
  "Snelheid tegen een stoeprand of trede die te hoog is om over te rollen waarbij je struikelt (u/s)",
  setting_land_crash_speed = "Valsnelheid bij landen",
  setting_land_crash_speed_help = "Land je sneller dan dit (u/s de grond in), dan val je om",
  setting_crash_lean = "Valhelling",
  setting_crash_lean_help = "Hellingshoek die als val telt (graden)",
  setting_crash_pitch = "Valkanteling",
  setting_crash_pitch_help = "Kanteling voorover of achterover ten opzichte van de grond die als val telt (graden)",
  setting_forward_damage = "Skaters kunnen gewond raken",
  setting_forward_damage_help =
  "Schade aan het lichaam van de skater, zoals door kogels en explosies, verwondt de skater",

  section_water = "Water",
  setting_water_level = "Omvallen bij waterdiepte",
  setting_water_level_help =
  "Water zo diep laat de skater omvallen: 1 aanrakend, 2 half onder, 3 helemaal onder, 0 nooit",
  setting_water_drag = "Waterweerstand",
  setting_water_drag_help = "Hoe hard water de skater afremt zodra de skates onder water zijn (1/s)",

  section_sounds = "Geluiden",
  setting_sounds = "Geluiden aan",
  setting_sounds_help = "Speel de geluiden van de skates af: rollen, afzetten, remmen, wind, landingen en vallen",

  section_mass = "Massa en de skater",
  setting_mass_ridden = "Massa tijdens skaten",
  setting_mass_ridden_help = "Natuurkundige massa tijdens het skaten (skates + skater)",
  setting_take_off_anywhere = "Skaters ze altijd laten uittrekken",
  setting_take_off_anywhere_help =
  "Skaters zonder ruimte om te staan stappen boven de skates af in plaats van ze aan te houden, waardoor ze voorbij een player clip kunnen komen waar de skater doorheen ging",
  setting_ragmod_crash = "Vallende skaters als ragdoll (RagMod)",
  setting_ragmod_crash_help = "Als RagMod geïnstalleerd en ingeschakeld is, worden vallende skaters een RagMod-ragdoll",
  setting_skater_seq = "Skatersequentie",
  setting_skater_seq_help = "Spelersequentie waar de houding van de skater van uitgaat",

  -- Client settings
  section_camera = "Camera",
  setting_cam_third_person = "Derde persoon Camera",
  setting_cam_third_person_help = "Skate in derde persoon in plaats van eerste persoon",
  setting_cam_roll = "Camerarol",
  setting_cam_roll_help = "Hoeveel van de helling van de skater de camera volgt (0-1)",
  setting_cam_level = "Camera waterpas houden",
  setting_cam_level_help =
  "Houd de horizon recht: de camera draait alleen mee met de skater, maar kantelt of rolt nooit mee",
  setting_cam_follow_travel = "Camera kijkt waar je heen gaat",
  setting_cam_follow_travel_help =
  "Kijk in derde persoon de kant op waar je heen gaat: skate je achteruit, dan kijkt de camera langs je rug",
  setting_cam_smooth = "Camera-afvlakking",
  setting_cam_smooth_help =
  "Seconden dat de camera achterloopt op het draaien en hellen van de skater, 0 is uit. Rondkijken met de muis blijft direct",
  setting_cam_dist = "Camera-afstand",
  setting_cam_dist_help = "Afstand van de camera in derde persoon",
  setting_cam_height = "Camerahoogte",
  setting_cam_height_help = "Hoogte van het draaipunt van de camera boven de skates in derde persoon",
  setting_cam_fov_boost = "FOV-boost bij sprinten",
  setting_cam_fov_boost_help = "Extra FOV op sprintsnelheid",
  setting_cam_put_on_blend = "Cameraovergang bij het aantrekken van skates",
  setting_cam_put_on_blend_help =
  "Seconden die de camera nodig heeft om van je zicht te voet naar het skatezicht te gaan, 0 is uit",
  setting_cam_body = "Toon je lichaam in eerste persoon",
  setting_cam_body_help =
  "Teken je eigen spelermodel in eerste persoon, zonder hoofd, zodat je je armen en skates ziet",

  section_skater = "Skater",
  setting_skater_ik = "Skaters animeren",
  setting_skater_ik_help = "Zet skaters in houding boven hun skates: passen, zwaaiende armen, bukken en hurken",
  setting_skater_knee_bend = "Kniebuiging",
  setting_skater_knee_bend_help =
  "Hoe ver skaters door de knieën gaan tijdens het glijden, als deel van hun beenlengte",
  setting_skater_torso_lean = "Voorover leunen",
  setting_skater_torso_lean_help = "Hoe ver skaters hun bovenlichaam naar voren buigen (graden)",
  setting_skater_stride_width = "Pasbreedte",
  setting_skater_stride_width_help = "Hoe ver elke afzet de skate opzij brengt",
  setting_skater_arm_swing = "Armzwaai",
  setting_skater_arm_swing_help = "Hoe ver skaters hun armen zwaaien tijdens het afzetten (0 houdt ze stil)",
  setting_skater_knee_out = "Knieën naar buiten",
  setting_skater_knee_out_help = "Hoe ver de knieën naar buiten wijzen (0 = recht vooruit)",

  section_hud = "HUD",
  setting_hud_speed_unit = "Snelheidsmeter",
  setting_hud_speed_unit_help = "Eenheid die de snelheidsmeter tijdens het skaten toont, of uit om hem te verbergen",
  setting_hud_tricks = "Gelande tricks tonen",
  setting_hud_tricks_help = "Toon de namen van de tricks die je landt",
  unit_kmh = "km/h",
  unit_mph = "mph",
  unit_units = "units",
  unit_off = "uit",

  section_volume = "Geluid",
  setting_sound_volume = "Volume skategeluiden",
  setting_sound_volume_help = "Volume van de rollende wielen, afzetten, remmen en landingen van elke skater (0-1)",
  setting_sound_wind = "Windvolume",
  setting_sound_wind_help = "Volume van de wind die je hoort als je snel skatet (0-1), 0 is uit",

  section_debug = "Debug",
  setting_debug = "Debugoverlay en -HUD (vereist developer 1)",
  setting_debug_help = "Teken de debugoverlay en -HUD voor benen, helling en lichaamsbox (vereist developer 1)",

  -- Keys, as drawn on keycaps
  key_mouse1 = "Linkermuisknop",
  key_mouse2 = "Rechtermuisknop",
  key_mouse3 = "Middelste muisknop",
  key_mouse4 = "Muisknop 4",
  key_mouse5 = "Muisknop 5",
  key_mwheelup = "Scrollwiel omhoog",
  key_mwheeldown = "Scrollwiel omlaag",
  key_ctrl = "Ctrl",
  key_rctrl = "Rechter Ctrl",
  key_rshift = "Rechter Shift",
  key_ralt = "Rechter Alt",
  key_unbound = "{bind} (niet toegewezen)",

  -- Skate guide
  guide_title = "SKATEGIDS",
  guide_subtitle = "ALLES WAT JE NODIG HEBT OM TE ROLLEN",
  guide_read_hint = "Druk op [+use] om te lezen",
  guide_tip = "Tip",
  guide_previous = "< VORIGE",
  guide_next = "VOLGENDE >",
  guide_chapter = "Hoofdstuk {number}",
  guide_page = "HOOFDSTUK {number} / {total}",

  chapter_getting_started = "Aan de slag",
  getting_started_intro =
  "Pak een paar skates uit het spawnmenu, onder Voorwerpen → {category}. Trek ze aan en je staat erop precies waar je stond, met je gezicht naar waar je keek.",
  getting_started_put_on = "De skates aantrekken, en weer uittrekken",
  getting_started_push = "Afzetten",
  getting_started_steer = "Sturen",
  getting_started_tip_take_off = "Trek je ze uit, dan blijven ze staan waar je was, klaar om weer aan te trekken.",
  getting_started_tip_first_person =
  "Skate je liever in eerste persoon? Zet de Derde persoon Camera uit onder Opties → Inlineskates → Client, of voer inline_skates_cam_third_person 0 uit in de console.",
  getting_started_tip_lost =
  "Deze ordner kwijt? Voer inline_skates_guide uit in de console om de gids overal te openen.",

  chapter_skating = "Skaten",
  skating_intro =
  "Zet af, pas na pas, carve door de bochten en spring stoepranden op. Alles hier werkt met je skates op de grond.",
  skating_push = "Afzetten. Rol je achteruit, dan rem je eerst",
  skating_brake = "Remmen. Sta je stil, dan skate je achteruit",
  skating_steer = "Sturen, terwijl je de bocht in helt. Sta je stil, dan stap je rond op de plaats",
  skating_turn_round = "Omdraaien, van vooruit naar achteruit skaten of terug, zonder snelheid te verliezen",
  skating_sprint = "Sprinten: langere, snellere passen",
  skating_tuck = "Diep hurken: niet afzetten, maar minder luchtweerstand, zodat je bergaf snelheid maakt",
  skating_jump_keys = "Houd [+jump] ingedrukt",
  skating_jump =
  "Door je knieën zakken en de sprong opladen. Laat los om te springen: hoe langer je vasthoudt, hoe hoger je komt",
  skating_take_off = "De skates uittrekken",
  skating_tip_backwards =
  "Skate je achteruit, dan kijkt de camera de kant op waar je heen gaat en draait sturen je nog steeds zoals je verwacht. Blijft de camera liever achter je rug? Zet Camera kijkt waar je heen gaat uit onder Opties → Inlineskates → Client.",
  skating_falling = "Vallen",
  skating_tip_fall =
  "Bots je hard tegen een muur, of rol je snel tegen een stoeprand waar je niet overheen kunt rollen, dan val je om. Spring stoepranden liever op.",
  skating_tip_water =
  "Water remt je af, en als je erin skatet tot je half onder bent, val je om. Serverbeheerders kunnen beide aanpassen, of het omvallen uitzetten, onder Water in de serverinstellingen.",

  chapter_in_the_air = "In de lucht",
  in_the_air_intro = "Zodra je skates van de grond komen, draaien de toetsen je in plaats daarvan in de lucht.",
  in_the_air_disabled =
  "Deze server heeft tricks en kantelen in de lucht uitgezet, dus je vliegt waar de sprong je heen brengt.",
  in_the_air_spin = "Ronddraaien in halve slagen, zie Tricks",
  in_the_air_pitch = "Voorover / achterover kantelen",
  in_the_air_spine_transfer =
  "Boven de rand van een quarter pipe: spine transfer over de rand naar de quarter pipe erachter",
  in_the_air_tip_landing_assist =
  "Je wordt gedraaid zodat je recht op je skates neerkomt, op waar je ook gaat landen, zoals de helling van een schans of terug in een quarter pipe. Kom je toch scheef neer? Kantel voorover of achterover voordat je landt.",
  in_the_air_tip_landing_assist_off =
  "Deze server heeft de landingshulp uitgezet, dus het is aan jou om recht op je skates neer te komen.",
  in_the_air_tip_held_keys =
  "Toetsen die je al ingedrukt hield toen je opsprong, zoals sturen of hurken richting een sprong, draaien je pas in de lucht als je ze opnieuw indrukt.",

  chapter_tricks = "Tricks",
  tricks_disabled =
  "Deze server heeft tricks uitgezet. Je kunt nog steeds springen, voorover en achterover kantelen en spine transfers doen, zie In de lucht.",
  tricks_intro =
  "Pak wat lucht en laat zien wat je kunt. Grabs duren zolang je hun toetsen ingedrukt houdt, spins en flips gaan door, dus laat op tijd los om ze te landen.",
  -- Where a trick can be done, shown on its card. A trick that can be done in more than one place lists each, joined
  -- by `tricks_place_separator`.
  tricks_place_none = "in de lucht",
  tricks_place_ground = "op de grond",
  tricks_place_separator = " of ",
  tricks_combos = "Combo's",
  tricks_combos_intro = "Tricks zijn te combineren. Probeer deze om te beginnen:",
  tricks_combo_backflip_safety_grab_keys = "Tik twee keer op [+back], dan [+attack2]",
  tricks_combo_backflip_safety_grab = "Backflip-safety-grab",
  tricks_combo_mute_grab_360 = "Mute grab 360",
  tricks_tip_landing =
  "Land je flips rechtop en je spins in de richting waarin je gaat: vooruit of achteruit werkt allebei, maar meer dan {degrees}° ernaast laat je omvallen. Laat de toetsen vroeg los en de trick maakt zijn draai vanzelf af.",
  tricks_tip_180 = "Een 180 geland? Je skatet achteruit verder, tot je je weer omdraait naar voren.",

  chapter_settings = "Instellingen",
  settings_intro =
  "Open het spawnmenu en ga naar Opties → Inlineskates. Wijzigingen werken meteen, dus je kunt dingen aanpassen terwijl je skatet.",
  settings_client = "Client",
  settings_client_text =
  "Alleen voor jou, en bewaard tussen sessies: eerste of derde persoon, camera-afstand en -hoogte, camerarol, hoe je personage skatet (kniebuiging, voorover leunen, pasbreedte, armzwaai), eenheden van de snelheidsmeter, het tonen van gelande tricks en het volume van de skategeluiden en wind.",
  settings_server = "Server",
  settings_server_text =
  "Hoe iedereen skatet: topsnelheid, acceleratie, remmen, sturen, springen, tricks, vallen en meer. In singleplayer en op een server die je vanuit het menu host, pas je ze daar meteen aan. Op een dedicated server toont het menu ze alleen: stel de inline_skates_*-ConVars dan in via de serverconsole, rcon of cfg/server.cfg.",
  settings_tip_reset =
  "Te veel veranderd? Voer inline_skates_reset_client uit in de console om je eigen instellingen te herstellen, of inline_skates_reset_tuning (admins) om de serverinstellingen te herstellen.",

  -- Tricks
  trick_spin = "Spin",
  trick_spin_help =
  "Draait je rond in halve slagen: 180, 360, 540... Blijf ingedrukt houden voor meer. Land je een 180, dan skate je achteruit verder.",
  trick_backflip = "Backflip",
  trick_backflip_keys = "Tik twee keer op [+back]",
  trick_backflip_help =
  "Trekt je in elkaar en draait je achterover rond. Houd de tweede tik ingedrukt voor meer flips.",
  trick_frontflip = "Frontflip",
  trick_frontflip_keys = "Tik twee keer op [+forward]",
  trick_frontflip_help = "Trekt je in elkaar en draait je voorover rond. Houd de tweede tik ingedrukt voor meer flips.",
  trick_safety_grab = "Safety grab",
  trick_safety_grab_help =
  "Knieën omhoog, en je rechterhand pakt de buitenkant van je rechterskate. Duurt zolang je het ingedrukt houdt.",
  trick_mute_grab = "Mute grab",
  trick_mute_grab_help = "Je rechterskate kruist voor je langs en je linkerhand reikt eroverheen om de neus te pakken.",
  trick_christ_air = "Christ air",
  trick_christ_air_help = "Benen gestrekt en tegen elkaar, rug gebogen en armen wijd gespreid.",

  -- Landed tricks, shown on the HUD
  hud_landed = "Geland",
  hud_combo = "Combo van {count} tricks",
  -- A trick landed with more than one whole turn, such as a double backflip.
  hud_turns = "{trick} x{turns}",
}
