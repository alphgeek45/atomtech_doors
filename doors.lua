-- Doors control

local users = {}
local doors = {}

local sides = require('sides')
local image = require("image")
local GUI = require("GUI")
local redstone = require('component').redstone
local event = require('event')
local modem = require('component').modem
local ser = require('serialization')
local server_address = 'd3e6ffb5-3964-4097-a8b7-19631d3be954'
local door_side = sides.east

local isOpen = false
------------------------------------------------------------------------------------------

local mainContainer = GUI.fullScreenContainer()
mainContainer:addChild(GUI.panel(1, 1, mainContainer.width, mainContainer.height, 0x2D2D2D))

local layout = mainContainer:addChild(GUI.layout(1, 1, mainContainer.width, mainContainer.height, 5, 1))

layout:setPosition(3, 1, layout:addChild(GUI.button(1, 1, 26, 3, 0xEEEEEE, 0x000000, 0xAAAAAA, 0x0, "Open Door")))

-- Assign an callback function to the first added button
layout.children[1].onTouch = function(mainContainer, button, e, _, _, _, _, player)
    modem.send(server_address, 1, ser.serialize({command="request", user=player}))
end

------------------------------------------------------------------------------------------
modem.open(1)

modem.broadcast(1, ser.serialize({command="discover"}))

event.listen('modem_message', function(e, _, sender, _, _, msg)

    local _msg = ser.unserialize(msg)
    if sender == server_address then
        -- deconstruct the message

        if _msg.command == "open" then
            redstone.setOutput(door_side, 15)
            event.timer(5, function()
                redstone.setOutput(door_side, 0)
            end)
        else
            GUI.alert("You do not have access to this door.")
        end
    end
    if _msg.command == "discresponse" then
        server_address = _msg.server
    end
end)

mainContainer:drawOnScreen(true)
mainContainer:startEventHandling()