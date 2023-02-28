local QBCore = exports['qb-core']:GetCoreObject()
RegisterNetEvent('QBCore:Client:UpdateObject', function() QBCore = exports['qb-core']:GetCoreObject() end)

local time = 1000
function loadModel(model) if not HasModelLoaded(model) then
	if Config.Debug then print("^5Debug^7: ^2Loading Model^7: '^6"..model.."^7'") end
	while not HasModelLoaded(model) do
		if time > 0 then time = time - 1 RequestModel(model)
		else time = 1000 print("^5Debug^7: ^3LoadModel^7: ^2Timed out loading model ^7'^6"..model.."^7'") break
		end
		Wait(10)
	end
end end
function unloadModel(model) if Config.Debug then print("^5Debug^7: ^2Removing Model^7: '^6"..model.."^7'") end SetModelAsNoLongerNeeded(model) end
function loadAnimDict(dict)	if Config.Debug then print("^5Debug^7: ^2Loading Anim Dictionary^7: '^6"..dict.."^7'") end while not HasAnimDictLoaded(dict) do RequestAnimDict(dict) Wait(5) end end
function unloadAnimDict(dict) if Config.Debug then print("^5Debug^7: ^2Removing Anim Dictionary^7: '^6"..dict.."^7'") end RemoveAnimDict(dict) end
function loadPtfxDict(dict)	if Config.Debug then print("^5Debug^7: ^2Loading Ptfx Dictionary^7: '^6"..dict.."^7'") end while not HasNamedPtfxAssetLoaded(dict) do RequestNamedPtfxAsset(dict) Wait(5) end end
function unloadPtfxDict(dict) if Config.Debug then print("^5Debug^7: ^2Removing Ptfx Dictionary^7: '^6"..dict.."^7'") end RemoveNamedPtfxAsset(dict) end

function lookEnt(entity)
	if type(entity) == "vector3" then
		if not IsPedHeadingTowardsPosition(PlayerPedId(), entity, 10.0) then
			TaskTurnPedToFaceCoord(PlayerPedId(), entity, 1500)
			if Config.Debug then print("^5Debug^7: ^2Turning Player to^7: '^6"..json.encode(entity).."^7'") end
			Wait(1500)
		end
	else
		if DoesEntityExist(entity) then
			if not IsPedHeadingTowardsPosition(PlayerPedId(), GetEntityCoords(entity), 30.0) then
				TaskTurnPedToFaceCoord(PlayerPedId(), GetEntityCoords(entity), 1500)
				if Config.Debug then print("^5Debug^7: ^2Turning Player to^7: '^6"..entity.."^7'") end
				Wait(1500)
			end
		end
	end
end

function destroyProp(entity)
	if Config.Debug then print("^5Debug^7: ^2Destroying Prop^7: '^6"..entity.."^7'") end
	SetEntityAsMissionEntity(entity) Wait(5)
	DetachEntity(entity, true, true) Wait(5)
	DeleteObject(entity)
end

function toBool(string)
	if string == "true" then string = true
	elseif string == "false" then string = false end
	return string
end

function makeProp(data, freeze, synced)
    loadModel(data.prop)
    local prop = CreateObject(data.prop, data.coords.x, data.coords.y, data.coords.z-1.03, synced or 0, synced or 0, 0)
    SetEntityHeading(prop, data.coords.w)
    FreezeEntityPosition(prop, freeze or 0)
    if Config.Debug then print("^5Debug^7: ^6Prop ^2Created ^7: '^6"..prop.."^7'") end
    return prop
end