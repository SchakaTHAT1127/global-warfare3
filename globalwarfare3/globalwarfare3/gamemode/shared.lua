DeriveGamemode("sandbox")
print("shared.lua yüklendi")

GM.Name = "Global Warfare 3"
GM.Author = "Alp Er Tunga"
-- this part is useful for some network things it makes them more basic
USA = 1
SGF = 2
--teams lie here
team.SetUp(USA, "North Atlantic Treaty Forces", Color(0, 33, 203))
team.SetUp(SGF, "Soviet Ground Forces", Color(223, 8, 8))

local precacheModels = {
	"models/olegun/ColdWarInfantry/coldwar_Woodland.mdl",
	"models/props/cs_militia/crate_extrasmallmill.mdl",
	"models/bratnik/soldier_aghanka.mdl",
	"models/weapons/w_pist_glock18.mdl",
	"models/weapons/w_eq_eholster_elite.mdl",
	"models/props_junk/Shoe001a.mdl",
	"models/props_c17/tools_wrench01a.mdl",
	"models/props_lab/box01a.mdl",
	"models/props/cs_office/trash_can_p5.mdl",
	"models/Items/357ammo.mdl",
	"models/Items/BoxSRounds.mdl",
	"models/Items/item_item_crate_chunk05.mdl",
	"models/gibs/wood_gib01c.mdl",
	"models/gibs/wood_gib01e.mdl",
	"models/gibs/wood_gib01b.mdl",
	"models/Items/item_item_crate_chunk08.mdl",
	"models/gibs/furniture_gibs/furniture_chair01a_gib02.mdl"
}

local precacheSounds = {
	"physics/cardboard/cardboard_box_break1.wav",
	"physics/cardboard/cardboard_box_break2.wav",
	"physics/cardboard/cardboard_box_break3.wav",
	"physics/cardboard/cardboard_box_impact_bullet1.wav",
	"physics/cardboard/cardboard_box_impact_bullet2.wav",
	"physics/cardboard/cardboard_box_impact_bullet3.wav",
	"physics/cardboard/cardboard_box_impact_bullet4.wav",
	"physics/cardboard/cardboard_box_impact_bullet5.wav"
}

function precacheLineUp()

	local finished = [[
ACB 1.0: Models are precached SUCCESFULLY
ACB 1.0: Sounds are precached SUCCESFULLY
	]]
	for _, models in ipairs(precacheModels) do
		util.PrecacheModel(models)
	end
	for _, sounds in ipairs(precacheSounds) do
		util.PrecacheModel(sounds)
	end
	print(finished)
end

precacheLineUp()