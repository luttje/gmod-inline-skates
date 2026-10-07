AddCSLuaFile()

-- TODO:
-- if (SERVER) then
--   resource.AddWorkshop("<workshop id>")
-- end

inlineSkates = inlineSkates or {}

inlineSkates.ENTITY_CLASS = "sent_inline_skates"

--- Includes a file from lua/inline_skates/, sending it to clients and/or running it depending on its cl_, sh_ or sv_
--- prefix.
--- @param fileName string
--- @param directory string? Optional subdirectory of lua/inline_skates/ to include from
function inlineSkates.includePrefixed(fileName, directory)
  local prefix = fileName:sub(1, 3)

  directory = directory or ""

  if (directory ~= "" and not directory:EndsWith("/")) then
    directory = directory .. "/"
  end

  local path = "inline_skates/" .. directory .. fileName

  if (prefix ~= "cl_" and prefix ~= "sh_" and prefix ~= "sv_") then
    ErrorNoHaltWithStack("Error on includePrefixed: File not prefixed with cl_, sh_ or sv_! File was: " .. path)
    return
  end

  if (SERVER and prefix ~= "sv_") then
    AddCSLuaFile(path)
  end

  if (prefix == "sh_" or (SERVER and prefix == "sv_") or (CLIENT and prefix == "cl_")) then
    return include(path)
  end
end

inlineSkates.includePrefixed("sh_config.lua")
inlineSkates.includePrefixed("sh_permissions.lua")
inlineSkates.includePrefixed("sh_models.lua")
inlineSkates.includePrefixed("sh_tricks.lua")
inlineSkates.includePrefixed("sh_hooks.lua")
inlineSkates.includePrefixed("sh_editor.lua")

inlineSkates.includePrefixed("sv_hooks.lua")
inlineSkates.includePrefixed("sv_commands.lua")
inlineSkates.includePrefixed("sv_editor.lua")

inlineSkates.includePrefixed("cl_config.lua")
inlineSkates.includePrefixed("cl_options.lua")
inlineSkates.includePrefixed("cl_ik.lua")
inlineSkates.includePrefixed("cl_skate_parts.lua")
inlineSkates.includePrefixed("cl_hooks.lua")
inlineSkates.includePrefixed("cl_editor.lua")

--- How many degrees `direction` points above the horizon, negative when below it.
--- @param direction Vector Normalized
--- @return number
function inlineSkates.getElevation(direction)
  return math.deg(math.asin(math.Clamp(direction.z, -1, 1)))
end

--- Whether `vehicle` is the seat of a pair of inline skates.
--- @param vehicle Entity?
--- @return boolean
function inlineSkates.isSeat(vehicle)
  return IsValid(vehicle) and vehicle:GetNW2Bool("inline_skates_Seat", false)
end

--- Resolves a skates seat to the skates it belongs to.
--- @param vehicle Entity?
--- @return Entity?
function inlineSkates.getFromSeat(vehicle)
  if (not inlineSkates.isSeat(vehicle)) then
    return nil
  end

  local skates = vehicle:GetParent()

  if (IsValid(skates) and skates.IsInlineSkates) then
    return skates
  end

  return nil
end

--- The skates `player` is skating on.
--- @param player Player
--- @return Entity?
function inlineSkates.getFromPlayer(player)
  return inlineSkates.getFromSeat(player:GetVehicle())
end
