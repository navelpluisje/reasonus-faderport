package.path = reaper.GetResourcePath() .. '/Scripts/ReaSonus/ref/?.lua'
local ref = require('core')
local rtk = require('rtk')

local pages = {}

local faderPort     = rtk.Image():load('./images/icons/Faderport8.png')


--******************************************************************************
--
-- Create the home page
--
--******************************************************************************
function pages.createHomePage()
  local homePage = rtk.VBox{spacing = 25, w = 1, padding = 10}
  homePage:add(rtk.Heading{
    text   = 'Welcome to ReaSonus FaderPort', 
    halign ='center', 
    w      = 1
  })
  local imageArea = homePage:add(rtk.Container{
    w      = 1, 
    halign = rtk.Widget.CENTER
  })
  imageArea:add(rtk.ImageBox{
    faderPort, 
    maxh   = 400, 
    halign = rtk.Widget.CENTER 
  })
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
function pages.createAboutPage()
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
    bg     = ref.Colors.Button.BackGround,
    border = ref.Colors.Button.Border, 
  }, {
    halign = rtk.Widget.RIGHT
  })
  donateButton.onclick = function()
    rtk.open_url('https://www.buymeacoffee.com/navelpluisje')
  end
  
  return aboutPage
end

return pages