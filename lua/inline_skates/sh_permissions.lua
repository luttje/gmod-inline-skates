-- Admin-only actions are CAMI privileges, so admin mods (ULX, SAM, Helix and others) can grant them to any group.
-- Without an admin mod they fall back to admins only.
inlineSkates.PRIVILEGES = {
  physgunRidden = {
    Name = "Inline Skates - Physgun Skaters",
    MinAccess = "admin",
    Description = "Pick up skates someone is skating on with the physgun",
  },
  resetTuning = {
    Name = "Inline Skates - Reset Tuning",
    MinAccess = "admin",
    Description = "Reset the server's skate tuning with inline_skates_reset_tuning",
  },
  editor = {
    Name = "Inline Skates - Model Editor",
    MinAccess = "admin",
    Description = "Change skate model settings with inline_skates_editor",
  },
}

-- Admin mods may load CAMI after this addon, so privileges are registered once every addon has loaded.
hook.Add("Initialize", "inlineSkates.registerPrivileges", function()
  if (not CAMI) then
    return
  end

  for _, privilege in pairs(inlineSkates.PRIVILEGES) do
    CAMI.RegisterPrivilege(privilege)
  end
end)

--- @param player Player
--- @param privilege table One of `inlineSkates.PRIVILEGES`
--- @return boolean
function inlineSkates.hasPermission(player, privilege)
  if (CAMI) then
    local hasAccess = nil

    CAMI.PlayerHasAccess(player, privilege.Name, function(result)
      hasAccess = result
    end)

    if (hasAccess ~= nil) then
      return hasAccess
    end
  end

  return player:IsAdmin()
end
