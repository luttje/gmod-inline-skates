concommand.Add("inline_skates_reset_tuning", function(player)
  if (IsValid(player) and not inlineSkates.hasPermission(player, inlineSkates.PRIVILEGES.resetTuning)) then
    return
  end

  for _, definition in ipairs(inlineSkates.tuningDefinitions) do
    RunConsoleCommand(inlineSkates.tuningConVars[definition.name]:GetName(), tostring(definition.default))
  end

  print("[inline_skates] Tuning reset to defaults.")
end)
