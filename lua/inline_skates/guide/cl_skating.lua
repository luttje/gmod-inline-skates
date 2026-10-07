inlineSkates.guide.registerChapter({
  id = "skating",
  title = "Skating",
  order = 20,
  content = {
    "Push off stride by stride, carve into corners and jump up curbs. Everything here works with your skates on the "
    .. "ground.",
    {
      type = "controls",
      rows = {
        { "[+forward]", "Push off. Rolling backwards, brake first" },
        { "[+back]", "Brake. Standing still, skate backwards" },
        { "[+moveleft] / [+moveright]", "Steer, leaning into the turn. Standing still, step round on the spot" },
        { "[+reload]", "Turn round, from skating forwards to backwards or back, keeping your speed" },
        { "[+speed]", "Sprint: longer, faster strides" },
        { "[+duck]", "Tuck down low: no pushing, but less drag, so you pick up speed downhill" },
        { "Hold [+jump]", "Crouch, charging the jump. Let go to jump: the longer you hold it, the higher you go" },
        { "[+use]", "Take the skates off" },
      },
    },
    {
      type = "tip",
      text = "Skating backwards, the camera looks the way you're going and steering still turns you the way you'd "
          .. "expect from it. Prefer the camera to stay behind your back? Turn off Camera looks where you go under "
          .. "Options → Inline Skates → Client.",
    },
    { type = "heading", text = "Falling" },
    {
      type = "tip",
      text = "Hitting a wall hard, or rolling fast into a curb you can't roll over, knocks you over. Jump up curbs "
          .. "instead.",
    },
    {
      type = "tip",
      text = "Water slows you down, and skating in until you're half under knocks you over. Server admins can change "
          .. "both, or turn the falling off, under Water in the server settings.",
    },
  },
})
