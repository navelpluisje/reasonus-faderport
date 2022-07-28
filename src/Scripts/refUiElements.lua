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
  Primary    = '#00529C',
  BackGround = '#ffffff0f',
  Border     = '#ffffff55',
  Button     = {
    Border      = '1px #ffffff55',
    BorderHover = '1px #ffffffee',
    BackGround  = '#ffffff0f',
  },
  Label      = {
    Border     = '1px #ffffff55',
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
  add       = rtk.Image():load('./assets/add.png'),
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
-- Show an rtk Entry
-- width: Number; widh of the button
-- height: Number; height of the button
--
--******************************************************************************
function uiElements.createEntry(width, height)
  return rtk.Entry {
    w              = width or 1,
    h              = height or 32,
    halign         = rtk.Widget.LEFT,
    padding        = 7,
    valign         = rtk.Widget.CENTER,
    bg             = Colors.Button.BackGround,
    border         = Colors.Button.Border,
    border_hover   = Colors.Button.BorderHover,
    border_focused = Colors.Button.BorderHover,
    fontsize       = 20,
  }
end

--******************************************************************************
--
-- Show an checkbox
-- width: Number; widh of the button
-- height: Number; height of the button
--
--******************************************************************************
function uiElements.createCheckBox(label, tborder)
  return rtk.CheckBox {
    w        = 1,
    h        = 32,
    halign   = rtk.Widget.LEFT,
    valign   = rtk.Widget.CENTER,
    label    = label,
    fontsize = 20,
    tborder  = tborder and Colors.Button.Border or nil,
    tpadding = 10,
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
function uiElements.createNavigationButton(label, icon, hover)
  return rtk.Button {
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
  local navLogo          = rtk.ImageBox { uiElements.Icons.logo }
  local navHome          = uiElements.createNavigationButton('Home', uiElements.Icons.home, true);
  local navFunction      = uiElements.createNavigationButton('Edit Function keys', uiElements.Icons.functions, false);
  local navMixManagement = uiElements.createNavigationButton('Mix Management', uiElements.Icons.mix, false);
  local navDocumentation = uiElements.createNavigationButton('Documentation', uiElements.Icons.mix, false);
  local navAbout         = uiElements.createNavigationButton('About', uiElements.Icons.about, false);

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

  navDocumentation.onclick = function()
    rtk.open_url('https://www.buymeacoffee.com/navelpluisje')
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
  sidebar:add(navDocumentation)
  sidebar:add(navAbout)
end

function uiElements.colorPicker(label, r, g, b)
  local redValue   = r or 0;
  local greenValue = g or 0;
  local blueValue  = b or 0;

  local red = rtk.HBox { w = 1 };
  red:add(rtk.Text { text = 'R', w = 15, fontsize = 16 })
  local redSlider = red:add(rtk.Slider {
    max        = 255,
    value      = redValue,
    trackcolor = Colors.Border,
    color      = "white",
  });
  local redValueLabel = red:add(rtk.Text { text = redValue, w = 30, lpadding = 5, fontsize = 16 })

  local green = rtk.HBox { w = 1 };
  green:add(rtk.Text { text = 'G', w = 15, fontsize = 16 })
  local greenSlider = green:add(rtk.Slider {
    max        = 255,
    value      = greenValue,
    trackcolor = Colors.Border,
    color      = "white",
  });
  local greenValueLabel = green:add(rtk.Text { text = greenValue, w = 30, lpadding = 5, fontsize = 16 })

  local blue = rtk.HBox { w = 1 };
  blue:add(rtk.Text { text = 'B', w = 15, fontsize = 16 })
  local blueSlider = blue:add(rtk.Slider {
    max        = 255,
    value      = blueValue,
    trackcolor = Colors.Border,
    color      = "white",
  });
  local blueValueLabel = blue:add(rtk.Text { text = blueValue, w = 30, lpadding = 5, fontsize = 16 })

  local sliderContainer      = rtk.VBox { w = 1, spacing = 8 };
  local controlContainer     = rtk.HBox { w = 1, spacing = 8 };
  local colorPickerContainer = rtk.VBox { w = 1, spacing = 8, tborder = Colors.Button.Border, tpadding = 8 };

  local swatch = rtk.Container {
    w      = 32,
    h      = 32,
    border = '2px white',
    bg     = { 0, 0, 0 }
  };

  local function updateColorSwatch()
    local color = { redValue / 255, greenValue / 255, blueValue / 255 }
    swatch:attr('bg', color);
  end

  local function setRedValue(value)
    redValue = math.round(value.value);
    redValueLabel:attr('text', redValue)
    updateColorSwatch();
  end

  local function setGreenValue(value)
    greenValue = math.round(value.value)
    greenValueLabel:attr('text', greenValue)
    updateColorSwatch();
  end

  local function setBlueValue(value)
    blueValue = math.round(value.value)
    blueValueLabel:attr('text', blueValue)
    updateColorSwatch();
  end

  local function setValue(red, green, blue)
    redValue = red;
    redSlider:attr('value', red);
    greenValue = green;
    greenSlider:attr('value', green);
    blueValue = blue;
    blueSlider:attr('value', blue);
    updateColorSwatch();
  end

  redSlider.onchange = setRedValue;
  greenSlider.onchange = setGreenValue;
  blueSlider.onchange = setBlueValue;

  sliderContainer:add(red)
  sliderContainer:add(green)
  sliderContainer:add(blue)
  controlContainer:add(swatch);
  controlContainer:add(sliderContainer);
  colorPickerContainer:add(rtk.Text { text = label, fontsize = 20 });
  colorPickerContainer:add(controlContainer);

  return {
    colorPicker = colorPickerContainer,
    getValue = function()
      return {
        redValue,
        greenValue,
        blueValue,
      }
    end,
    setValue = setValue,
  }

end

return uiElements
