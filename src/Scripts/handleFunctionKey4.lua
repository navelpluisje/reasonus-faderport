local function main()
  local isNewValue, file, sec, cmd = reaper.get_action_context()
  -- View: Toggle FX browser window
  -- Default value: 40271
  local functionAction = 40271;

  local actionState = reaper.GetToggleCommandStateEx(0, functionAction);
  reaper.Main_OnCommandEx(functionAction, 0, 0);

  reaper.SetToggleCommandState(sec, cmd, 0)
  reaper.RefreshToolbar2(sec, cmd);
end

main()
