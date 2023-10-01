local function main()
  local channelCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_NAVI_CHANNEL_BTN")
  local zoomCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_NAVI_ZOOM_BTN")
  local scrollCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_NAVI_SCROLL_BTN")
  local masterCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_NAVI_MASTER_BTN")
  local sectionCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_NAVI_SECTION_BTN")
  local markerCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_NAVI_MARKER_BTN")

  local isNewValue, file, sec, cmd = reaper.get_action_context()
  local state = reaper.GetToggleCommandStateEx(sec, cmd)
  local newState = 1

  if (state == -1) then
    newState = 1
  end

  reaper.SetToggleCommandState(sec, channelCmdId, 0)
  reaper.SetToggleCommandState(sec, zoomCmdId, 0)
  reaper.SetToggleCommandState(sec, scrollCmdId, 0)
  reaper.SetToggleCommandState(sec, masterCmdId, 0)
  reaper.SetToggleCommandState(sec, sectionCmdId, 0)
  reaper.SetToggleCommandState(sec, markerCmdId, 0)

  reaper.SetToggleCommandState(sec, cmd, newState)
  reaper.RefreshToolbar2(sec, cmd);
end

main()
