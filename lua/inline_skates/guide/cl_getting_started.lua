inlineSkates.guide.registerChapter({
  id = "getting_started",
  title = "Getting started",
  order = 10,
  content = {
    "Grab a pair of skates from the spawn menu, under Entities → " .. inlineSkates.SPAWN_CATEGORY .. ". Put them on "
    .. "and you're standing on them right where you stood, facing where you looked.",
    {
      type = "controls",
      rows = {
        { "[+use]", "Put the skates on, and take them off again" },
        { "[+forward]", "Push off" },
        { "[+moveleft] / [+moveright]", "Steer" },
      },
    },
    { type = "tip", text = "Take them off and they're left standing where you were, ready to put back on." },
    {
      type = "tip",
      text = "Prefer skating in first person? Turn off Third person under Options → Inline Skates → Client, or run "
          .. "inline_skates_cam_third_person 0 in the console.",
    },
    { type = "tip", text = "Lost this binder? Run inline_skates_guide in the console to open the guide anywhere." },
  },
})
