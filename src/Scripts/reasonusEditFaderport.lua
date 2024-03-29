-- Set package path to find the packages to import
local function createPath(path)
  return path:gsub("/", package.config:sub(1, 1));
end

package.path = reaper.GetResourcePath() .. createPath('/Scripts/ReaSonus/?.lua');
-- Load the packages
local rtk = require('rtk');
local uiElements = require('refUiElements');
local pages = require('refPages')

-- Set the state to 'on'.
local isNewValue, file, sec, cmd = reaper.get_action_context()
local state = reaper.GetToggleCommandStateEx(sec, cmd);
reaper.SetToggleCommandState(sec, cmd, 1)
reaper.RefreshToolbar2(sec, cmd);

rtk.long_press_delay = 1
-- rtk.debug = true

--******************************************************************************
--
-- Read the CSI.ini file to get the type of FaderPort
-- This is using the first faderport it catches in the ini file
--
--******************************************************************************
local csiIni = assert(io.open(reaper.GetResourcePath() .. '/CSI/CSI.ini', 'r'));
local faderPortVersion = string.match(csiIni:read('*all'), 'FP(%d+).mst');
csiIni:close()

-- Set the module-local log variable for more convenient logging.
local log = rtk.log
log.clear()

local Colours = uiElements.Colours;

-- UI variables
local contentHeight = 0
local contentWidth = 0

-- Both the FaderPort 8 and 16 have 8 function keys. Only the FaderPort 2 has 4
local nbFunctionKeys = 8
local nbMixManagementFilters = 8

if (faderPortVersion == '2') then
  nbFunctionKeys = 4
end
if (faderPortVersion == '16') then
  nbMixManagementFilters = 16
end

--******************************************************************************
--
-- Let's start creating the UI
--
--******************************************************************************
rtk.set_theme_overrides { button = '#ffffff1f' }

local window = rtk.Window {
  w         = 800,
  h         = 500,
  maxw      = 1200,
  maxh      = 800,
  minw      = 800,
  minh      = 400,
  resizable = false,
  bg        = Colours.Primary,
  title     = 'ReaSonus FaderPort Control'
}

window.onclose = function()
  rtk.quit();
end

rtk.onerror = function()
  reaper.SetToggleCommandState(sec, cmd, 0)
  reaper.RefreshToolbar2(sec, cmd);
  rtk.quit();
end

reaper.atexit(function()
  -- Set the state to 'off' on closing the window.
  reaper.SetToggleCommandState(sec, cmd, 0)
  reaper.RefreshToolbar2(sec, cmd);
end)

--******************************************************************************
--
-- Define all the main areas of the UI
--
--******************************************************************************
local mainBox = window:add(rtk.HBox {
  vpadding = 10,
  w        = 1
})
local sidebar = mainBox:add(rtk.VBox {
  h       = 1,
  w       = 230,
  padding = 10,
  spacing = 8,
})
local content = mainBox:add(rtk.Container {
  h        = 1,
  w        = 1,
  margin   = 10,
  padding  = 5,
  bg       = Colours.BackGround,
  minw     = 400,
  vspacing = 8,
  hspacing = 8,
})

--******************************************************************************
--
-- Create the app and add the different screen
--
--******************************************************************************
local app = content:add(rtk.Application())
app.statusbar:hide()

app:add_screen {
  name = 'home',
  init = function(_, screen)
    screen.widget = pages.createHomePage(faderPortVersion)
  end,
}

app:add_screen {
  name = 'functions',
  init = function(_, screen)
    screen.widget = pages.functionsPage.create(nbFunctionKeys)
  end,
  -- update = function()
  --   ReadFunctionsFile()
  -- end
}

if (faderPortVersion ~= '2') then
  app:add_screen {
    name = 'mix-management',
    init = function(_, screen)
      screen.widget = pages.mixManagementPage.create(nbMixManagementFilters)
    end,
  }

  app:add_screen {
    name = 'create-plgin-zone',
    init = function(_, screen)
      screen.widget = pages.createPluginZoneFile.create(nbMixManagementFilters, window)
    end,
  }
end

app:add_screen {
  name = 'about',
  init = function(_, screen)
    screen.widget = pages.createAboutPage()
  end,
}

--******************************************************************************
--
-- On resize of the content area, the positions and sizes of the function area's
--   nned to be recalculated
--
--******************************************************************************
local function reflowFunctions(width)
  if not width then return end
  local columns = 4;
  if (width < 910) then columns = 3 end
  if (width < 610) then columns = 2 end
  if (width < 310) then columns = 1 end

  pages.functionsPage.setWidth((width - 30 - (columns - 1) * 8) / columns);
end

--******************************************************************************
--
-- Chack if the content area has been resized. If so trigger the realignment
--   of the funtion areas
--
--******************************************************************************
local function checkContentSize()
  local width = content:calc('w') / gfx.ext_retina
  local height = content:calc('h') / gfx.ext_retina

  if (contentWidth == width and contentHeight == height) then
    return
  else
    contentWidth = width
    contentHeight = height
    reflowFunctions(width)
  end
end

--******************************************************************************
--
-- Check the height of the window and set the max or min if these get exceded
--
--******************************************************************************
local function checkWindowSize()
  local width = window:calc('w') / gfx.ext_retina
  local height = window:calc('h') / gfx.ext_retina
  local maxWidth = window.maxw
  local maxHeight = window.maxh
  local minWidth = window.minw
  local minHeight = window.minh

  if (width >= maxWidth) then window:attr('w', maxWidth) end
  if (height >= maxHeight) then window:attr('h', maxHeight) end
  if (width <= minWidth) then window:attr('w', minWidth) end
  if (height <= minHeight) then window:attr('h', minHeight) end
end

window.onresize = function()
  checkWindowSize()
  checkContentSize()
end

local function main()
  window:open({
    align = 'center'
  });
  uiElements.createNavigationSideBar(sidebar, app, faderPortVersion);
  checkContentSize();
end

main()
