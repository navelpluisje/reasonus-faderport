-- Set package path to find rtk installed via ReaPack
package.path = reaper.GetResourcePath() .. '/Scripts/ReaSonus/?.lua'
-- Load the package
local rtk = require('rtk')
local uiElements = require('refUiElements')

--******************************************************************************
--
-- Reset all the midi surfaces
--
--******************************************************************************
local function resetSurfaces()
  reaper.Main_OnCommandEx(41743, 0, 0)
end

--******************************************************************************
--
-- Class for the function action elements
--
--******************************************************************************
local MixManagement = {};

function MixManagement:new(index, faderPortVersion)
  local obj = {
    filterId = index,
    filterFilePath = reaper.GetResourcePath() .. '/Scripts/Reasonus/mixManagementFilter' .. index .. '.lua',
    zoneFilePath = reaper.GetResourcePath() ..
        '/CSI/Zones/ReasonusFaderPort/FP' .. faderPortVersion .. '_TracksByName.zon',
    fileLines = {},
    actionPaneOpened = false,
    isBuild = false,
    element = rtk.VBox {
      w = 1,
    },
    splitBox = rtk.HBox {
      w = 1,
      spacing = 16,
    },
    left = rtk.VBox {
      w = .5,
      spacing = 8,
    },
    right = rtk.VBox {
      w = 1,
      spacing = 8,
    },
    displayTextLabel = rtk.Text {
      text     = '',
      w        = 1,
      halign   = rtk.Widget.LEFT,
      valign   = rtk.Widget.CENTER,
      fontsize = 20,
      tmargin  = 7
    },
    labelText = rtk.Text {
      text     = '',
      w        = 1,
      halign   = rtk.Widget.LEFT,
      valign   = rtk.Widget.CENTER,
      fontsize = 20,
      tmargin  = 7
    },
    inputList = rtk.VBox {
      w = 1,
      spacing = 8,
    },
    buttonBar = rtk.HBox {
      w = 1,
      spacing = 16,
    },
    colorPicker = uiElements.colorPicker('Color');
    showSiblings = uiElements.createCheckBox('Show track siblings'),
    showParents = uiElements.createCheckBox('Show track parents', true),
    showChildren = uiElements.createCheckBox('Show track children', true),
    onlyTopLevel = uiElements.createCheckBox('Show only top level tracks', true),
    matchMultiple = uiElements.createCheckBox('Match multiple', true),
    displayText = uiElements.createEntry(),
  }
  setmetatable(obj, MixManagement);
  self.__index = self;
  return obj;
end

--******************************************************************************
--
-- Generate the UI for this MixManagement and return it
--
--******************************************************************************
function MixManagement:buildMixManagement()
  self.labelText:attr('text', 'Filter Text (Each word in a new field)');
  self.displayTextLabel:attr('text', 'Display Text');
  self.element:add(self.splitBox);
  self.splitBox:add(self.left);
  self.splitBox:add(self.right);
  self.left:add(self.displayTextLabel);
  self.left:add(self.displayText);
  self.left:add(self.labelText);
  self.left:add(self.inputList);
  self.left:add(self.buttonBar);
  self.buttonBar:add(rtk.Spacer(), { expand = 1, fillw = true, fillh = false });
  local button = self.buttonBar:add(uiElements.createButton('Add word', uiElements.Icons.add))
  self.right:add(self.showSiblings);
  self.right:add(self.showParents);
  self.right:add(self.showChildren);
  self.right:add(self.onlyTopLevel);
  self.right:add(self.matchMultiple);
  self.right:add(self.colorPicker.colorPicker);

  button:attr('halign', rtk.Widget.RIGHT)
  button.onclick = function()
    self.inputList:add(uiElements.createEntry())
  end

  self:readActionFile();
  self:readZoneFile();
end

function MixManagement:getMixManagement()
  if (not self.isBuild) then
    self.isBuild = true;
    self:buildMixManagement();
  end
  return self.element;
end

