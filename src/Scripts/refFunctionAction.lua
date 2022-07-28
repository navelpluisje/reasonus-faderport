-- Set package path to find rtk installed via ReaPack
package.path = reaper.GetResourcePath() .. '/Scripts/ReaSonus/?.lua'
-- Load the package
local rtk = require('rtk')
local uiElements = require('refUiElements')
local Colors = uiElements.Colors;

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
local FunctionAction = {};

function FunctionAction:new(index)
  local obj = {
    functionId = index,
    functionFilePath = reaper.GetResourcePath() .. '/Scripts/Reasonus/handleFunctionKey' .. index .. '.lua',
    fileLines = {},
    actionPaneOpened = false,
    element = rtk.VBox {
      w = 300,
      h = 80,
    },
    label = rtk.HBox {
      w        = 1,
      h        = 30,
      expand   = 1,
      vpadding = 10,
      bg       = Colors.Label.BackGround,
      border   = Colors.Label.Border,
    },
    labelText = rtk.Text {
      text     = '',
      w        = 1,
      halign   = rtk.Widget.CENTER,
      valign   = rtk.Widget.CENTER,
      fontsize = 20,
      tmargin  = 7
    },
    actionId = rtk.HBox {
      w        = 1,
      h        = 40,
      t        = 1,
      vpadding = 15,
      border   = Colors.Label.Border
    },
    actionButton = rtk.Button {
      icon    = uiElements.Icons.search,
      iconpos = rtk.Widget.CENTER,
      w       = 38,
      h       = 38,
      flat    = rtk.Button.FLAT,
    },
    actionIdText = rtk.Text {
      text      = 'actionId',
      h         = 1,
      halign    = rtk.Widget.CENTER,
      valign    = rtk.Widget.CENTER,
      expand    = 4,
      fillh     = true,
      fontflags = rtk.font.BOLD,
    },
    infoButton = rtk.Button {
      icon    = uiElements.Icons.about,
      iconpos = rtk.Widget.CENTER,
      w       = 38,
      h       = 38,
      flat    = rtk.Button.FLAT,
      halign  = rtk.Widget.RIGHT,
    },
  }
  setmetatable(obj, FunctionAction);
  self.__index = self;
  return obj;
end

--******************************************************************************
--
-- Generate the UI for this FunctionAction and return it
--
--******************************************************************************
function FunctionAction:getFunctionAction()
  self.labelText:attr('text', 'Function ' .. self.functionId);
  self.element:add(self.label);
  self.label:add(self.labelText)
  self.element:add(self.actionId);
  self.actionId:add(self.actionButton);
  self.actionId:add(rtk.Spacer(), { expand = 1, fillh = true })
  self.actionId:add(self.actionIdText)
  self.actionId:add(rtk.Spacer(), { expand = 1, fillh = true })
  self.actionId:add(self.infoButton);

  self.actionButton.onclick = self:getSelectedAction();
  self.infoButton.onclick = function() self:showActionInfoPopup() end;
  self:readActionFile();

  return self.element;
end

--******************************************************************************
--
-- Set position and size of the FunctionAction
-- x: Number; X-position og the FunctionAction
-- y: Number; Y-position of the FunctionAction
-- width: Number; Width of the FunctionAction
--
--******************************************************************************
function FunctionAction:setWidth(width)
  self.element:attr('w', width);
end

--******************************************************************************
--
-- Set the actionId for this FunctionAction. Also updates the values in the UI
-- actionId: the actionId for this FunctionAction
--
--******************************************************************************
function FunctionAction:setActionId(actionId)
  self.actionId = actionId;
  self.actionIdText:attr('text', actionId);
  local actionName = reaper.CF_GetCommandText(0, actionId);
  self.actionIdText:attr('tooltip', actionName);
end

--******************************************************************************
--
-- Read the data from the ActionFile corresponding to this FunctionAction
--
--******************************************************************************
function FunctionAction:readActionFile()
  for line in io.lines(self.functionFilePath) do
    self.fileLines[#self.fileLines + 1] = line;
    if string.match(line, '%s*local functionAction = (%d+);') then
      local actionId = string.match(line, '%s*local functionAction = (%d+);')
      if (actionId) then
        self:setActionId(actionId);
      end
    end
  end
end

--******************************************************************************
--
-- Write the data to the ActionFile corresponding to this FunctionAction
-- with the new actionId
--
--******************************************************************************
function FunctionAction:writeActionFile()
  local actionFile = assert(io.open(self.functionFilePath, "w"))
  for i = 1, #self.fileLines do
    local line = self.fileLines[i];
    if string.match(line, '%s*local functionAction = (%d+);') then
      line = '  local functionAction = ' .. self.actionId .. ';';
    end
    actionFile:write(line .. '\n');
  end
  actionFile:close();
  uiElements.showSavePopup(resetSurfaces);
end

--******************************************************************************
--
-- Show a Popup with the information of the action of this FunctionAction
--
--******************************************************************************
function FunctionAction:showActionInfoPopup()
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
function FunctionAction:getSelectedAction()
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

return FunctionAction;
