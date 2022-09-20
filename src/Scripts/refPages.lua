local function createPath(path)
  return path:gsub('/', package.config:sub(1, 1));
end

package.path = reaper.GetResourcePath() .. createPath('/Scripts/ReaSonus/?.lua');
-- Load the package
local rtk = require('rtk');
local uiElements = require('refUiElements');
local FunctionAction = require('refFunctionAction')
local MixManagement = require('refMixManagement')
local CreatePluginZone = require('refCreatePluginZone')

local faderPortImages = {
  fp2 = rtk.Image():load('./assets/faderport2.png'),
  fp8 = rtk.Image():load('./assets/faderport8.png'),
  fp16 = rtk.Image():load('./assets/faderport16.png'),
}

local log = rtk.log
log.level = log.WARNING

local pages = {};

---Create the home page
---@param faderPortVersion string
---@return table rtk.Element
function pages.createHomePage(faderPortVersion)
  local homePage = rtk.VBox { spacing = 25, w = 1, padding = 10 }
  homePage:add(rtk.Heading {
    text   = 'Welcome to ReaSonus FaderPort',
    halign = 'center',
    w      = 1,
  })
  local imageArea = homePage:add(rtk.Container {
    w      = 1,
    halign = rtk.Widget.CENTER,
                                 })
  imageArea:add(rtk.ImageBox {
    faderPortImages['fp' .. faderPortVersion],
    maxh   = 400,
    halign = rtk.Widget.CENTER,
  })
  homePage:add(rtk.Text {
    text   = 'Manage your FaderPort the best way possible in REAPER',
    w      = 1,
    halign = rtk.Widget.CENTER,
  })
  return homePage
end

---Create the about page
---@return table rtk.Element
function pages.createAboutPage()
  local aboutPage = rtk.VBox { spacing = 15, w = 1, padding = 10 }
  aboutPage:add(rtk.Heading {
    text = 'About',
  })
  aboutPage:add(rtk.Text {
    w    = 1,
    wrap = rtk.Text.WRAP_NORMAL,
    text = 'ReaSonus FaderPort is created to make the use of your FaderPort with Reaper as easy as possible. It is build on top of CSI, a tool for connecting controllers to REAPER with a huge flexibility.',
  })
  aboutPage:add(rtk.Text {
    w    = 1,
    wrap = rtk.Text.WRAP_NORMAL,
    text = 'Therefor a big thank you goes out to Geoff Waddington and the CSI community.',
  })
  aboutPage:add(rtk.Text {
    w    = 1,
    wrap = rtk.Text.WRAP_NORMAL,
    text = 'I work on ReaSonus in my spare time and is Open Source, so if you want to, feel free to add code.',
  })
  aboutPage:add(rtk.Text {
    w    = 1,
    wrap = rtk.Text.WRAP_NORMAL,
    text = 'You may also donate if you appreciate this project.',
  })
  local donateButton = aboutPage:add(uiElements.createButton('Buy me a coffe or beer', uiElements.Icons.coffee, 200), {
    halign = rtk.Widget.RIGHT,
  })
  donateButton.onclick = function()
    rtk.open_url('https://www.buymeacoffee.com/navelpluisje')
  end

  return aboutPage;
end

