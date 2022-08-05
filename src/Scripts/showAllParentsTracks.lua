package.path = reaper.GetResourcePath() .. '/Scripts/ReaSonus/?.lua'
local showTracks = require("showTracksByName")

local settings = {
  showsiblings = false,
  showparents = true,
  matchonlytop = true,
  search = "",
  showchildren = false,
  matchmultiple = true,
}

showTracks.showTracks(settings)

return
