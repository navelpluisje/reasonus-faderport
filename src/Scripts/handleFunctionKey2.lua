local function main()
  -- Media explorer: Show/hide media explorer
  -- Default value: 50124
  local functionAction = 50124;
  reaper.Main_OnCommandEx(functionAction, 0, 0);
end

main()
