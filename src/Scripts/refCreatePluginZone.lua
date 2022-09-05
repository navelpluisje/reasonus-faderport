-- Set package path to find rtk installed via ReaPack
local function createPath(path)
  return path:gsub("/", package.config:sub(1, 1));
end

package.path = reaper.GetResourcePath() .. createPath('/Scripts/ReaSonus/?.lua')
-- Load the package
local rtk = require('rtk')
local utils = require('utils')
local uiElements = require('refUiElements')

-- local log = rtk.log
-- log.level = log.WARNING

--******************************************************************************
--
-- Reset all the midi surfaces
--
--******************************************************************************
local function resetSurfaces()
  reaper.Main_OnCommandEx(41743, 0, 0)
end

local function trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

local function getEffectNameParts(effectName)
  local type = '';
  local name = '';
  local developer = '';

  for t, n, d in string.gmatch(effectName, "(%w+):(.*)%((%w+)%)") do
    type = t;
    name = n;
    developer = d;
  end

  return trim(type), trim(name), trim(developer);
end

--******************************************************************************
--
-- Class for the function action elements
--
--******************************************************************************
local CreatePluginZone = {};

function CreatePluginZone:new(faderPortVersion)
  local obj = {
    nbTracks = faderPortVersion,
    fileLines = {},
    editPaneOpened = false,
    isBuild = false,

    isDragging = nil,

    trackId = nil,
    track = nil,
    pluginId = nil,

    pluginName = '',
    pluginType = '',
    pluginDeveloper = '',
    tracks = {},

    element = rtk.VBox {
      w = 1,
      spacing = 16,
    },
    splitBox = rtk.HBox {
      w = 1,
      spacing = 16,
    },
    left = rtk.VBox {
      w = .6,
      spacing = 8,
    },
    right = rtk.VBox {
      w = 1,
      spacing = 8,
    },

    topBar = rtk.HBox {
      w = 1,
      spacing = 16,
    },
    displayNameLabel = rtk.Text {
      text     = 'Display Name',
      halign   = rtk.Widget.LEFT,
      valign   = rtk.Widget.CENTER,
      fontsize = 20,
      tmargin  = 7
    },
    displayNameEntry = uiElements.createEntry(125),
    developerName = rtk.Text {
      text     = '',
      halign   = rtk.Widget.LEFT,
      valign   = rtk.Widget.CENTER,
      fontsize = 20,
      tmargin  = 7
    },
    hSpacer = rtk.Spacer { expand = 1, fillw = true, fillh = false },
    pageNumber = rtk.Text {
      text     = '',
      w        = 1,
      halign   = rtk.Widget.LEFT,
      valign   = rtk.Widget.CENTER,
      fontsize = 20,
      tmargin  = 7
    },
    paramListBox = rtk.VBox {
      w = 1,
      spacing = 8,
      padding = 8,
      border = uiElements.Colours.Border,
    },
    widgetListBox = rtk.VBox {
      w = 1,
      spacing = 8,
    }
  }
  setmetatable(obj, CreatePluginZone);
  self.__index = self;
  self.pluginParamsList = {};

  return obj;
end

--******************************************************************************
--
-- Generate the UI for this MixManagement and return it
--
--******************************************************************************
function CreatePluginZone:buildPluginEditor()
  self.topBar:add(self.displayNameLabel);
  self.topBar:add(self.displayNameEntry);
  self.topBar:add(self.developerName);
  self.topBar:add(self.hSpacer);
  self.topBar:add(self.pageNumber);
  self.element:add(self.topBar);

  self.element:add(self.splitBox);
  self.splitBox:add(self.left);
  self.splitBox:add(self.right);

  self.right:add(rtk.Viewport { child = self.paramListBox });
  self.left:add(rtk.Viewport { child = self.widgetListBox });

  self:CreateTracks();
  self:SetPluginValues();
end

function CreatePluginZone:getPluginEditor()
  if (not self.isBuild) then
    self.isBuild = true;
    self:buildPluginEditor();
  end
  return self.element;
end

