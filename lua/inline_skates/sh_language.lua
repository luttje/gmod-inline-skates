inlineSkates.lang = inlineSkates.lang or {}

local LANGUAGES_FOLDER = "inline_skates/languages/"
local FALLBACK_LANGUAGE = "en"
local PHRASE_PREFIX = "inline_skates."

--- @type table<string, string> English, plus the current language on the client
local phrases = {}

--- @param code string
--- @return table<string, string>? # The language's phrases, nil when there is no file for it
local function loadLanguageFile(code)
  local path = LANGUAGES_FOLDER .. code .. ".lua"

  if (not file.Exists(path, "LUA")) then
    return nil
  end

  local languagePhrases = include(path)

  if (not istable(languagePhrases)) then
    ErrorNoHaltWithStack("[inline_skates] Language file " .. path .. " must return a table of phrases.\n")
    return nil
  end

  return languagePhrases
end

--- @return string # The language GMod is set to, such as "en" or "zh-CN"
function inlineSkates.lang.getCurrentCode()
  if (SERVER) then
    return FALLBACK_LANGUAGE
  end

  local code = GetConVar("gmod_language"):GetString()

  return code ~= "" and code or FALLBACK_LANGUAGE
end

--- Loads English and then the current language over it, and hands every phrase to GMod's language library.
function inlineSkates.lang.reload()
  phrases = table.Copy(loadLanguageFile(FALLBACK_LANGUAGE) or {})

  local code = inlineSkates.lang.getCurrentCode()

  if (code ~= FALLBACK_LANGUAGE) then
    -- Regional codes fall back to the language as a whole, such as "pt-BR" to a "pt" file.
    local languagePhrases = loadLanguageFile(code) or loadLanguageFile(code:match("^(%a+)%-") or code)

    table.Merge(phrases, languagePhrases or {})
  end

  if (CLIENT) then
    for key, text in pairs(phrases) do
      language.Add(PHRASE_PREFIX .. key, text)
    end
  end
end

--- @param key string
--- @return boolean # Whether a phrase exists for `key`, in English or the current language
function inlineSkates.lang.has(key)
  return phrases[key] ~= nil
end

--- @param text string
--- @param values table? Replaces each `{name}` in `text` with `values.name`
--- @return string
local function fillPlaceholders(text, values)
  if (not values) then
    return text
  end

  return (text:gsub("{([%w_]+)}", function(name)
    local value = values[name]

    return value ~= nil and tostring(value) or nil
  end))
end

--- @param key string A key from the language files, without the "inline_skates." prefix
--- @param values table? Replaces each `{name}` in the phrase with `values.name`
--- @return string # The phrase in the current language, or `key` itself when no language has it
function inlineSkates.lang.get(key, values)
  local text = phrases[key]

  -- Goes through GMod's language library, so other addons can override a phrase with language.Add.
  if (CLIENT and text) then
    text = language.GetPhrase(PHRASE_PREFIX .. key)
  end

  return fillPlaceholders(text or key, values)
end

