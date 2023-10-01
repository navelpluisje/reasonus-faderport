local path = ({ reaper.get_action_context() })[2]:match('^.+[\\//]')
package.path = path .. "?.lua"
local showTracks = require("showTracksByName")

local settings = {
  showsiblings = false,
  showparents = false,
  matchonlytop = true,
  search = "Keys|Synth|Organ",
  showchildren = true,
  matchmultiple = true,
}

showTracks.showTracks(settings)

return
