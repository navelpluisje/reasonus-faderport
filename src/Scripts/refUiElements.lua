package.path = reaper.GetResourcePath() .. '/Scripts/ReaSonus/?.lua'
-- Load the package
local rtk = require('rtk')

local methods = {
  func = function(self, ge)
    self.la = self.la + ge
  end
}

local uiElements = {}

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

uiElements.Colors = Colors;

uiElements.Icons = {
  logo      = rtk.Image():load('./assets/reasonus-logo.png'),
  functions = rtk.Image():load('./assets/grid.png'),
  home      = rtk.Image():load('./assets/home.png'),
  mix       = rtk.Image():load('./assets/mix.png'),
  about     = rtk.Image():load('./assets/info.png'),
  search    = rtk.Image():load('./assets/search.png'),
  save      = rtk.Image():load('./assets/save.png'),
  coffee    = rtk.Image():load('./assets/coffee.png'),
  close     = rtk.Image():load('./assets/close.png'),
}


--******************************************************************************
--
-- Show an rtk Button
-- label: String; label for the button
-- icon: rtk.Image; icon Image
-- width: Number; fixed widh of the button
--
--******************************************************************************
function uiElements.createButton(label, icon, width)
  return rtk.Button {
    icon   = icon,
    label  = label,
    w      = width,
    h      = 36,
    halign = rtk.Widget.CENTER,
    flat   = rtk.Button.FLAT,
    bg     = Colors.Button.BackGround,
    border = Colors.Button.Border,
  }
end

--******************************************************************************
--
-- Create a navigation button
-- label: String; label for the button
-- icon: rtk.Image; icon Image
-- bover: Boolean; Display in hover state
--
--******************************************************************************
function uiElements.createNavigationButton(label, icon, hover) ;return rtk.Button {
    icon    = icon,
    label   = label,
    flat    = rtk.Button.FLAT,
    bg      = Colors.Button.BackGround,
    border  = Colors.Button.Border,
    w       = 1,
    padding = 10,
    hover   = hover,
  }
end

--******************************************************************************
--
-- Show a rtk popup
-- title: String; title of the popup
-- content: rtk.Widget; Widget with the content for the popup
-- onClose: function; callback function for onclose
--
--******************************************************************************
function uiElements.showPopup(title, content, onClose)
  local popupBody = rtk.VBox { spacing = 20 }
  local popup = rtk.Popup {
    child   = popupBody,
    overlay = '#000000aa',
    bg      = Colors.Primary,
    padding = 0,
    w       = 460
  }

  popupBody:add(rtk.Heading {
    text    = title,
    t       = 0,
    w       = 1,
    bmargin = 5,
    padding = 10,
    bg      = Colors.Label.BackGround,
    bborder = Colors.Label.Border,
    halign  = 'center',
  })

  local container = popupBody:add(rtk.Container {
    lpadding = 30,
    rpadding = 30,
  })
  container:add(content)

  local footer = popupBody:add(rtk.HBox {
    padding = 10,
    tborder = Colors.Label.Border,
  })
  footer:add(rtk.Spacer(), { expand = 1, fillh = false, fillv = false })
  local popupClosebutton = footer:add(uiElements.createButton('Close', uiElements.Icons.close))
  footer:add(rtk.Spacer(), { expand = 1, fillh = false, fillv = false })

  popupClosebutton.onclick = function()
    if onClose then
      onClose()
    end
    popup:close()
  end

  popup:open()
end

--******************************************************************************
--
-- Show opup with success message for saving the action
--
--******************************************************************************
function uiElements.showSavePopup(callback)
  local content = rtk.Text {
    text = 'The changes have been saved successfully'
  }
  uiElements.showPopup('Message', content, callback)
end

--******************************************************************************
--
-- Create the navigation buttons and attach the onclick event handling
--
--******************************************************************************
function uiElements.createNavigationSideBar(sidebar, app, faderPortVersion)
  local navLogo = rtk.ImageBox { uiElements.Icons.logo }
  local navHome = uiElements.createNavigationButton('Home', uiElements.Icons.home, true);
  local navFunction = uiElements.createNavigationButton('Edit Function keys', uiElements.Icons.functions, false);
  local navMixManagement = uiElements.createNavigationButton('Mix Management', uiElements.Icons.mix, false);
  local navAbout = uiElements.createNavigationButton('About', uiElements.Icons.about, false);

  navHome.onclick = function()
    app:push_screen('home')
    navHome:attr('hover', true)
    navFunction:attr('hover', false)
    if (faderPortVersion ~= '2') then
      navMixManagement:attr('hover', false)
    end
    navAbout:attr('hover', false)
  end

  navFunction.onclick = function()
    app:push_screen('functions')
    navHome:attr('hover', false)
    navFunction:attr('hover', true)
    if (faderPortVersion ~= '2') then
      navMixManagement:attr('hover', false)
    end
    navAbout:attr('hover', false)
  end

  navMixManagement.onclick = function()
    app:push_screen('mix-management')
    navHome:attr('hover', false)
    navFunction:attr('hover', false)
    if (faderPortVersion ~= '2') then
      navMixManagement:attr('hover', true)
    end
    navAbout:attr('hover', false)
  end

  navAbout.onclick = function()
    app:push_screen('about')
    navHome:attr('hover', false)
    navFunction:attr('hover', false)
    if (faderPortVersion ~= '2') then
      navMixManagement:attr('hover', false)
    end
    navAbout:attr('hover', true)
  end

  navLogo.onclick = function()
    app:push_screen('home')
    navHome:attr('hover', true)
    navFunction:attr('hover', false)
    if (faderPortVersion ~= '2') then
      navMixManagement:attr('hover', false)
    end
    navAbout:attr('hover', false)
  end

  sidebar:add(navLogo)
  sidebar:add(navHome)
  sidebar:add(navFunction)
  if (faderPortVersion ~= '2') then
    sidebar:add(navMixManagement)
  end
  sidebar:add(navAbout)
end

return uiElements
