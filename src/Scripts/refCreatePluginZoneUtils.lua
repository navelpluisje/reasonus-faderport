local function createPath(path)
  return path:gsub('/', package.config:sub(1, 1));
end

package.path = reaper.GetResourcePath() .. createPath('/Scripts/ReaSonus/?.lua')
-- Load the packages
local rtk = require('rtk')
local utils = require('utils')

local zoneUtils = {};

---Split the REAPER effect name into separate parts for name, developer and type
---@param effectName string The name of the current selected effect
---@return string type, string name, string developer
function zoneUtils.getEffectNameParts(effectName)
  local type = '';
  local name = '';
  local developer = '';

  for t, n, d in string.gmatch(effectName, '(%w+):(.*)%((%w+)%)') do
    type = t;
    name = n;
    developer = d;
  end

  return utils.trim(type), utils.trim(name), utils.trim(developer);
end

---Create the filename with step info for us in the parameters list
---@param data table
---@return string|unknown
function zoneUtils.createParamName(data)
  local paramName = data.name;
  if (data.istoggle or data.nbSteps == 2) then
    paramName = paramName .. '  (toggle)';
  end

  if (data.nbSteps > 2) then
    paramName = paramName .. string.format('  (%ssteps)', data.nbSteps);
  end
  return paramName;
end

---Get the current zone number data for file names, zone names etc
---@param pageId integer
---@return string
function zoneUtils.zoneNumber(pageId)
  return (pageId == 1) and '' or ('-' .. pageId);
end

---Get the next zone number data for file names, zone names etc
---@param pageId number
---@param nbPages number
---@return string
function zoneUtils.nextZoneNumber(pageId, nbPages)
  if (pageId + 1 > nbPages) then
    return '';
  end
  return '-' .. (pageId + 1)
end

---Get the previous zone number data for file names, zone names etc
---@param pageId number
---@param nbPages number
---@return string
function zoneUtils.prevZoneNumber(pageId, nbPages)
  if ((nbPages == 2 and pageId == 2) or pageId - 1 == 1) then
    return '';
  end
  if (pageId - 1 < 1) then
    return '-' .. nbPages;
  end
  return '-' .. (pageId - 1)
end

---Get the Step info for the zone file
---@param nbSteps number
---@return string
function zoneUtils.getSteps(nbSteps)
  if (nbSteps < 2) then
    return '';
  end
  local stepsize = 1 / (nbSteps - 1);
  local steps = '[ ';
  for i = 0, nbSteps - 1, 1 do
    steps = steps .. string.sub(tostring(stepsize * i), 1, 6) .. ' ';
  end
  steps = steps .. ']';
  return steps;
end

---Create the SubZones block for zone files with more then 1 page
---@param pageId number
---@param nbPages number
---@param pluginRawName string
---@return string
function zoneUtils.createSubZonesPart(pageId, nbPages, pluginRawName)
  local result = '  SubZones\n';
  for i = 1, nbPages, 1 do
    if (i ~= pageId) then
      result = result .. string.format('    "%s%s"\n', pluginRawName, zoneUtils.zoneNumber(i));
    end
  end
  result = result .. '  SubZonesEnd\n\n';

  result = result .. string.format(
    '  Prev   GoSubZone "%s%s"\n',
    pluginRawName,
    zoneUtils.prevZoneNumber(pageId, nbPages)
  );
  result = result .. string.format(
    '  Next   GoSubZone "%s%s"\n',
    pluginRawName,
    zoneUtils.nextZoneNumber(pageId, nbPages)
  );
  return result;
end

---Create the Select button block for zone files with more then 1 page
---@param trackId number
---@param selectData table
---@return string
function zoneUtils.createSelectPart(trackId, selectData)
  local result = '';
  if (selectData == nil or selectData.paramId == nil) then
    result = string.gsub(zoneUtils.selectNoActionText, '{{id}}', trackId);
  elseif (selectData ~= nil) then
    result = string.gsub(zoneUtils.selectText, '{{id}}', trackId);
    result = string.gsub(result, '{{paramId}}', selectData.paramId);
    result = string.gsub(result, '{{paramName}}', selectData.paramName or selectData.paramData.name);
    result = string.gsub(result, '{{steps}}', zoneUtils.getSteps(selectData.paramData.nbSteps));
    result = string.gsub(result, '{{color}}',
      selectData.paramIsToggle == true and zoneUtils.selectColors.white or
      zoneUtils.selectColors.yellow);
  end
  return result;
end

---Create the Select button block for zone files with more then 1 page
---@param trackId number
---@param selectData table
---@return string
function zoneUtils.createFaderPart(trackId, selectData)
  local result = '';
  if (selectData == nil or selectData.paramId == nil) then
    result = string.gsub(zoneUtils.faderNoActionText, '{{id}}', trackId);
  elseif (selectData ~= nil) then
    result = string.gsub(zoneUtils.faderText, '{{id}}', trackId);
    result = string.gsub(result, '{{paramId}}', selectData.paramId);
    result = string.gsub(result, '{{paramName}}', selectData.paramName or selectData.paramData.name);
    result = string.gsub(result, '{{valueBarId}}', 'blaa');
  end
  return result;
end

---@type table<'white'|'yellow', string>
zoneUtils.selectColors = {
  white = '{ 20 20 20 255 255 255 }',
  yellow = '{ 20 20 0 20 20 0 }',
}

zoneUtils.selectText = [[
  Select{{id}}             FXParam {{paramId}} {{steps}} {{color}}
  ScribbleLine1_{{id}}     FXParamNameDisplay {{paramId}} "{{paramName}}"
  ScribbleLine2_{{id}}     FXParamValueDisplay {{paramId}}
]]

zoneUtils.selectNoActionText = [[
  Select{{id}}             NoAction
  ScribbleLine1_{{id}}     NoAction
  ScribbleLine2_{{id}}     NoAction
]]

zoneUtils.faderText = [[
  Fader{{id}}              FXParam {{paramId}}
  ScribbleLine3_{{id}}     FXParamNameDisplay {{paramId}} "{{paramName}}"
  ScribbleLine4_{{id}}     FXParamValueDisplay {{paramId}}
  ValueBar{{id}}           FXParam {{paramId}} {% {{valueBarId}} %}
]]

zoneUtils.faderNoActionText = [[
  Fader{{id}}              NoAction
  ScribbleLine3_{{id}}     NoAction
  ScribbleLine4_{{id}}     NoAction
  ValueBar{{id}}           NoAction
]]

return zoneUtils;
