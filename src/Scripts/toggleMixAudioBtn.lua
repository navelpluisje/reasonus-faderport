function main()
  isNewValue, file, sec, cmd = reaper.get_action_context()
  ownState = reaper.GetToggleCommandStateEx(sec, cmd)
  
  if ownState == 1 then
    reaper.Main_OnCommandEx(40150, 0, 0)
  end
  -- reaper.Main_OnCommandEx(40036, 0, 0)
  -- actionState = reaper.GetToggleCommandStateEx(0, 40036)
  reaper.SetToggleCommandState(sec, 40036, actionState)
  reaper.RefreshToolbar2(sec, cmd);
  cmdId = reaper.NamedCommandLookup("_REASONUS_SHOW_TRACKS_WITH_INSTRUMENT")
end

main()
