I hope you have fun with this script and that it brings jobs and RP to your server

If you need support I now have a discord available, it helps me keep track of issues and give better support.

https://discord.gg/xKgQZ6wZvS

# Jim-NotePad

## What Is it?
Simple notepad script

Allows players to place notes on the ground as crumpled pieces of paper (the prop) and other players can view them

Good for leaving info behind, eg for people roleplaying serial killers or whatever, or just telling people they need to do something

The notes will also be removed at server/script restart

## Dependencies
- [`jim_bridge`](https://github.com/jimathy/jim_bridge) - https://github.com/jimathy/jim_bridge

https://streamable.com/pt3e0n

## Install

### QB:
- Add the script to your resources eg. `resources/[jim]`
- Add this to your server.cfg: `ensure jim-notepad`
- Add the images to you inventory script eg `[qb]/qb-inventory/html/images`
- Add the item to your core eg. `[qb]/qb-core/shared/items.lua`
```lua
notepad = { name = "notepad", label = "Notepad", weight = 100, type = "item", image = "notepad.png", unique = false, useable = false, shouldClose = true, combinable = nil, description = "A pad of blank notes" },
```

### OX:
- Add the script to your resources eg. `resources/[jim]`
- Add this to your server.cfg: `ensure jim-notepad`
- Add the images to you inventory script eg `[ox]/ox_inventory/web/images`
- Add the item to your inventory eg. `[ox]/ox_inventory/data/items.lua`
```lua
["notepad"] = {
	label = "Notepad",
	weight = 100,
	stack = true,
	close = true,
	description = "A pad of blank notes",
	client = {
		image = "notepad.png",
		event = "jim-notepad:Client:CreateNote"
	}
},
```

## ChangeLog

### v2.0
	- Updated to use `jim_bridge` allowing for better support for other scripts/frameworks
	- Changed around the create note function
		- Remove the image option as the notes now accepts text and url then extracts that url to make
		- It takes the url as well as the text to show them separately in the "show note" part
	- Added options to enable a /command so players can type /notepad instead of having the item
	- Added option to disable the createUsableItem function from making notepad usable
	- Better support for ox_lib menus
	- Paper prop forced to be slightly larger to be more visible