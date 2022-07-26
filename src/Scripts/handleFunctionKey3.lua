local function main()
  -- Default value: 40251
  local functionAction = 40251;
  reaper.Main_OnCommandEx(functionAction, 0, 0);
end

main()
