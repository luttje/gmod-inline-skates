-- German (Deutsch). See en.lua for how to translate the addon.
return {
  -- Spawn menu
  spawn_category = "Fortbewegung",
  entity_inline_skates = "Inlineskates",
  entity_guide = "Skate-Handbuch",
  entity_guide_instructions = "Benutze es, um zu lesen, wie man skatet und Tricks macht",
  model_default = "Inlineskates",
  no_room_put_on = "Hier ist kein Platz, um die Skates anzuziehen",
  no_room_take_off = "Hier ist kein Platz, um die Skates auszuziehen",

  -- Options → Inline Skates
  options_category = "Inlineskates",
  options_client = "Client",
  options_server = "Server",
  options_client_help =
  "Deine eigenen Kamera-, Skater- und Debug-Einstellungen. Sie werden zwischen Sitzungen gespeichert.",
  options_server_help =
  "Wie alle skaten. Nur der Server-Host kann diese ändern (im Einzelspieler bist das du), und der Server speichert sie. Auf einem dedizierten Server setzt du stattdessen die inline_skates_*-ConVars über die Serverkonsole oder server.cfg.",
  options_open_guide = "Skate-Handbuch öffnen",
  options_reset = "Auf Standardwerte zurücksetzen",
  options_reset_client_done = "Client-Einstellungen auf Standardwerte zurückgesetzt.",
  options_reset_tuning_done = "Server-Einstellungen auf Standardwerte zurückgesetzt.",
  options_reset_tuning_denied = "Du hast keinen Zugriff, um die Server-Einstellungen zurückzusetzen.",
  options_skate_tools = "Trag zuerst Skates oder schau welche an:",
  options_open_editor = "Skate-Editor öffnen (Admins)",
  options_print_bones = "Knochen des Skate-Modells in der Konsole ausgeben",
  options_print_tuning = "Alle Werte in der Konsole ausgeben",
  options_tooltip = "{description}\n{convar} (Standard {default})",

  -- Server settings
  section_speed = "Geschwindigkeit und Abstoßen",
  setting_top_speed = "Höchstgeschwindigkeit",
  setting_top_speed_help = "Höchstgeschwindigkeit beim Skaten (u/s). 360 u/s ~ 25 km/h",
  setting_sprint_speed = "Sprintgeschwindigkeit",
  setting_sprint_speed_help = "Höchstgeschwindigkeit beim Sprinten (u/s). 500 u/s ~ 34 km/h",
  setting_push_accel = "Abstoßbeschleunigung",
  setting_push_accel_help = "Beschleunigung beim Abstoßen (u/s^2)",
  setting_sprint_accel = "Sprintbeschleunigung",
  setting_sprint_accel_help = "Multiplikator der Abstoßbeschleunigung beim Sprinten",
  setting_brake_accel = "Bremsverzögerung",
  setting_brake_accel_help = "Bremsverzögerung, mit dem Fersenstopper oder W beim Rückwärtsrollen (u/s^2)",
  setting_backwards_speed = "Höchstgeschwindigkeit rückwärts",
  setting_backwards_speed_help =
  "Höchstgeschwindigkeit beim Rückwärtsskaten, mit gedrücktem S (u/s). 260 u/s ~ 18 km/h",
  setting_backwards_accel = "Beschleunigung rückwärts",
  setting_backwards_accel_help = "Beschleunigung beim Abstoßen während des Rückwärtsskatens (u/s^2)",
  setting_rolling = "Rollwiderstand",
  setting_rolling_help = "Rollwiderstand beim Gleiten (u/s^2)",
  setting_drag = "Luftwiderstand",
  setting_drag_help = "Luftwiderstand beim Gleiten (pro u/s^2)",
  setting_tuck_drag = "Luftwiderstand in der Hocke",
  setting_tuck_drag_help = "Multiplikator des Luftwiderstands in der Hocke (Strg), um bergab schneller zu werden",

  section_legs = "Beine und Rollen",
  setting_spring = "Beinfederung",
  setting_spring_help = "Wie steif die Beine den Skater tragen (massennormiert)",
  setting_damper = "Beindämpfung",
  setting_damper_help = "Beindämpfung",
  setting_grip = "Seitenhaftung",
  setting_grip_help = "Wie schnell seitliches Rutschen abgebaut wird (1/s)",
  setting_mu = "Rollenreibung",
  setting_mu_help = "Reibungskoeffizient der Rollen (begrenzt Kurvenfahrt und Bremsen)",

  section_steering = "Neigung und Lenkung",
  setting_lean_max = "Maximale Neigung",
  setting_lean_max_help = "Maximaler Neigungswinkel (Grad)",
  setting_lean_p = "Neigungsverstärkung",
  setting_lean_p_help = "Verstärkung des Neigungsreglers (Grad/s pro Grad Abweichung)",
  setting_lean_rate = "Neigungsrate",
  setting_lean_rate_help = "Maximale Neigungsrate (Grad/s)",
  setting_lean_response = "Neigungsansprechen",
  setting_lean_response_help = "Wie stark der Neigungsregler korrigiert (1/s)",
  setting_lean_slack = "Neigungsspielraum",
  setting_lean_slack_help = "Erlaubte Kurvenfahrt, bevor sich der Skater in die Kurve gelegt hat (u/s^2)",
  setting_yaw_response = "Gieransprechen",
  setting_yaw_response_help = "Wie schnell die Fahrtrichtung der Lenkung folgt (1/s)",
  setting_landing_assist = "Landehilfe",
  setting_landing_assist_help =
  "Dreht Skater in der Luft, damit sie gerade auf ihren Skates landen, in Richtung ihrer Flugbahn",
  setting_air_pitch_speed = "Kippgeschwindigkeit in der Luft",
  setting_air_pitch_speed_help =
  "Wie schnell W / S den Skater in der Luft nach vorne / hinten kippen (Grad/s), 0 schaltet es aus",
  setting_turn_radius_slow = "Wenderadius (langsam)",
  setting_turn_radius_slow_help = "Engste Kurve bei niedriger Geschwindigkeit (Einheiten)",
  setting_turn_radius_fast = "Wenderadius (schnell)",
  setting_turn_radius_fast_help = "Engste Kurve bei hoher Geschwindigkeit (Einheiten)",
  setting_turn_slow_speed = "Langsames Wenden unter",
  setting_turn_slow_speed_help = "Unter dieser Geschwindigkeit ist der langsame Wenderadius erlaubt (u/s)",
  setting_turn_fast_speed = "Schnelles Wenden über",
  setting_turn_fast_speed_help =
  "Über dieser Geschwindigkeit werden Kurven auf den schnellen Wenderadius geweitet (u/s)",
  setting_steer_rate = "Lenkgeschwindigkeit",
  setting_steer_rate_help = "Wie schnell sich die Lenkung aufbaut (volle Einschläge pro Sekunde)",
  setting_pivot_turn_speed = "Auf der Stelle drehen",
  setting_pivot_turn_speed_help = "Wie schnell A / D einen stehenden Skater mit kleinen Schritten drehen (Grad/s)",

  section_tricks = "Springen und Tricks",
  setting_jump_min = "Sprung (getippt)",
  setting_jump_min_help = "Aufwärtsgeschwindigkeit eines getippten Sprungs (u/s)",
  setting_jump_max = "Sprung (aufgeladen)",
  setting_jump_max_help = "Aufwärtsgeschwindigkeit eines voll aufgeladenen Sprungs, mit gedrückter Leertaste (u/s)",
  setting_jump_charge_time = "Sprung-Aufladezeit",
  setting_jump_charge_time_help = "Sekunden, die du die Leertaste für einen voll aufgeladenen Sprung hältst",
  setting_jump_cooldown = "Sprung-Abklingzeit",
  setting_jump_cooldown_help = "Sekunden zwischen Sprüngen",
  setting_tricks = "Tricks erlauben",
  setting_tricks_help = "Skater in der Luft greifen, flippen und drehen lassen",
  setting_spin_speed = "Spin-Geschwindigkeit",
  setting_spin_speed_help = "Wie schnell sich ein Skater in der Luft dreht (Grad/s)",
  setting_flip_speed = "Flip-Geschwindigkeit",
  setting_flip_speed_help = "Wie schnell sich ein Skater bei einem Backflip oder Frontflip überschlägt (Grad/s)",
  setting_trick_land_tolerance = "Landetoleranz für Tricks",
  setting_trick_land_tolerance_help = "Landest du einen Flip oder Spin schiefer als das, stürzt du (Grad)",

  section_crashes = "Stürze",
  setting_crash_speed = "Aufprallgeschwindigkeit",
  setting_crash_speed_help = "Geschwindigkeit eines Frontalaufpralls, die dich umwirft (u/s)",
  setting_trip_speed = "Stolpergeschwindigkeit",
  setting_trip_speed_help =
  "Geschwindigkeit gegen einen Bordstein oder eine Stufe, zu hoch zum Überrollen, bei der du stolperst (u/s)",
  setting_land_crash_speed = "Sturzgeschwindigkeit bei der Landung",
  setting_land_crash_speed_help = "Landest du schneller als das (u/s in den Boden), stürzt du",
  setting_crash_lean = "Sturzneigung",
  setting_crash_lean_help = "Neigungswinkel, der als Sturz zählt (Grad)",
  setting_crash_pitch = "Sturz-Nickwinkel",
  setting_crash_pitch_help = "Neigung nach vorne oder hinten gegenüber dem Boden, die als Sturz zählt (Grad)",
  setting_forward_damage = "Skater können verletzt werden",
  setting_forward_damage_help = "Schaden am Körper des Skaters, etwa durch Kugeln und Explosionen, verletzt den Skater",

  section_water = "Wasser",
  setting_water_level = "Umwerfen ab Wassertiefe",
  setting_water_level_help =
  "Wasser dieser Tiefe wirft den Skater um: 1 berührend, 2 halb untergetaucht, 3 ganz untergetaucht, 0 nie",
  setting_water_drag = "Wasserwiderstand",
  setting_water_drag_help = "Wie stark Wasser den Skater bremst, sobald die Skates untergetaucht sind (1/s)",

  section_sounds = "Geräusche",
  setting_sounds = "Geräusche aktivieren",
  setting_sounds_help = "Die Geräusche der Skates abspielen: Rollen, Abstoßen, Bremsen, Wind, Landungen und Stürze",

  section_mass = "Masse und der Skater",
  setting_mass_ridden = "Masse beim Skaten",
  setting_mass_ridden_help = "Physikmasse beim Skaten (Skates + Skater)",
  setting_take_off_anywhere = "Skater sie immer ausziehen lassen",
  setting_take_off_anywhere_help =
  "Skater ohne Platz zum Stehen steigen oberhalb der Skates ab, statt sie anzubehalten, wodurch sie hinter einen Player-Clip gelangen könnten, durch den der Skater gefahren ist",
  setting_ragmod_crash = "Stürzende Skater als Ragdoll (RagMod)",
  setting_ragmod_crash_help =
  "Wenn RagMod installiert und aktiviert ist, werden stürzende Skater zu einer RagMod-Ragdoll",
  setting_skater_seq = "Skater-Sequenz",
  setting_skater_seq_help = "Spielersequenz, von der die Pose des Skaters ausgeht",

  -- Client settings
  section_camera = "Kamera",
  setting_cam_third_person = "Third-Person-Ansicht",
  setting_cam_third_person_help = "In der Third-Person-Ansicht skaten statt in der Ego-Perspektive",
  setting_cam_roll = "Kamerarollen",
  setting_cam_roll_help = "Wie viel der Neigung des Skaters die Kamera folgt (0-1)",
  setting_cam_level = "Kamera waagerecht halten",
  setting_cam_level_help =
  "Den Horizont gerade halten: Die Kamera dreht sich nur mit dem Skater, kippt oder rollt aber nie mit",
  setting_cam_follow_travel = "Kamera schaut, wohin du fährst",
  setting_cam_follow_travel_help =
  "In der Third-Person-Ansicht in Fahrtrichtung schauen: Beim Rückwärtsskaten schaut die Kamera an deinem Rücken vorbei",
  setting_cam_smooth = "Kameraglättung",
  setting_cam_smooth_help =
  "Sekunden, die die Kamera dem Drehen und Neigen des Skaters hinterherhinkt, 0 ist aus. Umsehen mit der Maus bleibt sofort",
  setting_cam_dist = "Kameraabstand",
  setting_cam_dist_help = "Kameraabstand in der Third-Person-Ansicht",
  setting_cam_height = "Kamerahöhe",
  setting_cam_height_help = "Höhe des Kameradrehpunkts über den Skates in der Third-Person-Ansicht",
  setting_cam_fov_boost = "Sprint-FOV-Boost",
  setting_cam_fov_boost_help = "Zusätzliches FOV bei Sprintgeschwindigkeit",
  setting_cam_put_on_blend = "Kameraübergang beim Anziehen der Skates",
  setting_cam_put_on_blend_help =
  "Sekunden, die die Kamera braucht, um von deiner Ansicht zu Fuß zur Skate-Ansicht zu wechseln, 0 ist aus",
  setting_cam_body = "Deinen Körper in der Ego-Perspektive zeigen",
  setting_cam_body_help =
  "Dein eigenes Spielermodell in der Ego-Perspektive ohne Kopf zeichnen, damit du deine Arme und Skates siehst",

  section_skater = "Skater",
  setting_skater_ik = "Skater animieren",
  setting_skater_ik_help = "Skater über ihren Skates in Pose bringen: Schritte, schwingende Arme, Ducken und Hocke",
  setting_skater_knee_bend = "Kniebeugung",
  setting_skater_knee_bend_help = "Wie tief Skater beim Gleiten in die Knie gehen, als Anteil ihrer Beinlänge",
  setting_skater_torso_lean = "Vorlage",
  setting_skater_torso_lean_help = "Wie weit Skater ihren Oberkörper nach vorne neigen (Grad)",
  setting_skater_stride_width = "Schrittbreite",
  setting_skater_stride_width_help = "Wie weit jeder Abstoß den Skate zur Seite führt",
  setting_skater_arm_swing = "Armschwung",
  setting_skater_arm_swing_help = "Wie weit Skater beim Abstoßen ihre Arme schwingen (0 hält sie still)",
  setting_skater_knee_out = "Knie nach außen",
  setting_skater_knee_out_help = "Wie weit die Knie nach außen zeigen (0 = geradeaus)",

  section_hud = "HUD",
  setting_hud_speed_unit = "Tacho",
  setting_hud_speed_unit_help = "Einheit, die der Tacho beim Skaten anzeigt, oder aus, um ihn auszublenden",
  setting_hud_tricks = "Gelandete Tricks anzeigen",
  setting_hud_tricks_help = "Die Namen der Tricks anzeigen, die du landest",
  unit_kmh = "km/h",
  unit_mph = "mph",
  unit_units = "Einheiten",
  unit_off = "aus",

  section_volume = "Ton",
  setting_sound_volume = "Lautstärke der Skate-Geräusche",
  setting_sound_volume_help = "Lautstärke von rollenden Rollen, Abstößen, Bremsen und Landungen jedes Skaters (0-1)",
  setting_sound_wind = "Windlautstärke",
  setting_sound_wind_help = "Lautstärke des Windes, den du beim schnellen Skaten hörst (0-1), 0 ist aus",

  section_debug = "Debug",
  setting_debug = "Debug-Overlay und -HUD (erfordert developer 1)",
  setting_debug_help = "Debug-Overlay und -HUD für Beine, Neigung und Körperbox zeichnen (erfordert developer 1)",

  -- Keys, as drawn on keycaps
  key_mouse1 = "Linke Maustaste",
  key_mouse2 = "Rechte Maustaste",
  key_mouse3 = "Mittlere Maustaste",
  key_mouse4 = "Maustaste 4",
  key_mouse5 = "Maustaste 5",
  key_mwheelup = "Mausrad hoch",
  key_mwheeldown = "Mausrad runter",
  key_ctrl = "Strg",
  key_rctrl = "Strg rechts",
  key_rshift = "Shift rechts",
  key_ralt = "Alt Gr",
  key_unbound = "{bind} (nicht belegt)",

  -- Skate guide
  guide_title = "SKATE-HANDBUCH",
  guide_subtitle = "ALLES, WAS DU ZUM ROLLEN BRAUCHST",
  guide_read_hint = "Drücke [+use] zum Lesen",
  guide_tip = "Tipp",
  guide_previous = "< ZURÜCK",
  guide_next = "WEITER >",
  guide_chapter = "Kapitel {number}",
  guide_page = "KAPITEL {number} / {total}",

  chapter_getting_started = "Erste Schritte",
  getting_started_intro =
  "Hol dir ein Paar Skates aus dem Spawnmenü, unter Entities → {category}. Zieh sie an, und du stehst genau dort auf ihnen, wo du gestanden hast, mit Blick dorthin, wohin du geschaut hast.",
  getting_started_put_on = "Die Skates anziehen und wieder ausziehen",
  getting_started_push = "Abstoßen",
  getting_started_steer = "Lenken",
  getting_started_tip_take_off =
  "Ziehst du sie aus, bleiben sie dort stehen, wo du warst, bereit zum erneuten Anziehen.",
  getting_started_tip_first_person =
  "Skatest du lieber in der Ego-Perspektive? Schalte Third-Person-Ansicht unter Optionen → Inlineskates → Client aus, oder gib inline_skates_cam_third_person 0 in der Konsole ein.",
  getting_started_tip_lost =
  "Diesen Ordner verloren? Gib inline_skates_guide in der Konsole ein, um das Handbuch überall zu öffnen.",

  chapter_skating = "Skaten",
  skating_intro =
  "Stoß dich Schritt für Schritt ab, carve durch die Kurven und spring auf Bordsteine. Alles hier funktioniert mit deinen Skates am Boden.",
  skating_push = "Abstoßen. Rollst du rückwärts, bremst du zuerst",
  skating_brake = "Bremsen. Im Stand skatest du rückwärts",
  skating_steer = "Lenken und dich in die Kurve legen. Im Stand drehst du dich mit kleinen Schritten auf der Stelle",
  skating_turn_round = "Umdrehen, von vorwärts auf rückwärts oder zurück, ohne Geschwindigkeit zu verlieren",
  skating_sprint = "Sprinten: längere, schnellere Schritte",
  skating_tuck = "In die Hocke gehen: kein Abstoßen, aber weniger Luftwiderstand, sodass du bergab schneller wirst",
  skating_jump_keys = "[+jump] halten",
  skating_jump =
  "In die Knie gehen und den Sprung aufladen. Lass los, um zu springen: Je länger du hältst, desto höher kommst du",
  skating_take_off = "Die Skates ausziehen",
  skating_tip_backwards =
  "Beim Rückwärtsskaten schaut die Kamera in Fahrtrichtung, und die Lenkung dreht dich trotzdem so, wie du es erwartest. Soll die Kamera lieber hinter deinem Rücken bleiben? Schalte Kamera schaut, wohin du fährst unter Optionen → Inlineskates → Client aus.",
  skating_falling = "Stürze",
  skating_tip_fall =
  "Prallst du hart gegen eine Wand oder rollst schnell gegen einen Bordstein, über den du nicht rollen kannst, stürzt du. Spring stattdessen auf Bordsteine.",
  skating_tip_water =
  "Wasser bremst dich, und wenn du hineinskatest, bis du halb untergetaucht bist, stürzt du. Server-Admins können beides ändern oder das Stürzen ausschalten, unter Wasser in den Server-Einstellungen.",

  chapter_in_the_air = "In der Luft",
  in_the_air_intro = "Sobald deine Skates den Boden verlassen, drehen dich die Tasten stattdessen in der Luft.",
  in_the_air_disabled =
  "Dieser Server hat Tricks und das Kippen in der Luft ausgeschaltet, also fliegst du dorthin, wohin dich der Sprung trägt.",
  in_the_air_spin = "In halben Drehungen herumdrehen, siehe Tricks",
  in_the_air_pitch = "Nach vorne / hinten kippen",
  in_the_air_spine_transfer =
  "Über der Kante einer Quarterpipe: Spine-Transfer über die Kante in die Quarterpipe dahinter",
  in_the_air_tip_landing_assist =
  "Du wirst so gedreht, dass du gerade auf deinen Skates aufkommst, auf dem, worauf du gleich landest, etwa der Schräge einer Rampe oder wieder unten in einer Quarterpipe. Kommst du trotzdem schief auf? Kipp vor der Landung nach vorne oder hinten.",
  in_the_air_tip_landing_assist_off =
  "Dieser Server hat die Landehilfe ausgeschaltet, also liegt es an dir, gerade auf deinen Skates aufzukommen.",
  in_the_air_tip_held_keys =
  "Tasten, die du beim Absprung schon gedrückt hattest, etwa zum Lenken oder für die Hocke in einen Sprung, drehen dich in der Luft erst, wenn du sie erneut drückst.",

  chapter_tricks = "Tricks",
  tricks_disabled =
  "Dieser Server hat Tricks ausgeschaltet. Du kannst trotzdem springen, nach vorne und hinten kippen und Spine-Transfers machen, siehe In der Luft.",
  tricks_intro =
  "Hol dir etwas Air und leg los. Grabs halten an, solange du ihre Tasten gedrückt hältst, Spins und Flips laufen weiter, also lass rechtzeitig los, um sie zu landen.",
  -- Where a trick can be done, shown on its card. A trick that can be done in more than one place lists each, joined
  -- by `tricks_place_separator`.
  tricks_place_none = "in der Luft",
  tricks_place_ground = "auf dem Boden",
  tricks_place_separator = " oder ",
  tricks_combos = "Kombos",
  tricks_combos_intro = "Tricks lassen sich kombinieren. Probier zum Einstieg diese:",
  tricks_combo_backflip_safety_grab_keys = "Zweimal [+back] tippen, dann [+attack2]",
  tricks_combo_backflip_safety_grab = "Backflip-Safety-Grab",
  tricks_combo_mute_grab_360 = "Mute-Grab 360",
  tricks_tip_landing =
  "Lande deine Flips aufrecht und deine Spins in Fahrtrichtung: Vorwärts oder rückwärts geht beides, aber mehr als {degrees}° daneben wirft dich um. Lass die Tasten früh los, und der Trick beendet seine Drehung von selbst.",
  tricks_tip_180 = "Einen 180 gelandet? Du skatest rückwärts weiter, bis du dich wieder nach vorne umdrehst.",

  chapter_settings = "Einstellungen",
  settings_intro =
  "Öffne das Spawnmenü und geh zu Optionen → Inlineskates. Änderungen gelten sofort, du kannst also während des Skatens herumprobieren.",
  settings_client = "Client",
  settings_client_text =
  "Nur für dich, und zwischen Sitzungen gespeichert: Ego- oder Third-Person-Ansicht, Kameraabstand und -höhe, Kamerarollen, wie deine Figur skatet (Kniebeugung, Vorlage, Schrittbreite, Armschwung), Tacho-Einheiten, das Anzeigen gelandeter Tricks und die Lautstärke der Skate-Geräusche und des Windes.",
  settings_server = "Server",
  settings_server_text =
  "Wie alle skaten: Höchstgeschwindigkeit, Beschleunigung, Bremsen, Lenkung, Springen, Tricks, Stürze und mehr. Im Einzelspieler und auf einem Server, den du aus dem Menü hostest, änderst du sie direkt dort. Auf einem dedizierten Server zeigt das Menü sie nur an: Setze die inline_skates_*-ConVars stattdessen über die Serverkonsole, rcon oder cfg/server.cfg.",
  settings_tip_reset =
  "Zu viel verstellt? Gib inline_skates_reset_client in der Konsole ein, um deine eigenen Einstellungen wiederherzustellen, oder inline_skates_reset_tuning (Admins), um die Server-Einstellungen wiederherzustellen.",

  -- Tricks
  trick_spin = "Spin",
  trick_spin_help =
  "Dreht dich in halben Drehungen herum: 180, 360, 540 ... Halte gedrückt für mehr. Landest du einen 180, skatest du rückwärts weiter.",
  trick_backflip = "Backflip",
  trick_backflip_keys = "Zweimal [+back] tippen",
  trick_backflip_help =
  "Zieht dich in die Hocke und überschlägt dich nach hinten. Halte den zweiten Tipp gedrückt für mehr Flips.",
  trick_frontflip = "Frontflip",
  trick_frontflip_keys = "Zweimal [+forward] tippen",
  trick_frontflip_help =
  "Zieht dich in die Hocke und überschlägt dich nach vorne. Halte den zweiten Tipp gedrückt für mehr Flips.",
  trick_safety_grab = "Safety-Grab",
  trick_safety_grab_help =
  "Knie hoch, und deine rechte Hand greift die Außenseite deines rechten Skates. Hält an, solange du gedrückt hältst.",
  trick_mute_grab = "Mute-Grab",
  trick_mute_grab_help = "Dein rechter Skate kreuzt vor dir, und deine linke Hand greift hinüber an seine Spitze.",
  trick_christ_air = "Christ Air",
  trick_christ_air_help = "Beine gestreckt und geschlossen, Rücken durchgebogen und Arme weit ausgebreitet.",

  -- Landed tricks, shown on the HUD
  hud_landed = "Gelandet",
  hud_combo = "Kombo aus {count} Tricks",
  -- A trick landed with more than one whole turn, such as a double backflip.
  hud_turns = "{trick} x{turns}",
}
