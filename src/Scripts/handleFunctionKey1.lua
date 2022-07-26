local function main()
  -- Default value: 40078
  local functionAction = 40078;
  reaper.Main_OnCommandEx(functionAction, 0, 0);
end

main()
