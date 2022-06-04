-- Set package path to find rtk installed via ReaPack
package.path = reaper.GetResourcePath() .. '/Scripts/ReaSonus/?.lua'
-- Load the package
local rtk = require('rtk')
-- Set the module-local log variable for more convenient logging.  Throughout
-- this tutorial we will assume both rtk and log variables have been set.
local log = rtk.log
log.clear()

local Colors = {
  Primary = '#00529C',
  BackGround = '#ffffff0f',
  Button = {
    Border = '1px #ffffff55',
    BackGround = '#ffffff0f',
  },
  Label = {
    Border = '1px #ffffff55',
    BackGround = '#ffffff0f',
  },
}

-- Global variables
local functionLines = {}
local functionIds = {}
local actionCallbacks = {}
local contentWidth = 0
local contentHeight = 0
local functionFilePath = reaper.GetResourcePath() .. '/CSI/Zones/ReasonusFaderPort/FP8_Navigators.zon'


-- UI variables
local contentWidth = 0
local functionActions = {}
local functionActionIds = {}
-- pre-define the popups
local popup


--******************************************************************************
--
-- Read the zon file for the functions and loop through the lines
-- Call SetAction for storing the value and update the gui
--
--******************************************************************************
function ReadFunctionsFile() 
  local readNext   = false;
  local functionId = 0;
  
  for line in io.lines(functionFilePath) do
    functionLines[#functionLines + 1] = line
    if readNext then
      if string.match(line, '.*Reaper.*%s(.*)%s') then
        local value = string.match(line, '.*Reaper%s(_?%w*)%s*//')
        SetAction(value, functionId)
      end
      readNext = false
    end
    if string.match(line, '// Function.Action.(%d)') then
      readNext = true
      functionId = math.floor(string.match(line, '// Function.Action.(%d)'))
    end    
  end
end


--******************************************************************************
--
-- Write the actionIds to the zon file
--
--******************************************************************************
function WriteFunctionsFile() 
  local writeNext = false;
  local functionId = 0;
  local zonFile = assert(io.open(functionFilePath, "w"))
  
  for i=1, #functionLines do
    local line = functionLines[i]

    if readNext then
      if string.match(line, '.*Reaper.*%s(.*)%s') then
        local actionId = string.match(line, '.*Reaper%s(_?%w*)%s*//')
        local value = string.gsub(
          line, 
          tostring(actionId), 
          tostring(functionIds[functionId])
        )
        
        functionLines[i] = value
      end
      readNext = false
    end
    if string.match(line, '// Function.Action.(%d)') then
      readNext = true
      functionId = math.floor(string.match(line, '// Function.Action.(%d)') - 1)
    end  
    zonFile:write(functionLines[i] .. '\n')
  end
  zonFile:close()
  popup:open()
end


--******************************************************************************
--
-- Store the action id and write it to the gui
--
-- actionId: ActionId to store
-- index:    Function Id to store the vaue to
--
--******************************************************************************
function SetAction(actionId, index) 
  if(functionActionIds[index]) then
    functionActionIds[index]:attr('text', actionId)
  end
  functionIds[index] = actionId
end


--******************************************************************************
--
-- Trigger the actionslist and stores the selected action id
--
-- callback: Callback function to execute after selecting an action
-- index:    The index of the function to set the action id to
--
--******************************************************************************
function GetSelectedAction(callback, index)
  return function()
    if (not actionPaneOpened) then
      action = reaper.PromptForAction(1, 0, 0)
      actionPaneOpened = true
    else 
      action = reaper.PromptForAction(0, 0, 0)
    end

    if action > 0 then
      while action > 0 do
        callback(action, index)
        action = reaper.PromptForAction(0, 0, 0)
        actionPaneOpened = false
      end
      -- we don't " have to end the session if we want the user to be 
      -- able to select actions multiple times
      reaper.PromptForAction(-1,0,0) 
      actionPaneOpened = false
    elseif action == 0 and actionPaneOpened then
      reaper.defer(actionCallbacks[index])
    else 
      actionPaneOpened = false
    end
  end
end


--******************************************************************************
--
-- Let's start creating the UI
--
--******************************************************************************
rtk.set_theme_overrides{button='#ffffff1f'}

local logo          = rtk.Image():load('./images/reasonus-logo.png')
local functionsIcon = rtk.Image():load('./images/icons/grid.png')
local homeIcon      = rtk.Image():load('./images/icons/home.png')
local aboutIcon     = rtk.Image():load('./images/icons/info.png')
local searchIcon    = rtk.Image():load('./images/icons/search.png')
local saveIcon      = rtk.Image():load('./images/icons/save.png')
local faderPort     = rtk.Image():load('./images/icons/Faderport8.png')
if not logo then
   log.error('image failed to load')
end

local window = rtk.Window{
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

local popupContent = rtk.VBox{spacing=20}
popup = rtk.Popup{
  child   = popupContent, 
  padding = 30, 
  overlay = '#000000aa', 
  bg      = Colors.Primary
}
popupContent:add(rtk.Heading{
  text    = 'Message',
  bmargin = 5
}, {halign='center'})
popupContent:add(rtk.Text{
  text = 'The changes have been saved successfully'
})
local popupClosebutton = popupContent:add(rtk.Button{label='Close'}, {halign='center'})
popupClosebutton.onclick = function() 
  -- Control surface: Refresh all surfaces
  reaper.Main_OnCommandEx(41743, 0, 0)
  popup:close() 
end


--******************************************************************************
--
-- Create the home page
--
--******************************************************************************
local function createHomePage()
  local homePage = rtk.VBox{spacing = 25, w = 1, padding = 10}
  homePage:add(rtk.Heading{
    text   = 'Welcome to ReaSonus FaderPort', 
    halign ='center', 
    w      = 1
  })
  local imageArea = homePage:add(rtk.Container{w=1, halign='center'})
  imageArea:add(rtk.ImageBox{faderPort, maxh=400, halign = 'center' })
  homePage:add(rtk.Text{
    text   = 'Manage your FaderPort the best way possible in REAPER', 
    w      = 1, 
    halign = rtk.Widget.CENTER
  })
  return homePage
end


--******************************************************************************
--
-- Create the about page
--
--******************************************************************************
local function createAboutPage()
  local aboutPage = rtk.VBox{spacing = 15, w = 1, padding = 10}
  aboutPage:add(rtk.Heading{
    text   = 'About', 
  })
  aboutPage:add(rtk.Text{
    w = 1,
    wrap = rtk.Text.WRAP_NORMAL,
    text   = 'ReaSonus FaderPort is created to make the use of your FaderPort with Reaper as easy as possible. It is build on top of CSI, a tool for connecting controllers to REAPER with a huge flexibility.' 
  })
  aboutPage:add(rtk.Text{
    w = 1,
    wrap = rtk.Text.WRAP_NORMAL,
    text   = 'Therefor a big thank you goes out to Geoff Waddington and the CSI community.' 
  })
  aboutPage:add(rtk.Text{
    w = 1,
    wrap = rtk.Text.WRAP_NORMAL,
    text   = 'I work on ReaSonus in my spare time and is Open Source, so if you want to, feel free to add code.' 
  })
  aboutPage:add(rtk.Text{
    w = 1,
    wrap = rtk.Text.WRAP_NORMAL,
    text   = 'You may also donate if you appreciate this project.' 
  })
  local donateButton = aboutPage:add(rtk.Button{
    label  = 'Buy me a coffe or beer', 
    halign = rtk.Widget.RIGHT,
    flat   = rtk.Button.FLAT,
    bg     = Colors.Button.BackGround,
    border = Colors.Button.Border, 
  }, {halign = rtk.Widget.RIGHT,})
  donateButton.onclick = function()
    rtk.open_url('https://www.buymeacoffee.com/navelpluisje')
  end
  
  return aboutPage
end

--******************************************************************************
--
-- Define all the main areas of the UI
--
--******************************************************************************
local mainBox = window:add(rtk.HBox{
  vpadding = 10, 
  w        = 1
})
local sidebar = mainBox:add(rtk.VBox{
  h       = 1, 
  w       = 230, 
  minw    = 400, 
  padding = 10, 
  spacing = 8,
})
local content = mainBox:add(rtk.Container{
  h        = 1, 
  w        = 1, 
  margin   = 10, 
  padding  = 5, 
  bg       = Colors.BackGround, 
  minw     = 400, 
  vspacing = 5, 
  hspacing = 10,
})
local functionsPage = rtk.Container{
  h = 1, 
  w = 1,
}


--******************************************************************************
--
-- Create the app and add the different screen
--
--******************************************************************************
local app = content:add(rtk.Application())
app.statusbar:hide()

app:add_screen{
    name = 'home',
    init = function(app, screen)
        screen.widget = createHomePage()
    end,
}

app:add_screen{
    name = 'functions',
    init = function(app, screen)
        screen.widget = functionsPage
    end,
    update = function()
      ReadFunctionsFile()
    end
}

app:add_screen{
    name = 'about',
    init = function(app, screen)
        screen.widget = createAboutPage()
    end,
}


--******************************************************************************
--
-- Create the navigation buttons and attach the onclick event handling
--
--******************************************************************************
local navLogo = rtk.ImageBox{logo}
local navHome = rtk.Button{
  icon    = homeIcon,
  label   = 'Home', 
  flat    = rtk.Button.FLAT,
  bg      = Colors.Button.BackGround,
  border  = Colors.Button.Border, 
  w       = 1, 
  padding = 10,
  hover   = true,
}
local navFunction = rtk.Button{
  icon    = functionsIcon,
  label   = 'Edit Function keys', 
  flat    = rtk.Button.FLAT,
  bg      = Colors.Button.BackGround,
  border  = Colors.Button.Border, 
  w       = 1, 
  padding = 10
}
local navAbout = rtk.Button{
  icon    = aboutIcon,
  label   = 'About', 
  flat    = rtk.Button.FLAT, 
  bg      = Colors.Button.BackGround,
  w       = 1, 
  padding = 10,
  border  = Colors.Button.Border,
}

navHome.onclick = function()
  app:push_screen('home')
  navHome:attr('hover', true)
  navFunction:attr('hover', false)
  navAbout:attr('hover', false)
end

navFunction.onclick = function()
  app:push_screen('functions')
  navHome:attr('hover', false)
  navFunction:attr('hover', true)
  navAbout:attr('hover', false)
end

navAbout.onclick = function()
  app:push_screen('about')
  navHome:attr('hover', false)
  navFunction:attr('hover', false)
  navAbout:attr('hover', true)
end

navLogo.onclick = function()
  app:push_screen('home')
  navHome:attr('hover', true)
  navFunction:attr('hover', false)
  navAbout:attr('hover', false)
end


--******************************************************************************
--
-- Populate the sidebar with the logo and navigation buttons
--
--******************************************************************************
sidebar:add(navLogo)
sidebar:add(navHome)
sidebar:add(navFunction)
sidebar:add(navAbout)


--******************************************************************************
--
-- Create the functions page with the 8 function key aqrea's. 
-- They contain a label, the value and a button for opening the actionslist
--
--******************************************************************************
for i = 1, 8 do
  actionCallbacks[i] = GetSelectedAction(SetAction, i)
  
  local functionLabel = 'Function ' .. i
  functionActions[i] = functionsPage:add(rtk.Container{
    w       = .25, 
    h       = 80,
    padding = 5, 
  })
  
  local label = functionActions[i]:add(rtk.HBox{
    w        = 1, 
    h        = 30,
    vpadding = 10, 
    bg       = Colors.Label.BackGround,
    border   = Colors.Label.Border,
  })
  label:add(rtk.Text{
    functionLabel, 
    w        = 1, 
    halign   = rtk.Widget.CENTER, 
    valign   = rtk.Widget.CENTER, 
    fontsize = 20, 
    tmargin  = 7
  })
  
  local acionId = functionActions[i]:add(rtk.HBox{
    w        = 1, 
    h        = 40, 
    tmargin  = 29, 
    vpadding = 15,
    border   = Colors.Label.Border
  })
  functionActionIds[i] = rtk.Text{
    'actionId', 
    w = 1, 
    halign    = rtk.Widget.CENTER, 
    valign    = rtk.Widget.CENTER, 
    fontflags = rtk.font.BOLD, 
    tmargin   = 12, 
    lpadding  = 38
  } 
  acionId:add(functionActionIds[i])
  
  local actionButton = functionActions[i]:add(rtk.Button{
    icon    = searchIcon, 
    iconpos = rtk.Widget.CENTER, 
    w       = 38, 
    h       = 38,
    tmargin = 30,
    flat    = rtk.Button.FLAT,
  })
  actionButton.onclick=actionCallbacks[i]
end

local saveButton = functionsPage:add(rtk.Button{
  icon   = saveIcon, 
  label  = 'Save', 
  w      = 90, 
  h      = 36, 
  halign = rtk.Widget.CENTER, 
  halign = rtk.Widget.CENTER,
  flat   = rtk.Button.FLAT,
  bg     = Colors.Button.BackGround,
  border = Colors.Button.Border, 
})
saveButton.onclick=WriteFunctionsFile


--******************************************************************************
--
-- On resize of the content area, the positions and sizes of the function area's
--   nned to be recalculated
--
--******************************************************************************
function reflowFunctions(width, height)
  if not width then return end
  local columns = 4;
  if (width < 900) then columns = 3 end
  if (width < 600) then columns = 2 end
  if (width < 300) then columns = 1 end
  
  for i = 1, 8 do
    local x = ((i - 1) % columns) * width / columns
    local y = (math.floor((i -1) / columns)) * 80
    
    functionActions[i]:attr('x', x)
    functionActions[i]:attr('y', y)
    functionActions[i]:attr('w', width / columns)
  end
  
  saveButton:attr('y', height - 15 - saveButton.h)
  saveButton:attr('x', width - saveButton.w - 5)
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

function main()
  window:open()
  checkContentSize()
end

main()


