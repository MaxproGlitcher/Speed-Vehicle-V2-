local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Env = getgenv()

Env.VehicleSpeedEnabled = true
Env.VehicleSpeed = 99999999999999999999999999999999
Env.VehicleTorque = 1000000000

Env.OriginalSpeeds = Env.OriginalSpeeds or {}
Env.OriginalTorques = Env.OriginalTorques or {}

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

Env.GetVehicleFromDescendant = GetVehicleFromDescendant

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
			if Env.OriginalSpeeds[Object] == nil then
				Env.OriginalSpeeds[Object] = Object.MaxSpeed
				Env.OriginalTorques[Object] = Object.Torque
			end

			local Success, Error = pcall(function()
				if Env.VehicleSpeedEnabled then
					Object.MaxSpeed = Env.VehicleSpeed
					Object.Torque = Env.VehicleTorque
				else
					Object.MaxSpeed = Env.OriginalSpeeds[Object]
					Object.Torque = Env.OriginalTorques[Object]
				end
			end)

			if not Success then
				warn("[Vehicle Speed] " .. tostring(Error))
			end
		end
	end
end

Env.UpdateVehicleSpeed = UpdateVehicleSpeed

if Env.VehicleSpeedConnection then
	Env.VehicleSpeedConnection:Disconnect()
end

Env.VehicleSpeedConnection = RunService.Heartbeat:Connect(function()
	local Success, Error = pcall(UpdateVehicleSpeed)

	if not Success then
		warn("[Vehicle Speed] " .. tostring(Error))
	end
end)
