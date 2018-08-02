local ser = require('serialization')
local event = require('event')
local GUI = require('GUI')
local modem = require('component').modem
local server = ''
local authorized = ""
local users = {}
------------------------------------------------------------------------------------------
modem.open(1)

modem.broadcast(1, ser.serialize({command="discover"}))

event.listen('modem_message', function(e, _, sender, _, _, msg)
    local _cmd = ser.unserialize(msg)
    if _cmd.command == 'userauthorized' then
        authorized = _cmd.user
    elseif _msg.command == "discresponse" then
        server_address = _msg.server
    elseif _msg.command == "useradded" then

    elseif _msg.command == "allusers" then
        users = _msg.users
    end
end)

local mainContainer = GUI.fullScreenContainer()
mainContainer:addChild(GUI.panel(1, 1, mainContainer.width, mainContainer.height, 0x2D2D2D))
local layout = mainContainer:addChild(GUI.layout(1, 1, mainContainer.width, mainContainer.height, 3, 1))

-- Create vertically oriented list
local playerList = layout:setPosition(1, 1, layout:addChild(GUI.list(3, 2, 25, 25, 3, 0, 0xE1E1E1, 0x4B4B4B, 0xD2D2D2, 0x4B4B4B, 0x3366CC, 0xFFFFFF, false)))
local addButton = layout:setPosition(3, 1, layout:addChild(GUI.button(1, 1, 26, 3, 0xEEEEEE, 0x000000, 0xAAAAAA, 0x0, "+Add")))
local playerText = layout:setPosition(2, 1, layout:addChild(GUI.input(2, 2, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D, "", "Username")))

addButton.onTouch = function(mainContainer, button, e, _, _, _, _, player)
    if authorized == player then
        local command = {command="adduser", playerText.text}
        modem.send(server_address, 1, ser.serialize(command))
    else
        local command = {command="userauthorized", user=player}
        print(ser.serialize(command))
        modem.send(server_address, 1, ser.serialize(command))
    end
end

mainContainer:drawOnScreen(true)
mainContainer:startEventHandling()