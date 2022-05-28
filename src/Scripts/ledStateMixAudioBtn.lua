function main()
  viCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_VI_BTN")
  busCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_BUS_BTN")
  vcaCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_VCA_BTN")
  allCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_ALL_BTN")

  isNewValue, file, sec, cmd = reaper.get_action_context()
  state = reaper.GetToggleCommandStateEx(sec, cmd)
  newState = 1
  
  if (state == -1) then
    newState = 0
  end
  if (state == 0) then
    newState = 1
  end
  if (state == 1) then
    newState = 0
  end
  if (state == 2) then
    newState = 3
  end
  if (state == 3) then
    newState = 2
  end
  
  -- 0 and 1 are only togglling. 2 and 3 are in a filter mode
  if (newState > 1) then  
    reaper.SetToggleCommandState(sec, viCmdId, 0)
    reaper.SetToggleCommandState(sec, busCmdId, 0)
    reaper.SetToggleCommandState(sec, vcaCmdId, 0)
    reaper.SetToggleCommandState(sec, allCmdId, 0)
  end
  
  reaper.SetToggleCommandState(sec, cmd, newState)
  reaper.RefreshToolbar2(sec, cmd);
end

main()

return
