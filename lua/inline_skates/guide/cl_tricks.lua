-- The contacts a trick can allow, in the order the places they're done in are listed.
local CONTACTS = { "none", "ground" }

--- @param trick table
--- @return string # Such as "in the air"
local function getTrickPlaces(trick)
  local places = {}

  for _, contact in ipairs(CONTACTS) do
    if (trick.contact[contact]) then
      places[#places + 1] = inlineSkates.lang.get("tricks_place_" .. contact)
    end
  end

  return table.concat(places, inlineSkates.lang.get("tricks_place_separator"))
end

inlineSkates.guide.registerChapter({
  id = "tricks",
  title = "#inline_skates.chapter_tricks",
  order = 40,
  -- A function, so it lists every trick registered by then and the server's current settings.
  content = function()
    if (not inlineSkates.getTuningBool("tricks")) then
      return { "#inline_skates.tricks_disabled" }
    end

    --- @type (table|string)[]
    local blocks = { "#inline_skates.tricks_intro" }

    for _, trick in ipairs(inlineSkates.trick.getAll()) do
      blocks[#blocks + 1] = {
        type = "card",
        title = trick.name,
        tag = getTrickPlaces(trick),
        keys = trick.keys,
        text = trick.description,
      }
    end

    blocks[#blocks + 1] = { type = "heading", text = "#inline_skates.tricks_combos" }
    blocks[#blocks + 1] = "#inline_skates.tricks_combos_intro"
    blocks[#blocks + 1] = {
      type = "controls",
      rows = {
        { "#inline_skates.tricks_combo_backflip_safety_grab_keys", "#inline_skates.tricks_combo_backflip_safety_grab" },
        { "[+attack] + [+moveleft] / [+moveright]",                "#inline_skates.tricks_combo_mute_grab_360" },
      },
    }
    blocks[#blocks + 1] = {
      type = "tip",
      text = inlineSkates.lang.get("tricks_tip_landing", {
        degrees = math.Round(inlineSkates.getTuning("trick_land_tolerance")),
      }),
    }
    blocks[#blocks + 1] = { type = "tip", text = "#inline_skates.tricks_tip_180" }

    return blocks
  end,
})
