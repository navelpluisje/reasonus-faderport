local function createPath(path)
  return path:gsub("/", package.config:sub(1, 1));
end

package.path = reaper.GetResourcePath() .. createPath('/Scripts/ReaSonus/?.lua')
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