--******************************************************************************
--
-- Read the data from the ActionFile corresponding to this MixManagement
--
--******************************************************************************
function MixManagement:readActionFile()
  for line in io.lines(self.filterFilePath) do
    self.fileLines[#self.fileLines + 1] = line;

    local showSibling = string.match(line, '%s*showsiblings = (%w*),') == 'true';
    if (showSibling) then
      self.showSiblings:attr('value', showSibling);
    end

    local showParents = string.match(line, '%s*showparents = (%w*),') == 'true';
    if (showParents) then
      self.showParents:attr('value', showParents);
    end

    local showChildren = string.match(line, '%s*showchildren = (%w*),') == 'true';
    if (showChildren) then
      self.showChildren:attr('value', showChildren);
    end

    local onlyTopLevel = string.match(line, '%s*matchonlytop = (%w*),') == 'true';
    if (onlyTopLevel) then
      self.onlyTopLevel:attr('value', onlyTopLevel);
    end

    local matchMultiple = string.match(line, '%s*matchmultiple = "(%w*)",') == 'true';
    if (matchMultiple) then
      self.matchMultiple:attr('value', matchMultiple);
    end

    local search = string.match(line, '%s*search = "(.*)",');
    if (search) then
      self:addSearchInputs(search);
    end
  end
end

--******************************************************************************
--
-- Write the data to the ActionFile corresponding to this MixManagement
--
--******************************************************************************
function MixManagement:writeActionFile()
  local lines = {};
  for line in io.lines(self.filterFilePath) do
    lines[#lines + 1] = line;
  end

  local actionFile = assert(io.open(self.filterFilePath, "w"))
  for i = 1, #lines do
    local line = lines[i];

    if string.match(line, '%s*showsiblings = (%w*),') then
      local value = self.showSiblings.value and 'true' or 'false';
      line = '\tshowsiblings = ' .. value .. ',';
    end

    if string.match(line, '%s*showparents = (%w*),') then
      local value = self.showParents.value and 'true' or 'false';
      line = '\tshowparents = ' .. value .. ',';
    end

    if string.match(line, '%s*showchildren = (%w*),') then
      local value = self.showChildren.value and 'true' or 'false';
      line = '\tshowchildren = ' .. value .. ',';
    end

    if string.match(line, '%s*matchonlytop = (%w*),') then
      local value = self.onlyTopLevel.value and 'true' or 'false';
      line = '\tmatchonlytop = ' .. value .. ',';
    end

    if string.match(line, '%s*matchmultiple = (%w*),') then
      local value = self.matchMultiple.value and 'true' or 'false';
      line = '\tmatchmultiple = ' .. value .. ',';
    end

    if string.match(line, '%s*search = "(.*)",') then
      local value = '';
      for j = 1, #self.inputList.children do
        local widget, attrs = table.unpack(self.inputList.children[j])
        if (value ~= '') then
          value = value .. '|';
        end
        value = value .. widget.value;
      end
      line = '\tsearch = "' .. value .. '",';
    end
    actionFile:write(line .. '\n');
  end
  actionFile:close();
end

--******************************************************************************
--
-- Read the color and name from the mix management ZoneFile
--
--******************************************************************************
function MixManagement:readZoneFile()
  for line in io.lines(self.zoneFilePath) do
    local displayText = string.match(line, '%s*ScribbleLine3_' .. self.filterId .. '%s*FixedTextDisplay "(%w*)"');

    if (displayText) then
      self.displayText:attr('value', displayText)
    end

    local color = string.match(line, '%s*Select' .. self.filterId .. '%s*FixedRGBColourDisplay%s*%{%s(.*)%s%}');
    if (color) then
      self:setFilterColor(color);
    end
  end
end

--******************************************************************************
--
-- Write the color and name to the mix management ZoneFile
--
--******************************************************************************
function MixManagement:writeZoneFile()
  local lines = {};
  for line in io.lines(self.zoneFilePath) do
    lines[#lines + 1] = line;
  end

  local zoneFile = assert(io.open(self.zoneFilePath, "w"))
  for i = 1, #lines do
    local line = lines[i];

    if (string.match(line, '%s*ScribbleLine3_' .. self.filterId .. '%s*FixedTextDisplay "(%w*)"')) then
      local value = self.displayText.value;
      line = '  ScribbleLine3_' .. self.filterId .. '     FixedTextDisplay "' .. value .. '" {% Invert %}';
    end

    if (string.match(line, '%s*Select' .. self.filterId .. '%s*FixedRGBColourDisplay%s{%s(.*)%s%}')) then
      local value = self.colorPicker.getCSIValue();
      line = '  Select' .. self.filterId .. '             FixedRGBColourDisplay { ' .. value .. ' }';
    end
    zoneFile:write(line .. '\n');
  end
  zoneFile:close();
end

function MixManagement:setFilterColor(clr)
  local color = {};
  local index = 1;

  for rgbValue in string.gmatch(clr, '%S+') do
    if (index < 4) then
      color[index] = rgbValue;
      index = index + 1;
    end
  end

  self.colorPicker.setValue(color[1], color[2], color[3]);
end

function MixManagement:addSearchInputs(searchQuery)
  for word in string.gmatch(searchQuery, "%w+") do
    local entry = uiElements.createEntry()
    entry:attr('value', word);
    self.inputList:add(entry);
  end
end

function MixManagement:writeChangesToFile()
  self:writeActionFile();
  self:writeZoneFile();
  uiElements.showSavePopup(resetSurfaces);

end

return MixManagement;
