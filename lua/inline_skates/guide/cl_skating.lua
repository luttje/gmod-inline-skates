inlineSkates.guide.registerChapter({
  id = "skating",
  title = "#inline_skates.chapter_skating",
  order = 20,
  content = {
    "#inline_skates.skating_intro",
    {
      type = "controls",
      rows = {
        { "[+forward]",                 "#inline_skates.skating_push" },
        { "[+back]",                    "#inline_skates.skating_brake" },
        { "[+moveleft] / [+moveright]", "#inline_skates.skating_steer" },
        { "[+reload]",                  "#inline_skates.skating_turn_round" },
        { "[+speed]",                   "#inline_skates.skating_sprint" },
        { "[+duck]",                    "#inline_skates.skating_tuck" },
        { "#inline_skates.skating_jump_keys", "#inline_skates.skating_jump" },
        { "[+use]",                     "#inline_skates.skating_take_off" },
      },
    },
    { type = "tip",     text = "#inline_skates.skating_tip_backwards" },
    { type = "heading", text = "#inline_skates.skating_falling" },
    { type = "tip",     text = "#inline_skates.skating_tip_fall" },
    { type = "tip",     text = "#inline_skates.skating_tip_water" },
  },
})
