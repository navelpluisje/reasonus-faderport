package.path = reaper.GetResourcePath() .. '/Scripts/ReaSonus/?.lua'
local showTracks = require("showTracksByName")

local settings = {
  showsiblings = true,
  showparents = true,
  matchonlytop = true,
  search = "",
  showchildren = true,
  matchmultiple = true,
}

showTracks.showTracks(settings)

return
