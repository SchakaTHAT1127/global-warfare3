util.AddNetworkString("SendTeam")

local TakimModelleri = {
    [UKR] = "models/morpeh/ukraine_marine2010.mdl",
    [RUS] = "models/4ervo/ml_project/russian_soldier2012.mdl"
}
UKR = 1
RUS = 2
--[[
"istenentakim" is the team that the player wanted to be in 
"digertakim" is the other team
"finaltakim" is just the final team
]]
net.Receive("SendTeam", function(len, ply)
    local istenentakim = net.ReadUInt(2)
    local digertakim = (istenentakim == UKR) and RUS or UKR

    istenensayi = team.NumPlayers(istenentakim)
    digersayi = team.NumPlayers(digertakim)

    local finaltakim = istenentakim
    print(string.format("Oyuncu: %s | İstediği: %d | Atanan: %d", ply:Nick(), istenentakim, finaltakim))

    if istenensayi > digersayi then
        finaltakim = digertakim
        ply:ChatPrint("Takımlar dengelendiği için " .. team.GetName(digertakim) .. " takımına aktarıldınız.")
    elseif istenensayi < digersayi then
        finaltakim = istenentakim
        ply:ChatPrint(team.GetName(istenentakim) .. " takımına katıldınız.")
    elseif istenensayi == digersayi then
        finaltakim = istenentakim
        ply:ChatPrint(team.GetName(istenentakim) .. " takımına katıldınız.")
    end

    ply:SetTeam(finaltakim)
    
    local modelSeti = {
        [1] = "models/morpeh/ukraine_marine2010.mdl",
        [2] = "models/4ervo/ml_project/russian_soldier2012.mdl"
    }

    local model = modelSeti[finaltakim]

    if model then
        ply:SetModel(model)
    end

    hook.Add("PlayerSpawn", "ModelleriSetle", function(ply)
        --giving it 1 tick time cuz sometimes it wont work for being "too early"
        timer.Simple(0, function()
            ply:SetModel(model)
        end)
    end)


    print(string.format("Oyuncu: %s | İstediği: %d | Atanan: %d", ply:Nick(), istenentakim, finaltakim))
    --i put this 2 times to understand if the finaltakim thing worked
end)