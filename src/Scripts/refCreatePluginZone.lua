local function createPath(path)
  return path:gsub('/', package.config:sub(1, 1));
end

-- replace ' ' with '\ '

package.path = reaper.GetResourcePath() .. createPath('/Scripts/ReaSonus/?.lua')
-- Load the packages
local rtk = require('rtk')
local utils = require('utils')
local uiElements = require('refUiElements')
local zoneUtils = require('refCreatePluginZoneUtils')

-- local log = rtk.log
-- log.level = log.WARNING


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
      h = 0.875,
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
      tmargin  = 7,
    },
    displayNameEntry = uiElements.createEntry(125),
    developerName = rtk.Text {
      text     = '',
      halign   = rtk.Widget.LEFT,
      valign   = rtk.Widget.CENTER,
      fontsize = 20,
      tmargin  = 7,
    },
    hSpacer = rtk.Spacer { expand = 1, fillw = true, fillh = false },
    pageNumber = rtk.Text {
      text     = '',
      w        = 1,
      halign   = rtk.Widget.LEFT,
      valign   = rtk.Widget.CENTER,
      fontsize = 20,
      tmargin  = 7,
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
    removeParamButton = rtk.Button {
      icon    = uiElements.Icons.close,
      iconpos = rtk.Widget.CENTER,
      w       = 28,
      h       = 28,
      flat    = rtk.Button.FLAT,
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

  -- self.displayNameEntry.onchange = self.setPluginName;

  self:createTracks();
  self:setPluginValues();
  self:loadPlugin();
end

function CreatePluginZone:setPluginName(name)
  if (self.pluginName ~= name) then
    self.pluginName = name;
  end
end

function CreatePluginZone:getZoneEditor()
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
    if (self.currentPage > 1) then
      self.currentPage = self.currentPage - 1;
      self:updatePageNumber();
    end
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
    self.currentPage = self.currentPage + 1;
    self:updatePageNumber();
  end
end

-- ---Read the colour and name from the mix management ZoneFile
-- ---@param fileName string
-- function CreatePluginZone:readZoneFile(fileName)
--   for line in io.lines(fileName) do
--     local displayText = string.match(line, '%s*ScribbleLine3_' .. self.filterId .. '%s*FixedTextDisplay "([%s%w]*)"');

--     if (displayText) then
--       self.displayText:attr('value', displayText)
--     end
--   end
-- end

local function sanitizeString(str)
  str = string.gsub(str, '%s', '_');
  str = string.gsub(str, '%,', '');

  return str;
end

---Get the filePath and filename by zoneNumber. If the folder not already exists, it will be created
---@param zoneNumber string
---@return string
---@return string
function CreatePluginZone:createFileInfo(zoneNumber)
  local filePath = self.zoneFolder .. '/' .. sanitizeString(self.pluginDeveloper);
  os.execute('mkdir -p "' .. filePath .. '"')

  local fileName = string.format(
    '/%s%s.%s.zon',
    sanitizeString(self.pluginName),
    zoneNumber,
    string.lower(self.pluginType)
  );

  return filePath, fileName;
end

---remove the empty pages and create zone file per page
function CreatePluginZone:generateZoneFiles()
  local pages = utils.filterTable(self.pages, function(value)
    return utils.tableCount(value) > 0;
  end)

  for key, page in ipairs(pages) do
    self:writeZoneFile(key, page, #pages);
  end
end

function CreatePluginZone:loadZoneFiles()
  local filePath, fileName = self:createFileInfo('');
  local nbFiles = 1;
  local isSubZone = false;
  local file = io.open(filePath .. fileName, 'a')

  if (file == nil) then
    return;
  end
  file:close();

  for line in io.lines(filePath .. fileName) do
    if (isSubZone and string.find(line, 'SubZonesEnd')) then
      isSubZone = false
      break;
    end
    if (isSubZone) then
      nbFiles = nbFiles + 1;
    end
    if (not isSubZone and string.find(line, 'SubZones')) then
      isSubZone = true;
    end
  end

  -- self:processZoneFile('', filePath .. fileName);
  for i = 1, nbFiles, 1 do
    local path, name = self:createFileInfo(zoneUtils.zoneNumber(i));
    self:processZoneFile(i, path .. name);
  end
  self:updatePageNumber();
end

---Extract all the plugin data from teh zonefile
---@param pageId number
---@param fileName string
function CreatePluginZone:processZoneFile(pageId, fileName)
  self.pages[pageId] = {};

  for line in io.lines(fileName) do
    -- Get the plugin name
    local pluginName = string.match(line, 'Zone%s".*"%s"(.*)"');
    if (pluginName) then
      self.pages[pageId].name = pluginName;
    end

    -- Get the param values for a select button
    local selectTrack, selectParamId, steps, colour = string.match(
      line,
      'Select(%d%d?)%s+FXParam%s+(%d%d?%d?)' --%s+(%[ [%s%.%d]+ %])%s+({[%d%s]+})'
    );
    if (selectTrack) then
      self.pages[pageId]['select' .. selectTrack] = {
        paramId = selectParamId,
        paramData = self.pluginParamsList[selectParamId],
      }
    end

    -- Get the param values for a fader
    local faderTrack, faderParamId = string.match(
      line,
      'Fader(%d%d?)%s+FXParam%s+(%d%d?%d?)'
    );
    if (faderTrack) then
      self.pages[pageId]['fader' .. faderTrack] = {
        paramId = faderParamId,
        paramData = self.pluginParamsList[faderParamId],
      }
    end

    -- Get the param name af the select button or fader
    local descrId, descrTrack, description = string.match(
      line,
      'ScribbleLine([%d])_([%d]+)%s+FixedTextDisplay%s+"(.*)"'
    );
    if (descrId) then
      local type = descrId == '1' and 'select' or 'fader';
      self.pages[pageId][type .. descrTrack]['paramName'] = description;
    end
  end
end

function CreatePluginZone:writeZoneFile(pageId, page, nbPages)
  local filePath, fileName = self:createFileInfo(zoneUtils.zoneNumber(pageId));
  local zoneFile = io.open(createPath(filePath .. fileName), 'w+')

  local zoneContent = string.format(
    'Zone "%s%s" "%s"\n  SelectedTrackNavigator\n',
    self.pluginRawName,
    zoneUtils.zoneNumber(pageId),
    self.pluginName
  );

  if (nbPages > 1) then
    zoneContent = zoneContent .. zoneUtils.createSubZonesPart(pageId, nbPages, self.pluginRawName);
  end

  for trackId = 1, self.nbTracks do
    local select = page['select' .. trackId];
    local fader = page['fader' .. trackId];

    zoneContent = zoneContent .. '\n' .. zoneUtils.createSelectPart(trackId, select);
    zoneContent = zoneContent .. '\n' .. zoneUtils.createFaderPart(trackId, fader);
  end

  zoneContent = zoneContent .. 'ZoneEnd';

  ---@diagnostic disable-next-line: need-check-nil
  zoneFile:write(zoneContent);
  ---@diagnostic disable-next-line: need-check-nil
  zoneFile:close();
end

function CreatePluginZone:saveZoneFiles()
  self:generateZoneFiles();
  uiElements.showSavePopup(utils.resetSurfaces);
end

function CreatePluginZone:setPluginValues()
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
        ((data.paramId ~= nil) and
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

function CreatePluginZone:setParamListBoxAlpha()
  for i, child in pairs(self.paramListBox.children) do
    self.paramListBox.children[i][1]:animate { 'alpha', dst = 1, duration = 0.3 }
  end

  for k, page in pairs(self.pages) do
    for y, x in pairs(page) do
      if (x.paramId ~= nil) then
        self.paramListBox.children[x.paramId + 1][1]:animate { 'alpha', dst = 0.5, duration = 0.3 }
      end
    end
  end
end

function CreatePluginZone:createTracks()
  self.widgetListBox:remove_all();
  self:setParamListBoxAlpha();

  for i = 1, self.nbTracks do
    local channelWidget = uiElements.channelWidgets(i);
    local select = self.pages[self.currentPage] and self.pages[self.currentPage]['select' .. i];
    local fader = self.pages[self.currentPage] and self.pages[self.currentPage]['fader' .. i];

    if (select ~= nil) then
      channelWidget.setSelectName(select.paramData.name)
    end

    if (fader ~= nil) then
      channelWidget.setFaderName(fader.paramData.name or '')
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
        if (data ~= nil) then
          uiElements.showPopup(data.paramData.name, rtk.Text { 'Text' });
        end
      end
    )

    channelWidget.setOnSelectLongPress(
      function()
        local data = self.pages[self.currentPage]['select' .. i];
        if (data ~= nil) then
          self.pages[self.currentPage]['select' .. i] = nil;
          self:createTracks();
        end
      end
    )

    channelWidget.setOnFaderDrop(
      function(_, _, source, data)
        channelWidget.setFaderName(data.name);
        source:animate { 'alpha', dst = 0.5, duration = 0.3 };
        self:addParamToPage('fader' .. i, data)
      end
    )

    channelWidget.setOnFaderClick(
      function()
        local data = self.pages[self.currentPage]['fader' .. i];
        if (data ~= nil) then
          uiElements.showPopup(data.paramData.name, rtk.Text { 'Text' });
        end
      end
    )

    channelWidget.setOnFaderLongPress(
      function()
        local data = self.pages[self.currentPage]['fader' .. i];
        if (data ~= nil) then
          self.pages[self.currentPage]['fader' .. i] = nil;
          self:createTracks();
        end
      end
    )
  end
end

local unWantedNames = {
  'midi cc',  -- Decomposer, Arturia
  'reserved', -- Decomposer, Valhalla
  -- Blue Cat
  'midi program change',
  'midi controller',
  -- Arturia
  'unassigned',
  'vst_programchange_',
  'mpe_',
  -- Spitfire
  'general purpose',
  -- global
  'undefined'
}

---Check if the param name is not in the list of unwanted names
---@param name string The param name
local function isWantedParam(name)
  local result = true;

  for i = 1, #unWantedNames do
    local startIndex = string.find(string.lower(name), unWantedNames[i]);
    if (startIndex ~= nil) then
      result = false;
    end
  end

  return result
end

---Get the list of parameters of the selected plugin. Store the data and create
---the add the parameters to the params list
function CreatePluginZone:getPluginParams()
  local nbParams = reaper.TrackFX_GetNumParams(self.track, self.pluginId);
  self.paramListBox:remove_all();
  for i = 0, math.min(nbParams, 500), 1 do
    local _, name = reaper.TrackFX_GetParamName(self.track, self.pluginId, i);
    local hasSteps, step, _, _, istoggle = reaper.TrackFX_GetParameterStepSizes(
      self.track,
      self.pluginId,
      i
    )
    if (utils.isString(name) and isWantedParam(name)) then
      local nbSteps = hasSteps and utils.round(1 / step) + 1 or 0;
      local paramValues = {
        paramId = i,
        name = name,
        stepSize = step,
        nbSteps = nbSteps,
        istoggle = istoggle,
      }
      self.pluginParamsList[tostring(i)] = paramValues;

      local listName = zoneUtils.createParamName(paramValues);
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
  local retval, trackId, paramnumber, pluginId = reaper.GetFocusedFX2(0);
  if (retval == 0) then
    return false;
  end

  local track = reaper.GetTrack(0, trackId - 1);
  local _, fxName = reaper.TrackFX_GetFXName(track, pluginId);
  local type, name, dev = zoneUtils.getEffectNameParts(fxName);

  self.trackId = trackId;
  self.pluginId = pluginId;
  self.pluginRawName = fxName;
  self.track = track;

  if (utils.isString(name)) then
    self:setPluginName(name)
    self.pluginType = type;
    self.pluginDeveloper = dev;
    self:setPluginValues();
    self.pluginParamsList = self:getPluginParams();
    self:loadZoneFiles();
  end

  return utils.isString(name);
end

return CreatePluginZone;
