inlineSkates.guide.registerChapter({
  id = "in_the_air",
  title = "In the air",
  order = 30,
  -- A function, as the server can turn these controls off at any time.
  content = function()
    local rows = {}

    if (inlineSkates.getTuningBool("tricks")) then
      rows[#rows + 1] = { "[+moveleft] / [+moveright]", "Spin round in half turns, see Tricks" }
    end

    if (inlineSkates.getTuning("air_pitch_speed") > 0) then
      rows[#rows + 1] = { "[+forward] / [+back]", "Tip forward / back" }
      rows[#rows + 1] = {
        "[+forward]",
        "Above the top of a quarter pipe: spine transfer over the top and into the quarter pipe behind it",
      }
    end

    local blocks = {
      "Once your skates leave the ground, the keys turn you in the air instead.",
    }

    if (#rows > 0) then
      blocks[#blocks + 1] = { type = "controls", rows = rows }
    else
      blocks[#blocks + 1] = "This server has turned tricks and tipping in the air off, so you fly wherever the jump "
          .. "takes you."
    end

    if (inlineSkates.getTuningBool("landing_assist")) then
      blocks[#blocks + 1] = {
        type = "tip",
        text = "You're turned to come down square on your skates, onto whatever you're about to land on, such as the "
            .. "slope of a ramp or back down a quarter pipe. Coming down tilted anyway? Tip forward or back before you "
            .. "land.",
      }
    else
      blocks[#blocks + 1] = {
        type = "tip",
        text = "This server has turned the landing assist off, so it's up to you to come down square on your skates.",
      }
    end

    blocks[#blocks + 1] = {
      type = "tip",
      text = "Keys you were already holding as you took off, such as steering or tucking into a jump, only turn you "
          .. "in the air once you press them again.",
    }

    return blocks
  end,
})
