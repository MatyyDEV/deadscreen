local respawnTime = 30 -- Čas do automatického respawnu v sekundách
local isDead = false
local timeLeft = respawnTime
local respawnOptionVisible = false

-- Funkce pro vykreslení deadscreenu
function DrawDeadScreen()
    -- Nastavení textového stylu pro odpočet
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(0.6, 0.6) -- menší velikost textu
    SetTextColour(255, 0, 0, 255) -- červená barva
    SetTextCentre(true)

            -- Zobrazí šedou obrazovku a odpočet
            SetTextFont(4)
            SetTextProportional(0)
            SetTextScale(0.5, 0.5) -- Zmenšený text
            SetTextColour(200, 0, 0, 200) -- Jemnější červená
            SetTextCentre(true)
            SetTextDropShadow(0, 0, 0, 0, 200)
            SetTextOutline()
            BeginTextCommandDisplayText('STRING')
            AddTextComponentString(string.format('Respawn in: ~r~%d ~w~seconds', timeLeft))
            EndTextCommandDisplayText(0.5, 0.5)

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

-- Funkce pro zastavení obrazovky smrti
function StopDeathScreen()
    isDead = false
    respawnOptionVisible = false
    timeLeft = respawnTime
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

-- Přidání příkazu /revive [id hráče]
RegisterCommand("revive", function(source, args, rawCommand)
    if #args < 1 then
        TriggerEvent("chat:addMessage", {
            args = { "Usage: /revive [player id]" }
        })
        return
    end

    local targetId = tonumber(args[1])
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))

    if targetPed and IsEntityDead(targetPed) then
        NetworkResurrectLocalPlayer(GetEntityCoords(targetPed), true, false)
        SetEntityHealth(targetPed, 200) -- Nastaví zdraví cílového hráče
        StopDeathScreen() -- Skryje obrazovku smrti a odpočet
        TriggerEvent("chat:addMessage", {
            args = { "You have revived player ID: " .. targetId }
        })
    else
        TriggerEvent("chat:addMessage", {
            args = { "Player ID not found or not dead." }
        })
    end
end, false)