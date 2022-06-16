-- Set package path to find rtk installed via ReaPack
package.path = reaper.GetResourcePath() .. '/Scripts/ReaSonus/ref/?.lua'
-- Load the package
local rtk = require('rtk')
local ref = require('core')

local pages = require('pages')

ref.createHomePage = pages.createHomePage
ref.createAboutPage = pages.createAboutPage
-- ref = {
--   Colors = {
--     Primary = '#00529C',
--     BackGround = '#ffffff0f',
--     Button = {
--       Border = '1px #ffffff55',
--       BackGround = '#ffffff0f',
--     },
--     Label = {
--       Border = '1px #ffffff55', 
--       BackGround = '#ffffff0f', 
--     },
--   } 
-- }

return ref