util.AddNetworkString("inline_skates.editModelSetting")

-- An admin changed a model setting in the skate editor: apply it here and pass it on to every client.
net.Receive("inline_skates.editModelSetting", function(_, player)
  local id, key = net.ReadString(), net.ReadString()
  local setting = inlineSkates.editor.settingsByKey[key]

  if (not setting or not inlineSkates.models[id]
        or not inlineSkates.hasPermission(player, inlineSkates.PRIVILEGES.editor)) then
    return
  end

  local value = inlineSkates.editor.clampValue(setting, inlineSkates.editor.readValue(setting))

  inlineSkates.setModelSetting(id, key, value)

  net.Start("inline_skates.editModelSetting")
  net.WriteString(id)
  net.WriteString(key)
  inlineSkates.editor.writeValue(setting, value)
  net.Broadcast()
end)