--******************************************************************************
--
-- Read the data from the ActionFile corresponding to this MixManagement
--
--******************************************************************************
function CreatePluginZone:readActionFile()
  for line in io.lines(self.filterFilePath) do
    self.fileLines[#self.fileLines + 1] = line;

    -- local showSibling = string.match(line, '%s*showsiblings = (%w*),');
    -- if (showSibling) then
    --   self.showSiblings:attr('value', showSibling == 'true');
    -- end

    -- local showParents = string.match(line, '%s*showparents = (%w*),');
    -- if (showParents) then
    --   self.showParents:attr('value', showParents == 'true');
    -- end

    -- local showChildren = string.match(line, '%s*showchildren = (%w*),');
    -- if (showChildren) then
    --   self.showChildren:attr('value', showChildren == 'true');
    -- end

    -- local onlyTopLevel = string.match(line, '%s*matchonlytop = (%w*),');
    -- if (onlyTopLevel) then
    --   self.onlyTopLevel:attr('value', onlyTopLevel == 'true');
    -- end

    -- local matchMultiple = string.match(line, '%s*matchmultiple = (%w*),');
    -- if (matchMultiple) then
    --   self.matchMultiple:attr('value', matchMultiple == 'true');
    -- end

    -- local search = string.match(line, '%s*search = "(.*)",');
    -- if (search) then
    --   self:addSearchInputs(search);
    -- end
  end
end

--******************************************************************************
--
-- Write the data to the ActionFile corresponding to this MixManagement
--
--******************************************************************************
function CreatePluginZone:writeActionFile()
  local lines = {};
  for line in io.lines(self.filterFilePath) do
    lines[#lines + 1] = line;
  end

  local actionFile = assert(io.open(self.filterFilePath, "w"))
  for i = 1, #lines do
    local line = lines[i];

    -- if string.match(line, '%s*showsiblings = (%w*),') then
    --   local value = self.showSiblings.value and 'true' or 'false';
    --   line = '\tshowsiblings = ' .. value .. ',';
    -- end

    -- if string.match(line, '%s*showparents = (%w*),') then
    --   local value = self.showParents.value and 'true' or 'false';
    --   line = '\tshowparents = ' .. value .. ',';
    -- end

    -- if string.match(line, '%s*showchildren = (%w*),') then
    --   local value = self.showChildren.value and 'true' or 'false';
    --   line = '\tshowchildren = ' .. value .. ',';
    -- end

    -- if string.match(line, '%s*matchonlytop = (%w*),') then
    --   local value = self.onlyTopLevel.value and 'true' or 'false';
    --   line = '\tmatchonlytop = ' .. value .. ',';
    -- end

    -- if string.match(line, '%s*matchmultiple = (%w*),') then
    --   local value = self.matchMultiple.value and 'true' or 'false';
    --   line = '\tmatchmultiple = ' .. value .. ',';
    -- end

    -- if string.match(line, '%s*search = "(.*)",') then
    --   local value = '';
    --   for j = 1, #self.inputList.children do
    --     local widget, attrs = table.unpack(self.inputList.children[j])
    --     if (widget.value == '') then
    --       goto continue;
    --     end
    --     if (value ~= '') then
    --       value = value .. '|';
    --     end
    --     value = value .. widget.value;
    --     ::continue::
    --   end
    --   line = '\tsearch = "' .. value .. '",';
    -- end
    actionFile:write(line .. '\n');
  end
  actionFile:close();
end

--******************************************************************************
--
-- Read the colour and name from the mix management ZoneFile
--
--******************************************************************************
function CreatePluginZone:readZoneFile()
  for line in io.lines(self.zoneFilePath) do
    local displayText = string.match(line, '%s*ScribbleLine3_' .. self.filterId .. '%s*FixedTextDisplay "([%s%w]*)"');

    if (displayText) then
      self.displayText:attr('value', displayText)
    end

    local colour = string.match(line, '%s*Select' .. self.filterId .. '%s*FixedRGBColourDisplay%s*%{%s(.*)%s%}');
    if (colour) then
      self:setFilterColour(colour);
    end
  end
end

--******************************************************************************
--
-- Write the colour and name to the mix management ZoneFile
--
--******************************************************************************
function CreatePluginZone:writeZoneFile()
  local lines = {};
  for line in io.lines(self.zoneFilePath) do
    lines[#lines + 1] = line;
  end

  local zoneFile = assert(io.open(self.zoneFilePath, "w"))
  for i = 1, #lines do
    local line = lines[i];

    if (string.match(line, '%s*ScribbleLine3_' .. self.filterId .. '%s*FixedTextDisplay "([%s%w]*)"')) then
      local value = self.displayText.value;
      line = '  ScribbleLine3_' .. self.filterId .. '     FixedTextDisplay "' .. value .. '" {% Invert %}';
    end

    if (string.match(line, '%s*Select' .. self.filterId .. '%s*FixedRGBColourDisplay%s{%s(.*)%s%}')) then
      local value = self.colourPicker.getCSIValue();
      line = '  Select' .. self.filterId .. '             FixedRGBColourDisplay { ' .. value .. ' }';
    end
    zoneFile:write(line .. '\n');
  end
  zoneFile:close();
end

function CreatePluginZone:setFilterColour(clr)
  local colour = {};
  local index = 1;

  for rgbValue in string.gmatch(clr, '%S+') do
    if (index < 4) then
      colour[index] = rgbValue;
      index = index + 1;
    end
  end

  self.colourPicker.setValue(colour[1], colour[2], colour[3]);
end

function CreatePluginZone:writeChangesToFile()
  self:writeActionFile();
  self:writeZoneFile();
  self:readActionFile();
  self:readZoneFile();
  uiElements.showSavePopup(resetSurfaces);
end

function CreatePluginZone:reloadFiles()
  self:readActionFile();
  self:readZoneFile();
end

function CreatePluginZone:SetPluginValues()
  self.displayNameEntry:attr('value', self.pluginName);
  if (self.pluginDeveloper and self.pluginType) then
    self.developerName:attr('text', self.pluginDeveloper .. ' :: ' .. self.pluginType);
  end
end

function CreatePluginZone:getParamsList()
  return self.pluginParamsList;
end

function CreatePluginZone:CreateTracks()
  for i = 1, self.nbTracks do
    local container = rtk.HBox { border = uiElements.Colours.Border, h = 50 }
    local trackIndex = rtk.Text {
      text = i,
      h = 1,
      w = 25,
      rborder = uiElements.Colours.Border,
      halign = 'center',
      valign = 'center'
    };
    local widgets = rtk.VBox { w = 1 }

    local select = widgets:add(rtk.HBox { h = .5, w = 1, lpadding = 8, bborder = uiElements.Colours.Border,
      bg = '#ffffff00' })
    select:add(rtk.Text { text = 'Select', h = 1, valign = 'center', w = 60 });
    local dropSelect = select:add(rtk.Text { text = '', h = 1, valign = 'center', minw = 60 });

    local slider = widgets:add(rtk.HBox { h = 1, w = 1, lpadding = 8,
      bg = '#ffffff00' })
    slider:add(rtk.Text { text = 'Slider', h = 1, valign = 'center', w = 60 });
    local dropSlider = slider:add(rtk.Text { text = '', h = 1, valign = 'center', minw = 60 });

    container:add(trackIndex);
    container:add(widgets)
    self.widgetListBox:add(container);

    select.ondropfocus = self:OnParamDropFocus(select);
    select.ondropblur = self:OnParamDropBlur(select);

    select.ondrop = function(_, _, source, data)
      dropSelect:attr('text', self.pluginParamsList[self.isDragging .. ''].name)
    end;

    slider.ondropfocus = self:OnParamDropFocus(slider);
    slider.ondropblur = self:OnParamDropBlur(slider);

    slider.ondrop = function(this, _, source, data)
      -- this.children[1]:attr('text', self.pluginParamsList[self.isDragging .. ''].name)
      source:animate { 'alpha', dst = 0.5, duration = 1 };
    end;
  end
end

function CreatePluginZone:OnParamDropFocus(widget)
  return function()
    widget:animate { 'bg', dst = '#ffffff55', duration = 0.2 };
    return true;
  end
end

function CreatePluginZone:OnParamDropBlur(widget)
  return function()
    widget:animate { 'bg', dst = '#ffffff00', duration = 0.2 };
  end
end

function CreatePluginZone:OnDrop(event, source, e, textWidget)
end

function CreatePluginZone:GetPluginParams()
  local nbParams = reaper.TrackFX_GetNumParams(self.track, self.pluginId);
  for i = 0, math.min(nbParams, 100), 1 do
    local x, name = reaper.TrackFX_GetParamName(self.track, self.pluginId, i);
    local hasSteps, step, smallstep, largestep, istoggle = reaper.TrackFX_GetParameterStepSizes(
      self.track,
      self.pluginId,
      i
    )
    if (utils.isString(name)) then
      local nbSteps = hasSteps and utils.round(1 / step) + 1 or 0;
      self.pluginParamsList[i .. ''] = {
        paramId = i,
        name = name,
        stepSize = step,
        nbSteps = nbSteps,
        istoggle = istoggle,
      }

      local listName = name;
      if (istoggle) then
        listName = listName .. '  (toggle)';
      end

      if (nbSteps > 2) then
        listName = listName .. '  (' .. nbSteps .. 'steps)';
      end

      local param = rtk.Text {
        text    = listName,
        padding = 4,
        border  = uiElements.Colours.Border,
        w       = 1,
        bg      = uiElements.Colours.BackGround,
        cursor  = rtk.mouse.cursors.MOVE
      }
      self.paramListBox:add(param);

      param.onmouseenter = function()
        param:attr('border', '1px #ffffff')
        return true
      end

      param.onmouseleave = function()
        param:attr('border', uiElements.Colours.Border)
        return true
      end

      param.ondragstart = function()
        return self.pluginParamsList[i .. ''], true;
      end

      param.ondragmousemove = function()
        param:attr('cursor', rtk.mouse.cursors.REAPER_DRAGDROP_COPY);
      end

      param.ondragend = function()
        param:attr('cursor', rtk.mouse.cursors.MOVE);
      end

    end
  end
end

function CreatePluginZone:loadPlugin()
  local hasFocussedFX, trackId, x, pluginId = reaper.GetFocusedFX2();
  if (hasFocussedFX == 0) then
    return false;
  end
  local track = reaper.GetTrack(0, trackId - 1);

  self.trackId = trackId;
  self.pluginId = pluginId;
  self.track = track;

  local hasFXName, fxName = reaper.TrackFX_GetFXName(track, pluginId);
  local type, name, dev = getEffectNameParts(fxName);

  if (utils.isString(name)) then
    self.pluginName = name;
    self.pluginType = type;
    self.pluginDeveloper = dev;
    self:SetPluginValues();
    self.pluginParamsList = self:GetPluginParams();
  end

  return utils.isString(name);
end

return CreatePluginZone;
