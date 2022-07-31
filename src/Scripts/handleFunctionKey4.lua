local function main()
  -- View: Toggle FX browser window
  -- Default value: 40271
  local functionAction = 40271;
  reaper.Main_OnCommandEx(functionAction, 0, 0);
end

main()
