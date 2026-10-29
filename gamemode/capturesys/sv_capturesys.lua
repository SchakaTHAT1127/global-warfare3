if sv_teamelimination:GetInt() == 1 then
else
    AddCSLuaFile("cl_capturesys.lua")
    ModeKurelerTablesi = {
        ["wid_peremen"] = {
            Kureler = {
                ["TokiKure"]   = { pos = Vector(-200.405151, 3079.191406, 83.725899), radius = 1200, color = Color(255, 255, 255), controlledByTeam = 1001, ukraineCapPoint = 0, rusCapPoint = 0, flag = "gamemodes/globalwarfare3/materials/unknown.png", kureOyuncuSayisiUKR = 0, kureOyuncuSayisiRUS = 0, ticketverenUKR = 0, ticketvermeSuresiUKR = 0, ticketverenRUS = 0, ticketvermeSuresiRUS = 0},
                ["YorukKure"]  = { pos = Vector(2551.250000, -6756.968750, -550.031250), radius = 1200, color = Color(255, 255, 255), controlledByTeam = 1001, ukraineCapPoint = 0, rusCapPoint = 0, flag = "gamemodes/globalwarfare3/materials/unknown.png", kureOyuncuSayisiUKR = 0, kureOyuncuSayisiRUS = 0, ticketverenUKR = 0, ticketvermeSuresiUKR = 0, ticketverenRUS = 0, ticketvermeSuresiRUS = 0 },
                ["KasabaKure"] = { pos = Vector(11523.310547, 2078.165771, -159.64688), radius = 2000, color = Color(255, 255, 255), controlledByTeam = 1001, ukraineCapPoint = 0, rusCapPoint = 0, flag = "gamemodes/globalwarfare3/materials/unknown.png", kureOyuncuSayisiUKR = 0, kureOyuncuSayisiRUS = 0, ticketverenUKR = 0, ticketvermeSuresiUKR = 0, ticketverenRUS = 0, ticketvermeSuresiRUS = 0 },
                ["ukraynaKoy"]     = { pos = Vector(-7807.058105, 10200.379883, -530.01007), radius = 1000, color = Color(255, 255, 255), controlledByTeam = 1001, ukraineCapPoint = 0, rusCapPoint = 0, flag = "gamemodes/globalwarfare3/materials/unknown.png", kureOyuncuSayisiUKR = 0, kureOyuncuSayisiRUS = 0, ticketverenUKR = 0, ticketvermeSuresiUKR = 0, ticketverenRUS = 0, ticketvermeSuresiRUS = 0 }
            }
        },
        ["prm_hrabske"] = {
            Kureler = {
                ["AmkKoy"] = { pos = Vector(-3807.058105, 1200.379883, 330.01007), radius = 550, color = Color(255, 255, 255), controlledByTeam = 1001, ukraineCapPoint = 0, rusCapPoint = 0, flag = "gamemodes/globalwarfare3/materials/unknown.png", kureOyuncuSayisiUKR = 0, kureOyuncuSayisiRUS = 0, ticketverenUKR = 0, ticketvermeSuresiUKR = 0, ticketverenRUS = 0, ticketvermeSuresiRUS = 0}
            }
        }
    }

    local SunucuMapi = game.GetMap()
    aktifKureler = ModeKurelerTablesi[SunucuMapi] and ModeKurelerTablesi[SunucuMapi].Kureler or {}
    local isim = nil
    local UKR = UKR or 1
    local RUS = RUS or 2

    util.AddNetworkString("alertServerKureler")
    util.AddNetworkString("sunucuIceriOyuncuGirdi")
    util.AddNetworkString("sunucuIceriOyuncuCikti")
    util.AddNetworkString("updateClientKureData")

    local function cift(num)
        return num % 2 == 0
    end

    net.Receive("alertServerKureler", function(len, ply)
        isim = net.ReadString()
        local plyTeam = net.ReadInt(16)

        local kure = aktifKureler[isim]
        local ukrOyuncu = kure.kureOyuncuSayisiUKR
        local rusOyuncu = kure.kureOyuncuSayisiRUS
        local ukrPointGiver = 1
        local rusPointGiver = 1

        ukrPointGiver = math.ceil(ukrOyuncu / 2)
        print("UKR OYUNCU SAYISI: " .. ukrOyuncu .. " UKR POINT KATSAYISI: " .. ukrPointGiver)

        rusPointGiver = math.ceil(rusOyuncu / 2)
        print("RUS OYUNCU SAYISI: " .. rusOyuncu .. " RUS POINT KATSAYISI: " .. rusPointGiver)

        if not kure then return end

        if plyTeam == UKR then
            if kure.rusCapPoint <= 0 then
                kure.ukraineCapPoint = math.min(kure.ukraineCapPoint + ukrPointGiver, 200)
            elseif kure.rusCapPoint > 0 then
                kure.rusCapPoint = kure.rusCapPoint - ukrPointGiver
            end
        elseif plyTeam == RUS then
            if kure.ukraineCapPoint <= 0 then
                kure.rusCapPoint = math.min(kure.rusCapPoint + rusPointGiver, 200)
            elseif kure.ukraineCapPoint > 0 then
                kure.ukraineCapPoint = kure.ukraineCapPoint - rusPointGiver
            end
        end
    end)

    net.Receive("sunucuIceriOyuncuGirdi", function()
        local sayiGirdi = net.ReadInt(3)
        local plyTeam = net.ReadInt(16)
        local kure = aktifKureler[isim]

        local function ukrEkle()
            kure.kureOyuncuSayisiUKR = math.max(0, kure.kureOyuncuSayisiUKR + sayiGirdi)
            print(kure.kureOyuncuSayisiUKR)
        end

        local function rusEkle()
            kure.kureOyuncuSayisiRUS = math.max(0, kure.kureOyuncuSayisiRUS + sayiGirdi)
            print(kure.kureOyuncuSayisiRUS)
        end

        local tabloEkleyici = {
            [1] = ukrEkle,
            [2] = rusEkle
        }

        if tabloEkleyici[plyTeam] then
            tabloEkleyici[plyTeam]()
        end
    end)

    net.Receive("sunucuIceriOyuncuCikti", function()
        local sayiCikti = net.ReadInt(3)
        local plyTeam = net.ReadInt(16)
        local kure = aktifKureler[isim]

        local function ukrCikar()
            kure.kureOyuncuSayisiUKR = math.max(0, kure.kureOyuncuSayisiUKR + sayiCikti)
            print(kure.kureOyuncuSayisiUKR)
        end

        local function rusCikar()
            kure.kureOyuncuSayisiRUS = math.max(0, kure.kureOyuncuSayisiRUS + sayiCikti)
            print(kure.kureOyuncuSayisiRUS)
        end

        local tabloEkleyici = {
            [1] = ukrCikar,
            [2] = rusCikar
        }

        if tabloEkleyici[plyTeam] then
            tabloEkleyici[plyTeam]()
        end
    end)

    local nextCheck = 0

    local nextCheck = 0

    hook.Add("Think", "controlledByTeamModifier", function()
        if CurTime() < nextCheck then return end
        nextCheck = CurTime() + 0.2 -- 0.2 saniyede bir çalışır

        for isim2, kure in pairs(aktifKureler) do
            local oldFlag = kure.flag
            local ukrOyuncu = kure.kureOyuncuSayisiUKR
            local rusOyuncu = kure.kureOyuncuSayisiRUS

            -- =========================================================
            -- UKRAYNA ELE GEÇİRME/KONTROL MANTIĞI
            -- =========================================================
            if kure.ukraineCapPoint == 200 then
                kure.flag = "gamemodes/globalwarfare3/materials/ukraineflag.png"

                -- SADECE KONTROL İLK DEFA UKRAYNA'YA GEÇTİĞİNDE BONUS TICKET VER
                if kure.controlledByTeam ~= UKR then
                    if sv_conquest:GetInt() == 1 then
                        if kure.controlledByTeam == RUS then
                            UKRticket = UKRticket + 30
                            RUSticket = RUSticket - 20
                        else
                            UKRticket = UKRticket + 20
                        end
                    elseif sv_resourcecontrol:GetInt() == 1 then
                        if kure.controlledByTeam == RUS then
                            UKRticket = UKRticket + 35
                            RUSticket = RUSticket - 45
                        else
                            UKRticket = UKRticket + 70
                        end
                    end

                    team.SetScore(1, UKRticket)
                    team.SetScore(2, RUSticket)
                    
                    -- Yeni alan ele geçirildiği için periyodik süreci sıfırla
                    kure.ticketvermeSuresiUKR = 0
                    kure.controlledByTeam = UKR
                end

                -- PERİYODİK TİCKET SİSTEMİ (Resource Control modu için)
                -- Zaten UKR kontrolündeyse her döngüde zamanlayıcıyı ilerletir
                if sv_resourcecontrol:GetInt() == 1 then
                    kure.ticketverenUKR = math.ceil(ukrOyuncu / 2)
                    kure.ticketvermeSuresiUKR = (kure.ticketvermeSuresiUKR or 0) + 1

                    -- 60 döngü = 12 saniye (0.2s * 60)
                    if kure.ticketvermeSuresiUKR >= 60 then
                        UKRticket = UKRticket + kure.ticketverenUKR
                        team.SetScore(1, UKRticket)
                        kure.ticketvermeSuresiUKR = 0
                    end
                end

            -- =========================================================
            -- RUSYA ELE GEÇİRME/KONTROL MANTIĞI
            -- =========================================================
            elseif kure.rusCapPoint == 200 then
                kure.flag = "gamemodes/globalwarfare3/materials/russiaflag.png"

                -- SADECE KONTROL İLK DEFA RUSYA'YA GEÇTİĞİNDE BONUS TICKET VER
                if kure.controlledByTeam ~= RUS then
                    if sv_conquest:GetInt() == 1 then
                        if kure.controlledByTeam == UKR then
                            UKRticket = UKRticket - 20
                            RUSticket = RUSticket + 30
                        else
                            RUSticket = RUSticket + 20
                        end
                    elseif sv_resourcecontrol:GetInt() == 1 then
                        if kure.controlledByTeam == UKR then
                            UKRticket = UKRticket - 45
                            RUSticket = RUSticket + 35
                        else
                            RUSticket = RUSticket + 70
                        end
                    end

                    team.SetScore(1, UKRticket)
                    team.SetScore(2, RUSticket)

                    -- Yeni alan ele geçirildiği için periyodik süreci sıfırla
                    kure.ticketvermeSuresiRUS = 0
                    kure.controlledByTeam = RUS
                end

                if sv_resourcecontrol:GetInt() == 1 then
                    kure.ticketverenRUS = math.ceil(rusOyuncu / 2)
                    kure.ticketvermeSuresiRUS = (kure.ticketvermeSuresiRUS or 0) + 1

                    if kure.ticketvermeSuresiRUS >= 60 then
                        RUSticket = RUSticket + kure.ticketverenRUS
                        team.SetScore(2, RUSticket)
                        kure.ticketvermeSuresiRUS = 0
                    end
                end
            elseif kure.rusCapPoint == 0 and kure.ukraineCapPoint == 0 then
                kure.flag = "gamemodes/globalwarfare3/materials/unknown.png"
                kure.ticketvermeSuresiUKR = 0
                kure.ticketvermeSuresiRUS = 0
            end

            -- Tüm oyunculara güncel küre durumunu gönder
            net.Start("updateClientKureData")
                net.WriteString(isim2)
                net.WriteString(kure.flag)
                net.WriteInt(kure.controlledByTeam, 16)
                net.WriteInt(kure.ukraineCapPoint, 16)
                net.WriteInt(kure.rusCapPoint, 16)
                net.WriteInt(kure.kureOyuncuSayisiUKR, 7)
                net.WriteInt(kure.kureOyuncuSayisiRUS, 7)
            net.Broadcast()
        end
    end)
end