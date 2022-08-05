local function main()
  local audioCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_AUDIO_BTN")
  local shiftAudioCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_SHIFT_AUDIO_BTN")
  local viCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_VI_BTN")
  local busCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_BUS_BTN")
  local shiftBusCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_SHIFT_BUS_BTN")
  local vcaCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_VCA_BTN")

  local allAction = reaper.NamedCommandLookup("_REASONUS_SHOW_ALL_TRACKS")

  local isNewValue, file, sec, cmd = reaper.get_action_context()
  local state = reaper.GetToggleCommandStateEx(sec, cmd)
  local newState = 1

  if (newState == 1) then
    reaper.Main_OnCommandEx(allAction, 0, 0)
  end

  reaper.SetToggleCommandState(sec, audioCmdId, 0)
  reaper.SetToggleCommandState(sec, shiftAudioCmdId, 0)
  reaper.SetToggleCommandState(sec, viCmdId, 0)
  reaper.SetToggleCommandState(sec, busCmdId, 0)
  reaper.SetToggleCommandState(sec, shiftBusCmdId, 0)
  reaper.SetToggleCommandState(sec, vcaCmdId, 0)

  reaper.SetToggleCommandState(sec, cmd, newState)
  reaper.RefreshToolbar2(sec, cmd);
end

main()

return
