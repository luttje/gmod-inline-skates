inlineSkates.guide.registerChapter({
  id = "getting_started",
  title = "#inline_skates.chapter_getting_started",
  order = 10,
  -- A function, as the intro names the spawn menu category.
  content = function()
    return {
      inlineSkates.lang.get("getting_started_intro", {
        category = inlineSkates.lang.translate(inlineSkates.SPAWN_CATEGORY),
      }),
      {
        type = "controls",
        rows = {
          { "[+use]",                     "#inline_skates.getting_started_put_on" },
          { "[+forward]",                 "#inline_skates.getting_started_push" },
          { "[+moveleft] / [+moveright]", "#inline_skates.getting_started_steer" },
        },
      },
      { type = "tip", text = "#inline_skates.getting_started_tip_take_off" },
      { type = "tip", text = "#inline_skates.getting_started_tip_first_person" },
      { type = "tip", text = "#inline_skates.getting_started_tip_lost" },
    }
  end,
})
