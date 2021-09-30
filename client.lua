local PlayerData = {}
local pedspawned = false
local currentGarage = 1

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded",function()
	PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate")
AddEventHandler("QBCore:Client:OnJobUpdate",function(job)
	PlayerData.job = job
end)

RegisterNetEvent("QBCore:Player:SetPlayerData")
AddEventHandler("QBCore:Player:SetPlayerData",function(val)
	PlayerData = val
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		for k, v in pairs(Config.PedLocations) do
			local ped = PlayerPedId()
			local pos = GetEntityCoords(ped)
			local dist = #(v.coords - pos)

			if dist < 35 and not pedspawned then
				TriggerEvent("pgarages:spawn:ped", v.coords)
				pedspawned = true
			elseif dist >= 35 and pedspawned then
				DeletePed(npc)
				pedspawned = false
			end
		end
	end
end)

RegisterNetEvent("pgarages:spawn:ped")
AddEventHandler("pgarages:spawn:ped",function(coords)
	local hash = `ig_trafficwarden`
	
	RequestModel(hash)
	while not HasModelLoaded(hash) do
		Wait(10)
	end

	pedspawned = true
	npc = CreatePed(5, hash, coords.x, coords.y, coords.z - 1.0, coords.w, false, false)
	FreezeEntityPosition(npc, true)
	SetBlockingOfNonTemporaryEvents(npc, true)
	loadAnimDict("amb@world_human_cop_idles@male@idle_b")
	TaskPlayAnim(npc, "amb@world_human_cop_idles@male@idle_b", "idle_e", 8.0, 1.0, -1, 17, 0, 0, 0, 0)
end)

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

RegisterNetEvent("pgarages:client:garage")
AddEventHandler("pgarages:client:garage",function(pd)
	local ped = PlayerPedId()
	local vehicle = pd.vehicle
	local coords = Config.ParkSpots["vehicle"][currentGarage]
	
	QBCore.Functions.SpawnVehicle(vehicle,function(veh)
		SetVehicleNumberPlateText(veh, "ZULU" .. GetRandomIntInRange(1000, 9999))
		exports["LegacyFuel"]:SetFuel(veh, 100.0)
		SetEntityHeading(veh, coords.w)
		TaskWarpPedIntoVehicle(ped, veh, -1)
		TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
		SetVehicleEngineOn(veh, true, true)
	end,
	coords,true)
end)

RegisterNetEvent("pgarages:client:storecar")
AddEventHandler("pgarages:client:storecar",function()
	local ped = PlayerPedId()
	
	QBCore.Functions.Notify("Vehicle Stored!")
	local car = GetVehiclePedIsIn(ped, true)
	NetworkFadeOutEntity(car, true, false)
	Citizen.Wait(2000)
	QBCore.Functions.DeleteVehicle(car)
end)

RegisterNetEvent("garage:menu",function()
	TriggerEvent("nh-context:sendMenu",{
		{
			id = 1,
			header = "Police Garage",
			txt = ""
		},
		{
			id = 2,
			header = "Charger",
			txt = "Police Charger",
			params = {
				event = "pgarages:client:garage",
				args = {
					vehicle = "polchar"
				}
			}
		},
		{
			id = 3,
			header = "Crown Vic",
			txt = "Police Crown Vic",
			params = {
				event = "pgarages:client:garage",
				args = {
					vehicle = "polvic"
				}
			}
		},
		{
			id = 4,
			header = "Raptor",
			txt = "Police Raptor",
			params = {
				event = "pgarages:client:garage",
				args = {
					vehicle = "polraptor"
				}
			}
		},
		{
			id = 5,
			header = "Taurus",
			txt = "Police Taurus",
			params = {
				event = "pgarages:client:garage",
				args = {
					vehicle = "poltaurus"
				}
			}
		},
		{
			id = 6,
			header = "Mustang",
			txt = "Police Mustang",
			params = {
				event = "pgarages:client:garage",
				args = {
					vehicle = "2015polstang"
				}
			}
		},
		{
			id = 9,
			header = "Store Vehicle",
			txt = "Store Vehicle Inside Garage",
			params = {
				event = "pgarages:client:storecar",
				args = {}
			}
		}
	})
end)
