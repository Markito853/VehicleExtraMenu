local AvailableExtras = {['VehicleExtras'] = {}, ['TrailerExtras'] = {}}
local Items = {['Vehicle'] = {}, ['Trailer'] = {}}
local GotTrailerExtras = false; GotVehicleExtras = false
local Pool = MenuPool.New()
local MainMenu = UIMenu.New('Vehicle Extras', '~b~Enable/Disable vehicle extras')
local TrailerMenu, MenuExists, Vehicle, TrailerHandle, GotTrailer
Pool:Add(MainMenu)

-- Actual Menu [

local IsAdmin

RegisterNetEvent('VEM:AdminStatusChecked')
AddEventHandler('VEM:AdminStatusChecked', function(State) --Just Don't Edit!
	IsAdmin = State
end)


Citizen.CreateThread(function() --Controls
	VEM.CheckStuff()

	while true do
		Citizen.Wait(0)

        Pool:ProcessMenus()
		
		local IsInVehicle = IsPedInAnyVehicle(PlayerPedId(), false)

		if ((GetIsControlJustPressed(VEM.KBKey) and GetLastInputMethod(2))) and ((VEM.OnlyForAdmins and IsAdmin) or not VEM.OnlyForAdmins) and MenuExists then
			MainMenu:Visible(not MainMenu:Visible())
		end
		
		if MainMenu:Visible() and not IsInVehicle then
			MainMenu:Visible(false)
		end
		
		local Got, Handle = GetVehicleTrailerVehicle(Vehicle)

		if IsInVehicle and not MenuExists then
			VEM.CreateMenu()
		elseif (not IsInVehicle and MenuExists) or Got ~= GotTrailer or Handle ~= TrailerHandle then
			VEM.DeleteMenu()
		end
	end
end)

-- ] Actual Menu

-- Functions [

function VEM.CreateMenu()
	Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	GotTrailer, TrailerHandle = GetVehicleTrailerVehicle(Vehicle)
	
	for ExtraID = 0, 20 do
		if DoesExtraExist(Vehicle, ExtraID) then
			AvailableExtras.VehicleExtras[ExtraID] = (IsVehicleExtraTurnedOn(Vehicle, ExtraID) == 1)
			
			GotVehicleExtras = true
		end
		
		if GotTrailer and DoesExtraExist(TrailerHandle, ExtraID) then
			AvailableExtras.TrailerExtras[ExtraID] = (IsVehicleExtraTurnedOn(TrailerHandle, ExtraID) == 1)
			
			GotTrailerExtras = true
		end
		
		if not TrailerMenu then
			for Key, Value in pairs(AvailableExtras.TrailerExtras) do
				if Value then
					TrailerMenu = Pool:AddSubMenu(MainMenu, 'Trailer Extras', '~b~Enable/Disable trailer extras')
					break
				end
			end
		end
	end
	
	for Key, Value in pairs(AvailableExtras.VehicleExtras) do
		local ExtraItem = UIMenuCheckboxItem.New('Extra ' .. Key, AvailableExtras.VehicleExtras[Key])
		MainMenu:AddItem(ExtraItem)
		Items.Vehicle[Key] = ExtraItem
	end
	
    MainMenu.OnCheckboxChange = function(Sender, Item, Checked)
		for Key, Value in pairs(Items.Vehicle) do
			if Item == Value then
				AvailableExtras.VehicleExtras[Key] = Checked
				if AvailableExtras.VehicleExtras[Key] then
					SetVehicleExtra(Vehicle, Key, 0)
				else
					SetVehicleExtra(Vehicle, Key, 1)
				end
			end
		end
    end
	
	if GotTrailerExtras then
		for Key, Value in pairs(AvailableExtras.TrailerExtras) do
			local ExtraItem = UIMenuCheckboxItem.New('Extra ' .. Key, AvailableExtras.TrailerExtras[Key])
			TrailerMenu:AddItem(ExtraItem)
			Items.Trailer[Key] = ExtraItem
		end
		
		TrailerMenu.OnCheckboxChange = function(Sender, Item, Checked)
			for Key, Value in pairs(Items.Trailer) do
				if Item == Value then
					AvailableExtras.TrailerExtras[Key] = Checked
					local GotTrailer, TrailerHandle = GetVehicleTrailerVehicle(Vehicle)
					if AvailableExtras.TrailerExtras[Key] then
						SetVehicleExtra(TrailerHandle, Key, 0)
					else
						SetVehicleExtra(TrailerHandle, Key, 1)
					end
				end
			end
		end
	end
	
	if GotVehicleExtras or GotTrailerExtras then
		Pool:RefreshIndex()

		MenuExists = true
	end
end

function VEM.DeleteMenu()
	Vehicle = nil
	AvailableExtras = {['VehicleExtras'] = {}, ['TrailerExtras'] = {}}
	Items = {['Vehicle'] = {}, ['Trailer'] = {}}
	if MainMenu then
		MainMenu:Clear()
	end
	if TrailerMenu then
		TrailerMenu:Clear()
	end
	Pool:Remove()
	MenuExists = false
end

function VEM.CheckStuff()
	IsAdmin = nil
	if VEM.OnlyForAdmins then
		TriggerServerEvent('VEM:CheckAdminStatus')
		while (IsAdmin == nil) do
			Citizen.Wait(0)
		end
	end
end

function GetIsControlPressed(Control)
	if IsControlPressed(1, Control) or IsDisabledControlPressed(1, Control) then
		return true
	end
	return false
end

function GetIsControlJustPressed(Control)
	if IsControlJustPressed(1, Control) or IsDisabledControlJustPressed(1, Control) then
		return true
	end
	return false
end

