local function createPath(path)
  return path:gsub("/", package.config:sub(1, 1));
end

package.path = reaper.GetResourcePath() .. createPath('/Scripts/ReaSonus/?.lua')
-- Load the packages
local rtk = require('rtk')
local utils = require('utils')
local uiElements = require('refUiElements')

-- local log = rtk.log
-- log.level = log.WARNING

local function getEffectNameParts(effectName)
  local type = '';
  local name = '';
  local developer = '';

  for t, n, d in string.gmatch(effectName, "(%w+):(.*)%((%w+)%)") do
    type = t;
    name = n;
    developer = d;
  end

  return utils.trim(type), utils.trim(name), utils.trim(developer);
end

local function createParamName(data)
  local paramName = data.name;
  if (data.istoggle or data.nbSteps == 2) then
    paramName = paramName .. '  (toggle)';
  end

  if (data.nbSteps > 2) then
    paramName = paramName .. string.format('  (%ssteps)', data.nbSteps);
  end
  return paramName;
end

local selectColors = {
  white = '{ 20 20 20 255 255 255 }',
  yellow = '{ 20 20 0 20 20 0 }',
}

local selectText = [[
  Select{{id}}             FXParam {{paramId}} {{steps}} {{color}}
  ScribbleLine1_{{id}}     FXParamNameDisplay {{paramId}} "{{paramName}}"
  ScribbleLine2_{{id}}     FXParamValueDisplay {{paramId}}
]]

local selectNoActionText = [[
  Select{{id}}             NoAction
  ScribbleLine1_{{id}}     NoAction
  ScribbleLine2_{{id}}     NoAction
]]

local sliderText = [[
  Fader{{id}}              FXParam {{paramId}}
  ScribbleLine3_{{id}}     FXParamNameDisplay {{paramId}} "{{paramName}}"
  ScribbleLine4_{{id}}     FXParamValueDisplay {{paramId}}
  ValueBar{{id}}           FXParam {{paramId}} {% {{valueBarId}} %}
]]

local sliderNoActionText = [[
  Fader{{id}}              NoAction
  ScribbleLine3_{{id}}     NoAction
  ScribbleLine4_{{id}}     NoAction
  ValueBar{{id}}           NoAction
]]

--******************************************************************************
--
-- Class for the function action elements
--
--******************************************************************************
local CreatePluginZone = {};

