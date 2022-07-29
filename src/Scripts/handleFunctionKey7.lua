local function main()
  -- Default value: 40378
  local functionAction = 40378;
  reaper.Main_OnCommandEx(functionAction, 0, 0);
end

main()
