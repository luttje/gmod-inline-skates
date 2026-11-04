inlineSkates.guide.registerChapter({
  id = "in_the_air",
  title = "#inline_skates.chapter_in_the_air",
  order = 30,
  -- A function, as the server can turn these controls off at any time.
  content = function()
    local rows = {}

    if (inlineSkates.getTuningBool("tricks")) then
      rows[#rows + 1] = { "[+moveleft] / [+moveright]", "#inline_skates.in_the_air_spin" }
    end

    if (inlineSkates.getTuning("air_pitch_speed") > 0) then
      rows[#rows + 1] = { "[+forward] / [+back]", "#inline_skates.in_the_air_pitch" }
      rows[#rows + 1] = { "[+forward]",           "#inline_skates.in_the_air_spine_transfer" }
    end

    --- @type (table|string)[]
    local blocks = { "#inline_skates.in_the_air_intro" }

    if (#rows > 0) then
      blocks[#blocks + 1] = { type = "controls", rows = rows }
    else
      blocks[#blocks + 1] = "#inline_skates.in_the_air_disabled"
    end

    if (inlineSkates.getTuningBool("landing_assist")) then
      blocks[#blocks + 1] = { type = "tip", text = "#inline_skates.in_the_air_tip_landing_assist" }
    else
      blocks[#blocks + 1] = { type = "tip", text = "#inline_skates.in_the_air_tip_landing_assist_off" }
    end

    blocks[#blocks + 1] = { type = "tip", text = "#inline_skates.in_the_air_tip_held_keys" }

    return blocks
  end,
})
