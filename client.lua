local Props, Targets, Notes = {}, {}, {}

onPlayerLoaded(function()
	TriggerEvent("jim-notepad:Client:SyncNotes")
end, true)

RegisterNetEvent("jim-notepad:Client:SyncNotes", function(newNotes)
	if not newNotes then
		Notes = triggerCallback("jim-notepad:Server:SyncNotes")

	else
		Notes = newNotes
	end

	for k, v in pairs(Notes) do

		if not Props[k] and Notes[k] then
			Props[k] = makeProp({prop = "prop_amanda_note_01b", coords = vec4(v.coords.x, v.coords.y, v.coords.z+0.07, v.coords.w)}, true, false)

			-- Make the paper prop larder so easier to see
			SetEntityScale(Props[k], 1.5)

			Targets[k] =
				createCircleTarget({k, vec3(v.coords.x, v.coords.y, v.coords.z-1.1), 0.5, {name = k, debugPoly = debugMode, useZ = true}}, {
					{
						icon = "fas fa-receipt",
						label = Loc[Config.Lan].targetinfo["read"],
						action = function()
							TriggerServerEvent("jim-notepad:Server:ReadNote", { noteid = k })
						end,
					}
				}, 1.5)
		end
	end
	for k in pairs(Props) do
		if not Notes[k] then
			removeZoneTarget(Targets[k])
			destroyProp(Props[k])
		end
	end
end)

RegisterNetEvent("jim-notepad:Client:CreateNote", function()
    local Ped = PlayerPedId()
    ExecuteCommand("e notepad")

    local dialog = createInput(Loc[Config.Lan].menu["make_a_note"], {
        { text = Loc[Config.Lan].text["enter_message"], name = "note", type = "text", isRequired = true },
        { text = "test", name = "checkbox", type = "checkbox",
            options = { { value = "isAnon", text = "Anonymous", } }
        },
    })

    if dialog then

		local text = dialog.note or dialog[1]
        local image

        -- Extract image URL if present
        local url = text:match("(https?://%S+)")
        if url then
			-- Remove the URL from the image
            text = text:gsub("([Hh][Tt][Tt][Pp][Ss]?://%S+)", "")
			-- Convert to an image the menu's can read

			if Config.System.Menu == "ox" then
				image = '!['..''.. ']('..url..')'
			else
				image = "<img src='"..url.."' width=250px>"
			end
        end

        local c = GetOffsetFromEntityInWorldCoords(Ped, 0.0, 0.6, 0.0)
        playAnim("pickup_object", "pickup_low", -1, 0)
		ExecuteCommand("e c")
        Wait(900)
        TriggerServerEvent("jim-notepad:Server:CreateNote", {
            coords = vec4(c.x, c.y, c.z, GetEntityHeading(Ped)),
            message = text,
            anon = dialog.isAnon or dialog[2],
            image = image or nil -- Pass image separately
        })
    end
end)

RegisterNetEvent("jim-notepad:Client:ReadNote", function(data)
	local notepad = {}
	notepad[#notepad+1] = {
		icon = "fas fa-receipt",
		isMenuHeader = true,
		header = Loc[Config.Lan].menu["message"],
		txt = data.message,
	}
	if data.image then
		notepad[#notepad+1] = {
			isMenuHeader = true,
			header = Config.System.Menu == "ox" and data.image or "", text = data.image,
		}
	end
	notepad[#notepad+1] = {
		icon = "fas fa-person",
		isMenuHeader = true,
		header = "",
		txt = Loc[Config.Lan].menu["written_by"]..data.creator,
	}
	notepad[#notepad+1] = {
		icon = "fas fa-hand-scissors",
		header = "",
		txt = Loc[Config.Lan].menu["tear_up_note"],
		onSelect = function()
			playAnim("pickup_object", "pickup_low", -1, 0)
			Wait(900)
			TriggerServerEvent("jim-notepad:Server:SyncEffect", data.coords)
			TriggerServerEvent("jim-notepad:Server:DestroyNote", data.id)
		end
	}
	openMenu(notepad, { header = "Note", canClose = true })
end)

RegisterNetEvent("jim-notepad:Client:SyncEffect", function(coords)
	UseParticleFxAssetNextCall("core")
	local dust = StartNetworkedParticleFxNonLoopedAtCoord("ent_sht_paper_bails", vec3(coords.x, coords.y, coords.z-1.03), 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0)
end)