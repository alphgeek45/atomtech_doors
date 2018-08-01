local ser = require('serialization')
local event = require('event')
local GUI = require('GUI')
local admin = "alphgeek45"
local users = {}
local modem = require('component').modem

local mainContainer = GUI.fullScreenContainer()
mainContainer:addChild(GUI.panel(1, 1, mainContainer.width, mainContainer.height, 0x2D2D2D))
local layout = mainContainer:addChild(GUI.layout(1, 1, mainContainer.width, mainContainer.height, 3, 1))

-- Create vertically oriented list
local playerList = layout:setPosition(1, 1, layout:addChild(GUI.list(3, 2, 25, 25, 3, 0, 0xE1E1E1, 0x4B4B4B, 0xD2D2D2, 0x4B4B4B, 0x3366CC, 0xFFFFFF, false)))
local addButton = layout:setPosition(3, 1, layout:addChild(GUI.button(1, 1, 26, 3, 0xEEEEEE, 0x000000, 0xAAAAAA, 0x0, "+Add")))
local playerText = layout:setPosition(2, 1, layout:addChild(GUI.input(2, 2, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D, "", "Placeholder text")))

addButton.onTouch = function()
    table.insert(users, playerText.text)
    playerList:addItem(playerText.text)
    playerText.text = ""
    mainContainer:drawOnScreen(true)
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

modem.open(1)

event.listen('modem_message', function(_, _, sender, _, _, msg)
    
    local _cmd = ser.unserialize(msg)
    local returned = {}
    if _cmd.command == "request" then
        if table.contains(users, _cmd.user) then
            returned = {command='open'}
        else
            returned = {command="deny"}
        end
    end
    modem.send(sender, 1, ser.serialize(returned))
end)

mainContainer:drawOnScreen(true)
mainContainer:startEventHandling()