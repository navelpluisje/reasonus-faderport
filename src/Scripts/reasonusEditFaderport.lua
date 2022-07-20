-- Set package path to find the packages to import
package.path = reaper.GetResourcePath() .. '/Scripts/ReaSonus/?.lua';
-- Load the packages
local rtk = require('rtk');
local uiElements = require('refUiElements');
local pages = require('refPages')

--******************************************************************************
--
-- Read the CSI.ini file to get the type of FaderPort
-- This is using the first faderport it catches in the ini file
--
--******************************************************************************
local csiIni = assert(io.open(reaper.GetResourcePath() .. '/CSI/CSI.ini', 'r'))
local faderPortVersion = string.match(csiIni:read('*all'), 'FP(%d+).mst');
csiIni:close()

-- Set the module-local log variable for more convenient logging.
local log = rtk.log
log.clear()

local Colors = uiElements.Colors;

-- UI variables
local contentHeight = 0
local contentWidth = 0

-- Both the FaderPort 8 and 16 have 8 function keys. Only the FaderPort 2 has 4
local nbFunctionKeys = 8

if (faderPortVersion == '2') then
  nbFunctionKeys = 4
end

--******************************************************************************
--
-- Let's start creating the UI
--
--******************************************************************************
rtk.set_theme_overrides { button = '#ffffff1f' }

local window = rtk.Window {
  w         = 800,
  h         = 400,
  maxw      = 1200,
  maxh      = 800,
  minw      = 800,
  minh      = 400,
  resizable = false,
  bg        = Colors.Primary,
  title     = 'ReaSonus FaderPort'
}

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
  minw    = 400,
  padding = 10,
  spacing = 8,
})
local content = mainBox:add(rtk.Container {
  h        = 1,
  w        = 1,
  margin   = 10,
  padding  = 5,
  bg       = Colors.BackGround,
  minw     = 400,
  vspacing = 5,
  hspacing = 10,
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
    screen.widget = pages.createFunctionsPage.create(nbFunctionKeys)
  end,
  -- update = function()
  --   ReadFunctionsFile()
  -- end
}

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
local function reflowFunctions(width, height)
  if not width then return end
  local columns = 4;
  if (width < 900) then columns = 3 end
  if (width < 600) then columns = 2 end
  if (width < 300) then columns = 1 end

  for i = 1, nbFunctionKeys do
    local x = ((i - 1) % columns) * width / columns
    local y = (math.floor((i - 1) / columns)) * 80
    pages.createFunctionsPage.functionActions[i]:setPositionAndSize(x, y, width / columns);
  end
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
    reflowFunctions(width - 10, height)
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
  window:open()
  uiElements.createNavigationSideBar(sidebar, app);
  checkContentSize()
end

main()
