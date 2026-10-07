-- Where each contact a trick allows has it done, in the order they're listed.
local CONTACT_PLACES = {
  { contact = "none", place = "in the air" },
  { contact = "ground", place = "on the ground" },
}

--- @param trick table
--- @return string # Such as "in the air"
local function getTrickPlaces(trick)
  local places = {}

  for _, contactPlace in ipairs(CONTACT_PLACES) do
    if (trick.contact[contactPlace.contact]) then
      places[#places + 1] = contactPlace.place
    end
  end

  return table.concat(places, " or ")
end

inlineSkates.guide.registerChapter({
  id = "tricks",
  title = "Tricks",
  order = 40,
  -- A function, so it lists every trick registered by then and the server's current settings.
  content = function()
    if (not inlineSkates.getTuningBool("tricks")) then
      return {
        "This server has turned tricks off. You can still jump, tip forward and back and spine transfer, see In the "
        .. "air.",
      }
    end

    local blocks = {
      "Get some air and throw down. Grabs last as long as you hold their keys, while spins and flips keep going, so "
      .. "let go in time to land them.",
    }

    for _, trick in ipairs(inlineSkates.trick.getAll()) do
      blocks[#blocks + 1] = {
        type = "card",
        title = trick.name,
        tag = getTrickPlaces(trick),
        keys = trick.keys,
        text = trick.description,
      }
    end

    blocks[#blocks + 1] = { type = "heading", text = "Combos" }
    blocks[#blocks + 1] = "Tricks combine. Try these to get started:"
    blocks[#blocks + 1] = {
      type = "controls",
      rows = {
        { "Double-tap [+back], then [+attack2]", "Backflip safety grab" },
        { "[+attack] + [+moveleft] / [+moveright]", "Mute grab 360" },
      },
    }
    blocks[#blocks + 1] = {
      type = "tip",
      text = string.format(
        "Land your flips upright and your spins facing along the way you're going: forwards or backwards both work, "
        .. "but more than %d° off knocks you over. Let go of the keys early and the trick finishes its turn by "
        .. "itself.",
        math.Round(inlineSkates.getTuning("trick_land_tolerance"))
      ),
    }
    blocks[#blocks + 1] = {
      type = "tip",
      text = "Landed a 180? You carry on skating backwards, until you turn round to face forwards again.",
    }

    return blocks
  end,
})
