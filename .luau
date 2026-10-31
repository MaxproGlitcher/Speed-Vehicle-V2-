local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local velocityEnabled = true
local vehicleSpeed = 99999999999999999999999999999999
local vehicleTorque = 1000000000

local OriginalSpeeds = {}
local OriginalTorques = {}

local function GetVehicleFromDescendant(Descendant)
	if not Descendant then
		return nil
	end

	local Success, Vehicle = pcall(function()
		return Descendant:FindFirstAncestor(LocalPlayer.Name .. "'s Car")
			or (Descendant:FindFirstAncestor("Body") and Descendant:FindFirstAncestor("Body").Parent)
			or (Descendant:FindFirstAncestor("Misc") and Descendant:FindFirstAncestor("Misc").Parent)
			or Descendant:FindFirstAncestorWhichIsA("Model")
	end)

	return Success and Vehicle or nil
end

local function TeleportVehicle(CoordinateFrame)
	local Success, Result = pcall(function()
		local Character = LocalPlayer.Character
		local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
		local SeatPart = Humanoid and Humanoid.SeatPart
		local Vehicle = GetVehicleFromDescendant(SeatPart)

		if not Vehicle or not Vehicle:IsA("Model") then
			return false
		end

		Character.Parent = Vehicle

		local TeleportSuccess = pcall(function()
			Vehicle:SetPrimaryPartCFrame(CoordinateFrame)
		end)

		if not TeleportSuccess then
			Vehicle:MoveTo(CoordinateFrame.Position)
		end

		return true
	end)

	return Success and Result == true
end

local function UpdateVehicleSpeed()
	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
	local SeatPart = Humanoid and Humanoid.SeatPart

	if not SeatPart or not SeatPart:IsA("VehicleSeat") then
		return
	end

	local Vehicle = GetVehicleFromDescendant(SeatPart)

	if not Vehicle then
		return
	end

	for _, Object in ipairs(Vehicle:GetDescendants()) do
		if Object:IsA("VehicleSeat") then
			if OriginalSpeeds[Object] == nil then
				OriginalSpeeds[Object] = Object.MaxSpeed
				OriginalTorques[Object] = Object.Torque
			end

			local Success, Error = pcall(function()
				if velocityEnabled then
					Object.MaxSpeed = vehicleSpeed
					Object.Torque = vehicleTorque
				else
					Object.MaxSpeed = OriginalSpeeds[Object]
					Object.Torque = OriginalTorques[Object]
				end
			end)

			if not Success then
				warn("[Vehicle Speed] " .. tostring(Error))
			end
		end
	end
end

local SpeedConnection = RunService.Heartbeat:Connect(function()
	local Success, Error = pcall(UpdateVehicleSpeed)

	if not Success then
		warn("[Vehicle Speed] " .. tostring(Error))
	end
end)
