local respawnTime = 5 * 60 -- Čas pro respawn v sekundách (5 minut)
local isDead = false
local timeLeft = respawnTime
local respawnCoords = vector3(200.0, 200.0, 20.0) -- Souřadnice pro respawn (EMS)

-- Funkce pro vykreslení deadscreenu
function DrawDeadScreen()
    -- Zobrazení pozadí pro odpočet
    DrawRect(0.5, 0.45, 0.2, 0.12, 0, 0, 0, 150) -- menší černé průhledné pozadí pro odpočet

    -- Nastavení textového stylu pro odpočet
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(0.6, 0.6) -- menší velikost textu
    SetTextColour(255, 0, 0, 255) -- červená barva
    SetTextCentre(true)

    -- Zobraz odpočet uprostřed obrazovky
    SetTextEntry("STRING")
    AddTextComponentString("Respawn za " .. math.floor(timeLeft / 60) .. " minut a " .. (timeLeft % 60) .. " sekund")
    DrawText(0.5, 0.42)

    -- Zobrazení textu "Stiskni G pro zavolání pomoci"
    SetTextScale(0.5, 0.5) -- menší velikost textu
    SetTextEntry("STRING")
    AddTextComponentString("Stiskni G pro zavolání pomoci")
    DrawText(0.5, 0.55)

    -- Pokud je čas na respawn, zobraz "Stiskni E"
    if timeLeft <= 0 then
        -- Zobrazení textu "Stiskni E pro respawn"
        SetTextScale(0.5, 0.5) -- menší velikost textu
        SetTextEntry("STRING")
        AddTextComponentString("Stiskni E pro respawn")
        DrawText(0.5, 0.65)
    end
end

-- Funkce pro respawn hráče
function RespawnPlayer()
    -- Respawn hráče na souřadnicích
    SetEntityCoords(PlayerPedId(), respawnCoords.x, respawnCoords.y, respawnCoords.z)
    -- Reset životů a zbroje
    NetworkResurrectLocalPlayer(respawnCoords.x, respawnCoords.y, respawnCoords.z, 0.0, true, false)
    SetEntityHealth(PlayerPedId(), 200)
    SetPedArmour(PlayerPedId(), 100)
    ClearPedTasksImmediately(PlayerPedId())
    isDead = false
    timeLeft = respawnTime
end

-- Funkce pro oživení hráče podle ID a zrušení cooldownu
function RevivePlayer(targetId, adminName)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
    if DoesEntityExist(targetPed) then
        -- Oživení hráče na aktuálních souřadnicích
        local coords = GetEntityCoords(targetPed)
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, 0.0, true, false)
        SetEntityHealth(targetPed, 200)
        SetPedArmour(targetPed, 100)
        ClearPedTasksImmediately(targetPed)

        -- Pokud oživujeme sebe, resetujeme isDead a cooldown
        if targetPed == PlayerPedId() then
            isDead = false
            timeLeft = respawnTime
        end

        -- Notifikace pro admina a oživeného hráče pomocí ox_lib
        lib.notify({
            title = 'Admin',
            description = 'Hráč byl oživen.',
            type = 'success'
        })
        lib.notify({
            title = 'Admin',
            description = 'Oživil jsi hráče.',
            type = 'success'
        })
        lib.notify({
            title = 'Oživení',
            description = 'Byl jsi oživen adminem ' .. adminName,
            type = 'info'
        })
    else
        lib.notify({
            title = 'Chyba',
            description = 'Hráč s tímto ID nebyl nalezen.',
            type = 'error'
        })
    end
end

-- Hlavní smyčka pro detekci smrti a odpočtu
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()

        -- Pokud je hráč mrtvý
        if IsEntityDead(playerPed) and not isDead then
            isDead = true
            timeLeft = respawnTime

            -- Spustit odpočet
            Citizen.CreateThread(function()
                while isDead do
                    Citizen.Wait(1000) -- Každou sekundu snížíme čas
                    timeLeft = timeLeft - 1

                    -- Pokud hráč stiskne G, nic se zatím nestane (volání pomoci)
                    if IsControlJustPressed(0, 47) then -- Klávesa G
                        -- Zatím žádná akce
                    end

                    -- Pokud čas dojde na nulu a hráč stiskne E, respawn
                    if timeLeft <= 0 then
                        if IsControlJustPressed(0, 38) then -- Klávesa E
                            RespawnPlayer()
                        end
                    end
                end
            end)
        end

        -- Pokud je hráč mrtvý, vykresli deadscreen
        if isDead then
            DrawDeadScreen()
        end
    end
end)

-- Registrace příkazu /revive [id hráče]
RegisterCommand("revive", function(source, args)
    if args[1] then
        local targetId = tonumber(args[1])
        if targetId then
            local adminName = GetPlayerName(PlayerId()) -- Získání jména admina
            RevivePlayer(targetId, adminName)
        else
            lib.notify({
                title = 'Chyba',
                description = 'Špatné ID hráče.',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Chyba',
            description = 'Musíte zadat ID hráče.',
            type = 'error'
        })
    end
end, false)
