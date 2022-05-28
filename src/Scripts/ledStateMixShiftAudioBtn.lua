function main()
  audioCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_AUDIO_BTN")
  viCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_VI_BTN")
  busCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_BUS_BTN")
  shiftBusCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_SHIFT_BUS_BTN")
  vcaCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_VCA_BTN")
  allCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_ALL_BTN")

  shiftAudioAction = reaper.NamedCommandLookup("_REASONUS_SHOW_TRACKS_WITH_RECEIVES")
  
  isNewValue, file, sec, cmd = reaper.get_action_context()
  state = reaper.GetToggleCommandStateEx(sec, cmd)
  newState = 1

  if (newState == 1) then 
    reaper.Main_OnCommandEx(shiftAudioAction, 0, 0)
  end  
  
  reaper.SetToggleCommandState(sec, audioCmdId, 0)
  reaper.SetToggleCommandState(sec, viCmdId, 0)
  reaper.SetToggleCommandState(sec, busCmdId, 0)
  reaper.SetToggleCommandState(sec, shiftBusCmdId, 0)
  reaper.SetToggleCommandState(sec, vcaCmdId, 0)
  reaper.SetToggleCommandState(sec, allCmdId, 0)
  
  reaper.SetToggleCommandState(sec, cmd, newState)
  reaper.RefreshToolbar2(sec, cmd);
end

main()

return
