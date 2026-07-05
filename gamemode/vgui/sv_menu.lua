util.AddNetworkString("SendTeam")
--cl_teampanel'den gelen takım değişme network isteği

--kendini açıklıyor
local TakimModelleri = {
    [UKR] = "models/morpeh/ukraine_marine2010.mdl",
    [RUS] = "models/4ervo/ml_project/russian_soldier2012.mdl"
}

--[[
"istenentakim" is the team that the player wanted to be in 
"digertakim" is the other team
"finaltakim" is just the final team
]]

net.Receive("SendTeam", function(len, ply) -- takım değişme isteğini kaptık
    local istenentakim = net.ReadUInt(2) --istenen takım, 1(ukr) veya 2(rus)

    --[["Eğer istenentakim değişkeni UKR (Ukrayna) ise, local digertakim değişkenine RUS (Rusya) değerini ata.
    Eğer istenentakim değişkeni UKR değilse (yani başka bir şeyse), o zaman UKR değerini ata."

    SATIR SATIR;
    local digertakim

    if istenentakim == UKR then
        digertakim = RUS
    else
        digertakim = UKR
    end
    ]]

    local digertakim = (istenentakim == UKR) and RUS or UKR 

    istenentakimsayi = team.NumPlayers(istenentakim) -- oyuncunun istediği takımın sayısı
    digertakimsayi = team.NumPlayers(digertakim) -- diğer takımın sayısı

    local finaltakim = istenentakim -- final karar takımını istenen takıma veriyor nolur nolmaz diye öylesine
    print(string.format("Oyuncu: %s | İstediği: %d | Atanan: %d", ply:Nick(), istenentakim, finaltakim))

    if istenentakimsayi > digertakimsayi then -- istenen takımda fazla oyuncu varsa öbür takıma atıyor
        finaltakim = digertakim
        ply:ChatPrint("Takımlar dengelendiği için " .. team.GetName(digertakim) .. " takımına aktarıldınız.")

    elseif istenentakimsayi < digertakimsayi then -- istenen takımda boş yer varsa istenen takıma atıyor
        finaltakim = istenentakim
        ply:ChatPrint(team.GetName(istenentakim) .. " takımına katıldınız.")

    elseif istenentakimsayi == digertakimsayi then -- istenen takımda boş yer varsa istenen takıma atıyor
        finaltakim = istenentakim
        ply:ChatPrint(team.GetName(istenentakim) .. " takımına katıldınız.")
    end

    ply:SetTeam(finaltakim) -- Oyuncunun takımını final seçilen takım yapıyoz
    
    local modelSeti = {
        [1] = "models/morpeh/ukraine_marine2010.mdl",
        [2] = "models/4ervo/ml_project/russian_soldier2012.mdl"
    }

    local model = modelSeti[finaltakim] -- Oyuncunun takımına göre model ayarlıyoruz

    if model then
        ply:SetModel(model)
    end

    hook.Add("PlayerSpawn", "ModelleriSetle", function(ply)
        --giving it 1 tick time cuz sometimes it wont work for being "too early"
        timer.Simple(0, function()
            ply:SetModel(model)
        end)
    end)
end)