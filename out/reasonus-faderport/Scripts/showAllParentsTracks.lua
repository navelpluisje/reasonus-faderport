-- This script was generated by Lokasenna_Show only specified tracks.lua
local path = ({reaper.get_action_context()})[2]:match('^.+[\\//]')
package.path = path .. "?.lua"
local showTracks = require("showTracksByName")

local settings = {
  showsiblings = false,
  showparents = false,
  matchonlytop = false,
  search = "",
  showchildren = false,
  matchmultiple = true,
}

showTracks.showTracks(settings)

return