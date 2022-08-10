local function main()
  local mixAllCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_ALL_BTN");
  local naviBankCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_NAVI_BANK_BTN");

  local function1CmdId = reaper.NamedCommandLookup("_REASONUS_HANDLE_FUNCTION_KEY_1");
  local function2CmdId = reaper.NamedCommandLookup("_REASONUS_HANDLE_FUNCTION_KEY_2");
  local function3CmdId = reaper.NamedCommandLookup("_REASONUS_HANDLE_FUNCTION_KEY_3");
  local function4CmdId = reaper.NamedCommandLookup("_REASONUS_HANDLE_FUNCTION_KEY_4");
  local function5CmdId = reaper.NamedCommandLookup("_REASONUS_HANDLE_FUNCTION_KEY_5");
  local function6CmdId = reaper.NamedCommandLookup("_REASONUS_HANDLE_FUNCTION_KEY_6");
  local function7CmdId = reaper.NamedCommandLookup("_REASONUS_HANDLE_FUNCTION_KEY_7");
  local function8CmdId = reaper.NamedCommandLookup("_REASONUS_HANDLE_FUNCTION_KEY_8");

  reaper.Main_OnCommandEx(mixAllCmdId, 0, 0);
  reaper.Main_OnCommandEx(naviBankCmdId, 0, 0);

  reaper.SetToggleCommandState(0, function1CmdId, 0)
  reaper.SetToggleCommandState(0, function2CmdId, 0)
  reaper.SetToggleCommandState(0, function3CmdId, 0)
  reaper.SetToggleCommandState(0, function4CmdId, 0)
  reaper.SetToggleCommandState(0, function5CmdId, 0)
  reaper.SetToggleCommandState(0, function6CmdId, 0)
  reaper.SetToggleCommandState(0, function7CmdId, 0)
  reaper.SetToggleCommandState(0, function8CmdId, 0)
  reaper.RefreshToolbar2(0, function1CmdId);
  reaper.RefreshToolbar2(0, function2CmdId);
  reaper.RefreshToolbar2(0, function3CmdId);
  reaper.RefreshToolbar2(0, function4CmdId);
  reaper.RefreshToolbar2(0, function5CmdId);
  reaper.RefreshToolbar2(0, function6CmdId);
  reaper.RefreshToolbar2(0, function7CmdId);
  reaper.RefreshToolbar2(0, function8CmdId);

end

main()
