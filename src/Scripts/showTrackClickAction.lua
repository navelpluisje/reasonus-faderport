local function main()
  local audioCmdId = reaper.NamedCommandLookup("_REASONUS_LED_STATE_MIX_AUDIO_BTN")
  reaper.SetToggleCommandState(0, audioCmdId, 2)
  reaper.RefreshToolbar2(0, audioCmdId);
  reaper.Main_OnCommandEx(audioCmdId, 0, 0)
end

main()

return
