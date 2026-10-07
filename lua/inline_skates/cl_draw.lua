inlineSkates.draw = inlineSkates.draw or {}

-- How far slanted shapes lean over, horizontally across their height.
local SLANT = 12
-- Hazard stripes.
local STRIPE_HEIGHT = 8
local STRIPE_WIDTH = 14
local TEXT_SHADOW_OFFSET = 3

local KEY_HEIGHT = 26
local KEY_PADDING = 8
local KEY_CORNER_RADIUS = 4
local KEY_SHADOW_OFFSET = 3

local TAG_HEIGHT = 22

inlineSkates.draw.SLANT = SLANT
inlineSkates.draw.STRIPE_HEIGHT = STRIPE_HEIGHT
inlineSkates.draw.STRIPE_WIDTH = STRIPE_WIDTH
inlineSkates.draw.KEY_HEIGHT = KEY_HEIGHT
inlineSkates.draw.KEY_SHADOW_OFFSET = KEY_SHADOW_OFFSET
inlineSkates.draw.TAG_HEIGHT = TAG_HEIGHT

local COLORS = {
  background = Color(17, 14, 22),
  panel = Color(34, 29, 42),
  panelAlternate = Color(42, 36, 52),
  panelHover = Color(57, 49, 70),
  sidebar = Color(25, 21, 31),
  accent = Color(255, 46, 136),
  highlight = Color(0, 222, 255),
  paper = Color(236, 234, 244),
  ink = Color(20, 16, 26),
  shadow = Color(0, 0, 0, 140),
  text = Color(238, 236, 242),
  muted = Color(146, 138, 158),
  key = Color(250, 250, 252),
  tape = Color(0, 222, 255, 150),
  watermark = Color(255, 255, 255, 8),
}

local FONTS = {
  title = "inlineSkates.draw.Title",
  chapter = "inlineSkates.draw.Chapter",
  heading = "inlineSkates.draw.Heading",
  tab = "inlineSkates.draw.Tab",
  number = "inlineSkates.draw.Number",
  watermark = "inlineSkates.draw.Watermark",
  body = "inlineSkates.draw.Body",
  small = "inlineSkates.draw.Small",
  key = "inlineSkates.draw.Key",
}

inlineSkates.draw.COLORS = COLORS
inlineSkates.draw.FONTS = FONTS

local DISPLAY_FONT = "Roboto Bk"

surface.CreateFont(FONTS.title, { font = DISPLAY_FONT, size = 56, weight = 700, italic = true })
surface.CreateFont(FONTS.chapter, { font = DISPLAY_FONT, size = 42, weight = 700, italic = true })
surface.CreateFont(FONTS.heading, { font = DISPLAY_FONT, size = 26, weight = 700, italic = true })
surface.CreateFont(FONTS.tab, { font = DISPLAY_FONT, size = 22, weight = 700, italic = true })
surface.CreateFont(FONTS.number, { font = DISPLAY_FONT, size = 30, weight = 700, italic = true })
surface.CreateFont(FONTS.watermark, { font = DISPLAY_FONT, size = 240, weight = 700, italic = true })
surface.CreateFont(FONTS.body, { font = "Roboto", size = 19, weight = 500, extended = true })
surface.CreateFont(FONTS.small, { font = "Roboto", size = 14, weight = 800, extended = true })
surface.CreateFont(FONTS.key, { font = "Roboto", size = 16, weight = 800, extended = true })

-- Keys as `input.LookupBinding` names them, which are otherwise shown capitalized.
local KEY_NAMES = {
  MOUSE1 = "Left mouse",
  MOUSE2 = "Right mouse",
  MOUSE3 = "Middle mouse",
  MOUSE4 = "Mouse 4",
  MOUSE5 = "Mouse 5",
  MWHEELUP = "Wheel up",
  MWHEELDOWN = "Wheel down",
  CTRL = "Ctrl",
  RCTRL = "Right Ctrl",
  RSHIFT = "Right Shift",
  RALT = "Right Alt",
}

--- @param text string
--- @param font string
--- @return number
function inlineSkates.draw.getTextWidth(text, font)
  surface.SetFont(font)

  return (surface.GetTextSize(text))
end

--- @param font string
--- @return number
function inlineSkates.draw.getFontHeight(font)
  surface.SetFont(font)

  return select(2, surface.GetTextSize("Ag"))
end

--- Draws a parallelogram leaning right by `slant` across its height.
function inlineSkates.draw.slantedBox(x, y, width, height, slant, color)
  surface.SetDrawColor(color)
  draw.NoTexture()
  surface.DrawPoly({
    { x = x + slant,         y = y },
    { x = x + width,         y = y },
    { x = x + width - slant, y = y + height },
    { x = x,                 y = y + height },
  })
