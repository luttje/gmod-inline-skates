concommand.Add("inline_skates_reset_tuning", function(player)
  if (IsValid(player) and not inlineSkates.hasPermission(player, inlineSkates.PRIVILEGES.resetTuning)) then
    inlineSkates.lang.sendMessage(player, "options_reset_tuning_denied")
    return
  end

  for _, definition in ipairs(inlineSkates.tuningDefinitions) do
    RunConsoleCommand(inlineSkates.tuningConVars[definition.name]:GetName(), tostring(definition.default))
  end

  if (IsValid(player)) then
    inlineSkates.lang.sendMessage(player, "options_reset_tuning_done")
  else
    inlineSkates.lang.print("options_reset_tuning_done")
  end
end)
