--|| SIT - QB-Target ||
if config.qb_target then
	exports['qb-target']:AddTargetModel(config.chairs, {
		options = {{
			label = config.targetName, icon = config.targetIcon,
			canInteract = function() return true end,
	        action = function(entity) return sit(entity) end
		}},
		distance = 2.5,
	})
end

--|| SIT - OX-Target ||
if config.ox_target then
	local options =
	{
	    {
	        label = config.targetName, name = "nvsit", icon = config.targetIcon, iconColor = "orange", distance = 2.5,
	        canInteract = function() return true end,
	        onSelect = function(data) return sit(data.entity) end
	    }
	}
	exports.ox_target:addModel(config.chairs, options)
end


local sitting = false
function sit(entity)
	local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local entityCoords = GetEntityCoords(entity)
    localEntity = entity

    FreezeEntityPosition(localEntity,true)
    SetEntityCollision(playerPed,false)
   	SetEntityHasGravity(playerPed,false)

    local direction = vector3(playerCoords.x - entityCoords.x, playerCoords.y - entityCoords.y, 0.0)
    heading = GetEntityHeading(entity) + 180.0
    local distance = #(playerCoords - entityCoords)
    local moveCoords = entityCoords + (playerCoords - entityCoords) * (1.0 / distance)
    if GetEntityArchetypeName(entity) == "apa_mp_h_yacht_barstool_01" then
    	playerCoords = vec3(playerCoords.x,playerCoords.y,playerCoords.z+0.25)
    	TaskStartScenarioAtPosition(playerPed, "PROP_HUMAN_SEAT_BENCH", entityCoords.x, entityCoords.y, playerCoords.z-0.5, heading, 0, true, true)
	else
		TaskGoStraightToCoord(playerPed, moveCoords.x, moveCoords.y, moveCoords.z, 1.0, 1, 0.0, 0.1)	
    	TaskStartScenarioAtPosition(playerPed, "PROP_HUMAN_SEAT_BENCH", entityCoords.x, entityCoords.y, playerCoords.z-0.5, heading, 0, true, false)
    end
    sitting = true
end


RegisterKeyMapping('neveradev:sit:stand_up', 'Nevera - Stand Up', 'keyboard', "SPACE")
RegisterCommand('neveradev:sit:stand_up', function()
    if sitting then
        sitting = false
        local playerPed = PlayerPedId()
        ClearPedTasks(playerPed)
        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_IDLE", 0, true)
        FreezeEntityPosition(localEntity,false)
        SetEntityCollision(playerPed,true)
        SetEntityHasGravity(playerPed,true)
        if attachedEntity ~= nil then
            DetachEntity(PlayerPedId(), true, false)
            attachedEntity = nil
        end
    end
end)
