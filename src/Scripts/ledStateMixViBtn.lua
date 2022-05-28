function main()
  audioCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_AUDIO_BTN")
  vcaCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_VCA_BTN")
  busCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_BUS_BTN")
  allCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_ALL_BTN")

  viAction = reaper.NamedCommandLookup("_REASONUS_SHOW_TRACKS_WITH_INSTRUMENT")
  
  isNewValue, file, sec, cmd = reaper.get_action_context()
  state = reaper.GetToggleCommandStateEx(sec, cmd)

  newState = 1
  if (state == -1) then
    newState = 0
  end
  
  if (newState == 1) then 
    reaper.Main_OnCommandEx(viAction, 0, 0)
  end  
  
  reaper.SetToggleCommandState(sec, audioCmdId, 0)
  reaper.SetToggleCommandState(sec, vcaCmdId, 0)
  reaper.SetToggleCommandState(sec, busCmdId, 0)
  reaper.SetToggleCommandState(sec, allCmdId, 0)
  
  reaper.SetToggleCommandState(sec, cmd, newState)
  reaper.RefreshToolbar2(sec, cmd);
end

main()

return
