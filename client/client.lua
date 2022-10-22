local QBCore = exports['qb-core']:GetCoreObject()
RegisterNetEvent('QBCore:Client:UpdateObject', function() QBCore = exports['qb-core']:GetCoreObject() end)

local Props = {}
local Targets = {}
local Notes = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() TriggerEvent("jim-notepad:Client:SyncNotes") end)
AddEventHandler('onResourceStart', function(r) if GetCurrentResourceName() ~= r then return end TriggerEvent("jim-notepad:Client:SyncNotes") end)

RegisterNetEvent("jim-notepad:Client:SyncNotes", function(newNotes)
	if not newNotes then
		local p = promise.new()
		QBCore.Functions.TriggerCallback('jim-notepad:Server:SyncNotes', function(cb) p:resolve(cb) end)
		Notes = Citizen.Await(p)
	else Notes = newNotes end
	for k, v in pairs(Notes) do
		if not Props[k] and Notes[k] then
			Props[k] = makeProp({prop = `prop_amanda_note_01b`, coords = vector4(v.coords.x, v.coords.y, v.coords.z+0.07, v.coords.w)}, 1, 0)
			Targets[k] =
				exports['qb-target']:AddCircleZone(k, vector3(v.coords.x, v.coords.y, v.coords.z-1.1), 0.5, { name=k, debugPoly=Config.Debug, useZ=true, },
				{ options = { { type = "server", event = "jim-notepad:Server:ReadNote", icon = "fas fa-receipt", label = Loc[Config.Lan].targetinfo["read"], noteid = k, }, },
						distance = 1.5 })
		end
	end
	for k in pairs(Props) do if not Notes[k] then exports["qb-target"]:RemoveZone(k) destroyProp(Props[k]) end end
end)

RegisterNetEvent("jim-notepad:Client:CreateNote", function()
	TriggerEvent('animations:client:EmoteCommandStart', {"notepad"})
	local dialog = exports['qb-input']:ShowInput({
        header = Loc[Config.Lan].menu["make_a_note"],
        submitText = "Drop",
        inputs = {
			{ text = Loc[Config.Lan].text["enter_message"], name = "note", type = "text", isRequired = true, },
			{ text = "", name = "checkbox", type = "checkbox",
				options = {
					{ value = "isImage", text = "Image" },
					{ value = "isAnon", text = "Anonymous" },
				},
			},
		},
    })
    if dialog.note ~= nil then
		local c = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.6, 0.0)
		loadAnimDict("pickup_object")
		TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false)
		TriggerEvent('animations:client:EmoteCommandStart', {"c"})
		unloadAnimDict("pickup_object")
		if toBool(dialog.isImage) then dialog.image = "<img src='"..dialog.note.."' width=200px>" end
		Wait(900)
        TriggerServerEvent("jim-notepad:Server:CreateNote", {
			coords = vector4(c.x, c.y, c.z, GetEntityHeading(PlayerPedId())),
			message = dialog.note,
			anon = dialog.isAnon,
			image = dialog.image or nil,
		})
    end
end)

RegisterNetEvent("jim-notepad:Client:ReadNote", function(data)
	local notepad = {}
	notepad[#notepad+1] = { icon = "fas fa-receipt", isMenuHeader = true, header = Loc[Config.Lan].menu["message"], text = data.message }
	notepad[#notepad+1] = { icon = "fas fa-person", isMenuHeader = true, header = "", text = Loc[Config.Lan].menu["written_by"]..data.creator }
	notepad[#notepad+1] = { icon = "fas fa-hand-scissors", header = "", text = Loc[Config.Lan].menu["tear_up_note"], params = { event = "jim-notepad:Client:DestroyNote", args = data } }
	exports["qb-menu"]:openMenu(notepad)
end)

RegisterNetEvent("jim-notepad:Client:DestroyNote", function(data)
	loadAnimDict("pickup_object")
	TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false)
	unloadAnimDict("pickup_object")
	Wait(900)
	TriggerServerEvent("jim-notepad:Server:SyncEffect", data.coords)
	TriggerServerEvent("jim-notepad:Server:DestroyNote", data.id)
end)

RegisterNetEvent("jim-notepad:Client:SyncEffect", function(coords)
	UseParticleFxAssetNextCall("core")
	local dust = StartNetworkedParticleFxNonLoopedAtCoord("ent_sht_paper_bails", vector3(coords.x, coords.y, coords.z-1.03), 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0)
end)

AddEventHandler('onResourceStop', function(r) if r ~= GetCurrentResourceName() then return end
	for k in pairs(Targets) do exports["qb-target"]:RemoveZone(k) end
	for k in pairs(Props) do DeleteEntity(Props[k]) end
end)