end

--- Draws hazard stripes, which overhang `x` and `x + width` unless clipped.
function inlineSkates.draw.stripes(x, y, width, height, color)
  for stripeX = x - height, x + width, STRIPE_WIDTH * 2 do
    inlineSkates.draw.slantedBox(stripeX, y, STRIPE_WIDTH + height, height, height, color)
  end
end

--- @return number width
--- @return number height
function inlineSkates.draw.shadowedText(text, font, x, y, color, shadowColor, alignX, alignY)
  draw.SimpleText(text, font, x + TEXT_SHADOW_OFFSET, y + TEXT_SHADOW_OFFSET, shadowColor, alignX, alignY)

  return draw.SimpleText(text, font, x, y, color, alignX, alignY)
end

--- @return number # How wide `inlineSkates.draw.tag` draws `text`
function inlineSkates.draw.getTagWidth(text)
  return inlineSkates.draw.getTextWidth(text:upper(), FONTS.small) + SLANT * 2 + KEY_PADDING * 2
end

--- Draws a slanted tag with uppercase text, right-aligned to `right`.
function inlineSkates.draw.tag(text, right, centerY, color, textColor)
  text = text:upper()

  local width = inlineSkates.draw.getTagWidth(text)
  local x = right - width

  inlineSkates.draw.slantedBox(x, centerY - TAG_HEIGHT * 0.5, width, TAG_HEIGHT, SLANT * 0.5, color)
  draw.SimpleText(text, FONTS.small, x + width * 0.5, centerY, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

--- @param key string A key's name, or a bind such as "+forward"
--- @return string # The name of the key bound to `key` if it's a bind, otherwise `key` itself
function inlineSkates.draw.getKeyName(key)
  if (not key:StartsWith("+")) then
    return key
  end

  local boundKey = input.LookupBinding(key, true)

  if (not boundKey) then
    return key:sub(2) .. " (unbound)"
  end

  boundKey = boundKey:upper()

  return KEY_NAMES[boundKey] or (boundKey:sub(1, 1) .. boundKey:sub(2):lower())
end

--- @param text string Such as "Double-tap [+back]"
--- @return table[] # `{ text, isKey }` for each key and each piece of text between them
function inlineSkates.draw.parseKeys(text)
  local tokens = {}
  local position = 1

  while (position <= #text) do
    local keyStart, keyEnd, key = text:find("%[(.-)%]", position)

    if (not keyStart) then
      tokens[#tokens + 1] = { text = text:sub(position) }
      break
    end

    if (keyStart > position) then
      tokens[#tokens + 1] = { text = text:sub(position, keyStart - 1) }
    end

    tokens[#tokens + 1] = { text = inlineSkates.draw.getKeyName(key), isKey = true }
    position = keyEnd + 1
  end

  return tokens
end

--- @param token table
--- @return number
local function getTokenWidth(token)
  surface.SetFont(token.isKey and FONTS.key or FONTS.body)

  local textWidth = surface.GetTextSize(token.text)

  return token.isKey and textWidth + KEY_PADDING * 2 + KEY_SHADOW_OFFSET or textWidth
end

--- @param tokens table[] From `inlineSkates.draw.parseKeys`
--- @return number
function inlineSkates.draw.getKeysWidth(tokens)
  local width = 0

  for _, token in ipairs(tokens) do
    width = width + getTokenWidth(token)
  end

  return width
end

--- Draws keys as keycaps in a row, with the text between them in `textColor`.
--- @param tokens table[] From `inlineSkates.draw.parseKeys`
--- @param x number
--- @param y number The top of the keycaps
--- @param textColor Color
function inlineSkates.draw.keys(tokens, x, y, textColor)
  for _, token in ipairs(tokens) do
    local width = getTokenWidth(token)

    if (token.isKey) then
      local capWidth = width - KEY_SHADOW_OFFSET

      local shadowX, shadowY = x + KEY_SHADOW_OFFSET, y + KEY_SHADOW_OFFSET

      draw.RoundedBox(KEY_CORNER_RADIUS, shadowX, shadowY, capWidth, KEY_HEIGHT, COLORS.accent)
      draw.RoundedBox(KEY_CORNER_RADIUS, x, y, capWidth, KEY_HEIGHT, COLORS.key)
      draw.SimpleText(
        token.text, FONTS.key, x + capWidth * 0.5, y + KEY_HEIGHT * 0.5, COLORS.ink,
        TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
      )
    else
      draw.SimpleText(token.text, FONTS.body, x, y + KEY_HEIGHT * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    x = x + width
  end
end
