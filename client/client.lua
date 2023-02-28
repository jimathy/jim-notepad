local QBCore = exports['qb-core']:GetCoreObject()
RegisterNetEvent('QBCore:Client:UpdateObject', function() QBCore = exports['qb-core']:GetCoreObject() end)

local Props, Targets, Notes = {}, {}, {}

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
			Props[k] = makeProp({prop = `prop_amanda_note_01b`, coords = vec4(v.coords.x, v.coords.y, v.coords.z+0.07, v.coords.w)}, 1, 0)
			Targets[k] =
				exports['qb-target']:AddCircleZone(k, vec3(v.coords.x, v.coords.y, v.coords.z-1.1), 0.5, { name=k, debugPoly=Config.Debug, useZ=true, },
				{ options = { { type = "server", event = "jim-notepad:Server:ReadNote", icon = "fas fa-receipt", label = Loc[Config.Lan].targetinfo["read"], noteid = k, }, },
						distance = 1.5 })
		end
	end
	for k in pairs(Props) do if not Notes[k] then exports["qb-target"]:RemoveZone(k) destroyProp(Props[k]) end end
end)

RegisterNetEvent("jim-notepad:Client:CreateNote", function()
	ExecuteCommand("e notepad")
	local dialog = nil
	if Config.Menu == "ox" then
		dialog = exports.ox_lib:inputDialog(Loc[Config.Lan].menu["make_a_note"], {
			{ type = 'input', label = "", placeholder = Loc[Config.Lan].text["enter_message"] },
			{ type = 'checkbox', label = "Image" },
			{ type = 'checkbox', label = "Anonymous" },
		})
		print(json.encode(dialog))
	else
		dialog = exports['qb-input']:ShowInput({
			header = Loc[Config.Lan].menu["make_a_note"],
			submitText = "Drop",
			inputs = {
				{ text = Loc[Config.Lan].text["enter_message"], name = "note", type = "text", isRequired = true, },
				{ text = "", name = "checkbox", type = "checkbox",
					options = {	{ value = "isImage", text = "Image" },	{ value = "isAnon", text = "Anonymous" }, },
				},
			},
		})
	end
    if dialog.note or dialog[1] then
		local c = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.6, 0.0)
		loadAnimDict("pickup_object")
		TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false)
		ExecuteCommand("e c")
		unloadAnimDict("pickup_object")
		if toBool(dialog.isImage) or toBool(dialog[2]) then if Config.Menu == "ox" then dialog.image = "![test]("..dialog[1]..")" else dialog.image = "<img src='"..dialog.note.."' width=200px>" end end
		Wait(900)
        TriggerServerEvent("jim-notepad:Server:CreateNote", {
			coords = vec4(c.x, c.y, c.z, GetEntityHeading(PlayerPedId())),
			message = dialog.note or dialog[1],
			anon = dialog.isAnon or dialog[3],
			image = dialog.image or nil,
		})
    end
end)

RegisterNetEvent("jim-notepad:Client:ReadNote", function(data)
	local notepad = {}
	notepad[#notepad+1] = {
		icon = "fas fa-receipt",
		isMenuHeader = true,
		header = Loc[Config.Lan].menu["message"], text = data.message,
		title = Loc[Config.Lan].menu["message"], description = data.message
	}
	notepad[#notepad+1] = {
		icon = "fas fa-person",
		isMenuHeader = true,
		header = "", text = Loc[Config.Lan].menu["written_by"]..data.creator,
		title = Loc[Config.Lan].menu["written_by"]..data.creator
	}
	notepad[#notepad+1] = {
		icon = "fas fa-hand-scissors",
		header = "", text = Loc[Config.Lan].menu["tear_up_note"],
		title = Loc[Config.Lan].menu["tear_up_note"],
		event = "jim-notepad:Client:DestroyNote", args = data,
		params = { event = "jim-notepad:Client:DestroyNote", args = data }
	}
	if Config.Menu == "ox" then
		exports.ox_lib:registerContext({id = 'notepad', title = "Note", position = 'top-right', options = notepad })
		exports.ox_lib:showContext("notepad")
	elseif Config.Menu == "qb" then
		exports['qb-menu']:openMenu(notepad)
	end
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
	local dust = StartNetworkedParticleFxNonLoopedAtCoord("ent_sht_paper_bails", vec3(coords.x, coords.y, coords.z-1.03), 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0)
end)

AddEventHandler('onResourceStop', function(r) if r ~= GetCurrentResourceName() then return end
	if GetResourceState("qb-target") == "started" or GetResourceState("ox_target") == "started" then
		for k in pairs(Targets) do exports["qb-target"]:RemoveZone(k) end
		for k in pairs(Props) do DeleteEntity(Props[k]) end
	end
end)