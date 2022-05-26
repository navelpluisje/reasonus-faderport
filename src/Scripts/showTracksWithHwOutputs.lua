-- Select the first visible track
local function select_first_visible_MCP()
  for i = 1, reaper.CountTracks(0) do
      local tr = reaper.GetTrack(0, i - 1)
      if reaper.IsTrackVisible(tr, true) then
          reaper.SetOnlyTrackSelected(tr)
          break
      end
  end
end

function set_visibility(tracks)
  if not tracks then return end
  --if not tracks or #tracks == 0 then return end

  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)  -- Disable refreshing the UI

  for i = 1, reaper.CountTracks(0) do
      local tr = reaper.GetTrack(0, i - 1)

      reaper.SetMediaTrackInfo_Value(tr, "B_SHOWINMIXER", tracks[i] and 1 or 0)
  end

  select_first_visible_MCP()

  reaper.PreventUIRefresh(-1)  -- Enable refreshing again
  reaper.Undo_EndBlock("Show only specified tracks", -1)

  reaper.TrackList_AdjustWindows(false)
  reaper.UpdateArrange()
end

-- Get the tracks which math the criteria.
-- Pass the settings
-- Return a table with the ids to display
function get_tracks_to_show()
  local matches = {}

  -- Find all matches
  for i = 1, reaper.CountTracks(0) do

      local tr = reaper.GetTrack(0, i - 1)
      local hasHwOutputs = reaper.GetTrackNumSends(tr, 1)
      local idx = math.floor( reaper.GetMediaTrackInfo_Value(tr, "IP_TRACKNUMBER") )

      if (hasHwOutputs > 0) then
          matches[idx] = true
      end
  end

  -- Hacky way to check if length of a hash table == 0
  for k in pairs(matches) do
      if not k then return {} end
  end

  return matches
end

function showTracks()
  local tracks = get_tracks_to_show()
  if tracks then
      set_visibility( tracks )
  else
      reaper.MB(
          "No tracks with instruments available", "Whoops!", 0)
  end
end

showTracks()