pages.functionsPage = {
  nbFunctions     = 8,
  functionActions = {},
  page            = {},
  tabBar          = {},
  content         = {},
  buttonBar       = {},
  create          = function(nbFunctions)
    pages.functionsPage.nbFunctions = nbFunctions;
    pages.functionsPage.page = rtk.VBox {
      h = 1,
      w = 1,
      padding = 8,
    }
    pages.functionsPage.content = pages.functionsPage.page:add(
      rtk.FlowBox {
        vspacing = 8,
        hspacing = 8,
        w = 1,
      }
    );
    pages.functionsPage.buttonBar = pages.functionsPage.page:add(
      rtk.HBox {
        w        = 1,
        tmargin  = 20,
        tpadding = 8,
        tborder  = uiElements.Colours.Button.Border,
      }
    );
    pages.functionsPage.buttonBar:add(
    rtk.Spacer(),
        {
          expand = 1,
          fillw = true,
          fillh = false,
        }
    );

    local resetButton = pages.functionsPage.buttonBar:add(
      uiElements.createButton(
        'Reset to defaults',
        uiElements.Icons.save
      )
    );
    resetButton:attr('halign', 'right');
    resetButton.onclick = function()
      uiElements.showConfirm(
      'Reset the Function Id s',
          rtk.Text {
            text      = 'Do you really want to reset to the default values?\n This can not be undone',
            wrap      = rtk.Text.WRAP_NORMAL,
            textalign = rtk.Widget.CENTER,
            w         = 1,
            halign    = 'center',
          },
          'Yes, I do',
          pages.functionsPage.resetActionId,
          'Cancel'
      )
    end
    pages.functionsPage.populateContent();
    return pages.functionsPage.page;
  end,
  populateContent = function()
    pages.functionsPage.content:remove_all();
    for i = 1, pages.functionsPage.nbFunctions do
      pages.functionsPage.functionActions[i] = FunctionAction:new(i);
      pages.functionsPage.content:add(pages.functionsPage.functionActions[i]:getFunctionAction(), {
        minw = 100,
        maxw = 200,
      });
    end
  end,
  setWidth        = function(width)
    for i = 1, #pages.functionsPage.functionActions do
      pages.functionsPage.functionActions[i]:setWidth(width)
    end
  end,
  resetActionId   = function()
    for i = 1, #pages.functionsPage.functionActions do
      pages.functionsPage.functionActions[i]:setDefaultActionId();
    end
  end,
}

pages.mixManagementPage = {
  nbFilters        = 16,
  filterActions    = {},
  activeIndex      = 1,
  page             = {},
  tabBar           = {},
  content          = {},
  buttonBar        = {},
  create           = function(nbFilters)
    pages.mixManagementPage.nbFilters = nbFilters;
    pages.mixManagementPage.page = rtk.VBox {
      h      = 1,
      w      = 1,
      margin = 8,
    }
    pages.mixManagementPage.tabBar = pages.mixManagementPage.page:add(
      rtk.HBox {
        w = 1,
      }
    )
    pages.mixManagementPage.content = pages.mixManagementPage.page:add(
      rtk.HBox {
        w = 1,
      }
    )
    pages.mixManagementPage.buttonBar = pages.mixManagementPage.page:add(
      rtk.HBox {
        w        = 1,
        tmargin  = 20,
        tpadding = 8,
        tborder  = uiElements.Colours.Button.Border,
      }
    )
    pages.mixManagementPage.buttonBar:add(rtk.Spacer(), { expand = 1, fillw = true, fillh = false });
    local reloadButton = pages.mixManagementPage.buttonBar:add(
      uiElements.createButton(
        'Reload',
        uiElements.Icons.refresh
      )
    );
    reloadButton:attr('rmargin', 16)
    reloadButton.onclick = pages.mixManagementPage.reload;
    local saveButton = pages.mixManagementPage.buttonBar:add(
      uiElements.createButton(
        'Save filter',
        uiElements.Icons.save
      )
    );
    saveButton:attr('halign', 'right')
    saveButton.onclick = pages.mixManagementPage.save;
    pages.mixManagementPage.createFilterTabs(nbFilters);
    pages.mixManagementPage.populateTabBar();

    return pages.mixManagementPage.page;
  end,
  populateTabBar   = function()
    pages.mixManagementPage.content:remove_all();
    pages.mixManagementPage.tabBar:remove_all();
    for i = 1, pages.mixManagementPage.nbFilters do
      local button = pages.mixManagementPage.tabBar:add(uiElements.createButton('' .. i), {
        expand = 1,
        fillh  = true,
      });
      button:attr('w', 1)
      button:attr('fontsize', 24)
      button:attr('fontweight', rtk.font.Bold)
      button:attr('hover', i == pages.mixManagementPage.activeIndex)
      button.onclick = function()
        if (not button:calc('hover')) then
          pages.mixManagementPage.activeIndex = i;
          pages.mixManagementPage.populateTabBar();
        end
      end
    end
    pages.mixManagementPage.content:add(pages.mixManagementPage.filterActions[pages.mixManagementPage.activeIndex]:
        getMixManagement())
  end,
  createFilterTabs = function(nbFilters)
    for i = 1, pages.mixManagementPage.nbFilters do
      pages.mixManagementPage.filterActions[i] = MixManagement:new(i, nbFilters);
    end
  end,
  save             = function()
    pages.mixManagementPage.filterActions[pages.mixManagementPage.activeIndex]:writeChangesToFile()
  end,
  reload           = function()
    pages.mixManagementPage.filterActions[pages.mixManagementPage.activeIndex]:reloadFiles()
  end,
}

