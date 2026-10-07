hook.Add("PlayerEnteredVehicle", "inlineSkates.riderEnter", function(player, vehicle)
  local skates = inlineSkates.getFromSeat(vehicle)

  if (skates) then
    skates:OnRiderEnter(player)
  end
end)

hook.Add("CanExitVehicle", "inlineSkates.riderCanLeave", function(vehicle, player)
  local skates = inlineSkates.getFromSeat(vehicle)

  if (skates and not skates:CanRiderLeave(player)) then
    return false
  end
end)

hook.Add("PlayerLeaveVehicle", "inlineSkates.riderLeave", function(player, vehicle)
  local skates = inlineSkates.getFromSeat(vehicle)

  if (skates) then
    skates:OnRiderLeave(player)
  end
end)

-- Caught for each of the skater's commands as it's run, as checking keys once a tick misses presses when a lagging
-- skater's commands arrive bunched up.
hook.Add("KeyPress", "inlineSkates.riderKeyPress", function(player, key)
  local skates = inlineSkates.getFromSeat(player:GetVehicle())

  if (skates and skates:GetRider() == player) then
    skates:OnRiderKeyPress(key)
  end
end)

-- Only admins may pick up skates someone wears, anyone else could use it to fling the skater around.
hook.Add("PhysgunPickup", "inlineSkates.physgunRidden", function(player, entity)
  if (entity.IsInlineSkates and IsValid(entity:GetRider())
        and not inlineSkates.hasPermission(player, inlineSkates.PRIVILEGES.physgunRidden)) then
    return false
  end
end)

-- The balance controller would fight the physgun, so it lets go while the skater is held.
hook.Add("OnPhysgunPickup", "inlineSkates.physgunPickup", function(_, entity)
  if (entity.IsInlineSkates) then
    entity.isPhysgunHeld = true
  end
end)

hook.Add("PhysgunDrop", "inlineSkates.physgunDrop", function(_, entity)
  if (entity.IsInlineSkates) then
    entity.isPhysgunHeld = false
  end
end)

-- Skaters already skating would otherwise keep the old mass until they put their skates on again.
cvars.AddChangeCallback("inline_skates_mass_ridden", function()
  -- Every registered model is its own class derived from the skates entity.
  for _, skates in ipairs(ents.FindByClass(inlineSkates.ENTITY_CLASS .. "_*")) do
    skates:UpdateMass()
  end
end, "inlineSkates.updateMass")