function CreatePluginZone:new(faderPortVersion, window)
  local obj = {
    nbTracks = faderPortVersion,
    fileLines = {},
    editPaneOpened = false,
    isBuild = false,
    zoneFolder = reaper.GetResourcePath() .. createPath('/CSI/Zones/ReasonusFaderPort/_ReaSonusEffects'),

    isDragging = nil,

    trackId = nil,
    track = nil,
    pluginId = nil,
    pluginRawName = '',

    pluginName = '',
    pluginType = '',
    pluginDeveloper = '',
    tracks = {},

    -- Configuration
    pages = { {} },
    currentPage = 1,

    element = rtk.VBox {
      w = 1,
      spacing = 16,
    },
    splitBox = rtk.HBox {
      w = 1,
      spacing = 16,
      h = 350,
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
    },
    pageButtonBar = rtk.HBox {
      w = 1,
      spacing = 8,
    },
    previousPageButton = uiElements.createButton('<'),
    addPageButton = uiElements.createButton('Add Page', uiElements.Icons.add),
    nextPageButton = uiElements.createButton('>'),
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

  self.pageButtonBar:add(self.previousPageButton);
  self.pageButtonBar:add(self.addPageButton);
  self.pageButtonBar:add(self.nextPageButton);

  self.right:add(rtk.Viewport { child = self.paramListBox });
  self.right:add(self.pageButtonBar);
  self.left:add(rtk.Viewport { child = self.widgetListBox });

  self.previousPageButton.onclick = self:goToPreviousPage();
  self.addPageButton.onclick = self:addPage()
  self.nextPageButton.onclick = self:goToNextPage();

  self:createTracks();
  self:SetPluginValues();
end

function CreatePluginZone:resizeColumns(box)
  local height = box[4];
  reaper.ShowConsoleMsg(height .. '\n')
  self.left:attr('h', height - 940 + 300);
end

function CreatePluginZone:getPluginEditor()
  if (not self.isBuild) then
    self.isBuild = true;
    self:buildPluginEditor();
  end
  return self.element;
end

function CreatePluginZone:updatePageNumber()
  self.pageNumber:attr('text', self.currentPage .. '/' .. #self.pages)
  self:createTracks();
end

function CreatePluginZone:goToPreviousPage()
  return function()
    self:generateZoneFiles();
    -- if (self.currentPage > 1) then
    --   self.currentPage = self.currentPage - 1;
    --   self:updatePageNumber();
    -- end
  end
end

function CreatePluginZone:goToNextPage()
  return function()
    if (self.currentPage < #self.pages) then
      self.currentPage = self.currentPage + 1;
      self:updatePageNumber();
    end
  end
end

function CreatePluginZone:addPage()
  return function()
    self.pages[#self.pages + 1] = {};
    self:updatePageNumber();
  end
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

function CreatePluginZone:createFileInfo(zoneNumber)
  local filePath = self.zoneFolder .. '/' .. self.pluginDeveloper;
  os.execute("mkdir -p " .. filePath)

  local fileName = string.format(
    '/%s%s.%s.zon',
    self.pluginName,
    zoneNumber,
    string.lower(self.pluginType)
  );

  return filePath, fileName;
end

function CreatePluginZone:generateZoneFiles()
  local pages = utils.filterTable(self.pages, function(value)
    return utils.tableCount(value) > 0;
  end)

  for key, page in ipairs(pages) do
    self:writeZoneFile(key, page, #pages);
  end
end

function CreatePluginZone:getSteps(nbSteps)
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

--******************************************************************************
--
-- Write the colour and name to the mix management ZoneFile
--
--******************************************************************************
function CreatePluginZone:writeZoneFile(pageId, page, nbPages)
  local zoneNumber = function(id)
    return (id == 1) and '' or ('-' .. id);
  end
  local nextZoneNumber = function()
    if (pageId + 1 > nbPages) then
      return '';
    end
    return '-' .. (pageId + 1)
  end
  local prevZoneNumber = function()
    if ((nbPages == 2 and pageId == 2) or pageId - 1 == 1) then
      return '';
    end
    if (pageId - 1 < 1) then
      return '-' .. nbPages;
    end
    return '-' .. (pageId - 1)
  end
  local filePath, fileName = self:createFileInfo(zoneNumber(pageId));
  local zoneFile = io.open(createPath(filePath .. fileName), 'w+')

  local zoneContent = string.format(
    'Zone "%s%s" "%s"\n  SelectedTrackNavigator\n',
    self.pluginRawName,
    zoneNumber(pageId),
    self.pluginName
  );

  if (nbPages > 1) then
    zoneContent = zoneContent .. '  SubZones\n';
    for i = 1, nbPages, 1 do
      if (i ~= pageId) then
        zoneContent = zoneContent .. string.format('    "%s%s"\n', self.pluginRawName, zoneNumber(i));
      end
    end
    zoneContent = zoneContent .. '  SubZonesEnd\n\n';

    zoneContent = zoneContent .. string.format('  Prev   GoSubZone "%s%s"\n', self.pluginRawName, prevZoneNumber());
    zoneContent = zoneContent .. string.format('  Next   GoSubZone "%s%s"\n', self.pluginRawName, nextZoneNumber());
  end

  for trackId = 1, self.nbTracks do
    local select = page['select' .. trackId];
    local slider = page['slider' .. trackId];
    local selectString = '';
    local sliderString = '';

    if (select == nil or select.paramId == nil) then
      selectString = string.gsub(selectNoActionText, '{{id}}', trackId);
    elseif (select ~= nil) then
      selectString = string.gsub(selectText, '{{id}}', trackId);
      selectString = string.gsub(selectString, '{{paramId}}', select.paramId);
      selectString = string.gsub(selectString, '{{paramName}}', select.paramName or select.paramData.name);
      selectString = string.gsub(selectString, '{{steps}}', self:getSteps(select.paramData.nbSteps));
      selectString = string.gsub(selectString, '{{color}}',
        select.paramIsToggle == true and selectColors.white or selectColors.yellow);
    end
    zoneContent = zoneContent .. '\n' .. selectString;

    if (slider == nil or slider.paramId == nil) then
      sliderString = string.gsub(sliderNoActionText, '{{id}}', trackId);
    elseif (slider ~= nil) then
      sliderString = string.gsub(sliderText, '{{id}}', trackId);
      sliderString = string.gsub(sliderString, '{{paramId}}', slider.paramId);
      sliderString = string.gsub(sliderString, '{{paramName}}', slider.paramName or slider.paramData.name);
      sliderString = string.gsub(sliderString, '{{valueBarId}}', 'blaa');
    end
    zoneContent = zoneContent .. '\n' .. sliderString;
  end
  zoneContent = zoneContent .. 'ZoneEnd';

  reaper.ShowConsoleMsg(zoneContent);

  ---@diagnostic disable-next-line: need-check-nil
  zoneFile:write(zoneContent);
  ---@diagnostic disable-next-line: need-check-nil
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
  uiElements.showSavePopup(utils.resetSurfaces);
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

function CreatePluginZone:addParamToPage(widget, paramData)
  self.pages[self.currentPage] = self.pages[self.currentPage] or {};
  self.pages[self.currentPage][widget] = self.pages[self.currentPage][widget] or {};
  local data = self.pages[self.currentPage][widget] or {};

  if (
      not ((data.paramId == nil) or
          (data.paramId == paramData.paramId))
      ) then
    local paramItem = self.paramListBox.children[data.paramId + 1];
    paramItem[1]:animate { 'alpha', dst = 1, duration = 0.3 };
    data.v = data.paramName or paramData.name;
  end

  data.paramId = paramData.paramId;
  data.paramData = paramData;
  self.pages[self.currentPage][widget] = data;
end

function CreatePluginZone:createTracks()
  self.widgetListBox:remove_all();
  for i = 1, self.nbTracks do
    local channelWidget = uiElements.channelWidgets(i);
    local select = self.pages[self.currentPage] and self.pages[self.currentPage]['select' .. i];
    local slider = self.pages[self.currentPage] and self.pages[self.currentPage]['slider' .. i];

    if (select ~= nil) then
      channelWidget.setSelectName(select.paramData.name)
    end

    if (slider ~= nil) then
      channelWidget.setSliderName(slider.paramData.name or '')
    end

    self.widgetListBox:add(channelWidget.element);

    channelWidget.setOnSelectDrop(
      function(_, _, source, data)
        channelWidget.setSelectName(data.name);
        source:animate { 'alpha', dst = 0.5, duration = 0.3 };
        self:addParamToPage('select' .. i, data)
      end
    );

    channelWidget.setOnSelectClick(
      function()
        local data = self.pages[self.currentPage]['select' .. i];
        uiElements.showPopup(data.paramData.name, rtk.Text { 'Text' });
      end
    )

    channelWidget.setOnSliderDrop(
      function(_, _, source, data)
        channelWidget.setSliderName(data.name);
        source:animate { 'alpha', dst = 0.5, duration = 0.3 };
        self:addParamToPage('slider' .. i, data)
      end
    )

    channelWidget.setOnSliderClick(
      function()
        local data = self.pages[self.currentPage]['select' .. i];
        uiElements.showPopup(data.paramData.name, rtk.Text { 'Text' });
      end
    )
  end
end

function CreatePluginZone:OnDrop(event, source, e, textWidget)
end

function CreatePluginZone:GetPluginParams()
  local nbParams = reaper.TrackFX_GetNumParams(self.track, self.pluginId);

  for i = 0, math.min(nbParams, 100), 1 do
    local _, name = reaper.TrackFX_GetParamName(self.track, self.pluginId, i);
    local hasSteps, step, _, _, istoggle = reaper.TrackFX_GetParameterStepSizes(
      self.track,
      self.pluginId,
      i
    )
    if (utils.isString(name)) then
      local nbSteps = hasSteps and utils.round(1 / step) + 1 or 0;
      local paramValues = {
        paramId = i,
        name = name,
        stepSize = step,
        nbSteps = nbSteps,
        istoggle = istoggle,
      }
      self.pluginParamsList[tostring(i)] = paramValues;

      local listName = createParamName(paramValues);
      local param = uiElements.pluginParam(listName);
      self.paramListBox:add(param.element);

      param.setOnDragStart(
        function()
          return paramValues, true;
        end
      )
    end
  end
end

function CreatePluginZone:loadPlugin()
  local hasFocussedFX, trackId, x, pluginId = reaper.GetFocusedFX2();
  if (hasFocussedFX == 0) then
    return false;
  end
  local track = reaper.GetTrack(0, trackId - 1);

  local _, fxName = reaper.TrackFX_GetFXName(track, pluginId);
  local type, name, dev = getEffectNameParts(fxName);

  self.trackId = trackId;
  self.pluginId = pluginId;
  self.pluginRawName = fxName;
  self.track = track;

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