pages.createPluginZoneFile = {
  nbTracks      = 16,
  filterActions = {},
  activeIndex   = 1,
  page          = {},
  content       = {},
  buttonBar     = {},
  pluginEditor  = {},
  create        = function(nbTracks, window)
    pages.createPluginZoneFile.nbTracks = nbTracks;
    pages.createPluginZoneFile.page = rtk.VBox {
      h      = 1,
      w      = 1,
      margin = 8,
    }
    pages.createPluginZoneFile.content = pages.createPluginZoneFile.page:add(
      rtk.HBox {
        w = 1,
      }
    )
    pages.createPluginZoneFile.buttonBar = pages.createPluginZoneFile.page:add(
      rtk.HBox {
        w        = 1,
        tmargin  = 20,
        tpadding = 8,
        tborder  = uiElements.Colours.Button.Border,
      }
    )
    pages.createPluginZoneFile.buttonBar:add(rtk.Spacer(), { expand = 1, fillw = true, fillh = false });
    local loadButton = pages.createPluginZoneFile.buttonBar:add(
      uiElements.createButton(
        'Load',
        uiElements.Icons.refresh
      )
    );
    loadButton:attr('rmargin', 16)
    loadButton.onclick = pages.createPluginZoneFile.loadPlugin;
    loadButton.ondragstart = function(a, b)
      reaper.ShowConsoleMsg('drag start')
      return true, true
    end
    loadButton.ondragmousemove = function(event, arg)
      loadButton:attr('x', rtk.mouse.x)
      loadButton:attr('y', rtk.mouse.y)
      log.warning(table.tostring(rtk.mouse))
    end
    local saveButton = pages.createPluginZoneFile.buttonBar:add(
      uiElements.createButton(
        'Save filter',
        uiElements.Icons.save
      )
    );
    saveButton:attr('halign', 'right')
    saveButton.onclick = pages.createPluginZoneFile.save;
    saveButton.ondropfocus = function()
      saveButton:attr('border', '1px red');
      return true
    end

    pages.createPluginZoneFile.pluginEditor = CreatePluginZone:new(nbTracks, window);
    pages.createPluginZoneFile.content:add(pages.createPluginZoneFile.pluginEditor:getZoneEditor())


    -- local activeEffect, a, b, c = CreatePluginZone.getPluginData();

    -- reaper.ShowConsoleMsg(activeEffect and 'active' or 'inactive');
    -- if (activeEffect) then
    --   reaper.ShowConsoleMsg(a .. ' ' .. b .. ' ' .. c .. '\n')
    -- else
    --   reaper.ShowConsoleMsg('No Effect selected \n');
    -- end

    return pages.createPluginZoneFile.page;
  end,
  save          = function()
    pages.createPluginZoneFile.pluginEditor:saveZoneFiles();
  end,
  loadPlugin    = function()
    -- pages.createPluginZoneFile.content.clear();
    -- reaper.ShowConsoleMsg('Cleared')
    -- pages.createPluginZoneFile.plugin = CreatePluginZone:new(pages.createPluginZoneFile.nbTracks);
    -- reaper.ShowConsoleMsg('nbTracks set')
    local hasPlugin = pages.createPluginZoneFile.pluginEditor:loadPlugin()
    -- reaper.ShowConsoleMsg('nbTracks loaded\n\n')
    -- if (not hasPlugin) then
    --   reaper.MB('NoPlugin', 'No plugin selected')
    -- else
    --   reaper.MB('Plugin', 'Plugin selected')

    -- end
  end,
}
return pages;
