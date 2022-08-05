local function main()
  -- View: Toggle project bay window
  -- Default value: 41157
  local functionAction = 41157;
  reaper.Main_OnCommandEx(functionAction, 0, 0);
end

main()
