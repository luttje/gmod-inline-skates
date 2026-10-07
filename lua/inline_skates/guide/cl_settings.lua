inlineSkates.guide.registerChapter({
  id = "settings",
  title = "Settings",
  order = 50,
  content = {
    "Open the spawn menu and go to Options → Inline Skates. Changes apply straight away, so you can tweak things while "
    .. "skating.",
    { type = "heading", text = "Client" },
    "Just for you, and saved between sessions: first or third person, camera distance and height, camera roll, how "
    .. "your character skates (knee bend, forward lean, stride width, arm swing), speedometer units, showing the "
    .. "tricks you land and the volume of the skating sounds and wind.",
    { type = "heading", text = "Server" },
    "How everyone skates: top speed, acceleration, braking, steering, jumping, tricks, falling and more. In "
    .. "singleplayer and on a server you host from the menu, you change them right there. On a dedicated server, the "
    .. "menu only shows them: set the inline_skates_* ConVars from the server console, rcon or cfg/server.cfg instead.",
    {
      type = "tip",
      text = "Changed too much? Run inline_skates_reset_client in the console to restore your own settings, or "
          .. "inline_skates_reset_tuning (admins) to restore the server settings.",
    },
  },
})
