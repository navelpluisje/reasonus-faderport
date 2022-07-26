local function main()
  -- Default value: 40326
  local functionAction = 40326;
  reaper.Main_OnCommandEx(functionAction, 0, 0);
end

main()
