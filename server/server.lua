local QBCore = exports['qb-core']:GetCoreObject()
RegisterNetEvent('QBCore:Server:UpdateObject', function() if source ~= '' then return false end	QBCore = exports['qb-core']:GetCoreObject() end)

local Notes = {}

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
    PerformHttpRequest(discord['webhook'], function(err, text, headers) end, 'POST', json.encode({username = discord['name'], embeds = embed, avatar_url = discord['image']}), { ['Content-Type'] = 'application/json' })
end

QBCore.Functions.CreateUseableItem("notepad", function(source, item) TriggerClientEvent("jim-notepad:Client:CreateNote", source) end)

QBCore.Functions.CreateCallback('jim-notepad:Server:SyncNotes', function(source, cb) cb(Notes) end)

RegisterNetEvent("jim-notepad:Server:CreateNote", function(data)
	for k, v in pairs(data) do print(k, tostring(v)) end
	local charset = {
		"q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m",
		"Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M",
		"1","2","3","4","5","6","7","8","9","0"
	}
	local GeneratedID = ""
	for i = 1, 12 do GeneratedID = GeneratedID..charset[math.random(1, #charset)] end

	local creator = QBCore.Functions.GetPlayer(source).PlayerData.charinfo.firstname..' '..QBCore.Functions.GetPlayer(source).PlayerData.charinfo.lastname

	DiscordLog(creator, data.message, 14177041)

	if tostring(data.anon) == "true" then creator = "Anonymous" end

	Notes[GeneratedID] = {
		id = GeneratedID,
		coords = data.coords,
		message = data.image or data.message,
		creator = creator,
	}

	TriggerClientEvent("jim-notepad:Client:SyncNotes", -1, Notes)
end)
RegisterNetEvent("jim-notepad:Server:DestroyNote", function(data) Notes[data] = nil TriggerClientEvent("jim-notepad:Client:SyncNotes", -1, Notes) end)
RegisterNetEvent("jim-notepad:Server:ReadNote", function(data) local src = source TriggerClientEvent("jim-notepad:Client:ReadNote", src, Notes[data.noteid]) end)
RegisterNetEvent("jim-notepad:Server:SyncEffect", function(coords) TriggerClientEvent("jim-notepad:Client:SyncEffect", -1, coords) end)

local function CheckVersion()
	PerformHttpRequest('https://raw.githubusercontent.com/jimathy/jim-notepad/master/version.txt', function(err, newestVersion, headers)
		local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
		if not newestVersion then print("Currently unable to run a version check.") return end
		local advice = "^1You are currently running an outdated version^7, ^1please update^7"
		if newestVersion:gsub("%s+", "") == currentVersion:gsub("%s+", "") then advice = '^6You are running the latest version.^7'
		else print("^3Version Check^7: ^2Current^7: "..currentVersion.." ^2Latest^7: "..newestVersion) end
		print(advice)
	end)
end
CheckVersion()