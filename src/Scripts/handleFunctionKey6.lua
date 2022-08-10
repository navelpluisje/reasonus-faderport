local function main()
  local isNewValue, file, sec, cmd = reaper.get_action_context()
  -- View: Toggle project bay window
  -- Default value: 41157
  local functionAction = 41157;

  local actionState = reaper.GetToggleCommandStateEx(0, functionAction);
  reaper.Main_OnCommandEx(functionAction, 0, 0);

  reaper.SetToggleCommandState(sec, cmd, 0)
  reaper.RefreshToolbar2(sec, cmd);
end

main()
