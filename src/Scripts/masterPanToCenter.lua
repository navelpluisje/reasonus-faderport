local function main()
  local master = reaper.GetMasterTrack()
  local ok, vol, pan = reaper.GetTrackUIVolPan(master, 0, 0)
  reaper.SetMediaTrackInfo_Value(master, 'D_PAN', 0)
end

main()
