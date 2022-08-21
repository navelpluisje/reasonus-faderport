package.path = reaper.GetResourcePath() .. '/Scripts/ReaSonus/?.lua'
local showTracks = require("showTracksByName")

local settings = {
  showsiblings = false,
  showparents = false,
  matchonlytop = true,
  search = "Vocals|vox",
  showchildren = true,
  matchmultiple = true,
}

showTracks.showTracks(settings)

return
