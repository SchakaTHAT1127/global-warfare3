DeriveGamemode("sandbox")
print("shared.lua yüklendi")

GM.Name = "Global Warfare 3"
GM.Author = "Alp Er Tunga"

--Bunu yazaraktan basit bir şekilde tüm takımları tek bir rakama sığdırıyorum
-- bu sayede bazı durumlarda işim daha kolaylaşıyor
UKR = 1
RUS = 2

--Takımları ayarlıyoruz
team.SetUp(UKR, "Ukrainian Ground Forces", Color(0, 33, 203))
team.SetUp(RUS, "Russian Ground Forces", Color(223, 8, 8))


--[[ Test için yazdığımı hatırlıyorum, düzeltebilirim
CreateConVar("ukrainetruckamount", "5", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("ukrainetruckcooldown", "30", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY)

CreateConVar("ukrainecaramount", "10", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("ukrainecarcooldown", "15", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY)

CreateConVar("ukraineapcamount", "2", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY)
CreateConVar("ukraineapccooldown", "60", FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_NOTIFY)
]]

--Modelleri ve sesleri precacheliyoruz, daha hızlı yüklensinler diye
local precacheModels = {
	"models/morpeh/ukraine_marine2010.mdl",
	"models/4ervo/ml_project/russian_soldier2012.mdl",
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

-- Yukardaki tabloların içindekilerini sırayla cacheliyoz
function precacheLineUp()
	for _, models in ipairs(precacheModels) do
		util.PrecacheModel(models)
	end
	for _, sounds in ipairs(precacheSounds) do
		util.PrecacheModel(sounds)
	end
end

--Fonksiyonu çağırıyozki cachlensin
precacheLineUp()