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

--precache for optimization etc.
util.PrecacheModel("models/olegun/ColdWarInfantry/coldwar_Woodland.mdl")
util.PrecacheModel("models/bratnik/soldier_aghanka.mdl")

