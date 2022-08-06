local function main()
  local isNewValue, file, sec, cmd = reaper.get_action_context()
  -- View: Toggle routing matrix window
  -- Default value: 40251
  local functionAction = 40251;

  local actionState = reaper.GetToggleCommandStateEx(0, functionAction);
  reaper.Main_OnCommandEx(functionAction, 0, 0);

  reaper.SetToggleCommandState(sec, cmd, actionState == 0 and 1 or 0)
  reaper.RefreshToolbar2(sec, cmd);
end

main()
