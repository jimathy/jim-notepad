local cachedNotes = {}

onResourceStart(function()

	if Config.General.command then
		registerCommand("notepad", {
			"Make a note",
			{}, false,
			function(source, args)
				TriggerClientEvent("jim-notepad:Client:CreateNote", source)
			end,
			nil,
		})
	end

	if Config.General.usableItem then
		createUseableItem("notepad", function(source, item)
			TriggerClientEvent("jim-notepad:Client:CreateNote", source)
		end)
	end

	createCallback('jim-notepad:Server:SyncNotes', function(source)
		return cachedNotes
	end)

end, true)

RegisterNetEvent("jim-notepad:Server:CreateNote", function(data)
	local GeneratedID = keyGen()..keyGen()

	local creator = getPlayer(source).name

	DiscordLog(creator, data.message, 14177041)

	if tostring(data.anon) == "true" then creator = "Anonymous" end

	cachedNotes[GeneratedID] = {
		id = GeneratedID,
		coords = data.coords,
		message = data.message,
		image = data.image or nil,
		creator = creator,
	}

	TriggerClientEvent("jim-notepad:Client:SyncNotes", -1, cachedNotes)
end)

RegisterNetEvent("jim-notepad:Server:DestroyNote", function(data)
	cachedNotes[data] = nil
	TriggerClientEvent("jim-notepad:Client:SyncNotes", -1, cachedNotes)
end)

RegisterNetEvent("jim-notepad:Server:ReadNote", function(data)
	local src = source
	TriggerClientEvent("jim-notepad:Client:ReadNote", src, cachedNotes[data.noteid])
end)

RegisterNetEvent("jim-notepad:Server:SyncEffect", function(coords)
	TriggerClientEvent("jim-notepad:Client:SyncEffect", -1, coords)
end)

discord = {
    ['webhook'] = "",
    ['name'] = 'Notepad',
    ['image'] = "https://i.imgur.com/G3jeSZv.png"
}

function DiscordLog(name, message, color)
    local embed = {
        {
            ["color"] = 04255,
            ["title"] = "**Note Dropped:**",
            ["description"] = message,
            ["url"] = "",
            ["footer"] = {
            ["text"] = "Dropped by: "..name,
            ["icon_url"] = ""
        },
            ["thumbnail"] = {
                ["url"] = "",
            },
		}
	}
    PerformHttpRequest(discord['webhook'], function(err, text, headers) end,
		'POST',
		json.encode({
			username = discord['name'],
			embeds = embed,
			avatar_url = discord['image']
		}), {
			['Content-Type'] = 'application/json'
		})
end
