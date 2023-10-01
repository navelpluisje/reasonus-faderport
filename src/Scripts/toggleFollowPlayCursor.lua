local function main()
  local isNewValue, file, sec, cmd = reaper.get_action_context()
  local ownState = reaper.GetToggleCommandStateEx(sec, cmd)

  if ownState == 1 then
    reaper.Main_OnCommandEx(40150, 0, 0)
  end
  reaper.Main_OnCommandEx(40036, 0, 0)
  local actionState = reaper.GetToggleCommandStateEx(0, 40036)
  reaper.SetToggleCommandState(sec, cmd, actionState)
  reaper.RefreshToolbar2(sec, cmd);
end

main()
