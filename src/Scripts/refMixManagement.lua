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
      reaper.ShowConsoleMsg(search);
      self:addSearchInputs(search);
    end
  end
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

function MixManagement:readZoneFile()
  for line in io.lines(self.zoneFilePath) do
    local displayText = string.match(line, '%s*ScribbleLine3_' .. self.filterId .. '%s*FixedTextDisplay "(%w*)"');
    if (displayText) then
      self.displayText:attr('value', displayText)
    end
    local color = string.match(line, '%s*Select' .. self.filterId .. '%s*Reaper%s*%S*%s*%{%s(.*)%s%}');

    if (color) then
      self:setFilterColor(color);
    end
  end
end

function MixManagement:addSearchInputs(searchQuery)
  for word in string.gmatch(searchQuery, "%w+") do
    local entry = uiElements.createEntry()
    entry:attr('value', word);
    self.inputList:add(entry);
  end
end

--******************************************************************************
--
-- Write the data to the ActionFile corresponding to this MixManagement
-- with the new actionId
--
--******************************************************************************
function MixManagement:writeActionFile()
  local actionFile = assert(io.open(self.functionFilePath, "w"))
  for i = 1, #self.fileLines do
    local line = self.fileLines[i];
    if string.match(line, '%s*local MixManagement = (%d+);') then
      line = '  local MixManagement = ' .. self.actionId .. ';';
    end
    actionFile:write(line .. '\n');
  end
  actionFile:close();
  uiElements.showSavePopup(resetSurfaces);
end

--******************************************************************************
--
-- Show a Popup with the information of the action of this MixManagement
--
--******************************************************************************
function MixManagement:showActionInfoPopup()
  local fullName = reaper.CF_GetCommandText(0, self.actionId)
  local actionType, actionName = string.match(fullName, "(.*):%s(.*)");
  local content = rtk.VBox {
    w       = 400,
    spacing = 10
  }
  local idLine = content:add(rtk.HBox {})
  idLine:add(rtk.Text { text = 'Action Id', w = .3 })
  idLine:add(rtk.Text { text = self.actionId })
  if (actionType) then
    local typeLine = content:add(rtk.HBox {})
    typeLine:add(rtk.Text { text = 'Action Type', w = .3 })
    typeLine:add(rtk.Text { text = actionType, w = 1 })
  end
  if (not actionName) then
    actionName = fullName
  end
  local nameLine = content:add(rtk.HBox {})
  nameLine:add(rtk.Text { text = 'Action Name', w = .3 })
  nameLine:add(rtk.Text {
    text = actionName,
    w    = 1,
    wrap = rtk.Text.WRAP_NORMAL,
  })
  uiElements.showPopup('Action info', content)
end

--******************************************************************************
--
-- Trigger the actionslist and store the selected action id
--
--******************************************************************************
function MixManagement:getSelectedAction()
  local action;
  return function()
    if (not self.actionPaneOpened) then
      action = reaper.PromptForAction(1, 0, 0);
      self.actionPaneOpened = true;
    else
      action = reaper.PromptForAction(0, 0, 0);
    end

    if action > 0 then
      while action > 0 do
        self:setActionId(action);
        self:writeActionFile();
        action = reaper.PromptForAction(0, 0, 0);
        self.actionPaneOpened = false
      end
      -- we don't " have to end the session if we want the user to be
      -- able to select actions multiple times
      reaper.PromptForAction(-1, 0, 0);
      self.actionPaneOpened = false;
    elseif action == 0 and self.actionPaneOpened then
      reaper.defer(self:getSelectedAction());
    else
      self.actionPaneOpened = false;
    end
  end
end

return MixManagement;
