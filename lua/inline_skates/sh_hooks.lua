-- Skaters start from a standing sequence that the client then poses over the skates.
-- Runs on both realms so the pose matches.
hook.Add("CalcMainActivity", "inlineSkates.riderPose", function(player)
  if (not inlineSkates.isSeat(player:GetVehicle())) then
    return
  end

  local sequence = player:LookupSequence(inlineSkates.getTuningString("skater_seq"))

  if (not sequence or sequence < 0) then
    sequence = player:LookupSequence(inlineSkates.DEFAULT_SKATER_SEQUENCE)
  end

  return ACT_HL2MP_IDLE, sequence
end)
