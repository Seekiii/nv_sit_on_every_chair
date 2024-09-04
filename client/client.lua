local sitting = false

-- QB Target
if config.qb_target then
	exports['qb-target']:AddTargetModel(config.chairs, {
		options = {
			{	
				-- Sit
				label = config.targetName, icon = config.targetIcon,
				canInteract = function() if not sitting then return true else return false end end,
	        	action = function(entity) return sit(entity) end
			},
			{
				-- Stand up
				label = config.targetNameStandUp, icon = config.targetIcon,
				canInteract = function() if sitting then return true else return false end end,
	        	action = function(entity) return ExecuteCommand('neveradev:sit:stand_up') end
			}
		},
		distance = 1.5,
	})
end

-- OX Target
if config.ox_target then
	local options =
	{
	    {
	    	-- Sit
	        label = config.targetName, name = "nvsit", icon = config.targetIcon, iconColor = "orange", distance = 1.5,
	        canInteract = function() if not sitting then return true else return false end end,
	        onSelect = function(data) 
	        	return sit(data.entity, data.coords)
	        end
	    },
	    {
	    	-- Stand Up
	        label = config.targetNameStandUp, name = "nvstandup", icon = config.targetIcon, iconColor = "orange", distance = 1.5,
	        canInteract = function() if sitting then return true else return false end end,
	        onSelect = function(data) return ExecuteCommand('neveradev:sit:stand_up') end
	    }
	}
	exports.ox_target:addModel(config.chairs, options)
end

function sit(entity,newCoords)
	local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local entityCoords = GetEntityCoords(entity)
    local name = GetEntityArchetypeName(entity)
    local heading = GetEntityHeading(entity) + 180.0
    if string.find(name, "bench") then
    	entityCoords = newCoords
    end
    if name == "prop_table_01_chr_b" then heading += 90 end
    localEntity = entity
    FreezeEntityPosition(localEntity,true)
    local direction = vector3(playerCoords.x - entityCoords.x, playerCoords.y - entityCoords.y, 0.0)
    local distance = #(playerCoords - entityCoords)
    local moveCoords = entityCoords + (playerCoords - entityCoords) * (1.0 / distance)
    if GetEntityArchetypeName(entity) == "apa_mp_h_yacht_barstool_01" then
    	playerCoords = vec3(playerCoords.x,playerCoords.y,playerCoords.z+0.25)
    	TaskStartScenarioAtPosition(playerPed, "PROP_HUMAN_SEAT_BENCH", entityCoords.x, entityCoords.y, playerCoords.z-0.5, heading, 0, true, true)
	else
    	TaskStartScenarioAtPosition(playerPed, "PROP_HUMAN_SEAT_BENCH", entityCoords.x, entityCoords.y, playerCoords.z-0.5, heading, 0, true, true)
    end
    if config.forceFPVonSit then
    	Wait(1000)
    	SetFollowPedCamViewMode(4)
    end
    sitting = true
end

RegisterKeyMapping('neveradev:sit:stand_up_x', 'Nevera - Stand Up X', 'keyboard', "X")
RegisterKeyMapping('neveradev:sit:stand_up_space', 'Nevera - Stand Up SPACE', 'keyboard', "SPACE")

RegisterCommand('neveradev:sit:stand_up_x', function() ExecuteCommand('neveradev:sit:stand_up') end)
RegisterCommand('neveradev:sit:stand_up_space', function() ExecuteCommand('neveradev:sit:stand_up') end)

RegisterCommand('neveradev:sit:stand_up', function()
	if sitting then
		sitting = false
		local playerPed = PlayerPedId()
		ClearPedTasks(playerPed)
		TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_IDLE", 0, true)
		FreezeEntityPosition(localEntity,false)
		if attachedEntity ~= nil then
			DetachEntity(PlayerPedId(), true, false)
			attachedEntity = nil
		end
		Wait(500)
		SetFollowPedCamViewMode(1)
	end
end)