--- Translates text that may be a phrase, as GMod does: text starting with "#" is a phrase's key, anything else is
--- shown as it is. For text that other addons can give either way, such as trick and guide chapter names.
--- @param text string Such as "#inline_skates.trick_spin" or "Tabletop"
--- @param values table? Replaces each `{name}` in the text with `values.name`
--- @return string
function inlineSkates.lang.translate(text, values)
  if (not isstring(text) or text:sub(1, 1) ~= "#") then
    return fillPlaceholders(text, values)
  end

  local key = text:sub(2)

  if (key:StartsWith(PHRASE_PREFIX)) then
    return inlineSkates.lang.get(key:sub(#PHRASE_PREFIX + 1), values)
  end

  return fillPlaceholders(CLIENT and language.GetPhrase(key) or key, values)
end

-- Lowercase letters outside ASCII that are this far after their uppercase letter, as first and last codepoints.
local UPPERCASE_OFFSETS = {
  { 0xE0,  0xF6,  0x20 }, -- Latin-1, such as ä and é
  { 0xF8,  0xFE,  0x20 },
  { 0x3B1, 0x3C1, 0x20 }, -- Greek
  { 0x3C3, 0x3CB, 0x20 },
  { 0x430, 0x44F, 0x20 }, -- Cyrillic
  { 0x450, 0x45F, 0x50 },
}
-- Latin Extended-A, such as ł and ž, pairs each uppercase letter with the lowercase one after it. They start on even
-- codepoints, except in these runs where they start on odd ones. The letters listed after them have no uppercase.
local LATIN_EXTENDED_ODD_RUNS = { { 0x139, 0x148 }, { 0x179, 0x17E } }
local LATIN_EXTENDED_UNPAIRED = { [0x131] = true, [0x138] = true, [0x149] = true, [0x17F] = true }

--- @param codepoint number
--- @return number # The uppercase letter's codepoint, or `codepoint` itself when it has none
local function getUppercaseCodepoint(codepoint)
  if (codepoint >= 0x61 and codepoint <= 0x7A) then
    return codepoint - 0x20
  end

  for _, range in ipairs(UPPERCASE_OFFSETS) do
    if (codepoint >= range[1] and codepoint <= range[2]) then
      return codepoint - range[3]
    end
  end

  if (codepoint == 0xFF) then
    return 0x178
  end

  if (codepoint < 0x100 or codepoint > 0x17F or LATIN_EXTENDED_UNPAIRED[codepoint]) then
    return codepoint
  end

  local isOddRun = false

  for _, run in ipairs(LATIN_EXTENDED_ODD_RUNS) do
    isOddRun = isOddRun or (codepoint >= run[1] and codepoint <= run[2])
  end

  local isLowercase = (codepoint % 2 == 1) ~= isOddRun

  return isLowercase and codepoint - 1 or codepoint
end

--- Like `string.upper`, but also for letters outside ASCII in Latin, Greek and Cyrillic scripts, which `string.upper`
--- leaves as they are. Scripts without case, such as Chinese, are left as they are too.
--- @param text string
--- @return string
function inlineSkates.lang.upper(text)
  if (not text:find("[\128-\255]")) then
    return text:upper()
  end

  local isValid, uppercase = pcall(function()
    local characters = {}

    for _, codepoint in utf8.codes(text) do
      characters[#characters + 1] = utf8.char(getUppercaseCodepoint(codepoint))
    end

    return table.concat(characters)
  end)

  return isValid and uppercase or text:upper()
end

--- Prints one of the addon's phrases to the console, in English on the server.
--- @param key string
--- @param values table? Replaces each `{name}` in the phrase with `values.name`
function inlineSkates.lang.print(key, values)
  print("[inline_skates] " .. inlineSkates.lang.get(key, values))
end

if (SERVER) then
  util.AddNetworkString("inline_skates.Message")

  for _, fileName in ipairs((file.Find(LANGUAGES_FOLDER .. "*.lua", "LUA"))) do
    AddCSLuaFile(LANGUAGES_FOLDER .. fileName)
  end

  --- Prints one of the addon's phrases to `player`'s console, in their own language.
  --- @param player Player
  --- @param key string
  --- @param values table? Replaces each `{name}` in the phrase with `values.name`
  function inlineSkates.lang.sendMessage(player, key, values)
    net.Start("inline_skates.Message")
    net.WriteString(key)
    net.WriteTable(values or {})
    net.Send(player)
  end
else
  net.Receive("inline_skates.Message", function()
    local key = net.ReadString()

    inlineSkates.lang.print(key, net.ReadTable())
  end)
end

inlineSkates.lang.reload()

if (CLIENT) then
  -- Panels built from phrases already, such as the spawn menu, keep their text until they're built again.
  cvars.AddChangeCallback("gmod_language", function()
    inlineSkates.lang.reload()
  end, "inlineSkates.lang")
end
