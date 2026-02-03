include("shared.lua")
include("vgui/cl_menu.lua")
include("vgui/cl_teampanel.lua")

-- These are some usefull presets i made back in the day always usefull dont delete

surface.CreateFont( "MenuSelectHud", {
	font = "Arial",
	extended = false,
	size = 23,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = true,
	outline = false,
} )

surface.CreateFont( "MenuSelectHud2", {
	font = "Arial",
	extended = false,
	size = 24,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = true,
	outline = false,
} )

surface.CreateFont( "LoadSelectHud", {
	font = "Arial",
	extended = false,
	size = 2,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = true,
	outline = false,
} )

surface.CreateFont( "BigLoadSelectHud", {
	font = "CreditsOutroText",
	extended = false,
	size = 30,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = true,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = true,
	outline = true,
} )
